<div align="center">

# 🧬 Reproducible Bulk RNA-Seq Analysis Pipeline

### From Raw Sequencing Reads to Biological Insight


</div>

---

## Project Overview

Bioinformatics analysis involves more than running a series of tools. Raw
sequencing data need to be checked, processed, analyzed, interpreted, and
presented in a way that can be reproduced and reviewed.

This repository brings those pieces together using **bulk RNA-seq as an
end-to-end case study**.

The workflow starts with raw paired-end FASTQ files and continues through
sequencing quality control, read alignment, library strandedness assessment,
gene quantification, count-matrix QC, expression-level QC, differential
expression, functional enrichment, and biological interpretation.

The individual analysis stages were first developed and validated using
**Python, R/Bioconductor, and command-line bioinformatics tools**. They were
then connected with **Nextflow** to automate process dependencies and data flow.
**Docker** provides controlled software environments, while **Linux and
SLURM** demonstrate how the same workflow principles can be applied in an HPC
setting. Final results are organized into a **Quarto HTML report** for
interactive review and sharing.

Together, the project demonstrates both the biological analysis and the
computational infrastructure needed to make an RNA-seq workflow reproducible.


---

## Workflow Overview

<p align="center">
  <img src="assets/rnaseq-workflow-overview-v3.png"
       alt="End-to-end reproducible RNA-seq workflow"
       width="100%">
</p>

---
## Computing Environment

The workflow can be run on a local Linux workstation or, when available, on
an institutional High Performance Computing (HPC) system. An HPC cluster is typically accessed remotely
from a macOS, Windows, or Linux workstation using SSH. Analysis files and jobs
are prepared on the login node, while computational work is submitted to
compute nodes through a scheduler such as SLURM.

For this project, an Ubuntu-based HPC environment was also configured to
demonstrate shared storage, environment modules, SSH access, and SLURM job
submission. Docker provides reproducible software environments, while Nextflow
coordinates the analysis steps and reuses the resulting BAM files for the
automated downstream workflow.


---
# RNA-Seq Case Study

## From RNA to Sequencing Reads

RNA-seq is used to measure **gene expression**—which genes are active in a
biological sample and how strongly they are expressed.

Comparing RNA-seq profiles between biological groups can identify genes with
increased or decreased expression and reveal biological processes and pathways
associated with those differences.

RNA-seq begins with RNA extracted from biological samples. The RNA is converted
to cDNA, prepared as a sequencing library, and sequenced to generate millions
of reads stored in **FASTQ files**.

Sequencing can be:

- **Single-end** — one end of each fragment is sequenced, producing one FASTQ
  file per sample.
- **Paired-end** — both ends are sequenced, producing corresponding `R1` and
  `R2` FASTQ files.

Paired-end sequencing provides information from both ends of a fragment, which
can improve alignment and genomic placement.

This project uses **paired-end RNA-seq data**.

---

## Dataset

The workflow was developed using publicly available RNA-seq data from a study
of **uveal melanoma**.

| | |
|---|---|
| GEO SuperSeries | **GSE199679** |
| RNA-seq SubSeries | **GSE198801** |
| Comparison | **MP46 uveal melanoma vs. normal melanocytes (NM)** |
| Samples | 3 NM + 3 MP46 |
| Reference genome | GRCh38 primary assembly |
| Gene annotation | GENCODE v48 |

Samples:

```text
NM:    NM_4, NM_5, NM_6
MP46:  MP46_1, MP46_2, MP46_3
```

---

# Analysis

## 1. Sequencing Quality Control

Raw sequencing reads were evaluated with **FastQC** for base quality, GC
content, duplication, adapter contamination, and other potential sequencing
problems.

**MultiQC** combined the individual FastQC outputs into a single report,
allowing sequencing quality to be reviewed across all samples before
downstream analysis.

---

## 2. Read Alignment

FASTQ reads contain nucleotide sequences but do not indicate where those
sequences originated in the genome.

**STAR**, a splice-aware RNA-seq aligner, was used to map the paired-end reads
to the GRCh38 human reference genome.

| Sample | Uniquely Mapped Reads |
|---|---:|
| NM_4 | 95.20% |
| NM_5 | 95.16% |
| NM_6 | 95.11% |
| MP46_1 | 88.29% |
| MP46_2 | 94.31% |
| MP46_3 | 89.23% |

Unique mapping rates ranged from **88.3% to 95.2%**.

The resulting coordinate-sorted BAM files provide the genomic alignments used
for gene quantification.

---

## 3. BAM Processing and Library Strandedness

**SAMtools** was used to index the BAM files for efficient downstream access.

Library orientation was then assessed with **RSeQC `infer_experiment.py`**.
Determining strandedness is important because RNA-seq libraries can preserve
the orientation of the original transcript, and an incorrect setting can lead
to incorrect gene counts.

The data were identified as **reverse-stranded paired-end RNA-seq**, so
featureCounts was configured with:

```text
-s 2
```

---

## 4. Gene Quantification and Count QC

**featureCounts** assigned aligned fragments to genes using the GENCODE v48
annotation, producing a gene-by-sample raw count matrix.

Python scripts then cleaned and validated the matrix by:

- removing unnecessary featureCounts columns
- simplifying sample names
- maintaining consistent sample order
- checking duplicate gene IDs, missing values, and negative counts

The initial matrix contained:

```text
78,894 genes × 6 samples
```

Genes with limited read support were removed using:

```text
≥10 counts in at least 3 samples
```

| | Genes |
|---|---:|
| Before filtering | 78,894 |
| Retained | **12,728** |
| Removed | 66,166 |

The remaining **12,728 genes** were used for downstream analysis.

---

## 5. Expression-Level Quality Control

Before testing individual genes, overall relationships among the samples were
examined.

The filtered counts were transformed using the **DESeq2
variance-stabilizing transformation (VST)** for exploratory visualization.

### PCA

Principal component analysis summarized the major expression differences among
samples.

```text
PC1 = 88.79%
PC2 =  3.73%
```

PC1 clearly separated NM and MP46 samples.

### Sample Correlation

Pearson correlation measured similarity between whole-sample expression
profiles.

```text
Within NM:       ≈ 0.96
Within MP46:     ≈ 0.96–0.98
Between groups:  ≈ 0.56–0.64
```

Together, PCA and correlation showed strong similarity among biological
replicates and clear differences between NM and MP46.

📊 **[View Expression QC](https://ArchanaAllishe.github.io/reproducible-rnaseq-pipeline/#expression-level-qc)**

---

## 6. Differential Expression

**DESeq2** was used to identify genes whose expression differed between MP46
and NM.

```text
Design:     ~ Group
Contrast:   MP46 vs NM
Reference:  NM
```

Significant differential expression was defined as:

```text
adjusted p-value < 0.05
AND
|log2FoldChange| ≥ 1
```

| Result | Genes |
|---|---:|
| Genes tested | 12,728 |
| padj < 0.05 | 8,501 |
| Significant with \|log2FC\| ≥ 1 | **6,816** |
| Higher in MP46 | **3,495** |
| Higher in NM | **3,321** |

The results were examined using a **volcano plot, MA plot, and top-30
differential-expression heatmap**.

GENCODE v48 annotations were also added to provide gene symbols and gene types
alongside the DESeq2 results.

📈 **[View Differential Expression](https://ArchanaAllishe.github.io/reproducible-rnaseq-pipeline/#differential-expression)**

---

## 7. Functional Enrichment

Differentially expressed genes were separated according to expression
direction and analyzed for functional enrichment.

Two complementary resources were used:

- **Gene Ontology Biological Process (GO BP)**
- **Reactome pathways**

All genes tested by DESeq2 were used as the enrichment background.

| Gene Set | GO BP | Reactome |
|---|---:|---:|
| Higher in MP46 | **31** | **0** |
| Higher in NM | **236** | **46** |

Genes higher in **MP46** were enriched for processes associated with cell
division, microtubule organization, centrosomes, and organelle fission.

Genes higher in **NM** showed broader enrichment involving extracellular matrix
organization, cell adhesion, antigen processing, and immune-related signaling.

No Reactome pathway passed the predefined significance threshold for genes
higher in MP46; the original threshold was retained.

🧬 **[View Functional Enrichment](https://ArchanaAllishe.github.io/reproducible-rnaseq-pipeline/#functional-enrichment)**

---

## Biological Summary

The analysis identified substantial transcriptomic differences between the two
groups.

```text
12,728 genes tested
        ↓
6,816 significant DE genes
        ↓
3,495 higher in MP46
3,321 higher in NM
        ↓
Distinct biological processes and pathways
```

PCA and sample correlation supported strong agreement among biological
replicates and clear separation between NM and MP46.

The enrichment results further showed that genes higher in MP46 and NM were
associated with different biological programs.

These results describe expression patterns associated with the two groups and
do not by themselves establish causal biological mechanisms.

---

# Reproducible Workflow Implementation

The biological analysis above was combined with workflow automation,
containerization, research-computing infrastructure, and reporting to make the
analysis easier to reproduce and share.

```text
Analysis scripts
      ↓
   Nextflow
      ↓
Docker environments
      ↓
Local / HPC execution
      ↓
Organized results
      ↓
Quarto report
```

## Nextflow Automation

The analysis stages were initially developed and validated independently before
being connected with **Nextflow DSL2**.

Nextflow was used because RNA-seq contains many dependent processes and
intermediate files. Manually managing these steps becomes increasingly
difficult as a workflow grows.

Nextflow provides:

- automatic process dependencies and data flow
- execution tracking
- process caching
- resumable runs with `-resume`
- integration with containers
- portability between local and HPC computing environments

The workflow therefore converts the individual validated scripts into a
connected and reproducible analysis pipeline.

The current Nextflow implementation **reuses the resulting STAR BAM files** for
downstream processing.

Workflow files:

```text
workflow/
├── main.nf
└── nextflow.config
```

Run the workflow:

```bash
nextflow run workflow/main.nf \
  -c workflow/nextflow.config
```

Resume a previous execution:

```bash
nextflow run workflow/main.nf \
  -c workflow/nextflow.config \
  -resume
```

---

## Docker and Computing Environment

Reproducibility also depends on the software environment in which the workflow
runs.

Bioinformatics tools often have different dependencies and version
requirements. **Docker** provides isolated software environments for tools used
by the workflow, reducing dependence on software installed directly on the
host computer.

The project also includes a simulated **Linux HPC environment with SLURM** to
demonstrate research-computing practices used when analyses require more CPU,
memory, or parallel execution than a local workstation can provide.

The HPC environment includes:

- SSH key-based access
- shared project storage and Linux permissions
- Environment Modules
- SLURM workload management
- CPU and memory resource requests
- `sbatch` job submission
- `squeue` job monitoring

A SLURM test job was successfully submitted and executed.

Together, these components address different parts of reproducible computing:

| Component | Role |
|---|---|
| **Git/GitHub** | Version-controlled analysis code |
| **Docker** | Consistent software environments |
| **Nextflow** | Automated workflow execution |
| **Linux/SLURM** | Scalable research computing |
| **Quarto** | Reproducible and shareable reporting |

---

## Results and Reporting

Workflow execution generates many intermediate files that are useful for
computation but not necessarily for interpretation.

Nextflow keeps temporary and cached process files under:

```text
work/
```

while selected analysis outputs are organized under:

```text
results/nextflow/
```

The final results are presented through a **Quarto HTML report** containing the
major QC results, figures, statistical analyses, enrichment results, and
biological interpretation.

This allows collaborators or reviewers to examine the analysis without
navigating workflow directories or individual scripts.

### 🔬 ***[View the Interactive RNA-Seq Report](https://ArchanaAllishe.github.io/reproducible-rnaseq-pipeline/)***

---

# Technologies

| Area | Technology |
|---|---|
| Workflow orchestration | Nextflow DSL2 |
| Containerization | Docker / BioContainers |
| Programming | Python, R, Bash |
| Sequencing QC | FastQC, MultiQC |
| Alignment | STAR |
| BAM processing | SAMtools |
| RNA-seq QC | RSeQC |
| Gene quantification | featureCounts |
| Differential expression | DESeq2 |
| Functional enrichment | clusterProfiler, ReactomePA |
| Annotation | GENCODE |
| Reporting | Quarto |
| Research computing | Linux, SLURM |
| Version control | Git, GitHub |

---

# Repository Structure

```text
reproducible-rnaseq-pipeline/
│
├── assets/                     # workflow diagrams
├── docs/                       # detailed methods and documentation
│
├── scripts/
│   ├── downstream/
│   ├── differential-expression/
│   └── functional-enrichment/
│
├── workflow/
│   ├── main.nf
│   └── nextflow.config
│
├── report/                     # Quarto analysis report
├── results/                    # selected analysis outputs
├── .gitignore
├── LICENSE
└── README.md
```

The README provides the high-level analysis story. Detailed methods, commands,
implementation notes, and analysis decisions are maintained in `docs/`.


---

# References

1. Gentien D, et al. *Cell Reports*. 2023. **GSE199679 / GSE198801**
2. Dobin A, et al. STAR. *Bioinformatics*. 2013.
3. Liao Y, et al. featureCounts. *Bioinformatics*. 2014.
4. Wang L, et al. RSeQC. *Bioinformatics*. 2012.
5. Ewels P, et al. MultiQC. *Bioinformatics*. 2016.
6. Love MI, et al. DESeq2. *Genome Biology*. 2014.
7. Yu G, et al. clusterProfiler. *OMICS*. 2012.
8. Milacic M, et al. Reactome. *Nucleic Acids Research*. 2024.
9. Frankish A, et al. GENCODE. *Nucleic Acids Research*. 2021.

---

<div align="center">

### 🧬 Raw Sequencing Data → Reproducible Analysis → Biological Insight → Shareable Results

**[View Interactive Results](https://ArchanaAllishe.github.io/reproducible-rnaseq-pipeline/)**

</div>
