# Docker and Reproducible Bioinformatics Environments

## Overview

Docker helps make bioinformatics analyses more reproducible by packaging
software and its dependencies into a reusable **Docker image**.

A Docker image can be used on another compatible system with Docker installed,
so the same software environment can be recreated without manually
reinstalling every tool and dependency.

When an image is run, Docker creates a temporary **container** that executes
the analysis.

```text
Docker image
    ↓
reusable software environment
    ↓
Docker container
    ↓
runs the analysis
    ↓
results
```

The sequencing data are usually **not stored inside the image**. FASTQ, BAM,
reference, and result files remain outside the container and are made available
to it when the analysis runs.

Reproducibility therefore comes from combining:

```text
same input data
+ same analysis scripts
+ same parameters
+ same reference files
+ same Docker image
```

Docker mainly solves the **software environment** part of this problem.

---

## Why Docker Was Used

Bioinformatics tools often depend on specific software versions, Python or R
packages, system libraries, and operating-system components.

Installing the same tool manually on different computers can therefore lead to
different environments or dependency conflicts.

Docker provides a controlled Linux-based environment that can be reused across
systems.

In this project, Docker helps to:

- preserve specific bioinformatics software versions
- package tools together with their dependencies
- reduce installation and dependency conflicts
- provide consistent Linux-based execution
- support analysis on an Apple Silicon host
- integrate software environments with Nextflow
- make the workflow easier to reproduce on another system

---

## Docker Image vs. Container

The two terms are related but different.

### Docker image

A **Docker image** is the reusable software package.

For example:

```text
MultiQC 1.35 image
=
Linux environment
+ Python
+ MultiQC 1.35
+ required dependencies
```

The same image can be pulled and used on another system.

### Docker container

A **container** is a running instance of the image.

```text
Docker image
     ↓ docker run
Docker container
     ↓
executes command
```

Containers are usually temporary. The analysis results are written back to the
host filesystem rather than kept only inside the container.

---

## How Docker Fits into This Project

The main project components have separate roles:

```text
Git / GitHub
    ↓
stores scripts and workflow code

Docker
    ↓
provides reproducible software environments

Nextflow
    ↓
controls process order and data flow

FASTQ / BAM / reference files
    ↓
provide analysis inputs

Quarto
    ↓
presents final results
```

A useful way to think about this is:

> **Nextflow is the recipe, Docker is the software environment, and the
> sequencing files are the input data.**

---

## Docker in the RNA-Seq Workflow

The current Nextflow workflow uses version-pinned containers for several
command-line bioinformatics tools:

| Process | Software | Version |
|---|---|---:|
| `FASTQC` | FastQC | 0.12.1 |
| `MULTIQC` | MultiQC | 1.35 |
| `SAMTOOLS_INDEX` | SAMtools | 1.22.1 |
| `RSEQC_INFER_EXPERIMENT` | RSeQC | 5.0.3 |
| `FEATURECOUNTS` | Subread / featureCounts | 2.0.6 |

The exact container images are specified in
[`workflow/main.nf`](../workflow/main.nf).

For example:

```groovy
process MULTIQC {

    container 'quay.io/biocontainers/multiqc:1.35--pyhdfd78af_0'

    ...
}
```

When this process runs, Nextflow starts the specified Docker image and executes
MultiQC inside that environment.

This means the workflow does not depend on whichever MultiQC version happens
to be installed directly on the host computer.

---

## Why Version Pinning Matters

A container should use a specific software version rather than an unspecified
or changing image tag.

For example:

```text
multiqc:1.35--pyhdfd78af_0
```

is more reproducible than relying on an unversioned image.

The project currently uses explicit BioContainers images such as:

```text
fastqc:0.12.1--hdfd78af_0
multiqc:1.35--pyhdfd78af_0
samtools:1.22.1--h96c455f_0
rseqc:5.0.3--py39hf95cd2a_0
subread:2.0.6--he4a0461_0
```

This records the software environment used by each process.

---

## Testing a Docker Image

Before using a container in the workflow, it can be tested independently.

General pattern:

```bash
docker run --rm \
    <image> \
    <tool> --version
```

For example, MultiQC 1.35 was verified with:

```bash
docker run --rm \
    quay.io/biocontainers/multiqc:1.35--pyhdfd78af_0 \
    multiqc --version
```

The container returned:

```text
multiqc, version 1.35
```

This confirms that:

```text
image starts successfully
        ↓
tool is available
        ↓
expected version is installed
```

Testing the image separately is useful when distinguishing Docker problems from
Nextflow problems.

---

## Running a Container with Project Files

Bioinformatics containers usually need access to files stored on the host
computer.

A directory can be mounted into a container with:

```bash
docker run --rm \
    -v /host/project:/data \
    <image> \
    <command>
```

Conceptually:

```text
Host
/path/to/project
        ↓
Docker mount
        ↓
/data
inside container
```

The container reads the input files from the mounted directory and writes
results back to the host filesystem.

With Nextflow, much of this file staging and container execution is handled
automatically.

---

## Docker and Nextflow

Nextflow manages **when and how a process runs**, while Docker provides the
software environment in which that process executes.

```text
Nextflow
    ↓
identifies process inputs
    ↓
starts specified Docker image
    ↓
runs analysis command
    ↓
captures process outputs
```

For example:

```groovy
process SAMTOOLS_INDEX {

    container 'quay.io/biocontainers/samtools:1.22.1--h96c455f_0'

    script:
    """
    samtools index ${bam}
    """
}
```

Here:

```text
Nextflow
    ↓
orchestration

Docker
    ↓
SAMtools environment

samtools index
    ↓
analysis command
```

This separation makes the workflow easier to maintain and reproduce.

---

## Containerized STAR Alignment

STAR alignment was also performed in a containerized Linux environment.

The STAR container setup is maintained under:

```text
containers/star/
```

and documented in:

[`10-star-alignment.md`](10-star-alignment.md)

The current downstream Nextflow workflow does **not** rerun STAR alignment.
Instead, it reuses the validated STAR BAM files.

```text
FASTQ
  ↓
containerized STAR alignment
  ↓
validated BAM files
  ↓
Nextflow downstream analysis
```

This avoids repeating the most computationally expensive upstream step.

---

## Current Containerization Scope

The current Nextflow workflow explicitly defines Docker containers for:

```text
FastQC
MultiQC
SAMtools
RSeQC
featureCounts
```

Other downstream stages currently rely on the host execution environment,
including:

```text
Python processing
DESeq2
gene annotation
PCA
correlation
DE plots
functional enrichment
Quarto rendering
```

The workflow should therefore be described as **partially containerized**, not
yet fully containerized end to end.

A future improvement is to package the remaining Python, R/Bioconductor, and
Quarto environments as well.

---

## Apple Silicon and CPU Architecture

The project was developed on an **Apple Silicon ARM64** system.

Docker images may target different architectures, commonly:

```text
linux/arm64
linux/amd64
```

When the MultiQC 1.35 image was tested, Docker reported an architecture warning
because the image was built for `linux/amd64` while the host used
`linux/arm64/v8`.

The container still executed successfully.

Conceptually:

```text
Apple Silicon host
      ARM64
        ↓
      Docker
        ↓
linux/amd64 image
        ↓
emulated execution
```

This is useful for portability, but a native ARM64 image may provide better
performance when available.

---

## Docker vs. Environment Modules

Docker and HPC Environment Modules both help manage software versions, but they
work differently.

| Docker | Environment Modules |
|---|---|
| Provides an isolated software environment | Modifies the current shell environment |
| Packages software and dependencies together | Uses software installed on the HPC system |
| Common on workstations and container-enabled systems | Common on institutional HPC systems |
| Uses versioned container images | Uses versioned module files |

For example:

```bash
module load multiqc/1.35
```

provides MultiQC through the HPC module system, while Docker can use:

```text
quay.io/biocontainers/multiqc:1.35--pyhdfd78af_0
```

Both approaches make software versions explicit.

---

## Docker and HPC

Institutional HPC systems do not always allow Docker directly on compute nodes.

In those environments, workflows may use:

```text
Environment Modules
or
an HPC-supported container runtime
```

instead.

The important point is that the **analysis workflow and software environment
remain separate concepts**.

```text
Nextflow workflow
       ↓
execution environment
   ┌───────┴─────────┐
   ↓                 ↓
Docker           HPC-supported
workstation      environment
```

This makes the workflow easier to move between different computing systems.

---

## Troubleshooting

### Docker is not running

Check:

```bash
docker --version
docker info
```

If `docker --version` succeeds but `docker info` fails, the Docker engine may
not be running.

### Image cannot be downloaded

Test:

```bash
docker pull <image>
```

Confirm that the image name and version tag are correct.

### Tool is missing inside the image

Run:

```bash
docker run --rm \
    <image> \
    <tool> --version
```

### ARM64 / AMD64 warning

A warning about `linux/amd64` and `linux/arm64` indicates a CPU architecture
difference.

If the container runs successfully, Docker is usually providing emulation.

### Container works manually but fails in Nextflow

Inspect the failed task:

```bash
cat work/<task-id>/.command.sh
cat work/<task-id>/.command.err
cat work/<task-id>/.command.out
```

Also check:

```text
input paths
file permissions
container image
software version
Nextflow configuration
```

---

## Reproducibility Strategy

Docker is one part of the overall reproducibility design:

```text
Input data
    ↓
FASTQ / BAM / reference files

Analysis logic
    ↓
Python / R / Bash

Workflow orchestration
    ↓
Nextflow

Software environment
    ↓
Docker / BioContainers

Version control
    ↓
Git / GitHub

Scientific reporting
    ↓
Quarto
```

Reproducing the analysis therefore requires more than preserving the scripts.

The goal is to retain:

```text
same data
+ same scripts
+ same parameters
+ same references
+ same software environment
```

Docker provides the **same software environment** component.



