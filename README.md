<div align="center">

# 🧬 From Sequencing Data to Biological Insight

### A Reproducible Bioinformatics Framework Demonstrated with End-to-End RNA-Seq Analysis

**Large-Scale Data → Quality Control → Reproducible Analysis → Statistical Genomics → Biological Interpretation → Shareable Results**

<br>

[![Python](https://img.shields.io/badge/Python-Analysis-3776AB?logo=python&logoColor=white)](#technical-skills-demonstrated)
[![R](https://img.shields.io/badge/R-Bioconductor-276DC3?logo=r&logoColor=white)](#technical-skills-demonstrated)
[![Linux](https://img.shields.io/badge/Linux-Bioinformatics-FCC624?logo=linux&logoColor=black)](#technical-skills-demonstrated)
[![Bash](https://img.shields.io/badge/Shell-Bash-4EAA25?logo=gnubash&logoColor=white)](#technical-skills-demonstrated)
[![Docker](https://img.shields.io/badge/Docker-Reproducibility-2496ED?logo=docker&logoColor=white)](#reproducibility)
[![HPC](https://img.shields.io/badge/HPC-SLURM-6A5ACD)](#hpc--slurm-experience)
[![Quarto](https://img.shields.io/badge/Quarto-Interactive_Report-75AADB)](https://ArchanaAllishe.github.io/reproducible-rnaseq-pipeline/)

<br>

### 🔬 [Explore the Interactive RNA-Seq Analysis Report](https://ArchanaAllishe.github.io/reproducible-rnaseq-pipeline/)

`Python` · `R/Bioconductor` · `Bash` · `Linux` · `Docker` · `HPC/SLURM`  
`FastQC` · `MultiQC` · `STAR` · `SAMtools` · `RSeQC` · `featureCounts` · `DESeq2` · `Quarto`

</div>

---

## Overview

Modern bioinformatics requires more than running individual analysis tools.

Large-scale sequencing data must be **quality controlled, processed,
statistically analyzed, biologically interpreted, reproduced across computing
environments, and communicated clearly to researchers and collaborators**.

This project demonstrates that complete process using **bulk RNA-seq as an
end-to-end case study**.

Starting with raw paired-end FASTQ files, the project progresses through
sequencing QC, alignment, gene quantification, expression-level QC,
differential expression, functional enrichment, and biological interpretation,
ending with a publicly accessible interactive scientific report.

The project also incorporates software and infrastructure practices relevant
to modern bioinformatics, including **Python, R, Bash, Linux, Docker, Git,
HPC concepts, SLURM, environment modules, and reproducible reporting**.

---

## Technical Skills Demonstrated

| Area | Technologies & Application |
|---|---|
| **Python** | `pandas`, `scikit-learn`, `matplotlib`, `pathlib`, `re` — count processing, QC, filtering, normalization, PCA, sample correlation, gene annotation, and visualization |
| **R / Bioconductor** | `DESeq2`, `clusterProfiler`, `ReactomePA` — statistical modeling, differential expression, GO enrichment, and Reactome pathway analysis |
| **Shell / Bash** | FASTQ/BAM handling, command-line bioinformatics, batch processing, tool execution, Git/Docker operations, and troubleshooting |
| **Linux** | filesystem management, permissions, command-line processing, software environments, large sequencing-file handling, and remote computing |
| **HPC / SLURM** | SSH access, shared storage, Linux users/groups, environment modules, SLURM job scripts, resource requests, `sbatch`, `squeue`, and job-output review |
| **RNA-Seq / NGS** | raw-read QC, alignment, strandedness assessment, gene quantification, filtering, normalization, expression QC, differential expression, and enrichment |
| **Bioinformatics Tools** | FastQC, MultiQC, STAR, SAMtools, RSeQC, featureCounts |
| **Reproducibility** | Docker, Git, GitHub, documented analytical decisions |
| **Scientific Reporting** | Quarto, Markdown, visualization, GitHub Pages |

---

## RNA-Seq Demonstration

Bulk RNA-seq was selected as the first end-to-end demonstration because it
requires integration of **large-scale data processing, command-line
bioinformatics, programming, statistical analysis, biological interpretation,
and scientific communication**.

<p align="center">
  <img src="assets/rnaseq-workflow-overview.png"
       alt="End-to-end reproducible RNA-seq analysis workflow"
       width="100%">
</p>

The workflow demonstrates how raw sequencing data can be transformed into
reproducible and biologically interpretable results while maintaining clear
quality-control checkpoints and documented analytical decisions.

---

## Why This Project?

The project was developed with two connected objectives.

### Scientific objective

To perform an end-to-end bulk RNA-seq analysis and determine whether the
experimental groups show reproducible transcriptomic differences and distinct
biological signatures.

### Computational objective

To demonstrate the ability to build and execute a reproducible bioinformatics
analysis that connects:

- large-scale sequencing data processing
- Linux and command-line bioinformatics
- Python-based data analysis
- R/Bioconductor statistical genomics
- quality-control checkpoints
- containerized computational environments
- HPC/SLURM concepts
- version-controlled code and documentation
- biological interpretation
- collaborator-facing scientific reporting

The goal is therefore not simply to produce a collection of bioinformatics
outputs.

It is to demonstrate the ability to move from **raw biological data to
quality-controlled, statistically supported, biologically meaningful, and
shareable scientific results**.

---

## Interactive Analysis Report

The scientific results are presented through a collaborator-facing **Quarto
HTML report published with GitHub Pages**.

### 🔬 [Open the Interactive RNA-Seq Analysis Report](https://ArchanaAllishe.github.io/reproducible-rnaseq-pipeline/)

The report integrates:

- sequencing and alignment QC
- count-matrix processing
- PCA
- sample-correlation analysis
- differential expression
- volcano and MA plots
- top-DE-gene heatmap
- GO Biological Process enrichment
- Reactome pathway enrichment
- biological interpretation

This provides a results-first interface so that collaborators can review the
analysis without navigating scripts, command-line output, or intermediate
files.

---

## Project at a Glance

| Metric | Result |
|---|---:|
| Samples analyzed | **6** |
| Experimental groups | **2** |
| Unique mapping rate | **88.3–95.2%** |
| Initial genes | **78,894** |
| Genes retained after filtering | **12,728** |
| Variance explained by PC1 | **88.79%** |
| Variance explained by PC1 + PC2 | **92.52%** |
| Significant DE genes | **6,816** |
| Higher in MP46 | **3,495** |
| Higher in NM | **3,321** |
| GO BP terms — MP46 | **31** |
| GO BP terms — NM | **236** |
| Reactome pathways — MP46 | **0** |
| Reactome pathways — NM | **46** |

---

# RNA-Seq Case Study

## Dataset

The demonstration uses publicly available bulk RNA-seq data from:

**GEO accession: GSE199679**

Six paired-end RNA-seq samples were analyzed.

| Group | Samples |
|---|---|
| **NM** | NM_4, NM_5, NM_6 |
| **MP46** | MP46_1, MP46_2, MP46_3 |

Primary comparison:

```text
MP46 vs NM
```

### Reference Configuration

| Component | Reference |
|---|---|
| Genome | GRCh38 primary assembly |
| Annotation | GENCODE v48 |

The same annotation release was maintained across genome indexing,
gene-level quantification, and downstream gene annotation to reduce
inconsistencies between analysis stages.

---

# Analysis and Results

## 1. Sequencing Quality Control

Raw paired-end FASTQ files were evaluated using **FastQC**.

Individual QC reports were aggregated with **MultiQC** to provide a
dataset-level overview.

QC evaluation included metrics such as:

- per-base sequence quality
- GC content
- adapter content
- sequence duplication
- overall read-quality patterns

This provides the first checkpoint before computationally expensive downstream
analysis.

---

## 2. Read Alignment

Reads were aligned against the GRCh38 reference genome using **STAR**.

Alignment files were processed and inspected using **SAMtools** and STAR
alignment statistics.

| Sample | Uniquely Mapped Reads |
|---|---:|
| NM_4 | 95.20% |
| NM_5 | 95.16% |
| NM_6 | 95.11% |
| MP46_1 | 88.29% |
| MP46_2 | 94.31% |
| MP46_3 | 89.23% |

Unique mapping rates ranged from approximately **88.3% to 95.2%**.

---

## 3. Library Strandedness

Library orientation was not assumed from metadata.

It was empirically evaluated using:

```text
RSeQC infer_experiment.py
```

The results supported a **reverse-stranded paired-end library**.

featureCounts was therefore configured using:

```text
-s 2
```

This ensured that gene-level quantification reflected the observed library
orientation.

---

## 4. Gene Quantification and Count-Matrix QC

Gene-level counts were generated using **featureCounts**.

The initial matrix contained:

```text
78,894 genes
```

Before statistical analysis, the matrix was evaluated for:

- duplicate gene identifiers
- missing values
- negative counts
- library sizes
- detected genes
- low-expression features

### Filtering Criterion

```text
Retain genes with ≥10 raw counts in at least 3 samples
```

### Count-Matrix Summary

| Metric | Result |
|---|---:|
| Genes before filtering | 78,894 |
| Genes retained | **12,728** |
| Genes removed | 66,166 |
| Duplicate gene IDs | **0** |
| Missing values | **0** |
| Negative counts | **0** |

The validated **12,728-gene matrix** was carried forward for downstream
analysis.

---

## 5. Expression-Level Quality Control

Sample-level expression patterns were evaluated before differential-expression
interpretation.

Normalized and transformed expression values were used for exploratory
sample-level analysis, while raw integer counts were retained separately for
DESeq2 modeling.

### Principal Component Analysis

PCA was implemented in Python using **scikit-learn**.

```text
PC1 = 88.79%
PC2 =  3.73%

PC1 + PC2 = 92.52%
```

PC1 provided strong separation between NM and MP46.

### Sample Correlation

Within-group correlations were high:

```text
NM    ≈ 0.96
MP46  ≈ 0.96–0.98
```

Between-group correlations were substantially lower:

```text
≈ 0.56–0.64
```

Together, PCA and correlation analysis supported strong replicate consistency,
and no obvious expression-level outlier was identified.

📊 **[Explore Expression QC](https://ArchanaAllishe.github.io/reproducible-rnaseq-pipeline/#expression-level-qc)**

---

## 6. Differential Expression

Differential-expression analysis was performed using **DESeq2**.

```text
Design   : ~ Group
Contrast : MP46 vs NM
```

Direction was explicitly defined as:

```text
log2FoldChange > 0  → higher in MP46
log2FoldChange < 0  → higher in NM
```

### Primary Significance Criterion

```text
adjusted p-value < 0.05
AND
|log2FoldChange| ≥ 1
```

### Differential-Expression Summary

| Result | Genes |
|---|---:|
| Genes tested | 12,728 |
| padj < 0.05 | 8,501 |
| **Significant DE genes** | **6,816** |
| Higher in MP46 | **3,495** |
| Higher in NM | **3,321** |
| padj < 0.01 and \|log2FC\| ≥ 1 | 6,425 |
| padj < 0.05 and \|log2FC\| ≥ 2 | 3,200 |

Results were evaluated using:

- volcano plot
- MA plot
- top-30 differentially expressed gene heatmap
- annotated DESeq2 result tables

📈 **[Explore Differential Expression](https://ArchanaAllishe.github.io/reproducible-rnaseq-pipeline/#differential-expression)**

---

## 7. Functional Enrichment

Significant genes were separated according to expression direction:

```text
Higher in MP46 → 3,495 genes
Higher in NM   → 3,321 genes
```

The two gene sets were independently analyzed using:

- **Gene Ontology Biological Process**
- **Reactome**

The enrichment background consisted of genes **tested in DESeq2**, rather
than all annotated human genes.

### Enrichment Summary

| Gene Set | GO BP | Reactome |
|---|---:|---:|
| Higher in MP46 | **31** | **0** |
| Higher in NM | **236** | **46** |

### Higher in MP46

Prominent functional themes included:

- cell and nuclear division
- microtubule organization
- centrosome-associated processes
- organelle fission

### Higher in NM

Prominent functional themes included:

- extracellular matrix organization
- cell adhesion
- antigen processing and presentation
- interferon-associated signaling
- extracellular matrix remodeling

No Reactome pathway passed the predefined significance threshold for the
MP46-higher gene set.

The statistical threshold was not relaxed after observing this result.

🧬 **[Explore Functional Enrichment](https://ArchanaAllishe.github.io/reproducible-rnaseq-pipeline/#functional-enrichment)**

---

## Biological Summary

Independent analysis stages consistently distinguished the NM and MP46
transcriptomic profiles.

**Expression-level QC** showed strong group separation and high replicate
consistency.

**Differential-expression analysis** identified 6,816 genes meeting the
predefined significance and effect-size criteria.

**Functional enrichment** showed that genes higher in MP46 were associated
primarily with cell-division and microtubule-related processes, whereas genes
higher in NM showed broader extracellular-matrix, adhesion, immune-associated,
and antigen-processing signatures.

> **Interpretation note:** These findings represent expression-associated
> biological signatures. They are not interpreted as direct evidence of
> biological mechanism without additional experimental context.

---

# Analytical Decisions

An important objective of this project was to make analytical decisions
explicit and reproducible rather than treating the workflow as a black box.

<details>
<summary><b>Why maintain the same genome annotation?</b></summary>

GRCh38 and GENCODE v48 were maintained consistently across STAR genome
indexing, featureCounts quantification, and downstream gene annotation.

This reduces gene-coordinate and identifier inconsistencies between analysis
stages.

</details>

<details>
<summary><b>Why determine strandedness empirically?</b></summary>

Incorrect strandedness settings can substantially affect gene-level
quantification.

RSeQC was therefore used to assess library orientation before configuring
featureCounts.

</details>

<details>
<summary><b>Why filter low-expression genes?</b></summary>

Very low-count genes provide limited statistical information while increasing
the multiple-testing burden.

The predefined criterion was:

```text
≥10 counts in at least 3 samples
```

</details>

<details>
<summary><b>Why perform PCA and correlation before differential expression?</b></summary>

Sample-level QC was performed before interpreting DESeq2 results to evaluate
replicate consistency, group structure, and potential expression-level
outliers.

</details>

<details>
<summary><b>Why separate enrichment by expression direction?</b></summary>

Genes higher in MP46 and genes higher in NM represent opposite expression
patterns.

Analyzing the two sets separately preserves direction-specific biological
information.

</details>

<details>
<summary><b>Why use DESeq2-tested genes as the enrichment background?</b></summary>

Only genes included in the statistical analysis could become members of the
significant gene sets.

The tested-gene universe therefore provides a more appropriate enrichment
background than all annotated genes.

</details>

<details>
<summary><b>Why retain zero significant MP46 Reactome pathways?</b></summary>

No Reactome pathway passed the predefined significance threshold for this
gene set.

The threshold was not relaxed after observing the results. This preserves the
predefined analytical criteria rather than selecting a threshold simply to
produce significant pathways.

</details>

---

# Programming and Computational Implementation

## Python

Python was used for reusable downstream-analysis scripts rather than relying
only on manual or interactive analysis.

```text
pandas
    └── count tables, filtering, transformations, result processing

scikit-learn
    └── principal component analysis

matplotlib
    └── scientific visualization

pathlib
    └── reproducible path and filesystem handling

re
    └── annotation parsing and text processing
```

This demonstrates the use of Python as a **scientific data-processing and
workflow-support language**, not simply as a plotting tool.

---

## R / Bioconductor

R was used where established statistical-genomics methods were most
appropriate.

```text
DESeq2
    └── differential-expression modeling

clusterProfiler
    └── Gene Ontology enrichment

ReactomePA
    └── Reactome pathway enrichment
```

This allows the workflow to combine Python-based data processing with
specialized Bioconductor statistical methods.

---

## Shell / Bash

Shell commands and scripts were used throughout the project for:

```text
FASTQ and BAM management
bioinformatics program execution
STAR alignment
SAMtools processing
RSeQC execution
featureCounts quantification
batch processing
Docker execution
Git operations
filesystem inspection
workflow troubleshooting
```

Shell therefore acts as an important integration layer between the individual
bioinformatics tools.

---

## Linux

Linux-based computing was used for:

```text
filesystem navigation and organization
permissions and access control
command-line data processing
bioinformatics software execution
software/environment management
large sequencing-file handling
SSH-based remote computing
environment modules
HPC workflow practice
```

---

# HPC / SLURM Experience

In addition to local analysis, the project includes a **simulated Linux HPC
environment** designed to reproduce key concepts used in institutional
research-computing environments.

Implemented components include:

```text
HPC login node
        ↓
SSH key-based access
        ↓
Linux users and groups
        ↓
Shared project storage
        ↓
Environment Modules
        ↓
Bioinformatics software modules
        ↓
SLURM resource requests
        ↓
sbatch job submission
        ↓
squeue monitoring
        ↓
Job-output inspection
```

Practical tasks included:

- configuring SSH access
- managing Linux users and groups
- configuring shared project directories
- working with filesystem permissions
- creating bioinformatics environment modules
- loading STAR, SAMtools, FastQC, and MultiQC through modules
- writing SLURM job scripts
- requesting CPU, memory, and runtime resources
- submitting jobs using `sbatch`
- monitoring jobs using `squeue`
- reviewing generated job output

This environment provides practical exposure to the execution model used by
many institutional bioinformatics and research-computing systems.

> The current RNA-seq analysis itself was validated separately. Full
> end-to-end execution of the RNA-seq workflow through SLURM is a planned
> development step rather than being presented as already completed.

---

# Reproducibility

Reproducibility was treated as part of the analysis design rather than an
afterthought.

The project separates:

```text
Analysis code
     └── Git / GitHub

Computational environment
     └── Docker

Large sequencing data
     └── maintained outside Git

Technical methodology
     └── docs/

Selected results
     └── results/

Scientific communication
     └── Quarto + GitHub Pages
```

## Containerized Environment

Command-line bioinformatics tools were executed in a **Linux ARM64 Docker
environment**.

Docker was used to:

- isolate bioinformatics dependencies
- provide a consistent Linux environment
- reduce host-specific software conflicts
- support execution on Apple Silicon
- improve computational portability

Container definitions are maintained under:

```text
containers/
```

---

# Repository Structure

```text
reproducible-rnaseq-pipeline/
│
├── assets/
│   └── rnaseq-workflow-overview.png
│
├── containers/
│   └── star/
│
├── scripts/
│   ├── downstream/
│   ├── differential-expression/
│   └── functional-enrichment/
│
├── docs/
│
├── results/
│   ├── qc/
│   ├── expression-qc/
│   ├── differential-expression/
│   └── functional-enrichment/
│
├── report/
│   ├── _quarto.yml
│   ├── index.qmd
│   ├── styles.css
│   └── images/
│
├── .gitignore
├── LICENSE
└── README.md
```

Large files are intentionally excluded from version control, including:

```text
FASTQ files
BAM files
reference genomes
STAR genome indexes
large intermediate files
```

This keeps the repository focused on **code, reproducibility, analytical
decisions, documentation, and selected results**.

---

# Documentation Strategy

The repository separates technical and scientific communication according to
audience:

| Component | Purpose |
|---|---|
| `README.md` | Project overview, capabilities, workflow, and major findings |
| `docs/` | Detailed methodology and analytical decisions |
| `scripts/` | Reusable analysis code |
| `containers/` | Reproducible software environments |
| `results/` | Selected final analysis outputs |
| Quarto report | Collaborator-facing scientific results |

This allows the same project to serve both **technical reviewers** interested
in implementation and **scientific collaborators** interested primarily in
results.

---

# Project Status

### ✅ RNA-Seq Demonstration

- [x] paired-end FASTQ processing
- [x] FastQC and MultiQC
- [x] STAR alignment
- [x] empirical strandedness assessment
- [x] featureCounts gene quantification
- [x] count-matrix cleaning and validation
- [x] low-expression filtering
- [x] normalization
- [x] PCA
- [x] sample-correlation analysis
- [x] DESeq2 differential expression
- [x] gene annotation
- [x] volcano plot
- [x] MA plot
- [x] top-DE-gene heatmap
- [x] GO Biological Process enrichment
- [x] Reactome enrichment
- [x] Quarto scientific report
- [x] GitHub Pages publication

### ✅ Reproducibility & Computing

- [x] Linux-based analysis
- [x] Python analysis scripts
- [x] R/Bioconductor statistical analysis
- [x] Shell/Bash workflow execution
- [x] Dockerized bioinformatics environment
- [x] Git/GitHub version control
- [x] simulated HPC environment
- [x] SSH-based HPC access
- [x] shared project storage
- [x] environment modules
- [x] SLURM job submission
- [x] SLURM job monitoring

---

# Next Development

The current project establishes the individual analysis components and
validates the RNA-seq demonstration.

The next phase will focus on **workflow engineering and automation**.

### Planned

- [ ] **Nextflow workflow implementation**
- [ ] automated dependency between analysis stages
- [ ] end-to-end containerized execution
- [ ] configurable paired-end and single-end input
- [ ] automated QC reporting
- [ ] automated downstream analysis
- [ ] automated Quarto report generation
- [ ] full workflow execution through **HPC / SLURM**
- [ ] workflow testing
- [ ] continuous integration

The target architecture is:

```text
                     Sequencing Data
                           │
                           ▼
                       Nextflow
                           │
             ┌─────────────┼─────────────┐
             ▼             ▼             ▼
             QC        Alignment    Quantification
             │             │             │
             └─────────────┼─────────────┘
                           ▼
                     Expression QC
                           │
                           ▼
                 Statistical Analysis
                           │
                           ▼
                Functional Interpretation
                           │
                           ▼
                  Automated Reporting
                           │
                  ┌────────┴────────┐
                  ▼                 ▼
                Local          HPC / SLURM
```

The longer-term objective is to evolve the RNA-seq demonstration into a
**portable and reusable bioinformatics framework** capable of supporting
additional sequencing-analysis workflows.

---

# What This Project Demonstrates

This project intentionally brings together three areas that are often treated
separately.

### 🧬 Computational Biology

The ability to progress from raw sequencing data through quality control,
quantification, statistical analysis, functional enrichment, and biological
interpretation.

### 💻 Bioinformatics Engineering

The ability to use Python, R, Bash, Linux, Docker, Git, HPC/SLURM concepts,
structured scripts, and reproducible environments to build maintainable
computational analyses.

### 📊 Scientific Communication

The ability to transform complex computational outputs into understandable
figures, summaries, biological interpretations, documentation, and a
collaborator-facing interactive report.

---

## Core Takeaway

> **The value of a bioinformatics workflow is not simply that it runs. It
> should produce results that are quality-controlled, statistically defensible,
> biologically interpretable, computationally reproducible, and accessible to
> the people who need to use them.**

This project demonstrates that progression using **RNA-seq as the first
end-to-end implementation**.

---

<div align="center">

## 🔬 Explore the RNA-Seq Demonstration

### [View the Interactive Analysis Report](https://ArchanaAllishe.github.io/reproducible-rnaseq-pipeline/)

**Raw Sequencing Data → Reproducible Computing → Biological Insight → Shareable Results**

</div>