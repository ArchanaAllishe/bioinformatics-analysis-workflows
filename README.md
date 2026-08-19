<div align="center">

# 🧬 From Sequencing Data to Biological Insight

### An End-to-End RNA-Seq Case Study in Reproducible Bioinformatics

**Raw FASTQ → QC → Alignment → Gene Counts → Expression Analysis → Biological Interpretation → Interactive Report**

<br>

`Python` · `R/Bioconductor` · `Bash` · `Linux` · `Docker` · `HPC/SLURM`  
`FastQC` · `MultiQC` · `STAR` · `SAMtools` · `RSeQC` · `featureCounts` · `DESeq2` · `Quarto`

<br>

### 🔬 [View the Interactive RNA-Seq Report](https://ArchanaAllishe.github.io/reproducible-rnaseq-pipeline/)

</div>

---

## About This Project

I built this project to work through a complete RNA-seq analysis starting from
raw sequencing reads and ending with biological interpretation and a report
that could be shared with collaborators.

I wanted the project to cover more than the analysis itself. It also gave me a
way to bring together the tools and practices I use in bioinformatics:
**Python, R, Bash, Linux, Docker, Git, HPC/SLURM, and scientific reporting**.

Bulk RNA-seq is the case study used here. The same overall approach—checking
the data carefully, documenting analysis decisions, keeping the environment
reproducible, and presenting the results clearly—can be applied to other
sequencing workflows as well.

<p align="center">
  <img src="assets/rnaseq-workflow-overview.png"
       alt="End-to-end RNA-seq workflow"
       width="100%">
</p>

---

## What I Used

| Area | Tools / Libraries | How I used them |
|---|---|---|
| **Python** | pandas, scikit-learn, matplotlib | Count-table processing, filtering, PCA, correlation analysis, annotation, and plotting |
| **R / Bioconductor** | DESeq2, clusterProfiler, ReactomePA | Differential expression and functional enrichment |
| **Command line** | Bash, Linux | File handling, batch processing, running bioinformatics tools, and troubleshooting |
| **RNA-seq tools** | FastQC, MultiQC, STAR, SAMtools, RSeQC, featureCounts | QC, alignment, strandedness assessment, and gene quantification |
| **Reproducibility** | Docker, Git, GitHub | Software environment and version-controlled analysis |
| **HPC** | SSH, Environment Modules, SLURM | Practice with shared computing and job submission |
| **Reporting** | Quarto, GitHub Pages | Interactive, shareable results report |

---

# RNA-Seq Dataset

## Study Background

This analysis uses publicly available RNA-seq data associated with
**GSE199679**, a study investigating molecular differences between normal
uveal melanocytes and uveal melanoma.

The RNA-seq portion of the study is available under **GSE198801**.

For this analysis, I used two groups:

- **NM (Normal Melanocytes)** — normal uveal/choroidal melanocytes used as the
  non-malignant reference.
- **MP46** — a patient-derived xenograft (PDX) model of uveal melanoma.

Six RNA-seq samples were included:

| Group | Biological context | Samples |
|---|---|---|
| **NM** | Normal uveal melanocytes | NM_4, NM_5, NM_6 |
| **MP46** | Uveal melanoma PDX model | MP46_1, MP46_2, MP46_3 |

The main comparison throughout the analysis is:

> **MP46 uveal melanoma vs. normal melanocytes (NM)**

## Reference Genome and Gene Annotation

Reads were aligned to the human **GRCh38 primary assembly**, with
**GENCODE v48** used for gene annotation.

| Resource | Version |
|---|---|
| Reference genome | GRCh38 primary assembly |
| Gene annotation | GENCODE v48 |

The same annotation release was kept throughout the workflow so that genome
indexing, gene counting, and downstream gene annotation were based on
consistent gene definitions.

---

# Analysis

## 1. Raw Read Quality Control

I started by checking the raw paired-end FASTQ files with **FastQC** and
combined the individual reports with **MultiQC**.

I reviewed the main sequencing QC metrics, including:

- per-base sequence quality
- GC content
- adapter content
- sequence duplication
- overall read-quality patterns

This was done before alignment so that obvious problems in the raw sequencing
data could be identified early.

---

## 2. Read Alignment

Reads were aligned to GRCh38 using **STAR**.

I then reviewed the STAR alignment statistics and used **SAMtools** for
alignment-file processing.

| Sample | Uniquely mapped reads |
|---|---:|
| NM_4 | 95.20% |
| NM_5 | 95.16% |
| NM_6 | 95.11% |
| MP46_1 | 88.29% |
| MP46_2 | 94.31% |
| MP46_3 | 89.23% |

Unique mapping rates ranged from **88.3% to 95.2%** across the six samples.

---

## 3. Checking Library Strandedness

Rather than assuming the library orientation, I checked it with
**RSeQC `infer_experiment.py`**.

The results were consistent with a **reverse-stranded paired-end library**.

I therefore used:

```text
-s 2
```

for featureCounts.

This was an important check because using the wrong strandedness setting can
affect gene-level counts.

---

## 4. Gene Quantification and Count-Matrix QC

Gene-level counts were generated with **featureCounts**.

The initial count matrix contained **78,894 genes**.

Before moving to expression analysis, I checked the matrix for:

- duplicate gene IDs
- missing values
- negative counts
- library sizes
- detected genes
- low-expression genes

Low-expression genes were filtered using:

```text
Keep genes with ≥10 raw counts in at least 3 samples
```

After filtering:

| Metric | Result |
|---|---:|
| Genes before filtering | 78,894 |
| Genes retained | **12,728** |
| Genes removed | 66,166 |
| Duplicate gene IDs | 0 |
| Missing values | 0 |
| Negative counts | 0 |

The remaining **12,728 genes** were used for downstream analysis.

---

## 5. Expression-Level QC

Before differential-expression testing, I looked at the overall relationships
between samples using **PCA and sample correlation**.

### PCA

PCA was performed in Python using `scikit-learn`.

```text
PC1 = 88.79%
PC2 =  3.73%

PC1 + PC2 = 92.52%
```

The first principal component clearly separated the NM and MP46 samples.

### Sample Correlation

Replicates within each group were highly correlated:

```text
NM    ≈ 0.96
MP46  ≈ 0.96–0.98
```

Correlations between NM and MP46 were lower:

```text
≈ 0.56–0.64
```

The PCA and correlation heatmap told the same overall story: replicates were
consistent within each group, while NM and MP46 had clearly different
expression profiles.

📊 **[View the expression QC results](https://ArchanaAllishe.github.io/reproducible-rnaseq-pipeline/#expression-level-qc)**

---

## 6. Differential Expression

I used **DESeq2** to test for differential expression between MP46 and NM.

```text
Design   : ~ Group
Contrast : MP46 vs NM
```

The direction of the fold change is:

```text
log2FoldChange > 0  → higher in MP46
log2FoldChange < 0  → higher in NM
```

For the main result set, I used:

```text
adjusted p-value < 0.05
and
|log2FoldChange| ≥ 1
```

### Results

| Criterion | Genes |
|---|---:|
| Genes tested | 12,728 |
| padj < 0.05 | 8,501 |
| **padj < 0.05 and \|log2FC\| ≥ 1** | **6,816** |
| Higher in MP46 | **3,495** |
| Higher in NM | **3,321** |
| padj < 0.01 and \|log2FC\| ≥ 1 | 6,425 |
| padj < 0.05 and \|log2FC\| ≥ 2 | 3,200 |

I used a volcano plot, MA plot, and top-30 DE-gene heatmap to examine these
results from different perspectives.

📈 **[View the differential-expression results](https://ArchanaAllishe.github.io/reproducible-rnaseq-pipeline/#differential-expression)**

---

## 7. Functional Enrichment

To make the differential-expression results easier to interpret biologically,
I separated the significant genes by direction:

```text
Higher in MP46 → 3,495 genes
Higher in NM   → 3,321 genes
```

I analyzed the two lists separately using:

- **Gene Ontology Biological Process**
- **Reactome pathways**

Genes that were actually tested by DESeq2 were used as the enrichment
background.

| Gene set | GO Biological Process | Reactome |
|---|---:|---:|
| Higher in MP46 | **31** | **0** |
| Higher in NM | **236** | **46** |

### Genes Higher in MP46

The main enriched themes were related to:

- cell and nuclear division
- microtubule organization
- centrosome-associated processes
- organelle fission

### Genes Higher in NM

The main themes included:

- extracellular matrix organization
- cell adhesion
- antigen processing and presentation
- interferon-associated signaling
- extracellular matrix remodeling

No Reactome pathway passed the predefined significance threshold for genes
higher in MP46. I kept this as a negative result rather than changing the
threshold after seeing the output.

🧬 **[View the functional-enrichment results](https://ArchanaAllishe.github.io/reproducible-rnaseq-pipeline/#functional-enrichment)**

---

# What Did the Analysis Show?

Several independent analyses separated MP46 from normal melanocytes.

PCA showed strong separation between the groups, while the correlation
analysis showed good agreement among biological replicates.

DESeq2 identified **6,816 differentially expressed genes** using the predefined
adjusted p-value and fold-change cutoffs.

Genes higher in MP46 were mainly associated with **cell division and
microtubule-related processes**. Genes higher in NM showed broader enrichment
for **extracellular matrix, adhesion, immune-related, and antigen-processing
processes**.

These results describe expression patterns associated with the two sample
groups. Without additional experimental evidence, I do not interpret them as
proof of a specific biological mechanism.

---

# Programming and Bioinformatics Tools

## Python

I used Python mainly for count-table processing, QC, exploratory analysis,
annotation, and visualization.

| Library | Used for |
|---|---|
| `pandas` | Reading, cleaning, filtering, and processing tabular data |
| `scikit-learn` | PCA |
| `matplotlib` | Plotting |
| `pathlib` | File and directory handling |
| `re` | Parsing annotation information |

The analysis steps were saved as scripts under `scripts/` rather than being
performed only interactively, so they can be rerun when needed.

## R / Bioconductor

I used R for the parts of the workflow where established Bioconductor tools
were the natural choice.

| Package | Used for |
|---|---|
| `DESeq2` | Differential-expression analysis |
| `clusterProfiler` | Gene Ontology enrichment |
| `ReactomePA` | Reactome pathway enrichment |

## Bash and Linux

Bash and Linux tied the workflow together.

I used the command line for FASTQ and alignment-file management, running
FastQC, MultiQC, STAR, SAMtools, RSeQC and featureCounts, processing multiple
samples, working with Docker, managing files and permissions, and using Git.

---

# HPC / SLURM Practice

I also built a small simulated HPC environment to practice the way
bioinformatics analyses are commonly run on shared research-computing systems.

The setup included:

- SSH key-based access
- Linux users and groups
- shared project storage
- file permissions
- Environment Modules
- STAR, SAMtools, FastQC, and MultiQC modules
- SLURM job scripts
- CPU, memory, and runtime requests
- job submission with `sbatch`
- job monitoring with `squeue`
- job-output review

This part of the project was specifically for HPC practice. The current
RNA-seq analysis was not run end-to-end through this simulated cluster, so I
keep that distinction explicit.

A future step is to connect the RNA-seq workflow to SLURM through Nextflow.

---

# Reproducibility

I kept code, software environments, large data files, documentation, and
results separate so that each part of the project has a clear role.

| Component | Where it lives |
|---|---|
| Analysis code | `scripts/` + Git/GitHub |
| Software environment | `containers/` |
| Detailed methods | `docs/` |
| Selected results | `results/` |
| Scientific report | `report/` |
| Large sequencing/reference files | Outside Git |

## Reproducible Software Setup with Docker

Some bioinformatics tools can be difficult to install consistently across
operating systems, particularly when software versions and dependencies differ.

I used **Docker** to provide a Linux environment for command-line
bioinformatics tools while working on an Apple Silicon system.

This helped me keep the software environment separate from macOS, avoid
dependency conflicts, and document how the tools were run.

The Docker files are kept in:

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

FASTQ files, BAM files, reference genomes, STAR indexes, and other large
intermediate files are intentionally kept out of Git.

The repository therefore contains the parts needed to understand and reproduce
the analysis without trying to use GitHub as storage for large sequencing
files.

---

# Documentation

I kept detailed methods in `docs/` so that the README can stay focused on the
overall project and results.

| Location | Purpose |
|---|---|
| `README.md` | Project overview and key results |
| `docs/` | Detailed methods and analysis decisions |
| `scripts/` | Analysis code |
| `containers/` | Docker setup |
| `results/` | Selected results and figures |
| `report/` | Quarto report source |

The final Quarto report is aimed at someone who wants to see the scientific
results without having to work through the code or intermediate files.

---

# Project Status

### Completed

- [x] Raw paired-end FASTQ QC
- [x] FastQC / MultiQC
- [x] STAR alignment
- [x] strandedness assessment
- [x] featureCounts quantification
- [x] count-matrix QC and filtering
- [x] expression normalization
- [x] PCA
- [x] sample-correlation heatmap
- [x] DESeq2 differential expression
- [x] gene annotation
- [x] volcano plot
- [x] MA plot
- [x] top-DE-gene heatmap
- [x] GO enrichment
- [x] Reactome enrichment
- [x] Docker environment
- [x] Git/GitHub version control
- [x] simulated HPC/SLURM setup
- [x] Quarto report
- [x] GitHub Pages deployment

---

# What's Next?

The individual analysis steps are now working and documented. The next step is
to connect them into an automated **Nextflow workflow**.

Planned work includes:

- [ ] Nextflow workflow
- [ ] automated handoff between analysis stages
- [ ] paired-end and single-end input support
- [ ] containerized execution
- [ ] automated QC
- [ ] automated downstream analysis
- [ ] automated report generation
- [ ] SLURM execution
- [ ] workflow testing
- [ ] continuous integration

The aim is to move from a set of validated analysis steps to a workflow that
can be launched reproducibly on either a local system or HPC infrastructure.

---

<div align="center">

## 🔬 Explore the RNA-Seq Analysis

### [View the Interactive Analysis Report](https://ArchanaAllishe.github.io/reproducible-rnaseq-pipeline/)

**Raw Sequencing Data → Analysis → Biological Insight → Shareable Results**

</div>