# Reproducible RNA-Seq Analysis Pipeline

An end-to-end RNA-seq analysis project designed to process raw sequencing reads through quality control, alignment, gene-level quantification, differential expression analysis, and collaborator-facing HTML reporting.

## Project Objective

The objective is to implement a reproducible RNA-seq workflow that supports both **single-end and paired-end sequencing data** and can be executed consistently across local Linux and high-performance computing (HPC) environments.

The workflow is being developed with reproducibility, portability, automation, and clear scientific reporting as core design requirements.

## Planned Workflow

```text
Raw FASTQ (.fastq.gz)
        │
        ▼
      FastQC
        │
        ▼
      MultiQC
        │
        ▼
   Read Processing
        │
        ▼
       STAR
        │
        ▼
    Aligned BAM
        │
        ▼
  featureCounts
        │
        ▼
 Gene Count Matrix
        │
        ▼
Differential Expression
        │
        ▼
Figures + Result Tables
        │
        ▼
   HTML Report
```

## Input Support

The workflow is designed to support both major RNA-seq library layouts.

### Paired-end

```text
sample1_R1.fastq.gz
sample1_R2.fastq.gz
```

### Single-end

```text
sample1.fastq.gz
```

## Development System

| Component    | Configuration         |
| ------------ | --------------------- |
| Workstation  | Apple MacBook Pro     |
| Processor    | Apple M5 Pro          |
| Memory       | 24 GB                 |
| Host OS      | macOS Tahoe 26.6      |
| Build        | 25G72                 |
| Architecture | Apple Silicon / ARM64 |

## Reproducibility Strategy

The project is structured around four complementary layers:

* **Git/GitHub** — source code, documentation, and version control
* **Docker** — reproducible software environments
* **Nextflow** — workflow orchestration and automation
* **Linux/HPC** — scalable computational execution

## Results Delivery

The final analysis will generate a structured HTML report that allows collaborators to review results through a web browser without navigating individual pipeline output directories.

The report will integrate key outputs including:

* sequencing quality control
* MultiQC summaries
* alignment statistics
* sample-level quality assessment
* exploratory analysis
* differential expression results
* figures and tables
* analysis methods
* software and reference versions

## Repository Structure

The repository will be expanded incrementally as each workflow component is implemented and validated.

```text
reproducible-rnaseq-pipeline/
│
├── README.md
├── LICENSE
└── docs/
```

## Project Status

**Current stage:** Local computational environment setup and validation.

Implementation details, commands, configuration decisions, and validation results are documented as the project progresses.
