# Docker and Reproducible Bioinformatics Environments

## Overview

A reproducible bioinformatics analysis depends on more than the data and
scripts. It also depends on the **software versions and dependencies** used to
run the analysis.

Docker addresses this by packaging software and its dependencies into a
reusable **Docker image**.

For example:

```text
MultiQC 1.35 image
=
Linux environment
+ Python
+ MultiQC 1.35
+ required dependencies
```

When an image is run, Docker creates a **container** that executes the analysis:

```text
Docker image
    ↓
Docker container
    ↓
analysis command
    ↓
results
```

The **image** defines the reusable software environment. The **container** is
the running instance of that environment.

This allows the same software environment to be recreated on another
compatible system without manually reinstalling each tool and its dependencies.

---

## What Docker Stores

Docker images contain the **software environment**, not the entire RNA-seq
project.

The main project components remain separate:

```text
GitHub repository
    ↓
workflow + scripts + configuration + documentation

Data storage
    ↓
FASTQ + BAM + reference files

Container registry
    ↓
versioned Docker images

Results
    ↓
analysis outputs + Quarto report
```

FASTQ files therefore do **not** need to be stored in the same directory as a
Docker image. Docker manages images separately from the project data.

When an analysis runs, the required files are made available to the container,
and the resulting outputs are written back to the host filesystem.

---

## Reproducing the Analysis on Another System

Docker provides the **software environment** needed for reproducibility, while
the remaining analysis components are maintained separately.

A reproducible computational analysis combines:

```text
input data
+ reference files
+ sample metadata
+ analysis scripts
+ parameters
+ Nextflow workflow
+ versioned Docker images
```

On another compatible system, the analysis can therefore be recreated by:

```text
Clone the GitHub repository
        ↓
Provide the sequencing and reference data
        ↓
Use the same container images
        ↓
Run the Nextflow workflow
        ↓
Generate the analysis results
```

The Docker images usually do not need to be copied manually. Their names and
versions are recorded in the workflow and can be pulled from the container
registry when needed.

---

## How Data Reach the Container

Project data can remain anywhere accessible to the system running the
workflow.

For example:

```text
project/
├── workflow/
├── scripts/
├── report/
└── results/

data/
├── Sample1_R1.fastq.gz
├── Sample1_R2.fastq.gz
├── Sample2_R1.fastq.gz
└── Sample2_R2.fastq.gz

reference/
├── genome.fa
└── annotation.gtf
```

When Docker is run manually, a host directory can be mounted into the
container:

```bash
docker run --rm \
    -v /host/project:/data \
    <image> \
    <command>
```

This makes the files accessible inside the container:

```text
Host files
    ↓
Docker mount
    ↓
Container
    ↓
Bioinformatics tool
    ↓
Results written to host
```

When Docker is used through Nextflow, Nextflow handles much of the file staging
and container execution automatically.

---

## Docker in the RNA-Seq Workflow

The workflow uses versioned containers for bioinformatics tools such as:

| Software | Version |
|---|---:|
| FastQC | 0.12.1 |
| MultiQC | 1.35 |
| SAMtools | 1.22.1 |
| RSeQC | 5.0.3 |
| Subread / featureCounts | 2.0.6 |

Container images are defined in the Nextflow workflow.

For example:

```groovy
process MULTIQC {

    container 'quay.io/biocontainers/multiqc:1.35--pyhdfd78af_0'

    ...
}
```

When this process runs:

```text
QC files
    ↓
Nextflow
    ↓
MultiQC 1.35 container
    ↓
MultiQC analysis
    ↓
multiqc_report.html
```

The analysis therefore uses the specified software environment rather than
depending on whichever version happens to be installed on the host.

---

## Why Container Versions Are Pinned

The workflow uses explicit image versions such as:

```text
fastqc:0.12.1--hdfd78af_0
multiqc:1.35--pyhdfd78af_0
samtools:1.22.1--h96c455f_0
rseqc:5.0.3--py39hf95cd2a_0
subread:2.0.6--he4a0461_0
```

Version pinning records the software environment used for the analysis and
prevents a later run from unintentionally using a different tool version.

```text
version-controlled workflow
        +
version-pinned software
        +
same analysis inputs
        ↓
reproducible execution
```

---

## Testing a Docker Image

A container can be tested independently before running the complete workflow.

For example:

```bash
docker run --rm \
    quay.io/biocontainers/multiqc:1.35--pyhdfd78af_0 \
    multiqc --version
```

Expected output:

```text
multiqc, version 1.35
```

The same approach can be used for other tools:

```bash
docker run --rm \
    <image> \
    <tool> --version
```

This verifies that the image starts successfully and contains the expected
software version.

---

## Docker and Nextflow

Docker and Nextflow have different but complementary roles.

**Nextflow** manages:

- process execution
- input and output files
- dependencies between analysis stages
- workflow automation

**Docker** provides:

- software
- software versions
- required dependencies
- isolated execution environments

Together:

```text
Input data
    ↓
Nextflow process
    ↓
Docker container
    ↓
analysis tool
    ↓
output
    ↓
next Nextflow process
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

Nextflow determines **what should run and when**, while Docker provides the
environment in which `samtools` runs.

---

## Containerized STAR Alignment

STAR alignment is also executed in a containerized Linux environment.

The STAR container configuration is stored under:

```text
containers/star/
```

and documented in:

[`10-star-alignment.md`](10-star-alignment.md)

The resulting coordinate-sorted BAM files can then be used by downstream
analysis:

```text
Paired-end FASTQ
       ↓
containerized STAR
       ↓
coordinate-sorted BAM
       ↓
downstream RNA-seq workflow
```

This keeps the STAR software environment reproducible while allowing its
alignment outputs to be used by subsequent analysis stages.

---

## Apple Silicon and Container Architecture

The project is designed to run in containerized environments even when the host
and container use different processor architectures.

Common Docker image architectures include:

```text
linux/arm64
linux/amd64
```

For example:

```text
Apple Silicon host
      ARM64
        ↓
      Docker
        ↓
linux/amd64 image
        ↓
container execution
```

Docker can use emulation when a compatible native image is unavailable,
although native images may provide better performance.

The container should therefore be tested on the target system before running a
large analysis.

---

## Docker and HPC

Docker is commonly used on workstations and container-enabled systems, while
institutional HPC clusters may manage software through **Environment Modules**
or another supported container runtime.

For example, an HPC environment may provide:

```bash
module load multiqc/1.35
```

while a Docker environment can use:

```text
quay.io/biocontainers/multiqc:1.35--pyhdfd78af_0
```

Both approaches make the software version explicit.

| Docker | Environment Modules |
|---|---|
| Packages software and dependencies | Uses software installed on the HPC system |
| Provides an isolated environment | Configures the current shell environment |
| Uses versioned images | Uses versioned module files |
| Common on container-enabled systems | Common on institutional HPC systems |

Keeping the workflow separate from the software environment makes it easier to
run the same analysis across different computing infrastructures.

---

## Troubleshooting

Check that Docker is available and running:

```bash
docker --version
docker info
```

Test whether an image can be obtained:

```bash
docker pull <image>
```

Verify the software inside an image:

```bash
docker run --rm \
    <image> \
    <tool> --version
```

If a container works manually but fails in Nextflow, inspect the failed task:

```bash
cat work/<task-id>/.command.sh
cat work/<task-id>/.command.err
cat work/<task-id>/.command.out
```

Common causes include incorrect input paths, file permissions, container
versions, or workflow configuration.

---

## Reproducibility Model

Docker forms one layer of the project's overall reproducibility strategy:

```text
Raw sequencing data
        +
Reference files
        +
Sample metadata
        +
Analysis scripts and parameters
        +
Nextflow workflow
        +
Version-pinned Docker images
        ↓
Reproducible computational analysis
```

Each component has a defined role:

```text
GitHub
    → code, workflow, configuration, documentation

Data storage
    → sequencing and reference data

Container registry
    → reproducible software environments

Nextflow
    → workflow orchestration

Quarto
    → results and scientific reporting
```

This separation allows the workflow, data, and software environments to be
managed independently while still being brought together to reproduce the
analysis.
