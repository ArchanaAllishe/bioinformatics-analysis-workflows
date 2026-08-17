# Environment Modules and Bioinformatics Software Management

## Overview

A centralized software-management environment was configured on the simulated HPC server using **Environment Modules**.

Bioinformatics applications were installed and exposed to researchers through versioned modulefiles rather than requiring individual users to manage separate software installations.

The configured software environment includes:

| Software | Version | Purpose                   |
| -------- | ------: | ------------------------- |
| FastQC   |  0.12.1 | FASTQ quality control     |
| MultiQC  |    1.21 | Aggregation of QC reports |
| STAR     | 2.7.11b | RNA-seq read alignment    |
| Samtools |  1.22.1 | SAM/BAM/CRAM processing   |

The researcher can now select software explicitly using commands such as:

```bash
module load fastqc/0.12.1
module load star/2.7.11b
```

This provides a reproducible software environment for subsequent SLURM-based RNA-seq analysis.

---

## What Are Environment Modules?

Environment Modules provide a mechanism for dynamically modifying a user's shell environment.

On an HPC system, multiple researchers may require different applications or different versions of the same application.

Instead of permanently modifying system environment variables, researchers can load the required software when needed.

For example:

```bash
module load star/2.7.11b
```

The module system modifies the environment for the current shell so that the selected software is available.

Modules can subsequently be removed:

```bash
module unload star/2.7.11b
```

or the environment can be reset:

```bash
module purge
```

---

## Why Use Modules on an HPC?

Research computing environments frequently support many applications and software versions simultaneously.

A module-based approach provides:

* centralized software management;
* explicit software-version selection;
* cleaner researcher environments;
* reduced dependency conflicts;
* reproducible computational workflows;
* separation between administrator-managed software and researcher accounts.

For example, a cluster could provide:

```text
star/2.7.10b
star/2.7.11a
star/2.7.11b
```

A pipeline can explicitly select:

```bash
module load star/2.7.11b
```

rather than depending on whichever STAR executable happens to be available in the default system environment.

This is particularly important for reproducible bioinformatics analyses because software versions can affect computational results.

---

# Software Management Architecture

The implemented environment separates software administration from research use.

```text
HPC Administrator
    hpcadmin
        │
        ├── installs software
        ├── manages versions
        └── creates modulefiles
                    │
                    ▼
             /opt/modulefiles
                    │
        ┌───────────┼───────────┐
        ▼           ▼           ▼
      FastQC       STAR      Samtools
        │           │           │
        └───────────┼───────────┘
                    ▼
             Researcher: dev
                    │
                    ├── module avail
                    ├── module load
                    └── sbatch
```

The `dev` researcher account does not require `sudo` privileges to use the centrally managed applications.

---

# Environment Modules Installation

Environment Modules was installed by the HPC administrator:

```bash
sudo apt update
sudo apt install environment-modules -y
```

The module system can be inspected using:

```bash
module --version
```

Available software can be displayed with:

```bash
module avail
```

---

# Central Module Repository

A dedicated modulefile repository was created:

```text
/opt/modulefiles
```

The directory is reserved for locally managed HPC software definitions.

The module search path was configured through:

```text
/etc/profile.d/bioinformatics-modules.sh
```

with:

```bash
#!/bin/bash

if [ -f /etc/profile.d/modules.sh ]; then
    source /etc/profile.d/modules.sh
fi

module use /opt/modulefiles
```

This makes the bioinformatics module repository available automatically when researchers establish a new login session.

---

## Researcher Module Search Path

The configuration was validated from the `dev` account using:

```bash
module use
```

The resulting module search path included:

```text
/opt/modulefiles
/etc/environment-modules/modules
/usr/share/modules/versions
/usr/share/modules/modulefiles
```

This confirmed that the centrally managed bioinformatics repository was available to the researcher.

---

# Modulefile Organization

Version-specific modulefiles were organized as:

```text
/opt/modulefiles/
├── fastqc/
│   └── 0.12.1
├── multiqc/
│   └── 1.21
├── samtools/
│   └── 1.22.1
└── star/
    └── 2.7.11b
```

This structure allows additional versions to be added later without replacing existing versions.

For example:

```text
/opt/modulefiles/star/
├── 2.7.11b
└── <future-version>
```

---

# FastQC

## What Is FastQC?

FastQC evaluates the quality characteristics of sequencing reads.

It generates reports containing metrics such as:

* per-base sequence quality;
* sequence-quality distributions;
* GC content;
* sequence duplication;
* adapter content;
* overrepresented sequences.

FastQC will provide the initial quality-control assessment of the RNA-seq FASTQ files.

## Installed Version

The installed executable was verified with:

```bash
which fastqc
fastqc --version
```

Version:

```text
FastQC v0.12.1
```

A versioned modulefile was created at:

```text
/opt/modulefiles/fastqc/0.12.1
```

Researchers can load it using:

```bash
module load fastqc/0.12.1
```

---

# MultiQC

## What Is MultiQC?

MultiQC aggregates results from multiple bioinformatics tools and samples into a single report.

For RNA-seq quality control, individual FastQC analyses can produce many separate HTML and ZIP files.

Instead of reviewing every report individually:

```text
sample1_fastqc.html
sample2_fastqc.html
sample3_fastqc.html
...
```

MultiQC summarizes the results into a consolidated report:

```text
multiqc_report.html
```

This makes it easier to compare sequencing quality across an entire experiment.

## Installed Version

The executable was verified with:

```bash
which multiqc
multiqc --version
```

Actual installation:

```text
/usr/bin/multiqc
multiqc, version 1.21
```

The corresponding modulefile was created at:

```text
/opt/modulefiles/multiqc/1.21
```

It can be loaded with:

```bash
module load multiqc/1.21
```

---

# STAR

## What Is STAR?

STAR (**Spliced Transcripts Alignment to a Reference**) is a read aligner designed for RNA-seq data.

RNA-seq reads frequently span exon-exon junctions. STAR performs splice-aware alignment against a reference genome and can identify these junction-spanning reads.

Conceptually:

```text
Paired-end FASTQ
       │
       ▼
      STAR
       │
       ├── reference genome
       ├── genome index
       └── gene annotation
       │
       ▼
Aligned reads
```

STAR will provide the alignment stage of the RNA-seq pipeline.

## Installed Version

STAR was verified using:

```bash
which STAR
STAR --version
```

Actual installation:

```text
/usr/bin/STAR
2.7.11b
```

The corresponding modulefile was created at:

```text
/opt/modulefiles/star/2.7.11b
```

It can be loaded with:

```bash
module load star/2.7.11b
```

---

# Samtools

## What Is Samtools?

Samtools provides command-line utilities for manipulating sequencing alignment files.

It supports formats including:

```text
SAM
BAM
CRAM
```

Typical RNA-seq operations include:

```text
alignment
    │
    ▼
SAM/BAM
    │
    ├── inspect
    ├── sort
    ├── index
    └── calculate statistics
```

Samtools therefore provides essential downstream processing and validation of alignment files.

## Installed Version

Samtools was verified with:

```bash
which samtools
samtools --version
```

Actual installation:

```text
/usr/bin/samtools
samtools 1.22.1
Using htslib 1.22.1
```

The corresponding modulefile was created at:

```text
/opt/modulefiles/samtools/1.22.1
```

It can be loaded using:

```bash
module load samtools/1.22.1
```

---

# Researcher Validation

The complete module environment was tested from:

```text
dev@hpc-login
```

The environment was first reset:

```bash
module purge
```

Available modules were then inspected:

```bash
module avail
```

The HPC returned:

```text
------------------------------- /opt/modulefiles -------------------------------

fastqc/0.12.1
multiqc/1.21
samtools/1.22.1
star/2.7.11b
```

This confirmed that all four bioinformatics applications were exposed through the central module repository.

---

# Loading Software

Researchers can explicitly load the software required for an analysis:

```bash
module load fastqc/0.12.1
module load multiqc/1.21
module load star/2.7.11b
module load samtools/1.22.1
```

Loaded modules can be inspected using:

```bash
module list
```

The environment can be reset using:

```bash
module purge
```

---

# Why Explicit Versions Matter

A reproducible workflow should identify the exact computational environment used for an analysis.

Instead of documenting:

```text
STAR was used for alignment.
```

the pipeline can record:

```text
STAR 2.7.11b was used for alignment.
```

The SLURM job itself can enforce that version:

```bash
#!/bin/bash

#SBATCH --job-name=star
#SBATCH --partition=compute

module purge
module load star/2.7.11b

STAR ...
```

This makes the software requirement part of the executable workflow rather than relying only on documentation.

---

# Integration with SLURM

Environment Modules and SLURM serve different but complementary purposes.

```text
Environment Modules
        │
        └── Which software/version?
                    │
                    ▼
                 SLURM
                    │
                    └── Which compute resources?
                                │
                                ▼
                              Job
```

For example:

```bash
#!/bin/bash

#SBATCH --job-name=fastqc
#SBATCH --partition=compute
#SBATCH --cpus-per-task=2
#SBATCH --mem=2G
#SBATCH --time=01:00:00

module purge
module load fastqc/0.12.1

fastqc ...
```

The module declaration defines the software environment.

The `#SBATCH` directives define the computational resources.

Together they make the job more portable and reproducible.

---

# RNA-Seq Software Environment

The current RNA-seq software stack is:

```text
Raw FASTQ
    │
    ▼
FastQC 0.12.1
    │
    ▼
MultiQC 1.21
    │
    ▼
STAR 2.7.11b
    │
    ▼
SAM/BAM
    │
    ▼
Samtools 1.22.1
```

Additional tools will be added as required by subsequent pipeline stages rather than installing an unnecessarily large software stack in advance.

---

# Administrator vs Researcher Responsibilities

The environment maintains a clear separation of responsibilities.

```text
hpcadmin
│
├── install system software
├── configure module repositories
├── create modulefiles
└── maintain HPC infrastructure

dev
│
├── inspect available modules
├── load required versions
├── prepare analysis scripts
├── submit SLURM jobs
└── inspect results
```

This preserves the non-administrative researcher model established during the HPC deployment.

---

# Outcome

A centralized, versioned bioinformatics software environment was successfully deployed and validated.

The HPC now provides:

* Environment Modules;
* a dedicated `/opt/modulefiles` repository;
* automatic module-path configuration;
* administrator-managed bioinformatics software;
* version-specific modulefiles;
* researcher-level software selection;
* FastQC 0.12.1;
* MultiQC 1.21;
* STAR 2.7.11b;
* Samtools 1.22.1;
* integration with the SLURM job-submission workflow.

The infrastructure now supports the execution model:

```text
Ubuntu Workstation
        │
        │ SSH
        ▼
dev@hpc-login
        │
        ├── module load
        │       │
        │       └── select software/version
        │
        └── sbatch
                │
                └── request compute resources
                        │
                        ▼
                      SLURM
                        │
                        ▼
                 RNA-seq analysis
```

This establishes the software-management layer required for reproducible, scheduler-controlled RNA-seq processing on the simulated HPC environment.
