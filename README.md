# Linux, Server & HPC for Bioinformatics

## Project Overview

This project documents a hands-on progression from Linux system setup to reproducible, scalable bioinformatics workflow development.

The project begins with Ubuntu installation and Linux administration and progressively introduces remote server access, secure authentication, file transfer, environment management, containerization, HPC concepts, Slurm workload scheduling, Nextflow workflow development, RNA-seq analysis, and collaborator-facing HTML reporting.

The primary applied use case is an end-to-end RNA-seq workflow beginning with raw sequencing files in `FASTQ.gz` format.

The workflow is designed to support both:

* single-end RNA-seq data
* paired-end RNA-seq data

The final goal is to combine Linux, Docker, Slurm, Nextflow, R, and Quarto into a reproducible scientific computing workflow that can process RNA-seq data and communicate results through a browser-based HTML results portal.

---

## Project Goals

This project is designed to develop and demonstrate practical skills in:

### Linux and Server Administration

* Ubuntu Linux
* Linux command-line usage
* filesystem navigation
* package management
* users and groups
* file ownership and permissions
* process and resource monitoring
* networking fundamentals

### Remote Computing

* SSH
* SSH server configuration
* public/private SSH key authentication
* remote login
* SCP
* rsync
* secure file transfer

### Reproducible Environments

* Git
* GitHub
* Conda/Mamba
* environment management
* Docker
* Dockerfiles
* container images
* container volumes
* reproducible software environments

### High-Performance Computing

* HPC architecture
* login and compute nodes
* resource allocation
* CPU and memory requests
* Slurm
* `sbatch`
* `squeue`
* job monitoring
* batch job scripts

### Workflow Engineering

* Bash scripting
* workflow automation
* Nextflow
* processes and channels
* workflow configuration
* containerized workflow execution
* Nextflow with Slurm
* reproducibility
* logging and troubleshooting

### RNA-seq Analysis

* raw `FASTQ.gz` files
* single-end sequencing
* paired-end sequencing
* sample metadata
* FastQC
* MultiQC
* QC-based trimming decisions
* reference genome preparation
* STAR alignment
* BAM files
* alignment QC
* featureCounts
* gene count matrices
* R
* DESeq2
* normalization
* PCA
* differential expression
* volcano plots
* heatmaps
* pathway analysis

### Scientific Reporting

* Quarto
* HTML reports
* interactive tables and figures
* analysis summaries
* key findings
* methods documentation
* downloadable result files
* GitHub Pages
* collaborator-facing results portals

---

# RNA-seq Input

The workflow will support both major RNA-seq read layouts.

## Single-End Reads

A single FASTQ file represents each sample.

Example:

```text
Control_1.fastq.gz
Control_2.fastq.gz
Treatment_1.fastq.gz
Treatment_2.fastq.gz
```

Workflow representation:

```text
Sample
   |
   └── FASTQ.gz
```

---

## Paired-End Reads

Each sample contains two corresponding FASTQ files.

Example:

```text
Control_1_R1.fastq.gz
Control_1_R2.fastq.gz

Control_2_R1.fastq.gz
Control_2_R2.fastq.gz

Treatment_1_R1.fastq.gz
Treatment_1_R2.fastq.gz
```

Workflow representation:

```text
             Sample
            /      \
           /        \
         R1          R2
          |          |
     FASTQ.gz    FASTQ.gz
```

The workflow will determine the appropriate processing path based on sample metadata and sequencing layout.

---

# RNA-seq Workflow

```text
                        Raw FASTQ.gz
                             |
                             v
                      Input validation
                             |
                             v
                    Sequencing layout
                             |
                 +-----------+-----------+
                 |                       |
                 v                       v
            Single-End              Paired-End
              FASTQ                  R1 + R2
                 |                       |
                 +-----------+-----------+
                             |
                             v
                          FastQC
                             |
                             v
                          MultiQC
                             |
                             v
                     Quality assessment
                             |
                             v
                Trim reads only if required
                             |
                             v
                           STAR
                             |
                             v
                    Sorted BAM files
                             |
                             v
                     Alignment QC
                             |
                             v
                      featureCounts
                             |
                             v
                    Gene count matrix
                             |
                             v
                         R / DESeq2
                             |
              +--------------+--------------+
              |              |              |
              v              v              v
        Normalization       PCA      Differential
                                   Expression
                                          |
                               +----------+----------+
                               |                     |
                               v                     v
                         Volcano plots           Heatmaps
                               |
                               v
                     Biological interpretation
                               |
                               v
                          Quarto
                               |
                               v
                    HTML Results Portal
                               |
                               v
                         GitHub Pages
                               |
                               v
                         Collaborator
```

---

# Quality-Control Strategy

Read trimming will not automatically be performed on every dataset.

The workflow will first examine FastQC and MultiQC results.

A trimming step will be introduced only when supported by QC evidence such as:

* adapter contamination
* poor-quality read ends
* technical sequence contamination

This approach separates quality assessment from automatic preprocessing and makes analysis decisions explicit and reproducible.

---

# Workflow Engineering Progression

The RNA-seq analysis will initially be performed manually to understand each computational step.

The same workflow will then progressively be engineered into a more automated and scalable system.

```text
Manual Linux commands
          |
          v
      Bash scripts
          |
          v
    Conda environments
          |
          v
    Docker containers
          |
          v
      Slurm jobs
          |
          v
    Nextflow workflow
          |
          v
Nextflow + Containers
          |
          v
 Nextflow + Slurm / HPC
```

This progression demonstrates how a bioinformatics workflow can evolve from command-line analysis into a reproducible scientific computing pipeline.

---

# Planned HPC Architecture

```text
                  Local Workstation
                       Ubuntu
                          |
                          |
                  SSH / SCP / rsync
                          |
                          v
                     Login Node
                          |
                          v
                       Slurm
                          |
               +----------+----------+
               |          |          |
               v          v          v
          Compute Job Compute Job Compute Job
               |          |          |
               +----------+----------+
                          |
                          v
                       Results
```

Nextflow will eventually submit individual pipeline processes through the scheduler rather than executing the entire analysis manually.

---

# Containerization Strategy

Docker will be used to create reproducible environments for bioinformatics tools.

Conceptually:

```text
Nextflow Process
       |
       v
 Docker Container
       |
       +-- FastQC
       +-- STAR
       +-- featureCounts
       +-- other tools
       |
       v
 Reproducible execution
```

This isolates software dependencies from the host operating system and improves portability and reproducibility.

---

# Collaborator-Facing Results Portal

A major deliverable of this project will be a browser-based HTML results portal.

Instead of requiring collaborators to navigate directories such as:

```text
results/fastqc/
results/star/
results/counts/
results/deseq2/
results/plots/
```

the analysis will provide a structured website.

Planned sections include:

```text
RNA-seq Results
│
├── Project Overview
├── Experimental Design
├── Samples
├── Raw Read QC
├── MultiQC
├── Alignment QC
├── Gene Counts
├── PCA
├── Differential Expression
├── Volcano Plots
├── Heatmaps
├── Pathway Analysis
├── Key Findings
├── Methods
├── Software Versions
└── Downloads
```

The portal will be created using **Quarto**.

When appropriate for public data, it will be deployed through **GitHub Pages** so that collaborators or reviewers can access the analysis through a web browser.

---

# Public Data Strategy

The portfolio implementation will use publicly available RNA-seq data.

The main case study will use a dataset selected according to criteria such as:

* raw FASTQ files available
* clear experimental design
* biological replicates
* suitable metadata
* manageable data size
* appropriate reference genome
* suitability for differential-expression analysis

The main analysis may use paired-end data, while a smaller single-end dataset can be used to test and demonstrate the single-end branch of the workflow.

Real patient, protected, proprietary, or collaborator sequencing data will not be committed to this public repository.

---

# Reproducibility

The project will document information required to reproduce the workflow, including:

* operating system
* processor architecture
* software versions
* Conda environments
* Docker images
* reference genome version
* annotation version
* workflow parameters
* sample metadata
* Nextflow configuration
* Slurm resource requests
* analysis parameters
* statistical thresholds

---

# Project Development Strategy

The repository will be developed incrementally.

Each major capability will be:

1. implemented,
2. tested,
3. documented,
4. committed to GitHub.

The Git history will therefore reflect the actual development of the project.

---

# Project Roadmap

```text
Phase 1
Linux Foundation
    |
    v
Phase 2
Server & SSH
    |
    v
Phase 3
Environment Management
    |
    v
Phase 4
Docker & Containerization
    |
    v
Phase 5
HPC & Slurm
    |
    v
Phase 6
RNA-seq Analysis
    |
    v
Phase 7
Nextflow Workflow Engineering
    |
    v
Phase 8
Quarto Results Portal
    |
    v
Phase 9
Testing, Reproducibility & Final Documentation
```

---

# Current Stage

**Task 01 — Ubuntu Installation and Linux Environment Setup**

The first milestone establishes and documents the Linux environment that will serve as the foundation for the server, HPC, containerization, workflow-engineering, RNA-seq, and scientific-reporting components of this project.
