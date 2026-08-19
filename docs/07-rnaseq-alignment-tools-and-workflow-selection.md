# Task 07 — RNA-Seq Alignment Tools and Workflow Selection

## Overview

RNA-seq reads originate from mature RNA molecules in which introns have been
removed through splicing.

As a result, some sequencing reads span exon-exon junctions.

Genome-based RNA-seq analysis therefore requires an aligner capable of
recognizing splice junctions.

Several established tools are available for RNA-seq alignment and expression
quantification. The appropriate choice depends on:

- sequencing design;
- biological objective;
- required downstream outputs;
- available CPU and memory;
- computational environment.

For this project, **HISAT2 was selected for genome alignment** because it
supports paired-end, splice-aware RNA-seq alignment while requiring
substantially less memory than a conventional human-genome STAR workflow.

---

## RNA-Seq Analysis Approaches

Two commonly used strategies are genome alignment and transcript
quantification.

                         RNA-seq FASTQ
                              │
                 ┌────────────┴────────────┐
                 │                         │
                 ▼                         ▼
          Genome alignment        Transcript quantification
                 │                         │
           STAR / HISAT2            Salmon / kallisto
                 │                         │
                 ▼                         ▼
             SAM / BAM             Transcript abundance
                 │
                 ▼
           featureCounts
                 │
                 ▼
            Gene counts

Genome alignment is appropriate when genomic alignments, BAM files, alignment
quality control, or featureCounts-based quantification are required.

Transcript-quantification tools provide an efficient alternative when
expression estimation is the primary objective and genome-aligned BAM files
are not required.

---

## STAR

STAR is a high-performance splice-aware RNA-seq aligner.

Typical workflow:

    FASTQ
      ↓
    STAR
      ↓
    SAM/BAM
      ↓
    featureCounts

### Strengths

STAR provides:

- splice-aware alignment;
- paired-end and single-end support;
- high alignment speed;
- splice-junction detection;
- genome-aligned output;
- compatibility with Samtools and featureCounts.

STAR is particularly well suited to HPC environments where high-memory compute
nodes are available.

### Resource Consideration

STAR achieves high alignment performance partly through the use of a large
genome index.

For a human reference genome such as GRCh38, a conventional STAR workflow can
require substantial memory.

This can make STAR less practical on laptops and smaller virtual compute
environments.

---

## HISAT2

HISAT2 is a splice-aware genome aligner suitable for RNA-seq analysis.

Typical workflow:

    FASTQ
      ↓
    HISAT2
      ↓
    SAM
      ↓
    Samtools
      ↓
    Sorted BAM
      ↓
    featureCounts

### Strengths

HISAT2 provides:

- splice-aware alignment;
- paired-end and single-end support;
- human-genome alignment;
- SAM output;
- compatibility with Samtools;
- compatibility with featureCounts;
- lower memory requirements than a conventional STAR human-genome workflow.

Its memory-efficient indexing strategy makes HISAT2 suitable for workstations
and smaller compute environments.

---

## Salmon and kallisto

Salmon and kallisto focus primarily on rapid transcript abundance
quantification.

Typical workflow:

    FASTQ
      ↓
    Salmon / kallisto
      ↓
    Transcript abundance
      ↓
    Gene-level summarization
      ↓
    Differential expression

These tools are useful when expression quantification is the primary objective.

They were not selected for this project because the intended workflow includes:

- genome alignment;
- SAM/BAM processing;
- alignment quality control;
- Samtools;
- featureCounts-based gene quantification.

---

## Other Sequence Aligners

Bowtie2 and BWA are widely used short-read aligners but are more commonly
associated with DNA-sequencing workflows.

Examples include:

    Bowtie2 → ChIP-seq / ATAC-seq

    BWA     → WGS / WES

They are not the primary choices for conventional splice-aware eukaryotic
RNA-seq genome alignment.

---

## Tool Comparison

| Tool | Primary approach | Splice-aware | Genome BAM workflow | Relative memory | Typical use |
|------|------------------|--------------|---------------------|-----------------|-------------|
| STAR | Genome alignment | Yes | Yes | High | RNA-seq |
| HISAT2 | Genome alignment | Yes | Yes | Lower | RNA-seq |
| Salmon | Transcript quantification | Not applicable | Not required | Lower | RNA-seq quantification |
| kallisto | Transcript quantification | Not applicable | Not required | Lower | RNA-seq quantification |
| Bowtie2 | Genome alignment | No | Yes | Lower | ChIP-seq / ATAC-seq |
| BWA | Genome alignment | No | Yes | Lower | WGS / WES |

No single aligner is optimal for every sequencing project.

Tool selection should consider both scientific requirements and computational
resources.

---

## Alignment Requirements for This Project

The RNA-seq workflow requires:

    Paired-end FASTQ
           │
           ▼
    Splice-aware genome alignment
           │
           ▼
        SAM/BAM
           │
           ▼
      Alignment QC
           │
           ▼
    Gene-level quantification
           │
           ▼
    Differential expression

The selected aligner therefore needs to:

- support paired-end RNA-seq;
- recognize splice junctions;
- align reads against the human genome;
- produce SAM/BAM-compatible output;
- integrate with Samtools;
- integrate with featureCounts;
- operate within the available computational resources.

Both STAR and HISAT2 satisfy the biological requirements.

The primary difference relevant to this implementation is computational
resource usage.

---

## STAR and HISAT2: Resource Considerations

STAR and HISAT2 are both established splice-aware aligners suitable for
genome-based RNA-seq analysis.

Both support paired-end sequencing and produce alignments that can be processed
with Samtools and quantified with featureCounts.

### STAR

STAR is optimized for high-speed RNA-seq alignment and is particularly well
suited to HPC environments with high-memory compute nodes.

For a human reference genome such as GRCh38, its conventional genome index
requires substantially more memory than is desirable for the local
computational environment used for this project.

STAR remains an appropriate option when sufficient high-memory computational
resources are available.

### HISAT2

HISAT2 provides splice-aware genome alignment using a more memory-efficient
indexing strategy.

This makes it particularly suitable for:

- workstation-based RNA-seq analysis;
- smaller compute nodes;
- memory-constrained environments;
- paired-end workflows requiring genome-aligned BAM files.

HISAT2 also preserves the downstream workflow required for this project:

    Paired-end FASTQ
            ↓
          HISAT2
            ↓
         Samtools
            ↓
        Sorted BAM
            ↓
      featureCounts
            ↓
      Gene count matrix

---

## Selection for This Project

HISAT2 was selected because it satisfies both the biological and computational
requirements.

| Requirement | HISAT2 |
|-------------|--------|
| Splice-aware RNA-seq alignment | Yes |
| Paired-end sequencing | Yes |
| Human genome alignment | Yes |
| SAM/BAM workflow | Yes |
| Samtools compatibility | Yes |
| featureCounts compatibility | Yes |
| Suitable for available local memory | Yes |

The selection preserves a conventional genome-alignment-based RNA-seq workflow
while allowing the analysis to run within the available local computational
resources.

---

## Reference Genome Strategy

The planned reference configuration is:

    Reference genome: GRCh38
    Aligner:          HISAT2
    Index:            Prebuilt GRCh38 HISAT2 genome index

A prebuilt HISAT2 genome index will be used rather than constructing a large
specialized human index locally.

The source and release of the reference genome and gene annotation will be
recorded.

Reference and annotation compatibility will be verified before gene
quantification.

---

## Computational Strategy

The analysis is executed within a simulated Linux/HPC environment hosted
locally.

For RNA-seq processing, the compute environment will be configured with
approximately:

    CPU:  4 cores
    RAM:  10–12 GB

Alignment jobs will be processed sequentially, or with carefully controlled
concurrency, to avoid exhausting the available memory.

Computational requirements will be specified through SLURM batch scripts.

For example:

    #SBATCH --cpus-per-task=4
    #SBATCH --mem=8G

Actual resource usage will be evaluated during pipeline execution.

---

## Reproducibility

This project performs an independent re-analysis of public RNA-seq data.

The workflow will record:

- GEO/SRA accession;
- sample metadata;
- sequencing layout;
- reference genome release;
- annotation release;
- HISAT2 version;
- alignment parameters;
- Samtools version;
- featureCounts version;
- software modules;
- SLURM resource requests;
- quality-control results.

This allows the computational analysis to be independently reproduced.

---

## Selected RNA-Seq Workflow

The finalized analysis strategy is:

    GSE199679
        │
        ▼
    RNA-seq component
        │
        ▼
    Paired-end FASTQ
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
       SAM
        │
        ▼
     Samtools
        │
        ├── convert
        ├── sort
        ├── index
        └── alignment QC
        │
        ▼
    Sorted BAM
        │
        ▼
    featureCounts
        │
        ▼
    Raw gene-count matrix
        │
        ▼
    Sample metadata
        │
        ▼
      DESeq2
        │
        ├── normalization
        ├── sample QC
        ├── PCA
        └── differential expression
        │
        ▼
    Visualization and biological interpretation
        │
        ▼
    Reproducible HTML report

---

## Outcome

HISAT2 was selected as the RNA-seq aligner because it provides the required
splice-aware, paired-end genome alignment while remaining practical within the
available computational resources.

STAR remains available in the HPC software environment as an alternative
aligner for compute environments with greater memory capacity.

The selected strategy allows the project to retain a complete
alignment-based RNA-seq workflow while remaining executable on the available
local hardware.