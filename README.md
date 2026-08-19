<div align="center">

# 🧬 From Sequencing Data to Biological Insight

### An End-to-End RNA-Seq Case Study in Reproducible Bioinformatics

</div>

---

Bioinformatics analysis involves more than running a series of tools. Raw
sequencing data need to be checked, processed, analyzed, interpreted, and
presented in a way that can be reproduced and reviewed.

This repository brings those pieces together using **bulk RNA-seq as an
end-to-end case study**.

The workflow starts with raw paired-end FASTQ files and continues through
sequencing quality control, read alignment, gene quantification, count-matrix
QC, expression-level QC, differential expression, functional enrichment, and
biological interpretation.

The final results are presented through an interactive Quarto report so that
the analysis can be reviewed without navigating scripts and intermediate
files.

The project also brings together the programming and computing tools commonly
used in bioinformatics: **Python, R, Bash, Linux, Docker, Git, HPC/SLURM, and
scientific reporting**.

---

## RNA-Seq Workflow

<p align="center">
  <img src="assets/rnaseq-workflow-overview.png"
       alt="End-to-end reproducible RNA-seq workflow"
       width="100%">
</p>

The workflow follows the data from raw sequencing reads to a final
collaborator-facing report, with quality-control checks and documented
analysis decisions along the way.

---

# RNA-Seq Case Study

## Study Background

## Study Background

The analysis uses publicly available RNA-seq data from a multi-omics study of
uveal melanoma by **Gentien et al. (2023)**. The study compared aggressive
uveal melanoma patient-derived xenograft models with normal choroidal
melanocytes to investigate molecular features associated with uveal melanoma.

The complete dataset is available as GEO SuperSeries **GSE199679**, with the
RNA-seq data available under SubSeries **GSE198801**.

Two groups were selected for this analysis:

- **NM (Normal Melanocytes)** — normal uveal/choroidal melanocytes used as the
  non-malignant reference.
- **MP46** — a patient-derived xenograft (PDX) model of uveal melanoma.

Six paired-end RNA-seq samples were analyzed:

| Group | Biological Context | Samples |
|---|---|---|
| **NM** | Normal uveal melanocytes | NM_4, NM_5, NM_6 |
| **MP46** | Uveal melanoma PDX model | MP46_1, MP46_2, MP46_3 |

The main comparison is:

> **MP46 uveal melanoma vs. normal melanocytes (NM)**

---

## Reference Genome and Gene Annotation

RNA-seq reads were aligned and quantified using the following human reference
resources:

| Resource | Used in the Analysis |
|---|---|
| **Reference genome** | GRCh38 primary assembly |
| **Gene annotation** | GENCODE v48 |

The reference genome provides the DNA sequence used for read alignment, while
the GTF annotation defines the genomic locations of genes and exons used for
gene-level quantification.

The same annotation release was maintained across genome indexing,
quantification, and downstream gene annotation to avoid inconsistencies
between analysis stages.

---

# Analysis and Results

## 1. Raw Read Quality Control

Raw paired-end FASTQ files were checked with **FastQC**, and the individual
reports were combined with **MultiQC**.

The review included:

- per-base sequence quality
- GC content
- adapter content
- sequence duplication
- overall read-quality patterns

This provides an early checkpoint before alignment and downstream analysis.

---

## 2. Read Alignment

Reads were aligned to the GRCh38 reference genome using **STAR**.

STAR alignment statistics were reviewed for each sample, and **SAMtools** was
used for alignment-file processing.

| Sample | Uniquely Mapped Reads |
|---|---:|
| NM_4 | 95.20% |
| NM_5 | 95.16% |
| NM_6 | 95.11% |
| MP46_1 | 88.29% |
| MP46_2 | 94.31% |
| MP46_3 | 89.23% |

Unique mapping rates ranged from approximately **88.3% to 95.2%** across the
six samples.

---

## 3. Library Strandedness

Library orientation was checked with **RSeQC `infer_experiment.py`** rather
than assumed from the sample metadata.

The results supported a **reverse-stranded paired-end library**.

featureCounts was therefore run with:

```text
-s 2
```

Checking strandedness before gene quantification helps avoid incorrect
assignment of reads to genes.

---

## 4. Gene Quantification and Count-Matrix QC

Gene-level counts were generated using **featureCounts**.

The initial count matrix contained:

```text
78,894 genes
```

Before downstream analysis, the matrix was checked for:

- duplicate gene IDs
- missing values
- negative counts
- library sizes
- detected genes
- low-expression genes

Low-expression genes were filtered using the following rule:

```text
Keep genes with ≥10 raw counts in at least 3 samples
```

### Count-Matrix Summary

| Metric | Result |
|---|---:|
| Genes before filtering | 78,894 |
| Genes retained | **12,728** |
| Genes removed | 66,166 |
| Duplicate gene IDs | **0** |
| Missing values | **0** |
| Negative counts | **0** |

The remaining **12,728 genes** were carried forward for expression analysis.

---

## 5. Expression-Level Quality Control

Sample relationships were examined before differential-expression testing
using **principal component analysis (PCA)** and **sample correlation**.

### Principal Component Analysis

PCA was performed in Python using `scikit-learn`.

```text
PC1 = 88.79%
PC2 =  3.73%

PC1 + PC2 = 92.52%
```

The first principal component clearly separated the NM and MP46 samples,
indicating that the largest source of expression variation corresponded to the
two sample groups.

### Sample Correlation

Within-group correlations were high:

```text
NM    ≈ 0.96
MP46  ≈ 0.96–0.98
```

Between-group correlations were lower:

```text
≈ 0.56–0.64
```

PCA and sample correlation showed the same overall pattern: replicates were
consistent within each group, while NM and MP46 had clearly different
expression profiles.

📊 **[View the Expression QC Results](https://ArchanaAllishe.github.io/reproducible-rnaseq-pipeline/#expression-level-qc)**

---

## 6. Differential Expression

Differential-expression analysis was performed with **DESeq2**.

```text
Design   : ~ Group
Contrast : MP46 vs NM
```

Fold-change direction was defined as:

```text
log2FoldChange > 0  → higher in MP46
log2FoldChange < 0  → higher in NM
```

The primary significance criterion was:

```text
adjusted p-value < 0.05
and
|log2FoldChange| ≥ 1
```

### Differential-Expression Summary

| Criterion | Genes |
|---|---:|
| Genes tested | 12,728 |
| padj < 0.05 | 8,501 |
| **padj < 0.05 and \|log2FC\| ≥ 1** | **6,816** |
| Higher in MP46 | **3,495** |
| Higher in NM | **3,321** |
| padj < 0.01 and \|log2FC\| ≥ 1 | 6,425 |
| padj < 0.05 and \|log2FC\| ≥ 2 | 3,200 |

The results were examined using:

- volcano plot
- MA plot
- top-30 differentially expressed gene heatmap
- annotated DESeq2 result tables

📈 **[View the Differential-Expression Results](https://ArchanaAllishe.github.io/reproducible-rnaseq-pipeline/#differential-expression)**

---

## 7. Functional Enrichment

Significant genes were separated according to the direction of expression:

```text
Higher in MP46 → 3,495 genes
Higher in NM   → 3,321 genes
```

The two gene sets were analyzed independently using:

- **Gene Ontology Biological Process**
- **Reactome**

Genes tested in the DESeq2 analysis were used as the enrichment background.

### Enrichment Summary

| Gene Set | GO Biological Process | Reactome |
|---|---:|---:|
| Higher in MP46 | **31** | **0** |
| Higher in NM | **236** | **46** |

### Higher in MP46

The main enriched themes were related to:

- cell and nuclear division
- microtubule organization
- centrosome-associated processes
- organelle fission

### Higher in NM

The main themes included:

- extracellular matrix organization
- cell adhesion
- antigen processing and presentation
- interferon-associated signaling
- extracellular matrix remodeling

No Reactome pathway passed the predefined significance threshold for genes
higher in MP46.

The threshold was left unchanged rather than relaxed after reviewing the
results.

🧬 **[View the Functional-Enrichment Results](https://ArchanaAllishe.github.io/reproducible-rnaseq-pipeline/#functional-enrichment)**

---

# Analysis Findings

The different analysis stages produced a consistent picture.

PCA showed strong separation between MP46 and normal melanocytes, while the
correlation analysis showed good agreement among replicates within each group.

DESeq2 identified **6,816 differentially expressed genes** using the predefined
adjusted p-value and fold-change thresholds.

Genes higher in **MP46** were mainly associated with cell division,
microtubule organization, and related processes.

Genes higher in **NM** showed broader enrichment for extracellular matrix,
cell adhesion, immune-associated signaling, and antigen-processing processes.

These findings describe expression patterns associated with the two groups.
Additional experimental evidence would be required to establish specific
biological mechanisms.

---

# Key Analysis Decisions

Several decisions in the workflow can substantially affect the final results.
These were checked explicitly rather than left to assumptions or software
defaults.

<details>
<summary><b>Why use the same genome annotation throughout the analysis?</b></summary>

GRCh38 and GENCODE v48 were used consistently across genome indexing,
gene-level quantification, and downstream annotation.

This reduces the risk of gene-coordinate and identifier inconsistencies
between stages.

</details>

<details>
<summary><b>Why check strandedness?</b></summary>

An incorrect strandedness setting can change gene-level counts.

Library orientation was therefore checked with RSeQC before configuring
featureCounts.

</details>

<details>
<summary><b>Why filter low-expression genes?</b></summary>

Genes with very few reads provide limited information for differential
expression and increase the number of statistical tests.

The predefined filtering rule was:

```text
≥10 counts in at least 3 samples
```

</details>

<details>
<summary><b>Why run PCA and sample correlation before DESeq2?</b></summary>

These analyses provide a sample-level check of replicate consistency, group
structure, and potential outliers before differential-expression results are
interpreted.

</details>

<details>
<summary><b>Why separate enrichment by expression direction?</b></summary>

Genes higher in MP46 and genes higher in NM represent opposite expression
patterns.

Analyzing them separately makes it possible to identify biological processes
associated with each direction.

</details>

<details>
<summary><b>Why use DESeq2-tested genes as the enrichment background?</b></summary>

Only genes included in the statistical analysis had the opportunity to appear
in the significant gene lists.

Using the tested genes as the background therefore better reflects the set of
genes that could have been selected.

</details>

<details>
<summary><b>Why report zero significant Reactome pathways for MP46?</b></summary>

No Reactome pathway passed the predefined significance threshold for this gene
set.

The result was retained rather than changing the cutoff after seeing the
output.

</details>

---

# Programming and Bioinformatics Tools

Different languages and tools were used where they fit naturally in the
workflow rather than forcing the entire analysis into a single programming
language.

## Python

Python was used for count-table processing, QC, exploratory analysis,
annotation, and visualization.

| Library | Application |
|---|---|
| `pandas` | Reading, cleaning, filtering, and processing tabular data |
| `scikit-learn` | Principal component analysis |
| `matplotlib` | Scientific visualization |
| `pathlib` | File and directory handling |
| `re` | Parsing annotation information |

Analysis steps were saved as reusable scripts under `scripts/` so that they
can be rerun without manually repeating the analysis.

---

## R / Bioconductor

R and Bioconductor were used for statistical genomics and functional
enrichment.

| Package | Application |
|---|---|
| `DESeq2` | Differential-expression analysis |
| `clusterProfiler` | Gene Ontology enrichment |
| `ReactomePA` | Reactome pathway enrichment |

These packages provide established methods designed specifically for genomic
data analysis.

---

## Bash and Linux

Bash and Linux connect the individual stages of the workflow.

They were used for:

- FASTQ and alignment-file management
- running FastQC and MultiQC
- STAR alignment
- SAMtools processing
- RSeQC strandedness assessment
- featureCounts gene quantification
- processing multiple samples
- Docker execution
- Git operations
- filesystem and permission management
- workflow troubleshooting

The command line provides the main environment in which the individual
bioinformatics tools are connected.

---

# HPC / SLURM Practice

A simulated HPC environment was configured to practice the way
bioinformatics jobs are commonly organized on shared research-computing
systems.

The environment included:

- SSH key-based access
- Linux users and groups
- shared project storage
- filesystem permissions
- Environment Modules
- bioinformatics software modules
- SLURM job scripts
- CPU, memory, and runtime requests
- job submission with `sbatch`
- job monitoring with `squeue`
- job-output review

STAR, SAMtools, FastQC, and MultiQC were made available through environment
modules.

This part of the project focuses on the computing infrastructure surrounding
bioinformatics analysis.

The current RNA-seq case study was **not run end-to-end through the simulated
cluster**. Full workflow execution through SLURM is planned as part of the
Nextflow implementation.

---

# Reproducibility

Reproducibility was considered throughout the project rather than added only
after the analysis was complete.

Code, software environments, large data files, documentation, and final
results are kept separate:

| Component | Location / Approach |
|---|---|
| Analysis code | `scripts/` + Git/GitHub |
| Software environment | `containers/` |
| Detailed methods | `docs/` |
| Selected results | `results/` |
| Scientific report | `report/` |
| Large sequencing/reference files | Stored outside Git |

This keeps the repository focused on the material needed to understand and
rerun the analysis without using GitHub as storage for large sequencing files.

---

## Reproducible Software Environment with Docker

Bioinformatics software often depends on specific operating-system libraries,
software versions, and other dependencies. These differences can make the
same analysis difficult to reproduce on another computer.

Docker was used to provide a consistent **Linux-based software environment**
for command-line bioinformatics tools.

In this project, Docker helps to:

- keep bioinformatics dependencies separate from the host operating system
- reduce software-version and dependency conflicts
- provide a consistent Linux environment
- support bioinformatics tools on an Apple Silicon system
- make the software setup easier to reproduce

Docker configuration files are maintained under:

```text
containers/
```

This keeps the software environment separate from the analysis code and makes
the computational setup easier to understand and reproduce.

---

# Repository Structure

```text
reproducible-rnaseq-pipeline/
│
├── assets/
│   └── rnaseq-workflow-overview.png
│
├── containers/
│   └── star/
│
├── scripts/
│   ├── downstream/
│   ├── differential-expression/
│   └── functional-enrichment/
│
├── docs/
│
├── results/
│   ├── qc/
│   ├── expression-qc/
│   ├── differential-expression/
│   └── functional-enrichment/
│
├── report/
│   ├── _quarto.yml
│   ├── index.qmd
│   ├── styles.css
│   └── images/
│
├── .gitignore
├── LICENSE
└── README.md
```

Large files are intentionally excluded from version control, including:

```text
FASTQ files
BAM files
reference genomes
STAR genome indexes
large intermediate files
```

---

# Documentation

Detailed methods are kept in `docs/` so that the README can stay focused on
the overall workflow and main results.

| Location | Purpose |
|---|---|
| `README.md` | Project overview, workflow, tools, and key results |
| `docs/` | Detailed methods and analysis decisions |
| `scripts/` | Reusable analysis code |
| `containers/` | Docker setup |
| `results/` | Selected figures and results |
| `report/` | Quarto report source |

The Quarto report provides a separate, results-focused view for collaborators
or readers who are interested in the scientific findings rather than the
implementation details.

---

# Project Status

## Completed

### RNA-Seq Analysis

- [x] Raw paired-end FASTQ QC
- [x] FastQC and MultiQC
- [x] STAR alignment
- [x] strandedness assessment
- [x] featureCounts gene quantification
- [x] count-matrix QC
- [x] low-expression filtering
- [x] expression normalization
- [x] PCA
- [x] sample-correlation heatmap
- [x] DESeq2 differential expression
- [x] gene annotation
- [x] volcano plot
- [x] MA plot
- [x] top-DE-gene heatmap
- [x] GO Biological Process enrichment
- [x] Reactome enrichment

### Computing and Reproducibility

- [x] Python analysis scripts
- [x] R/Bioconductor analysis
- [x] Bash/Linux workflow execution
- [x] Docker-based software environment
- [x] Git/GitHub version control
- [x] simulated HPC environment
- [x] SSH-based HPC access
- [x] shared project storage
- [x] Environment Modules
- [x] SLURM job submission and monitoring

### Reporting

- [x] technical documentation
- [x] Quarto HTML report
- [x] GitHub Pages deployment

---

# Next Steps

The individual RNA-seq analysis stages are working and documented. The next
step is to connect them into an automated workflow using **Nextflow**.

Planned work includes:

- [ ] Nextflow workflow implementation
- [ ] automated handoff between analysis stages
- [ ] paired-end and single-end input support
- [ ] containerized workflow execution
- [ ] automated QC
- [ ] automated downstream analysis
- [ ] automated Quarto report generation
- [ ] full workflow execution through HPC / SLURM
- [ ] workflow testing
- [ ] continuous integration

The goal is to move from individually validated analysis steps to a workflow
that can be launched reproducibly on either a local system or HPC
infrastructure.

The same project structure can then be extended to additional sequencing
workflows without changing the core principles of QC, reproducibility,
automation, and clear reporting.


---

<div align="center">

## 🔬 Explore the RNA-Seq Analysis

### [View the Interactive Analysis Report](https://ArchanaAllishe.github.io/reproducible-rnaseq-pipeline/)

**Raw Sequencing Data → Reproducible Analysis → Biological Insight → Shareable Results**

</div>

---
# AI Usage

AI-assisted tools were used during development to support tasks such as
documentation refinement, code review, troubleshooting, and exploration of
implementation approaches.

The analysis itself was executed and validated using the tools and workflows
documented in this repository. Quality-control decisions, parameter selection,
statistical thresholds, result verification, and biological interpretation
were reviewed against the underlying data and established bioinformatics
methods.

AI-generated suggestions were treated as development assistance rather than
as a substitute for analysis validation or scientific interpretation.

</div>
---
# References

## Dataset and Study

1. **Gentien D, et al.** Multi-omics comparison of malignant and normal uveal
   melanocytes reveals molecular features of uveal melanoma.
   *Cell Reports*. 2023;42(9):113132.
   doi: 10.1016/j.celrep.2023.113132

   - GEO SuperSeries: **GSE199679**
   - RNA-seq SubSeries: **GSE198801**
   - PMID: **37708024**

## Bioinformatics Methods and Resources

2. **Dobin A, et al.** STAR: ultrafast universal RNA-seq aligner.
   *Bioinformatics*. 2013;29(1):15–21.
   doi: 10.1093/bioinformatics/bts635

3. **Liao Y, Smyth GK, Shi W.** featureCounts: an efficient general purpose
   program for assigning sequence reads to genomic features.
   *Bioinformatics*. 2014;30(7):923–930.
   doi: 10.1093/bioinformatics/btt656

4. **Wang L, Wang S, Li W.** RSeQC: quality control of RNA-seq experiments.
   *Bioinformatics*. 2012;28(16):2184–2185.
   doi: 10.1093/bioinformatics/bts356

5. **Ewels P, Magnusson M, Lundin S, Käller M.** MultiQC: summarize analysis
   results for multiple tools and samples in a single report.
   *Bioinformatics*. 2016;32(19):3047–3048.
   doi: 10.1093/bioinformatics/btw354

6. **Love MI, Huber W, Anders S.** Moderated estimation of fold change and
   dispersion for RNA-seq data with DESeq2.
   *Genome Biology*. 2014;15:550.
   doi: 10.1186/s13059-014-0550-8

7. **Yu G, Wang LG, Han Y, He QY.** clusterProfiler: an R package for
   comparing biological themes among gene clusters.
   *OMICS*. 2012;16(5):284–287.
   doi: 10.1089/omi.2011.0118

8. **Milacic M, et al.** The Reactome Pathway Knowledgebase 2024.
   *Nucleic Acids Research*. 2024;52(D1):D672–D678.
   doi: 10.1093/nar/gkad1025

9. **Frankish A, et al.** GENCODE 2021.
   *Nucleic Acids Research*. 2021;49(D1):D916–D923.
   doi: 10.1093/nar/gkaa1087
