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
## Requirements and Reproducibility

The analysis combines standard bioinformatics tools with workflow automation
and containerization. Individual analysis steps can be run manually, while the
automated workflow uses **Nextflow and Docker** to provide a more reproducible
execution environment.

| Tool | Purpose |
|---|---|
| FastQC | Raw-read quality assessment |
| MultiQC 1.35 | Combined sequencing QC report |
| STAR | RNA-seq read alignment |
| SAMtools | BAM processing and indexing |
| RSeQC | Library strandedness assessment |
| featureCounts | Gene-level quantification |
| R / DESeq2 | Differential-expression analysis |
| Python | Data processing and visualization |
| Nextflow | Workflow automation |
| Docker | Reproducible software environments |
| Quarto | Interactive results reporting |
| Git | Version control |
| SLURM | HPC job scheduling when available |

For the automated workflow, install **Nextflow**, **Docker**, and **Quarto**.
Bioinformatics software used by the workflow is provided through versioned
containers, reducing the need to install each tool separately.

```bash
nextflow -version
docker --version
quarto --version
```

The workflow can then be run with:

```bash
nextflow run workflow/main.nf \
    -c workflow/nextflow.config \
    -resume
```

On an institutional HPC system, software may instead be provided through
environment modules or container technologies supported by the cluster.
Detailed Linux, HPC, environment-module, and SLURM setup is documented in
[`docs/`](docs/).

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

## Analysis

The workflow follows RNA-seq data from raw paired-end reads through alignment,
gene quantification, differential expression, functional interpretation, and
reporting. Sample identifiers are retained throughout the workflow so results
can be traced back to the original sequencing files.

### Sample Naming

Each biological sample is represented by two paired-end FASTQ files:

```text
<sample>_R1.fastq.gz
<sample>_R2.fastq.gz
```

`R1` and `R2` contain reads from opposite ends of the same library fragments.
The shared filename prefix identifies the sample.

For example:

```text
NM_4_R1.fastq.gz
NM_4_R2.fastq.gz
        ↓
     NM_4
```

These sample identifiers are retained through alignment and quantification and
matched to the metadata defining the NM and MP46 experimental groups.

---

### 1. Sequencing Quality Control — FastQC and MultiQC

Raw FASTQ files were assessed before alignment to identify sequencing-quality
issues that could affect downstream analysis. **FastQC** evaluates metrics such
as per-base quality, GC content, duplication, adapter content, and
overrepresented sequences. **MultiQC 1.35** combines the individual FastQC
reports for comparison across the complete dataset.

FastQC examines each `R1` and `R2` file independently. In Nextflow, matching
paired files are discovered from their shared sample prefix using
`Channel.fromFilePairs()`.

```text
NM_4_R1.fastq.gz ─┐
                  ├── sample = NM_4
NM_4_R2.fastq.gz ─┘
```

**Standalone**

```bash
fastqc /path/to/fastq/*.fastq.gz
multiqc /path/to/fastqc/results
```

**Nextflow:** [`workflow/main.nf`](workflow/main.nf) — `FASTQC` and `MULTIQC`

| Output | Purpose |
|---|---|
| `*_fastqc.html` | QC report for each FASTQ file |
| `*_fastqc.zip` | Machine-readable FastQC results |
| `multiqc_report.html` | Combined interactive QC report |
| `multiqc_data/` | Structured MultiQC results |

<h2 align="center">
  <a href="https://archanaallishe.github.io/bioinformatics-analysis-workflows/multiqc_report.html">
    View Interactive MultiQC Report
  </a>
</h2>

---

### 2. Read Alignment — STAR

FASTQ reads do not contain information about their genomic origin. **STAR**
aligns the paired reads to the human reference genome and accounts for
RNA-seq reads that span exon-exon splice junctions.

Files sharing the same sample prefix are aligned together:

```text
NM_4_R1.fastq.gz + NM_4_R2.fastq.gz
                  ↓
                 STAR
                  ↓
NM_4_Aligned.sortedByCoord.out.bam
```

The resulting BAM file stores the genomic locations and alignment information
for the reads and becomes the main input for downstream alignment-based
analysis.

**Standalone:** [`scripts/alignment/run_star_all.sh`](scripts/alignment/run_star_all.sh)

```bash
bash scripts/alignment/run_star_all.sh
```

The downstream Nextflow workflow reuses these validated STAR BAM files rather
than repeating alignment.

| Output | Purpose |
|---|---|
| `*_Aligned.sortedByCoord.out.bam` | Coordinate-sorted read alignments |
| `*Log.final.out` | Main STAR mapping statistics |
| `*SJ.out.tab` | Detected splice junctions |

---

### 3. BAM Indexing — SAMtools

STAR BAM files can be large. **SAMtools** creates a `.bai` index that allows
downstream programs to jump directly to specific genomic regions instead of
reading the entire BAM file.

```text
sample.bam
    ↓
SAMtools index
    ↓
sample.bam.bai
```

The BAM filename retains the sample identifier.

**Standalone**

```bash
samtools index sample.bam
```

**Nextflow:** [`workflow/main.nf`](workflow/main.nf) — `SAMTOOLS_INDEX`

| Output | Purpose |
|---|---|
| `*.bam.bai` | Index for efficient access to the corresponding BAM |

---

### 4. Library Strandedness — RSeQC

RNA-seq libraries may be **unstranded, forward-stranded, or
reverse-stranded**, depending on the library-preparation protocol.
Strandedness describes whether read orientation retains information about the
strand from which the original RNA transcript originated.

- **Unstranded:** read orientation does not reliably identify the transcript
  strand.
- **Forward-stranded:** the paired reads follow the forward orientation defined
  by the library protocol.
- **Reverse-stranded:** the paired reads follow the opposite orientation
  convention.

For paired-end data, forward and reverse orientation depend on the relationship
between `R1`, `R2`, and the annotated transcript rather than simply whether
every read maps to the same or opposite strand as a gene.

This matters when genes overlap on opposite strands. Using the wrong
strandedness during counting can cause reads to be assigned incorrectly or
excluded.

**RSeQC `infer_experiment.py`** compared the aligned reads with the reference
gene annotation to determine the library orientation.

```text
BAM + gene annotation
        ↓
RSeQC infer_experiment.py
        ↓
reverse-stranded
        ↓
featureCounts -s 2
```

**Standalone**

```bash
infer_experiment.py \
    -r gencode.v48.bed \
    -i sample.bam
```

**Nextflow:** [`workflow/main.nf`](workflow/main.nf) —
`RSEQC_INFER_EXPERIMENT`

The results supported **reverse-stranded** counting:

```text
-s 0    unstranded
-s 1    stranded
-s 2    reversely stranded
```

| Output | Purpose |
|---|---|
| `*_infer_experiment.txt` | Per-sample strandedness assessment |

---

### 5. Gene Quantification — featureCounts

BAM files describe where reads align, but differential-expression analysis
requires a count for each gene in each sample. **featureCounts** assigns
aligned fragments to annotated exons and summarizes them by `gene_id`.

Reverse-stranded paired-end counting was used based on the RSeQC assessment:

```text
-t exon             annotated exons
-g gene_id          summarize by gene
-p                  paired-end data
--countReadPairs    count fragments/read pairs
-s 2                reverse-stranded
```

Each BAM file becomes a sample column in the resulting count table.

**Standalone:** [`scripts/quantification/run_featurecounts.sh`](scripts/quantification/run_featurecounts.sh)

```bash
bash scripts/quantification/run_featurecounts.sh
```

**Nextflow:** [`workflow/main.nf`](workflow/main.nf) — `FEATURECOUNTS`

| Output | Purpose |
|---|---|
| `gene_counts.txt` | Raw gene counts across samples |
| `gene_counts.txt.summary` | Read-assignment statistics |

---

### 6. Count-Matrix Preparation and Filtering

The featureCounts table contains genomic annotation fields in addition to
sample counts. These fields were removed and BAM-derived column names were
cleaned to restore the original sample identifiers.

Low-expression genes were then removed because they provide little statistical
information and increase unnecessary multiple testing.

```text
featureCounts table
        ↓
clean sample names
        ↓
gene × sample matrix
        ↓
low-count filtering
        ↓
filtered count matrix
```

Raw integer counts were retained for DESeq2; counts were **not log-transformed
before statistical modeling**.

**Standalone**

```bash
python3 scripts/downstream/clean_featurecounts.py \
    gene_counts.txt gene_counts_matrix.tsv

python3 scripts/downstream/filter_counts.py \
    gene_counts_matrix.tsv gene_counts_filtered.tsv
```

**Nextflow:** [`workflow/main.nf`](workflow/main.nf) — count-cleaning and
filtering processes

| Output | Purpose |
|---|---|
| `gene_counts_matrix.tsv` | Clean gene-by-sample count matrix |
| `gene_counts_filtered.tsv` | Count matrix used for DESeq2 |

---

### 7. Differential Expression — DESeq2

The filtered raw counts were analyzed with **DESeq2**. DESeq2 accounts for
differences in sequencing depth and library composition, models RNA-seq counts
using a negative-binomial framework, and tests for expression differences
between the experimental groups.

Sample identifiers in the count matrix were matched to metadata defining
**NM** and **MP46**.

The comparison was:

```text
MP46 vs NM

positive log2FoldChange → higher in MP46
negative log2FoldChange → higher in NM
```

Significant genes were defined as:

```text
adjusted p-value < 0.05
AND
|log2FoldChange| ≥ log2(1.5)
```

**Standalone**

```bash
Rscript scripts/differential-expression/run_deseq2.R \
    gene_counts_filtered.tsv \
    samples.tsv \
    deseq2_results
```

Gene annotations were subsequently added with:

```bash
python3 scripts/differential-expression/annotate_deseq2.py \
    ...
```

**Nextflow:** [`workflow/main.nf`](workflow/main.nf) — DESeq2 and annotation
processes

| Output | Purpose |
|---|---|
| `deseq2_MP46_vs_NM.tsv` | Statistics for all tested genes |
| `deseq2_MP46_vs_NM_significant.tsv` | Genes meeting significance criteria |
| `deseq2_MP46_vs_NM_annotated.tsv` | DE results with gene annotation |
| `vst_expression.tsv` | Variance-stabilized values for QC and visualization |

---

### 8. Expression-Level Quality Control — PCA and Correlation

Differential-expression testing evaluates individual genes, while
expression-level QC evaluates relationships among entire samples.

**PCA** summarizes the largest sources of expression variation and helps
identify group separation and potential outliers. **Pearson correlation**
measures overall expression similarity between samples and helps assess
consistency among biological replicates.

Both analyses use the DESeq2 variance-stabilized expression values rather than
raw counts.

**Standalone**

```bash
python3 scripts/differential-expression/plot_pca.py \
    vst_expression.tsv samples.tsv pca_results

python3 scripts/downstream/sample_correlation.py \
    vst_expression.tsv sample_correlation.tsv

python3 scripts/downstream/plot_correlation.py \
    sample_correlation.tsv correlation_results
```

**Nextflow:** [`workflow/main.nf`](workflow/main.nf) — PCA and correlation
processes

| Output | Purpose |
|---|---|
| `PCA_MP46_vs_NM.png/.pdf` | Sample relationships in PCA space |
| `PCA_coordinates.tsv` | PCA coordinates for each sample |
| `sample_correlation.tsv` | Pairwise sample correlations |
| `sample_correlation_heatmap.png/.pdf` | Visual comparison of sample similarity |

---

### 9. Differential-Expression Visualization

Three complementary plots summarize the differential-expression results.

- **Volcano plot:** effect size versus statistical significance.
- **MA plot:** fold change across the range of mean gene expression.
- **DE heatmap:** expression patterns of the top differentially expressed genes
  across samples.

**Standalone**

```bash
python3 scripts/differential-expression/plot_volcano.py ...
python3 scripts/differential-expression/plot_ma.py ...
python3 scripts/differential-expression/plot_de_heatmap.py ...
```

**Nextflow:** [`workflow/main.nf`](workflow/main.nf) — visualization processes

| Output | Purpose |
|---|---|
| `volcano_MP46_vs_NM.png/.pdf` | Highlights significant expression changes |
| `MA_MP46_vs_NM.png/.pdf` | Shows fold change relative to gene abundance |
| `top30_DE_heatmap.png/.pdf` | Shows top DE-gene patterns across samples |

---

### 10. Functional Enrichment

Differential expression identifies individual genes, but biological responses
often involve groups of genes participating in related processes.

Significant genes were separated by expression direction:

```text
positive log2FoldChange → Higher in MP46
negative log2FoldChange → Higher in NM
```

**Gene Ontology Biological Process** and **Reactome** enrichment were used to
identify biological functions and pathways represented more frequently than
expected among these genes.

**Standalone**

```bash
Rscript scripts/functional-enrichment/run_enrichment.R ...
python3 scripts/functional-enrichment/plot_enrichment.py ...
```

**Nextflow:** [`workflow/main.nf`](workflow/main.nf) — enrichment processes

| Output | Purpose |
|---|---|
| `GO_BP_Higher_in_MP46.tsv` | GO processes enriched in genes higher in MP46 |
| `GO_BP_Higher_in_NM.tsv` | GO processes enriched in genes higher in NM |
| `Reactome_Higher_in_NM.tsv` | Reactome pathways enriched in genes higher in NM |
| `*_summary.png` | Visual summaries of enrichment results |

---

### 11. Workflow Automation — Nextflow

After the individual analysis stages were established, **Nextflow** connected
them into a reproducible workflow. The workflow reuses the validated STAR BAM
files and manages the downstream dependencies automatically.

**Docker** provides versioned software environments for workflow processes,
reducing differences caused by local software installations.

```text
FASTQ → FastQC → MultiQC
                    ↓
          validated STAR BAMs
                    ↓
      SAMtools → RSeQC → featureCounts
                    ↓
             count preparation
                    ↓
                  DESeq2
              ┌─────┼─────┐
             PCA   plots  enrichment
              └─────┼─────┘
                    ↓
              Quarto report
```

**Workflow:** [`workflow/main.nf`](workflow/main.nf) and
[`workflow/nextflow.config`](workflow/nextflow.config)

```bash
nextflow run workflow/main.nf \
    -c workflow/nextflow.config \
    -resume
```

`-resume` allows successfully completed processes to be reused when their
inputs and configuration have not changed.

---

### 12. Interactive Reporting — Quarto

The final QC, differential-expression, visualization, and enrichment results
were assembled into an interactive **Quarto** report. This provides a single
entry point for reviewing the analysis without navigating individual scripts
and result directories.

**Standalone**

```bash
quarto render report
```

**Nextflow:** [`workflow/main.nf`](workflow/main.nf) — `QUARTO_REPORT`

| Output | Purpose |
|---|---|
| `index.html` | Main interactive analysis report |
| `multiqc_report.html` | Complete interactive sequencing-QC report |
| `images/` | Figures displayed in the report |
| `site_libs/` | Supporting resources for the Quarto website |
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
