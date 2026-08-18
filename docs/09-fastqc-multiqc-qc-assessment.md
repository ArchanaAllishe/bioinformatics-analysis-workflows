# FastQC and MultiQC Quality Control Assessment

## Overview

Quality control was performed on the RNA-seq FASTQ files before read alignment to evaluate sequencing quality and determine whether adapter or quality trimming was necessary.

The development dataset consists of six paired-end RNA-seq samples from **GSE199679**, giving a total of 12 FASTQ files.

| Sample | Read 1 | Read 2 |
| --- | --- | --- |
| NM_4 | NM_4_R1.fastq.gz | NM_4_R2.fastq.gz |
| NM_5 | NM_5_R1.fastq.gz | NM_5_R2.fastq.gz |
| NM_6 | NM_6_R1.fastq.gz | NM_6_R2.fastq.gz |
| MP46_1 | MP46_1_R1.fastq.gz | MP46_1_R2.fastq.gz |
| MP46_2 | MP46_2_R1.fastq.gz | MP46_2_R2.fastq.gz |
| MP46_3 | MP46_3_R1.fastq.gz | MP46_3_R2.fastq.gz |

For workflow development, each FASTQ file contains a subset of **5 million reads**.

---

## Quality Control Workflow

Individual FASTQ files were evaluated with **FastQC**, and the resulting reports were aggregated with **MultiQC**.

```text
12 FASTQ Files
      │
      ▼
    FastQC
      │
      ▼
12 FastQC Reports
      │
      ▼
    MultiQC
      │
      ▼
Combined QC Report
      │
      ▼
 QC Assessment
      │
      ▼
Trimming Decision
```

MultiQC successfully detected and summarized all 12 FastQC reports.

---

## QC Summary

| Metric | Observation | Interpretation |
| --- | --- | --- |
| Read count | 5 million reads per FASTQ | Expected development subset size |
| Read length | 101 bp | Consistent across samples |
| GC content | Approximately 47–53% | No extreme GC-content abnormality |
| Adapter content | Passed across all FASTQ files | No substantial adapter contamination detected |
| Sequence quality | Overall suitable for alignment | No severe quality deterioration requiring trimming |
| Per-base sequence content | Warnings/failures observed | Interpreted in the context of RNA-seq library composition |
| Sequence duplication | Elevated in several samples | Can occur in RNA-seq because of highly expressed transcripts |
| Overrepresented sequences | Warnings in some files | Low-level observations; adapter checks remained clean |

---

## Read Count and Length

Each FASTQ file contains:

```text
5,000,000 reads
```

Because the data are paired-end, each biological sample contains approximately:

```text
5,000,000 read pairs
```

in the development subset.

Read length was consistently:

```text
101 bp
```

across the dataset.

The consistent read length indicates that the development FASTQs were generated uniformly and had not undergone variable-length trimming before this analysis.

---

## GC Content

GC content was approximately:

```text
47–53%
```

across the samples.

No extreme sample-specific GC-content shift was observed that would independently justify removal or trimming of reads.

---

## Adapter Content

Adapter-content checks passed across all 12 FASTQ files.

This was an important consideration when deciding whether preprocessing was necessary.

The results did not indicate substantial residual adapter contamination.

Therefore, adapter trimming was not performed.

---

## Sequence Quality

Overall sequence-quality profiles were suitable for downstream alignment.

There was no evidence of severe quality deterioration that justified removing substantial portions of the 101-bp reads.

Quality trimming was therefore not performed solely to modify FastQC warning status.

---

## Per-Base Sequence Content

FastQC identified non-random nucleotide composition in the dataset.

Per-base sequence content evaluates the relative proportions of A, C, G, and T across positions within sequencing reads.

For RNA-seq data, deviations from equal nucleotide composition can occur because the sequenced molecules originate from transcripts rather than from a random genomic sequence population. Library-preparation effects can also influence nucleotide composition near the beginning of reads.

For this dataset, the sequence-content findings were therefore interpreted together with the other QC metrics rather than being treated as an automatic indication for trimming.

Because sequence quality and adapter content were acceptable, trimming was not performed simply to eliminate the sequence-content warning/failure.

---

## Sequence Duplication

Elevated duplication was observed in several FASTQ files.

Duplication requires careful interpretation for RNA-seq data because highly expressed transcripts can naturally contribute large numbers of identical or similar reads.

Therefore, elevated FastQC duplication does not necessarily represent technical PCR duplication or poor-quality sequencing.

Duplicate reads were not removed at the raw FASTQ QC stage based solely on this metric.

---

## Overrepresented Sequences

Overrepresented-sequence warnings were observed in a small number of FASTQ files.

These findings were evaluated together with adapter-content and sequence-quality results.

Because adapter-content checks passed across the dataset and the observed overrepresented sequences represented only a small fraction of the reads, these warnings were not considered sufficient evidence for adapter trimming.

---

## Trimming Decision

After reviewing the combined FastQC and MultiQC results:

> **No adapter or quality trimming was performed before alignment.**

The decision was based on the combined evidence that:

1. adapter-content checks passed across all FASTQ files;
2. overall sequence quality was suitable for alignment;
3. read lengths were consistently 101 bp;
4. no severe quality deterioration was observed;
5. sequence-content findings were interpreted in the context of RNA-seq;
6. elevated duplication can reflect biological transcript abundance;
7. overrepresented sequences did not indicate substantial adapter contamination.

The workflow therefore preserves the original reads for alignment.

```text
FASTQ
  │
  ▼
FastQC
  │
  ▼
MultiQC
  │
  ▼
QC Review
  │
  ├── Significant adapter contamination? ── No
  │
  ├── Severe quality deterioration? ─────── No
  │
  ▼
No Trimming
  │
  ▼
STAR Alignment
```

This makes trimming an **evidence-based decision** rather than a mandatory preprocessing step.

Future datasets processed through the workflow will be evaluated independently, and trimming can be introduced when supported by their QC results.

---

## QC Reports

The final MultiQC report is retained in both HTML and PDF formats.

### Interactive HTML Report

[View MultiQC HTML Report](../results/qc/multiqc_report.html)

The HTML report contains the complete interactive MultiQC output and allows individual samples and QC metrics to be explored.

### PDF Report

[View MultiQC PDF Report](../results/qc/multiqc_report.pdf)

The PDF provides a static version of the QC report for convenient viewing and sharing.

---

## Output Files

Final QC deliverables committed to the repository are:

```text
results/qc/
├── multiqc_report.html
└── multiqc_report.pdf
```

Detailed intermediate FastQC files and large sequencing datasets are retained in the analysis environment rather than committed to the Git repository.

---

## Conclusion

Quality-control analysis of the six paired-end RNA-seq samples showed that the development dataset was suitable for downstream alignment without additional adapter or quality trimming.

The QC stage therefore concludes with:

**12 FASTQ files → FastQC → MultiQC → QC review → no trimming → STAR alignment**

The next workflow stage is **reference-genome preparation and STAR alignment**.