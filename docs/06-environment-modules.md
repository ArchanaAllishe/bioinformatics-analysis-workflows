# Task 06 — Environment Modules and Bioinformatics Software Management

## Overview

Bioinformatics analyses depend on many command-line tools, often with specific
version requirements.

On shared high-performance computing (HPC) systems, users generally should not
install separate copies of commonly used software into their home directories.
Instead, administrators can provide centrally managed software through an
environment module system.

This simulated HPC environment uses **Environment Modules** to manage
bioinformatics software.

The module system allows users to load, unload, and switch between software
versions without permanently modifying their shell environment.

---

## Why Environment Modules Are Used

Different research projects may require different versions of the same software.

For example:

- one workflow may require STAR 2.7.11b;
- another may require a different STAR release;
- another project may use HISAT2 instead of STAR.

Installing every program directly into the global system PATH can make software
management difficult and may create version conflicts.

Environment Modules provide a cleaner approach.

Conceptually:

    Software installed on HPC
              ↓
        Module files
              ↓
         module load
              ↓
      User environment
              ↓
      Analysis software

This allows software to be managed centrally while users control which tools
are active in their individual sessions.

---

## Module Search Path

The module search path can be inspected using:

    module use

The configured environment includes:

    /opt/modulefiles

along with the standard system module locations.

The `/opt/modulefiles` directory is used for locally managed bioinformatics
software modules.

---

## Available Bioinformatics Modules

The following modules were configured:

    fastqc/0.12.1
    multiqc/1.21
    samtools/1.22.1
    star/2.7.11b

The available modules can be displayed using:

    module avail

Example:

    module purge
    module avail

---

## Loading Software

A module is activated using:

    module load <software>/<version>

For example:

    module load fastqc/0.12.1

The loaded software can then be verified:

    fastqc --version

Similarly:

    module load star/2.7.11b
    STAR --version

or:

    module load samtools/1.22.1
    samtools --version

---

## Removing Modules

A specific module can be unloaded using:

    module unload fastqc/0.12.1

All currently loaded modules can be removed using:

    module purge

This is useful at the beginning of batch jobs because it creates a predictable
software environment.

For example:

    module purge
    module load fastqc/0.12.1

---

## Why Module Versions Are Specified

Using:

    module load fastqc/0.12.1

instead of simply:

    module load fastqc

makes the software version explicit.

Recording exact software versions improves reproducibility because future users
can determine which program version was used to generate the results.

This is particularly important in bioinformatics because software updates may
change:

- algorithms;
- default parameters;
- file formats;
- output;
- performance.

---

## Software Available in the HPC Environment

The currently configured bioinformatics software supports several stages of
sequencing analysis.

### FastQC

FastQC evaluates the quality of raw sequencing reads.

Typical input:

    FASTQ / FASTQ.GZ

Typical output:

    HTML quality report
    ZIP results

---

### MultiQC

MultiQC collects results from multiple bioinformatics tools and generates a
single combined report.

For example:

    FastQC reports from many samples
                ↓
             MultiQC
                ↓
        Combined HTML report

This is especially useful for projects containing multiple sequencing samples.

---

### STAR

STAR is a splice-aware RNA-seq aligner.

It is available in the HPC software environment as:

    star/2.7.11b

STAR is well suited to RNA-seq alignment on systems with sufficient memory.

The presence of STAR as an HPC module does not require every RNA-seq project to
use STAR. Alignment software should be selected according to the biological
requirements and computational resources of each analysis.

The alignment strategy for this project is evaluated separately in:

    Task 07 — RNA-Seq Alignment Tools and Workflow Selection

---

### Samtools

Samtools is used to manipulate SAM and BAM alignment files.

Common operations include:

    SAM → BAM conversion
    BAM sorting
    BAM indexing
    alignment statistics

Example workflow:

    Aligner
       ↓
    SAM/BAM
       ↓
    Samtools
       ↓
    Sorted/indexed BAM

---

## Infrastructure vs Workflow Selection

An important distinction is made between **software availability** and
**workflow selection**.

Task 06 answers:

    What software is available in the HPC environment?

Task 07 answers:

    Which alignment software is appropriate for this RNA-seq analysis?

For example, STAR can remain installed and available as an HPC module even when
another aligner is selected for a particular project.

This separation reflects how real shared computational environments operate.

An HPC system may provide many bioinformatics tools, while individual projects
select only the tools appropriate for their analysis.

---

## Workflow-Specific Software

Additional software can be added as project requirements are defined.

For the RNA-seq workflow, HISAT2 will be added because it was selected as the
primary aligner after evaluating the computational requirements of the
available alignment approaches.

The module environment will therefore evolve as the analysis workflow is
implemented.

---

## Using Modules in SLURM Jobs

Environment modules can be loaded directly inside SLURM batch scripts.

For example:

    #!/bin/bash

    #SBATCH --job-name=fastqc
    #SBATCH --partition=compute
    #SBATCH --cpus-per-task=2
    #SBATCH --mem=2G

    module purge
    module load fastqc/0.12.1

    fastqc sample.fastq.gz

This ensures that the batch job runs with the intended software version.

---

## Benefits of This Design

The module-based software environment provides:

- centralized software management;
- explicit software versions;
- reduced PATH conflicts;
- reproducible computational environments;
- easier SLURM integration;
- support for multiple analysis workflows.

The resulting architecture is:

    HPC system
        │
        ▼
    /opt/modulefiles
        │
        ├── FastQC
        ├── MultiQC
        ├── STAR
        ├── Samtools
        └── additional workflow tools
                 │
                 ▼
             module load
                 │
                 ▼
             SLURM jobs

---

## Outcome

A version-controlled bioinformatics software environment was established using
Environment Modules.

FastQC, MultiQC, STAR, and Samtools are available through the module system,
providing the software-management foundation required for reproducible
sequencing workflows.

Project-specific tool selection is documented independently from infrastructure
configuration so that the HPC environment can support multiple analysis
strategies.