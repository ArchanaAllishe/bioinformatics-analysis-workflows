# Reproducible Genomic & Biomedical Data Analysis Platform

A reproducible computational platform for genomic and biomedical data analysis, demonstrated through an end-to-end **RNA-seq workflow** and designed for extension to **ChIP-seq, ATAC-seq, Exome-seq/WES, WGS, multi-omics, and other sequencing applications**.

![Project Architecture](docs/images/project-architecture.png)

## Skills Demonstrated

**Bioinformatics:** RNA-seq, NGS, FASTQ, FastQC, MultiQC, HISAT2, STAR, Samtools, featureCounts, DESeq2, GRCh38, GTF annotations, differential expression

**Linux & HPC:** Ubuntu, SSH, Linux users/groups, permissions, shared storage, Environment Modules, SLURM, batch computing, resource management

**Programming & Data:** Python, R, Bash, SQL, PostgreSQL

**Workflow Engineering:** Git, GitHub, Nextflow, Docker, workflow automation, containerization, reproducible computing

**Research Software & AI:** HTML reporting, APIs, LLMs, RAG, Text-to-SQL, natural-language data exploration

---

## Project at a Glance

```text
Development Environment
        │
        ▼
Ubuntu Workstation
        │
        │ SSH
        ▼
HPC Environment
        │
        │ SLURM
        ▼
Genomic Data Analysis
        │
        ├── RNA-Seq       ← current demonstration
        ├── ChIP-Seq      ← planned
        ├── ATAC-Seq      ← planned
        ├── Exome / WES   ← planned
        └── WGS           ← planned
        │
        ▼
Reproducible Results
        │
        ▼
Nextflow + Docker
        │
        ▼
PostgreSQL
        │
        ▼
AI-Assisted Data Exploration
```

## Current Status

| Component | Status |
|---|---|
| Ubuntu workstation | Complete |
| HPC environment | Complete |
| SSH and account provisioning | Complete |
| Shared research storage | Complete |
| SLURM workload management | Complete |
| Environment Modules | Complete |
| RNA-seq workflow design | Complete |
| RNA-seq dataset validation | Next |
| RNA-seq analysis | Planned |
| HTML results reporting | Planned |
| Nextflow automation | Planned |
| Docker containerization | Planned |
| Additional genomic workflows | Planned |
| PostgreSQL results layer | Planned |
| AI-assisted interface | Planned |

---

# Project Overview

Modern genomic analysis requires more than running individual bioinformatics tools.

A reproducible research-computing workflow must integrate:

- scientific data;
- Linux computing;
- software environments;
- computational resources;
- workflow execution;
- statistical analysis;
- quality control;
- reporting;
- version control;
- reproducibility.

This project builds those components as a unified analysis platform.

**RNA-seq serves as the first end-to-end demonstration workflow.**

The same infrastructure and software-engineering principles are designed to support additional genomic assays, with analysis tools selected according to the biological and computational requirements of each data type.

```text
RNA-Seq
ChIP-Seq
ATAC-Seq
Exome-Seq / WES
WGS
Multi-Omics
Other NGS Workflows
```

---

# Platform Architecture

The platform separates development, remote computing, analysis, reporting, and future data-access layers.

```text
                    macOS Host
                        │
                        ▼
                Ubuntu Workstation
                        │
                        │ SSH
                        ▼
                  HPC Environment
                        │
             ┌──────────┼──────────┐
             ▼          ▼          ▼
           SLURM     Modules    Shared Data
             │          │          │
             └──────────┼──────────┘
                        ▼
                Genomic Analysis
                        │
                        ▼
               Results & Reporting
                        │
                        ▼
               Nextflow + Docker
                        │
                        ▼
                  PostgreSQL
                        │
                        ▼
              AI-Assisted Exploration
```

---

# Development Environment

The platform is hosted on an **Apple M5 Pro MacBook Pro with 24 GB memory and macOS Tahoe 26.6**, using UTM virtualization for the Linux environments.

Two Linux systems represent the development-to-compute workflow commonly used in research computing:

```text
Ubuntu Workstation
        │
        │ SSH
        ▼
HPC Environment
        │
        │ SLURM
        ▼
Scheduled Analysis
```

The **Ubuntu workstation** provides the development and access environment.

The **HPC environment** provides shared storage, centrally managed software, resource allocation, and scheduled computation.

This separation reproduces the workflow:

```text
Develop
   ↓
Connect
   ↓
Submit
   ↓
Schedule
   ↓
Compute
   ↓
Review Results
```

---

## Ubuntu Workstation

The workstation is used for:

- script development;
- Python, R, and Bash programming;
- Git/GitHub;
- documentation;
- SSH access;
- job submission;
- result inspection.

### Configuration

```text
Ubuntu 26.04 LTS
Architecture: aarch64
CPUs: 6
Memory: ~11 GiB
Swap: 4 GiB
Root filesystem: 146 GB
```

---

## HPC Environment

A separate Ubuntu Server VM provides an HPC-style research-computing environment.

It is used to demonstrate:

- remote Linux access;
- administrator and researcher accounts;
- SSH authentication;
- shared research storage;
- Linux groups and permissions;
- Environment Modules;
- SLURM scheduling;
- CPU and memory allocation;
- batch-job execution.

### Configuration

```text
Hostname: hpc-login
Ubuntu Server 26.04 LTS
Architecture: aarch64
CPUs: 4
Memory: 6 GB
Virtual disk: 64 GB
```

This environment is locally deployed for development and portfolio demonstration while reproducing the core workflow of an institutional HPC system.

---

# HPC User Roles

Two account roles separate system administration from research computing.

```text
hpcadmin
    │
    └── system administration

dev
    │
    └── research computing
```

The `hpcadmin` account manages:

- system configuration;
- user/group administration;
- software installation;
- shared storage;
- Environment Modules;
- SLURM configuration.

The `dev` account performs:

- project analysis;
- software-module loading;
- SLURM job submission;
- data processing;
- result inspection.

This keeps routine research work separate from administrative privileges.

---

# SSH Access

SSH key authentication provides workstation-to-HPC access.

```text
Ubuntu Workstation
       │
       │ SSH
       ▼
dev@hpc-login
```

The configured SSH alias allows connection with:

```bash
ssh hpc-login
```

This reproduces a typical researcher workflow in which analysis is prepared locally and computational jobs are submitted remotely.

---

# Shared Research Storage

The HPC environment uses dedicated shared directories:

```text
/shared/
├── data/
├── projects/
└── reference/
```

Their roles are:

```text
/shared/data
    → sequencing datasets

/shared/projects
    → project scripts, logs, metadata, and results

/shared/reference
    → genomes, annotations, and indexes
```

The current RNA-seq demonstration workspace is:

```text
/shared/projects/reproducible-rnaseq-pipeline/
```

A Linux group named:

```text
bioinformatics
```

provides controlled collaborative access to shared project directories.

Large FASTQ, BAM, reference, and index files are kept outside the Git repository.

---

# SLURM Workload Management

SLURM manages computational workloads in the HPC environment.

Current configuration:

```text
Cluster: local-hpc
Partition: compute
Node: hpc-login
CPUs: 4
RealMemory: 5386 MB
```

A test SLURM job successfully validated:

- job submission;
- scheduler execution;
- CPU allocation;
- memory requests;
- SLURM environment variables;
- job IDs;
- output-file generation.

Example:

```bash
sbatch hello-hpc.sh
```

Validated output:

```text
Hello from SLURM
User: dev
Host: hpc-login
Job ID: 1
CPUs: 1
```

The computational model is:

```text
Researcher
    │
    │ sbatch
    ▼
  SLURM
    │
    ▼
Resource Allocation
    │
    ▼
Scheduled Analysis
    │
    ▼
Results
```

Detailed implementation:

```text
docs/05-slurm-workload-management.md
```

---

# Environment Modules

Bioinformatics software is centrally managed using Environment Modules.

Module location:

```text
/opt/modulefiles
```

Currently configured modules include:

```text
fastqc/0.12.1
multiqc/1.21
samtools/1.22.1
star/2.7.11b
```

Example:

```bash
module purge
module load fastqc/0.12.1
```

Environment Modules provide:

- explicit software versions;
- reproducible environments;
- reduced dependency conflicts;
- centralized software management;
- straightforward SLURM integration.

Additional tools will be added as workflow requirements expand.

Detailed implementation:

```text
docs/06-environment-modules.md
```

---

# Demonstration Workflow: RNA-Seq

RNA-seq is the first complete genomic workflow being implemented on the platform.

It demonstrates the progression from raw sequencing data to statistical analysis and biological interpretation.

```text
Public RNA-Seq Dataset
        │
        ▼
Sample Metadata
        │
        ▼
Paired-End FASTQ
        │
        ▼
FastQC
        │
        ▼
MultiQC
        │
        ▼
HISAT2 + GRCh38
        │
        ▼
Samtools
        │
        ▼
Sorted / Indexed BAM
        │
        ▼
featureCounts
        │
        ▼
Raw Gene Counts
        │
        ▼
DESeq2
        │
        ├── Normalization
        ├── Sample QC
        ├── PCA
        ├── Differential Expression
        └── Visualization
        │
        ▼
Biological Interpretation
        │
        ▼
HTML Report
```

---

# RNA-Seq Alignment Strategy

RNA-seq requires splice-aware alignment because sequencing reads may span exon-exon junctions.

Several commonly used approaches were evaluated:

| Tool | Approach | Typical Application | Relative Memory |
|---|---|---|---|
| STAR | Splice-aware genome alignment | RNA-seq | High |
| HISAT2 | Splice-aware genome alignment | RNA-seq | Lower |
| Salmon | Transcript quantification | RNA-seq | Lower |
| kallisto | Transcript quantification | RNA-seq | Lower |
| Bowtie2 | Genome alignment | ChIP-seq / ATAC-seq | Lower |
| BWA | Genome alignment | WES / WGS | Lower |

## Selected RNA-Seq Aligner: HISAT2

HISAT2 was selected for the initial RNA-seq implementation because it provides:

```text
Splice-aware alignment       ✓
Paired-end support           ✓
Human genome alignment       ✓
SAM/BAM workflow             ✓
Samtools compatibility       ✓
featureCounts compatibility  ✓
Lower memory requirement     ✓
```

The selected workflow is:

```text
FASTQ
  ↓
HISAT2
  ↓
Samtools
  ↓
Sorted BAM
  ↓
featureCounts
```

STAR remains available in the HPC software environment as an alternative for higher-memory systems or workflows where its performance characteristics are preferred.

Detailed evaluation:

```text
docs/07-rnaseq-alignment-tools-and-workflow-selection.md
```

---

# RNA-Seq Reference Genome

The planned reference configuration is:

```text
Genome:      GRCh38
Aligner:     HISAT2
Index:       Prebuilt GRCh38 HISAT2 index
Annotation:  Compatible GTF annotation
```

The exact reference genome and annotation releases will be recorded before analysis.

Genome and annotation compatibility will be verified before gene quantification.

---

# RNA-Seq Demonstration Dataset

The project is currently evaluating the RNA-seq component associated with:

```text
GSE199679
```

Before downloading raw sequencing files, the study will be validated for:

- sample identities;
- experimental groups;
- biological replicates;
- SRA run accessions;
- paired-end sequencing layout;
- read lengths;
- FASTQ sizes;
- total storage requirements.

The dataset will be finalized after the experimental design and computational requirements are confirmed.

---

# Raw Read Quality Control

FastQC will evaluate raw sequencing data for metrics including:

- per-base sequence quality;
- sequence quality distribution;
- GC content;
- sequence duplication;
- adapter content;
- overrepresented sequences.

MultiQC will aggregate individual QC reports.

```text
Sample 1 FastQC ──┐
Sample 2 FastQC ──┤
Sample 3 FastQC ──┤
                  ├── MultiQC
Sample N FastQC ──┘
                       │
                       ▼
                Combined QC Report
```

---

# Alignment Processing

HISAT2 alignment output will be processed with Samtools.

```text
HISAT2
   ↓
SAM
   ↓
Samtools
   ↓
BAM
   ↓
Sort
   ↓
Index
   ↓
Alignment QC
```

Intermediate files will be managed to minimize unnecessary disk usage.

---

# Gene Quantification

featureCounts will assign aligned fragments to annotated genes.

```text
Sorted BAM
    +
GTF Annotation
      │
      ▼
featureCounts
      │
      ├── counts.txt
      └── counts.txt.summary
```

For paired-end RNA-seq, paired reads will be counted as fragments where appropriate.

Raw integer counts will be retained for DESeq2.

---

# Sample Metadata

Sample metadata will describe the experimental design.

Example:

```text
sample       condition
sample_01    control
sample_02    control
sample_03    treatment
sample_04    treatment
```

Additional study-specific variables may include:

- biological replicate;
- treatment;
- cell type;
- batch;
- genotype;
- other experimental factors.

Sample identifiers must correspond to count-matrix sample columns.

---

# Differential Expression Analysis

DESeq2 will be used for statistical analysis of gene-level counts.

The workflow will include:

- raw count import;
- metadata integration;
- normalization;
- sample-level QC;
- PCA;
- clustering;
- differential-expression testing;
- multiple-testing correction;
- visualization.

Planned outputs include:

```text
PCA
Sample correlations
MA plots
Volcano plots
Heatmaps
Differential-expression tables
Functional / pathway analysis
```

Raw featureCounts values will be provided directly to DESeq2 rather than pre-normalized TPM or FPKM values.

---

# Results & Reporting

A major platform goal is to transform computational outputs into **researcher-facing results**.

The RNA-seq analysis will generate a browser-accessible HTML report containing:

- study description;
- experimental design;
- sample metadata;
- sequencing information;
- FastQC/MultiQC results;
- alignment statistics;
- featureCounts statistics;
- expression-level QC;
- PCA;
- differential-expression results;
- volcano and MA plots;
- heatmaps;
- biological interpretation;
- computational methods;
- software versions.

The intended workflow is:

```text
Analysis Outputs
       │
       ▼
Integrated Results
       │
       ▼
HTML Report
       │
       ▼
Researcher / Collaborator
```

This avoids requiring collaborators to interpret a directory of disconnected analysis files.

---

# Reproducibility

Reproducibility is incorporated throughout the platform.

The analysis will record:

- public dataset accessions;
- sample metadata;
- reference genome release;
- annotation release;
- software versions;
- command-line parameters;
- Environment Module versions;
- SLURM resource requests;
- scripts;
- quality-control results;
- statistical-analysis code.

Git and GitHub are used for source code, configuration, and documentation.

Large scientific data remain outside the Git repository.

---

# Workflow Automation with Nextflow

After the individual RNA-seq stages are validated, the workflow will be converted into a Nextflow pipeline.

```text
                 Nextflow
                    │
       ┌────────────┼────────────┐
       ▼            ▼            ▼
      QC        Alignment    Processing
       │            │            │
       └────────────┼────────────┘
                    ▼
               Quantification
                    │
                    ▼
             Statistical Analysis
                    │
                    ▼
                  Report
```

Nextflow will provide:

- workflow orchestration;
- automated file passing;
- dependency handling;
- parallel sample processing;
- workflow resumption;
- reproducible configuration;
- local execution;
- SLURM execution.

Planned execution profiles:

```bash
nextflow run main.nf -profile local
```

and:

```bash
nextflow run main.nf -profile slurm
```

---

# Containerization with Docker

Docker will provide portable and version-controlled software environments.

The platform will demonstrate two complementary approaches:

```text
Institutional-Style HPC
        │
        ▼
Environment Modules
```

and:

```text
Portable Workflow
        │
        ▼
Docker Containers
```

The planned workflow-engineering architecture combines:

```text
Nextflow
   +
Docker
   +
SLURM
```

This separates workflow logic from the underlying software and compute environment.

---

# Extending the Platform

The infrastructure is designed to support additional genomic workflows after the RNA-seq implementation is validated.

## ChIP-Seq

Planned workflow:

```text
FASTQ
  ↓
Quality Control
  ↓
Alignment
  ↓
BAM Processing
  ↓
Peak Calling
  ↓
Peak Annotation
  ↓
Motif / Functional Analysis
  ↓
HTML Report
```

Potential tools include Bowtie2, Samtools, peak-calling software, genomic annotation tools, and downstream enrichment analysis.

---

## ATAC-Seq

Planned workflow:

```text
FASTQ
  ↓
Quality Control
  ↓
Alignment
  ↓
Filtering
  ↓
Peak Calling
  ↓
Chromatin Accessibility
  ↓
Regulatory Analysis
  ↓
HTML Report
```

This workflow will demonstrate chromatin-accessibility and regulatory-element analysis.

---

## Exome-Seq / WES

Planned workflow:

```text
FASTQ
  ↓
Quality Control
  ↓
Genome Alignment
  ↓
BAM Processing
  ↓
Variant Calling
  ↓
Variant Filtering
  ↓
Annotation
  ↓
Interpretation
```

This workflow will demonstrate coding-region variant analysis.

---

## Whole-Genome Sequencing

The platform can later support WGS analysis including:

- genome alignment;
- BAM processing;
- variant calling;
- variant filtering;
- annotation;
- genomic interpretation;
- reproducible reporting.

---

## Multi-Omics Integration

Once multiple workflows are implemented, the platform can be extended toward integrative analyses such as:

```text
RNA-Seq
   │
   ├──────────────┐
   ▼              │
Expression        │
                  │
ChIP-Seq ─────────┤
                  │
ATAC-Seq ─────────┤
                  │
WES / WGS ────────┤
                  ▼
           Integrated Analysis
                  │
                  ▼
          Biological Insights
```

---

# Structured Results with PostgreSQL

Processed results will eventually be organized in PostgreSQL.

RNA-seq tables may include:

```text
samples
genes
gene_counts
differential_expression
pathway_results
qc_metrics
```

Additional genomic workflows can introduce tables such as:

```text
variants
peaks
genomic_regions
annotations
motifs
accessibility_results
```

This provides a common structured results layer across different analysis types.

---

# AI-Assisted Data Exploration

A future platform layer will provide natural-language access to processed research data.

```text
Researcher
     │
     ▼
Natural-Language Question
     │
     ▼
LLM Interface
     │
 ┌───┴─────────┐
 ▼             ▼
RAG        Text-to-SQL
 │             │
 ▼             ▼
Project     PostgreSQL
Knowledge    Results
 │             │
 └──────┬──────┘
        ▼
 Insights & Answers
```

## AI-Assisted Chat Interface

Example RNA-seq questions:

```text
Which genes are significantly upregulated?

Show genes with adjusted p-value < 0.05 and log2 fold change > 2.

Which pathways are enriched?

Which samples had QC issues?
```

Future genomic workflows could support questions such as:

```text
Which genes are associated with the strongest ChIP-seq peaks?

Which regulatory regions show increased ATAC-seq accessibility?

Which high-impact coding variants were detected in the exome data?
```

Planned technologies:

```text
Python
PostgreSQL
SQL
APIs
LLMs
RAG
Text-to-SQL
```

The AI layer will operate on validated computational results rather than replace the underlying bioinformatics analysis.

---

# Future Clinical Research Data Adaptation

The same data-access architecture can later be adapted to appropriately governed clinical research datasets.

## AI-Assisted Chat Interface for Clinical Research Data

**Concept:** Researchers frequently depend on data analysts to retrieve information from complex structured datasets. A conversational interface using RAG and Text-to-SQL could allow authorized users to query appropriate research datasets using natural language.

Potential benefits include:

- self-service data exploration;
- reduced repetitive analyst requests;
- shorter query turnaround time;
- faster hypothesis generation;
- improved access to research-data resources.

Any clinical implementation would require appropriate authorization, privacy protection, governance, validation, auditing, and institutional security controls.

---

# Platform Evolution

```text
Research Computing Infrastructure
              │
              ▼
      RNA-Seq Demonstration
              │
              ▼
      Reproducible Reporting
              │
              ▼
       Nextflow Automation
              │
              ▼
     Docker Containerization
              │
              ▼
   Additional Genomic Workflows
      ┌───────┼───────┬────────┐
      ▼       ▼       ▼        ▼
   ChIP-Seq ATAC-Seq WES      WGS
      └───────┼───────┴────────┘
              ▼
      Multi-Omics Integration
              │
              ▼
    Structured Results Database
              │
              ▼
    AI-Assisted Data Exploration
```

---

# Repository Organization

The planned repository structure separates documentation, scripts, configuration, workflows, containers, metadata, and lightweight results.

```text
reproducible-rnaseq-pipeline/
│
├── README.md
├── LICENSE
├── .gitignore
│
├── docs/
│   └── images/
│       └── project-architecture.png
│
├── scripts/
├── config/
├── workflow/
├── containers/
├── metadata/
├── results/
└── report/
```

Large FASTQ, BAM, reference genome, index, and workflow working files are excluded from Git.

---

# Project Roadmap

## Phase 1 — Research Computing Infrastructure

- [x] Ubuntu workstation
- [x] HPC environment
- [x] SSH authentication
- [x] Linux users and groups
- [x] Shared research storage
- [x] SLURM workload management
- [x] Environment Modules
- [x] Bioinformatics software environment

## Phase 2 — RNA-Seq Demonstration

- [x] RNA-seq workflow design
- [x] Aligner evaluation
- [x] HISAT2 workflow selection
- [ ] Dataset validation and acquisition
- [ ] Raw-read quality control
- [ ] HISAT2 alignment
- [ ] Alignment processing and QC
- [ ] Gene quantification
- [ ] Differential-expression analysis
- [ ] Biological interpretation
- [ ] HTML results report

## Phase 3 — Workflow Engineering

- [ ] Nextflow pipeline
- [ ] Docker containerization
- [ ] Local execution profile
- [ ] SLURM execution profile
- [ ] Automated reporting
- [ ] Reproducibility testing

## Phase 4 — Additional Genomic Workflows

- [ ] ChIP-seq workflow
- [ ] ATAC-seq workflow
- [ ] Exome-seq / WES workflow
- [ ] WGS workflow
- [ ] Multi-omics integration

## Phase 5 — Research Data Platform

- [ ] PostgreSQL results database
- [ ] Results API
- [ ] AI-assisted data interface
- [ ] RAG integration
- [ ] Text-to-SQL
- [ ] Validation and query auditing

---

# Documentation

Detailed implementation documentation is maintained in:

```text
docs/
```

Current documentation includes:

```text
01 — Ubuntu Environment
02 — Shared Project Workspace
03 — Git and Version Control
04 — HPC Environment Deployment
05 — SLURM Workload Management
06 — Environment Modules and Bioinformatics Software Management
07 — RNA-Seq Alignment Tools and Workflow Selection
```

The README provides the high-level platform overview.

Detailed commands, implementation decisions, validation, and troubleshooting are maintained in the corresponding documentation.

---
```

## Current Focus

**RNA-seq is the first end-to-end demonstration of the platform.**

The next stage is to validate and acquire the selected public RNA-seq dataset and execute the workflow from raw FASTQ files through quality control, alignment, quantification, differential-expression analysis, biological interpretation, and reproducible reporting.

The same computing, workflow-engineering, and reporting framework will subsequently be extended to additional genomic data types.

---

# License

See the `LICENSE` file for licensing information.