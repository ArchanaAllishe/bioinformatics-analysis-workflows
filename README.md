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

The analysis follows the RNA-seq data from raw sequencing reads through
alignment, gene quantification, statistical analysis, biological
interpretation, and reporting. Sample identifiers are retained across the
workflow so that results can be traced back to the original sequencing files.

### Sample Naming and Paired-End Reads

The study uses paired-end RNA-seq data. During paired-end sequencing, each
library fragment is read from both ends, producing two FASTQ files for each
sample:

```text
<sample>_R1_001.fastq.gz    # Read 1
<sample>_R2_001.fastq.gz    # Read 2
```

Files with the same sample prefix are treated as a pair. This identifier is
retained through alignment, quantification, and downstream analysis and is
matched to the metadata defining the NM and MP46 experimental groups.

---

### 1. Sequencing Quality Control — FastQC and MultiQC

RNA-seq analysis begins with the raw FASTQ files. Before alignment, the reads
need to be checked for technical problems that could affect later results.

**FastQC** examines each FASTQ file independently and reports metrics such as
per-base sequence quality, GC-content distribution, sequence duplication,
adapter contamination, and overrepresented sequences. These checks help
identify poor-quality sequencing, residual adapters, or other technical
features that may require investigation before alignment.

Because FastQC produces a separate report for every FASTQ file, **MultiQC
1.35** collects the individual reports into a single summary. This makes it
easier to compare all samples and identify unusual samples or systematic QC
problems.

| Files generated | Purpose |
|---|---|
| `*_fastqc.html` | Human-readable QC report for each FASTQ file |
| `*_fastqc.zip` | Machine-readable FastQC results |
| `multiqc_report.html` | Interactive summary of QC across all FASTQ files |
| `multiqc_data/` | Structured data generated by MultiQC |

**Implementation:** [`workflow/main.nf`](workflow/main.nf) — `FASTQC` and
`MULTIQC` processes.

```bash
fastqc *.fastq.gz
multiqc .
```

The QC results were reviewed before proceeding to alignment.

<h2 align="center">
  <a href="https://archanaallishe.github.io/bioinformatics-analysis-workflows/multiqc_report.html">
    View Interactive MultiQC Report
  </a>
</h2>

---

### 2. Read Alignment — STAR

FASTQ files contain sequencing reads but do not indicate where those reads
originated in the genome. **STAR** was therefore used to align the paired-end
reads to the human reference genome.

STAR is designed for RNA-seq and can recognize reads spanning exon-exon
junctions. This is important because mature RNA transcripts have undergone
splicing, so many RNA-seq reads cannot be represented as simple continuous
genomic alignments.

The paired FASTQ files for each sample produce a sample-specific alignment:

```text
Sample_R1_001.fastq.gz
Sample_R2_001.fastq.gz
        │
        └── STAR
              ↓
Sample_Aligned.sortedByCoord.out.bam
```

The BAM file contains the genomic position and alignment information for the
sequenced reads. It becomes the main input for alignment-based QC and gene
quantification.

| Files generated | Purpose |
|---|---|
| `*_Aligned.sortedByCoord.out.bam` | Coordinate-sorted genomic alignments |
| `*Log.final.out` | Summary statistics such as uniquely and multiply mapped reads |
| `*Log.out` | Detailed STAR execution information |
| `*Log.progress.out` | Alignment progress |
| `*SJ.out.tab` | Splice junctions detected during alignment |

**Script:** [`scripts/alignment/run_star_all.sh`](scripts/alignment/run_star_all.sh)

```bash
bash scripts/alignment/run_star_all.sh
```

The validated STAR BAM files are reused by the automated Nextflow workflow
rather than repeating alignment.

---

### 3. BAM Indexing — SAMtools

STAR produces coordinate-sorted BAM files containing the aligned reads.
Although these files contain the required alignment information, downstream
programs may need to retrieve reads from particular genomic regions.

Reading an entire BAM file every time a genomic region is requested would be
inefficient. **SAMtools** was therefore used to create a BAM index (`.bai`).
The index acts like a lookup table that allows software to jump directly to
the relevant part of the BAM file.

For each sample:

```text
Sample_Aligned.sortedByCoord.out.bam
                  │
             SAMtools index
                  ↓
Sample_Aligned.sortedByCoord.out.bam.bai
```

SAMtools is a standard utility for manipulating and inspecting SAM/BAM/CRAM
alignment files. Here, its role is specifically to index the STAR BAM files
so that alignment-based downstream tools can access them efficiently.

| File generated | Purpose |
|---|---|
| `*.bam.bai` | Index providing rapid random access to the corresponding BAM file |

**Implementation:** [`workflow/main.nf`](workflow/main.nf) —
`SAMTOOLS_INDEX` process.

```bash
samtools index sample.bam
```

The BAM and its index are then available for alignment-based QC, including
library-strandedness assessment.

---

### 4. Library Strandedness — RSeQC

RNA-seq libraries can be **unstranded, forward-stranded, or
reverse-stranded**, depending on the library-preparation protocol.

This matters during gene quantification because genes can overlap on opposite
DNA strands. If the wrong strandedness setting is used, reads may be assigned
to the wrong gene or not counted correctly.

Rather than assuming the library orientation, **RSeQC
`infer_experiment.py`** was used to infer it from the observed read
alignments relative to known gene annotations.

```text
Indexed BAM + reference annotation
              │
      RSeQC infer_experiment.py
              ↓
       Strandedness assessment
              ↓
     featureCounts setting
```

The analysis supported a **reverse-stranded** library configuration, which
was therefore represented by `-s 2` during featureCounts quantification.

| File generated | Purpose |
|---|---|
| `*_infer_experiment.txt` | Per-sample evidence used to determine library orientation |

**Implementation:** [`workflow/main.nf`](workflow/main.nf) —
`RSEQC_INFER_EXPERIMENT` process.

```bash
infer_experiment.py \
    -r gencode.v48.bed \
    -i sample.bam
```

Determining strandedness before counting ensures that featureCounts interprets
the aligned reads using the correct library orientation.

---

### 5. Gene Quantification — featureCounts

The BAM files identify where reads align in the genome, but differential
expression requires a numerical count for each gene in each sample.

**featureCounts** was used to connect the alignments to the gene annotation.
It determines which annotated exon each aligned fragment overlaps and assigns
that fragment to the corresponding `gene_id`.

The analysis used:

```text
-t exon       → count reads overlapping annotated exons
-g gene_id    → summarize exon counts at the gene level
-p            → paired-end data
--countReadPairs
-s 2          → reverse-stranded library
```

Conceptually:

```text
BAM alignments
      +
GTF gene annotation
      │
      └── featureCounts
              ↓
       Gene × Sample
        count matrix
```

Each BAM file becomes a sample column in the featureCounts output.

| Files generated | Purpose |
|---|---|
| `gene_counts.txt` | Raw gene-level counts across all samples |
| `gene_counts.txt.summary` | Summary of assigned and unassigned reads |

**Script:** [`scripts/quantification/run_featurecounts.sh`](scripts/quantification/run_featurecounts.sh)

```bash
bash scripts/quantification/run_featurecounts.sh
```

The same operation is represented by the `FEATURECOUNTS` process in
[`workflow/main.nf`](workflow/main.nf).

---

### 6. Count-Matrix Preparation and Filtering

The raw featureCounts table contains both gene counts and annotation fields
such as chromosome, genomic coordinates, strand, and gene length. DESeq2
requires a simpler matrix containing gene identifiers and integer counts for
each sample.

The featureCounts output was therefore cleaned to produce an analysis-ready
gene-by-sample count matrix. Sample-column names derived from the BAM
filenames were also simplified so that they could be matched consistently to
the sample metadata.

```text
featureCounts output
        ↓
remove annotation columns
        ↓
clean sample names
        ↓
gene_counts_matrix.tsv
        ↓
filter low-expression genes
        ↓
gene_counts_filtered.tsv
```

Very low-expression genes provide little statistical information and increase
the number of hypotheses being tested. They were therefore filtered before
differential-expression analysis.

| Files generated | Purpose |
|---|---|
| `gene_counts_matrix.tsv` | Clean gene-by-sample raw count matrix |
| `gene_counts_filtered.tsv` | Matrix retained for differential-expression analysis |

**Scripts:**
[`clean_featurecounts.py`](scripts/downstream/clean_featurecounts.py) and
[`filter_counts.py`](scripts/downstream/filter_counts.py).

```bash
python3 scripts/downstream/clean_featurecounts.py \
    gene_counts.txt \
    gene_counts_matrix.tsv

python3 scripts/downstream/filter_counts.py \
    gene_counts_matrix.tsv \
    gene_counts_filtered.tsv
```

Importantly, the values supplied to DESeq2 remain **raw integer counts**;
log transformation is not performed before DESeq2 modeling.

---

### 7. Differential Expression — DESeq2

The filtered count matrix describes how many fragments were assigned to each
gene, but raw counts cannot be compared directly across samples because
sequencing depth and library composition can differ.

**DESeq2** was used for normalization and differential-expression testing.
It estimates sample-specific size factors, models gene counts using a
negative-binomial framework, and tests whether expression differs between the
experimental groups.

Sample columns in the count matrix were matched to the metadata defining the
**NM** and **MP46** groups.

The comparison was defined as:

```text
MP46 vs NM
```

Therefore:

```text
positive log2FoldChange → higher expression in MP46
negative log2FoldChange → higher expression in NM
```

Genes were considered significant when they met both criteria:

```text
adjusted p-value < 0.05
AND
|log2FoldChange| ≥ log2(1.5)
```

Using the adjusted p-value controls the false-discovery rate associated with
testing thousands of genes simultaneously.

DESeq2 also generated variance-stabilized expression values. Unlike the raw
counts used for statistical modeling, these transformed values are useful for
sample-level visualization and exploratory analysis.

| Files generated | Purpose |
|---|---|
| `deseq2_MP46_vs_NM.tsv` | Differential-expression statistics for all tested genes |
| `deseq2_MP46_vs_NM_significant.tsv` | Genes meeting the predefined significance criteria |
| `vst_expression.tsv` | Variance-stabilized expression values for QC and visualization |
| `deseq2_MP46_vs_NM_annotated.tsv` | DE results supplemented with gene annotation |

**Scripts:**
[`run_deseq2.R`](scripts/differential-expression/run_deseq2.R) and
[`annotate_deseq2.py`](scripts/differential-expression/annotate_deseq2.py).

```bash
Rscript scripts/differential-expression/run_deseq2.R \
    gene_counts_filtered.tsv \
    samples.tsv \
    deseq2_results
```

---

### 8. Expression-Level Quality Control — PCA and Correlation

Statistically testing individual genes does not by itself show whether the
samples behave coherently at the whole-transcriptome level.

The DESeq2 variance-stabilized expression matrix was therefore used for two
complementary sample-level assessments.

**Principal component analysis (PCA)** reduces thousands of gene-expression
measurements into a small number of components representing the largest
sources of variation. It helps determine whether biological replicates
cluster together, whether NM and MP46 separate, and whether any sample behaves
as a potential outlier.

**Pearson sample correlation** measures the overall similarity of expression
profiles between every pair of samples. Strong within-group correlations
support consistency among biological replicates, while unexpectedly weak
correlations can indicate biological heterogeneity or technical problems.

| Files generated | Purpose |
|---|---|
| `PCA_MP46_vs_NM.png/.pdf` | Visualizes major expression differences among samples |
| `PCA_coordinates.tsv` | Numerical PCA coordinates for individual samples |
| `sample_correlation.tsv` | Pairwise sample-correlation matrix |
| `sample_correlation_heatmap.png/.pdf` | Visual summary of sample similarity |

**Scripts:** [`plot_pca.py`](scripts/differential-expression/plot_pca.py),
[`sample_correlation.py`](scripts/downstream/sample_correlation.py), and
[`plot_correlation.py`](scripts/downstream/plot_correlation.py).

---

### 9. Differential-Expression Visualization

Several plots were generated because no single visualization captures all
aspects of a differential-expression result.

The **volcano plot** displays effect size against statistical significance,
making genes with both large expression changes and strong statistical
support easy to identify.

The **MA plot** displays log2 fold change against mean expression, allowing
expression changes to be examined across the range of gene abundance.

The **top-30 DE heatmap** shows relative expression patterns of strongly
differentially expressed genes across individual samples and helps visualize
whether those genes distinguish the experimental groups.

| Files generated | Purpose |
|---|---|
| `volcano_MP46_vs_NM.png/.pdf` | Effect size versus statistical significance |
| `MA_MP46_vs_NM.png/.pdf` | Fold change across gene-expression abundance |
| `top30_DE_heatmap.png/.pdf` | Expression patterns of top DE genes across samples |

**Scripts:**
[`plot_volcano.py`](scripts/differential-expression/plot_volcano.py),
[`plot_ma.py`](scripts/differential-expression/plot_ma.py), and
[`plot_de_heatmap.py`](scripts/differential-expression/plot_de_heatmap.py).

---

### 10. Functional Enrichment

Differential-expression analysis identifies individual genes that change, but
a biological response often involves groups of genes participating in related
functions or pathways.

Significant genes were therefore separated according to the direction of
expression change:

```text
positive log2FoldChange → Higher in MP46
negative log2FoldChange → Higher in NM
```

**Gene Ontology Biological Process** enrichment was used to identify
biological processes represented more often than expected among the
differentially expressed genes.

**Reactome** enrichment provides a complementary pathway-level interpretation
based on curated biological pathways.

This converts a long list of differentially expressed genes into biological
themes that are easier to interpret.

| Files generated | Purpose |
|---|---|
| `GO_BP_Higher_in_MP46.tsv` | GO processes enriched among genes higher in MP46 |
| `GO_BP_Higher_in_NM.tsv` | GO processes enriched among genes higher in NM |
| `Reactome_Higher_in_NM.tsv` | Reactome pathways enriched among genes higher in NM |
| `*_summary.png` | Visual summaries of significant enrichment results |

**Scripts:**
[`run_enrichment.R`](scripts/functional-enrichment/run_enrichment.R) and
[`plot_enrichment.py`](scripts/functional-enrichment/plot_enrichment.py).

---

### 11. Nextflow Workflow Automation

The analysis stages were first established as individual commands and scripts
and were then connected using **Nextflow**.

Nextflow defines the dependency between steps so that an output from one
process becomes the input to the appropriate downstream process. This reduces
manual file handling and makes the analysis easier to repeat consistently.

For this implementation, the workflow reuses the validated STAR BAM files and
automates the downstream processing.

**Docker** containers provide versioned software environments for workflow
processes. This reduces dependency on software installed directly on the host
computer and improves reproducibility across computing environments.

```text
FASTQ
  ↓
FastQC → MultiQC
  ↓
validated STAR BAMs
  ↓
SAMtools indexing
  ↓
RSeQC strandedness
  ↓
featureCounts
  ↓
count preparation
  ↓
DESeq2
  ├── PCA / correlation
  ├── volcano / MA / heatmap
  └── functional enrichment
                 ↓
             Quarto report
```

**Workflow files:** [`workflow/main.nf`](workflow/main.nf) and
[`workflow/nextflow.config`](workflow/nextflow.config).

```bash
nextflow run workflow/main.nf \
    -c workflow/nextflow.config \
    -resume
```

The `-resume` option allows Nextflow to reuse previously completed processes
when their inputs and configuration have not changed, avoiding unnecessary
recomputation.

---

### 12. Interactive Reporting — Quarto

RNA-seq analysis produces many tables, plots, logs, and QC reports. Requiring a
collaborator to navigate these files individually makes the results difficult
to review.

**Quarto** was therefore used to combine the principal QC results, figures,
statistical findings, functional-enrichment results, and biological
interpretation into a single interactive HTML report.

The complete MultiQC report is also included so that sequencing QC can be
examined in greater detail when needed.

| Files generated | Purpose |
|---|---|
| `index.html` | Main interactive RNA-seq analysis report |
| `multiqc_report.html` | Full interactive sequencing-QC report |
| `images/` | Figures displayed in the report |
| `site_libs/` | Supporting resources required by the Quarto website |

**Report source:** [`report/index.qmd`](report/index.qmd)

```bash
quarto render report
```

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
