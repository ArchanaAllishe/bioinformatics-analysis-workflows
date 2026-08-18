# Reproducible RNA-Seq Analysis Pipeline

A reproducible, HPC-oriented RNA-seq analysis workflow for processing raw sequencing reads through quality control, alignment, gene-level quantification, normalization, and shareable HTML reporting.

This project demonstrates both **bioinformatics analysis** and the **computational infrastructure used to run reproducible sequencing workflows**, including Linux, SSH, environment modules, SLURM, scripting, version control, and report generation.

---

## Project Overview

The workflow begins with raw paired-end FASTQ files and progressively produces analysis-ready gene-expression data and shareable reports.

```text
Public RNA-Seq Data
        |
        v
   Raw FASTQ
        |
        v
 FastQC
        |
        v
 MultiQC
        |
        v
 QC Assessment
        |
        v
 Trimming Decision
        |
        v
 STAR Alignment
        |
        v
 BAM Files
        |
        v
 featureCounts
        |
        v
 Gene Count Matrix
        |
        v
 Normalization / QC
        |
        v
 HTML Analysis Report
```

The pipeline is being developed first with paired-end RNA-seq data and is designed to support single-end datasets as well.

---

## Project Goals

The goals of this project are to:

- build a reproducible RNA-seq analysis workflow from raw FASTQ files;
- implement the workflow in a Linux/HPC-style computing environment;
- use SLURM for batch-job submission and resource management;
- manage bioinformatics software through environment modules;
- document data provenance and analysis decisions;
- automate repetitive processing using shell/Python scripts;
- generate gene-level RNA-seq count matrices;
- perform downstream normalization and exploratory analysis;
- create HTML reports that can be shared with collaborators;
- incorporate workflow-management and containerization technologies as the project develops.

Planned workflow technologies include Nextflow/Snakemake and Docker.

---

# Dataset

## GSE199679

The development dataset is derived from the public RNA-seq study:

**GEO accession: GSE199679**

Six paired-end samples were selected for development and testing.

| Sample | SRA Run |
|---|---|
| NM_4 | SRR18355076 |
| NM_5 | SRR18355077 |
| NM_6 | SRR18355078 |
| MP46_1 | SRR18355085 |
| MP46_2 | SRR18355074 |
| MP46_3 | SRR18355081 |

Each sample contains paired-end reads:

```text
Sample_R1.fastq.gz
Sample_R2.fastq.gz
```

For pipeline development, a reproducible subset of:

```text
5,000,000 reads per FASTQ
```

was generated.

This provides a realistic RNA-seq dataset while keeping computational requirements manageable in the local simulated HPC environment.

---

# Computing Environment

The project uses a locally deployed Linux/HPC environment to reproduce common institutional bioinformatics computing practices.

## Local workstation

Host computer:

```text
Apple MacBook Pro
Apple Silicon
macOS
```

The workstation is used for:

- Git/GitHub development
- SSH access
- data transfer
- documentation
- viewing HTML analysis reports

---

## Ubuntu Environment

Ubuntu virtual machines are deployed using UTM.

The environment provides Linux-based command-line tools and a separate simulated HPC login node.

---

# Simulated HPC Environment

A Linux HPC-style environment was configured to practice infrastructure and workflow patterns commonly used by research computing facilities.

Login node:

```text
hpc-login
```

User roles include:

```text
hpcadmin    HPC administrator
dev         bioinformatics user
```

The environment includes:

- SSH key authentication
- shared storage
- Linux users and groups
- environment modules
- SLURM workload management
- reproducible project directories
- bioinformatics software installations

---

# Shared Storage

Shared project storage follows an HPC-style directory structure:

```text
/shared/
├── data/
├── projects/
└── reference/
```

The RNA-seq project is located at:

```text
/shared/projects/reproducible-rnaseq-pipeline
```

Raw development FASTQs are stored under:

```text
/shared/data/GSE199679/raw_fastq/
```

Reference genomes and annotations are maintained separately under:

```text
/shared/reference/
```

This keeps raw data, analysis code, results, and reference resources logically separated.

---

# Environment Modules

Bioinformatics software is managed through the Linux Environment Modules system.

Available modules include tools such as:

```text
fastqc
multiqc
samtools
star
```

Example:

```bash
module load fastqc/0.12.1
module load star/2.7.11b
```

This avoids hard-coding software paths into analysis scripts and makes software versions explicit and reproducible.

---

# SLURM Workload Management

SLURM is used to submit computational jobs.

Example:

```bash
sbatch scripts/08-fastqc.sh
```

Jobs can be monitored with:

```bash
squeue -u dev
```

The simulated cluster currently contains a `compute` partition and a Linux compute node.

This allows the project to follow an HPC-style execution model:

```text
Mac workstation
      |
      | SSH
      v
HPC login node
      |
      | sbatch
      v
SLURM
      |
      v
Compute resources
      |
      v
Results
```

---

# Raw FASTQ Acquisition

Direct SRA Toolkit downloads from the HPC environment were affected by network connectivity to NCBI/ENA endpoints.

To preserve a realistic workflow, FASTQ subsets were therefore downloaded on the local workstation and transferred to shared HPC storage.

The six paired-end samples produced 12 FASTQ files:

```text
NM_4_R1.fastq.gz
NM_4_R2.fastq.gz

NM_5_R1.fastq.gz
NM_5_R2.fastq.gz

NM_6_R1.fastq.gz
NM_6_R2.fastq.gz

MP46_1_R1.fastq.gz
MP46_1_R2.fastq.gz

MP46_2_R1.fastq.gz
MP46_2_R2.fastq.gz

MP46_3_R1.fastq.gz
MP46_3_R2.fastq.gz
```

FASTQ integrity and read counts were verified before analysis.

---

# Quality Control

## FastQC

FastQC was executed through SLURM for all 12 FASTQ files.

The batch job completed successfully and generated individual FastQC HTML and ZIP reports.

Output:

```text
results/fastqc/
```

---

## MultiQC

MultiQC was used to aggregate all FastQC results into a single report.

All:

```text
12 / 12 FASTQ files
```

were detected in the final report.

The report provides a unified view of:

- sequence quality
- GC content
- sequence length
- sequence duplication
- per-base sequence content
- overrepresented sequences
- adapter content
- FastQC PASS / WARN / FAIL metrics

---

# MultiQC Report

The complete QC results are included in the repository.

### Interactive report

[View MultiQC HTML Report](results/qc/multiqc_report.html)

### Static report

[View MultiQC PDF Report](results/qc/multiqc_report.pdf)

### QC interpretation

[Read the QC Assessment and Trimming Decision](docs/09-fastqc-multiqc-qc-assessment.md)

---

# QC Assessment

The MultiQC report was reviewed before proceeding to alignment.

Important observations included:

### Read count

Each FASTQ contains:

```text
5,000,000 reads
```

giving 5 million paired-end read pairs per biological sample in the development subset.

### Read length

Reads are consistently:

```text
101 bp
```

### GC content

GC content is approximately:

```text
47–53%
```

across the dataset.

### Adapter content

Adapter-content checks passed across the FASTQ files.

No substantial adapter contamination was detected.

### Sequence quality

Per-base sequencing quality was acceptable and did not indicate severe quality deterioration requiring trimming.

### Sequence duplication

Elevated duplication was observed in several samples.

Duplication was interpreted in the context of RNA-seq, where highly expressed transcripts can naturally generate repeated sequences.

Reads were therefore not removed solely on the basis of FastQC duplication warnings.

### Per-base sequence content

FastQC reported non-random nucleotide composition in the reads.

Such patterns can occur in RNA-seq libraries because of library-preparation effects and transcript-derived sequence composition.

These warnings alone were not considered sufficient justification for trimming.

### Overrepresented sequences

Some overrepresented-sequence warnings were observed, particularly among several R2 files.

However, adapter-content checks passed and the detected sequences represented only a small fraction of the reads.

---

# Trimming Decision

Based on the combined FastQC and MultiQC assessment:

> **No adapter or quality trimming was performed before alignment.**

The decision was based on:

1. adapter-content checks passing;
2. acceptable sequence-quality profiles;
3. consistent 101-bp read lengths;
4. absence of severe quality degradation;
5. RNA-seq-specific interpretation of duplication and sequence-content warnings.

The original reads are therefore retained for alignment.

This workflow intentionally avoids treating trimming as a mandatory preprocessing step.

Instead:

```text
QC results
    |
    v
Evidence-based decision
    |
    +---- trimming required ----> Trim reads
    |
    └---- trimming unnecessary -> Preserve reads
```

For the current dataset:

```text
FASTQ
  |
  v
FastQC
  |
  v
MultiQC
  |
  v
QC Review
  |
  +---- Significant adapters? ---- No
  |
  +---- Severe quality loss? ----- No
  |
  v
No trimming
  |
  v
STAR Alignment
```

---

# MultiQC Environment Troubleshooting

During report generation, the Ubuntu-packaged MultiQC installation generated the analysis data successfully but produced an HTML report that remained at:

```text
Loading report
```

The MultiQC logs indicated missing JavaScript assets required by the interactive report.

Rather than modifying the system Python installation, an isolated Python virtual environment was created:

```text
/opt/multiqc-venv
```

A complete MultiQC installation was installed inside this environment and used to regenerate the report.

The corrected report rendered successfully.

This troubleshooting step demonstrates why isolated software environments are useful for reproducible scientific computing.

---

# Current Workflow Status

| Stage | Status |
|---|---|
| Ubuntu workstation environment | Complete |
| Simulated HPC deployment | Complete |
| SSH access | Complete |
| Shared storage | Complete |
| Environment Modules | Complete |
| SLURM configuration | Complete |
| Public dataset selection | Complete |
| FASTQ acquisition | Complete |
| FASTQ subset generation | Complete |
| FASTQ transfer to HPC | Complete |
| FastQC | Complete |
| MultiQC | Complete |
| QC assessment | Complete |
| Trimming decision | Complete — no trimming |
| Reference genome preparation | Next |
| STAR alignment | Planned |
| BAM processing | Planned |
| featureCounts | Planned |
| Count-matrix cleanup | Planned |
| Normalization | Planned |
| Exploratory analysis | Planned |
| HTML results report | Planned |
| Workflow automation | Planned |
| Containerization | Planned |

---

# Next Step

The next stage is reference-genome preparation followed by STAR alignment.

Planned workflow:

```text
Human reference genome FASTA
          +
Gene annotation GTF
          |
          v
    STAR Genome Index
          |
          v
Paired-End FASTQ Files
          |
          v
     STAR Alignment
          |
          v
        BAM
          |
          v
   featureCounts
          |
          v
 Gene Count Matrix
```

The reference genome and annotation will be maintained under:

```text
/shared/reference/
```

Alignment will be submitted through SLURM rather than run interactively on the login shell.

---

# Repository Structure

```text
reproducible-rnaseq-pipeline/
│
├── README.md
│
├── docs/
│   ├── 01-ubuntu-environment.md
│   ├── ...
│   ├── 06-environment-modules.md
│   └── 09-fastqc-multiqc-qc-assessment.md
│
├── scripts/
│   ├── 08-fastqc.sh
│   └── 09-multiqc.sh
│
├── results/
│   ├── fastqc/
│   ├── multiqc/
│   └── qc/
│       ├── multiqc_report.html
│       └── multiqc_report.pdf
│
└── logs/
```

Large raw FASTQ, BAM, and reference-genome files are not intended to be committed to GitHub.

---

# Reproducibility Principles

This project follows several reproducibility practices:

- public sequencing data;
- documented sample accessions;
- version-controlled scripts;
- explicit software versions;
- environment modules;
- isolated software environments when appropriate;
- SLURM batch execution;
- separation of raw data, reference files, scripts, and results;
- documented QC decisions;
- preservation of analysis logs;
- shareable HTML/PDF reports.

---

# Technologies

Current and planned technologies include:

### Bioinformatics

- FastQC
- MultiQC
- STAR
- SAMtools
- featureCounts
- R / Bioconductor

### Linux / HPC

- Ubuntu Linux
- Bash
- SSH
- Environment Modules
- SLURM
- shared Linux storage
- users/groups and permissions

### Programming and Automation

- Bash
- Python
- R

### Reproducibility

- Git
- GitHub
- Docker
- Nextflow / Snakemake

### Reporting

- MultiQC
- R Markdown / Quarto
- HTML
- PDF
- GitHub Pages

---

# Planned Final Deliverable

The final project will provide a reproducible path from:

```text
Raw sequencing reads
        ↓
Quality control
        ↓
Alignment
        ↓
Gene quantification
        ↓
Normalization
        ↓
Exploratory analysis
        ↓
Biological results
        ↓
Shareable HTML report
```

A key objective is to make analysis results accessible to collaborators through a web-based report rather than requiring them to navigate analysis directories or interpret raw output files.

---

# Project Status

**Active development**

Current milestone:

> **Raw-data QC completed. MultiQC reviewed. No trimming required. Preparing the human reference genome for STAR alignment.**