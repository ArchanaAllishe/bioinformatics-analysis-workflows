# STAR Alignment and Library Strandedness

## Overview

Six paired-end RNA-seq samples were aligned to the human **GRCh38**
reference genome using **STAR 2.7.11b**.

A development subset of **5 million read pairs per sample** was used to
build and validate the workflow.

```text
FASTQ
  ↓
GRCh38 + GENCODE v48
  ↓
STAR
  ↓
Coordinate-sorted BAM
  ↓
SAMtools
  ↓
RSeQC strandedness assessment
  ↓
Gene quantification
```

## Dataset

| Group | Samples |
|---|---|
| NM | NM_4, NM_5, NM_6 |
| MP46 | MP46_1, MP46_2, MP46_3 |

Each development sample contained:

- 5,000,000 paired-end read pairs
- 101-bp reads

## Reference

The genome and annotation were obtained from the same GENCODE release
to maintain consistency between alignment and downstream quantification.

```text
Genome:      GRCh38 primary assembly
Annotation:  GENCODE v48
STAR:        2.7.11b
```

Reference files:

```text
GRCh38.primary_assembly.genome.fa
gencode.v48.primary_assembly.annotation.gtf
```

The STAR index was generated using:

```text
--genomeSAsparseD 3
--genomeSAindexNbases 12
--sjdbOverhang 100
```

Memory-conscious index settings were used because the development
workstation has 24 GB RAM. `sjdbOverhang=100` corresponds to the
101-bp read length (`read length - 1`).

## Why Docker Was Used

The workflow was developed on an **Apple Silicon macOS** workstation.

Native macOS STAR successfully loaded the GRCh38 index but repeatedly
reported **zero input reads**, despite validation of the paired FASTQ
files and testing both compressed and uncompressed input.

To avoid modifying valid sequencing data or relying on a
platform-specific workaround, STAR was moved into a **Linux ARM64
Docker container**.

The same FASTQ files were successfully processed in the container, with
STAR correctly detecting all 5 million input read pairs per sample.

```text
Apple Silicon Mac
       ↓
Docker Desktop
       ↓
Linux ARM64
       ↓
STAR + SAMtools + RSeQC
```

Docker therefore serves a practical reproducibility purpose:

- provides a consistent Linux execution environment
- isolates bioinformatics dependencies from macOS
- preserves the original sequencing data
- supports native ARM64 execution
- improves portability and reproducibility

The container definition is maintained at:

```text
containers/rnaseq/Dockerfile
```

## Multi-Sample Alignment

The workflow was first validated with `NM_4` and then automated across
the remaining samples.

The validated script is stored at:

```text
scripts/alignment/run_star_all.sh
```

Core STAR parameters:

```text
--runThreadN 6
--readFilesCommand zcat
--outSAMtype BAM SortedByCoordinate
```

STAR therefore produces coordinate-sorted BAM files directly without
retaining large intermediate SAM files.

## Alignment Results

| Sample | Input Read Pairs | Unique Mapping | Multi-mapped | Unmapped: Too Short |
|---|---:|---:|---:|---:|
| NM_4 | 5,000,000 | 95.20% | 3.29% | 1.49% |
| NM_5 | 5,000,000 | 95.16% | 3.43% | 1.39% |
| NM_6 | 5,000,000 | 95.11% | 3.44% | 1.43% |
| MP46_1 | 5,000,000 | 88.29% | 1.90% | 9.66% |
| MP46_2 | 5,000,000 | 94.31% | 3.37% | 2.25% |
| MP46_3 | 5,000,000 | 89.23% | 1.72% | 8.93% |

The NM samples showed highly consistent unique mapping rates of
approximately **95%**. MP46_2 showed similarly strong alignment.

MP46_1 and MP46_3 had lower unique mapping rates and higher fractions of
reads classified as `unmapped: too short`. Both still retained high
unique mapping rates and were kept for downstream analysis.

These differences will be evaluated further during expression-level QC
and PCA rather than excluding samples based on alignment statistics
alone.

## BAM Processing

STAR generated coordinate-sorted BAM files such as:

```text
NM_4_Aligned.sortedByCoord.out.bam
```

BAM files were indexed with SAMtools for downstream analysis.

Large FASTQ, BAM, reference genome, and STAR index files are analysis
inputs/intermediates and are not stored in GitHub.

## Library Strandedness

Library strandedness was determined empirically using
**RSeQC `infer_experiment.py`** before gene quantification.

A BED gene model was generated from the same GENCODE v48 annotation
using `gtfToGenePred` and `genePredToBed`.

For `NM_4`, RSeQC sampled 200,000 usable alignments:

```text
PairEnd Data

Failed to determine:          0.1892
1++,1--,2+-,2-+:              0.0025
1+-,1-+,2++,2--:              0.8084
```

The dominant orientation indicates a **reverse-stranded paired-end
library**.

Therefore, featureCounts will use:

```text
-s 2
```

Determining strandedness experimentally avoids incorrect gene
assignment caused by assuming the library orientation.

## Reproducibility

Validated scripts and environment definitions are maintained separately:

```text
reproducible-rnaseq-pipeline/
├── docs/
│   └── 10-star-alignment.md
├── scripts/
│   ├── qc/
│   ├── alignment/
│   │   └── run_star_all.sh
│   ├── quantification/
│   └── downstream/
└── containers/
    └── rnaseq/
        └── Dockerfile
```

Only tested, working analysis scripts are stored under `scripts/`.

## Skills Demonstrated

- STAR RNA-seq alignment
- GRCh38 / GENCODE reference handling
- paired-end RNA-seq processing
- SAM/BAM processing with SAMtools
- strandedness assessment with RSeQC
- Docker and Linux containers
- Apple Silicon / ARM64 compatibility
- Micromamba / Bioconda environments
- Bash multi-sample automation
- computational resource management
- cross-platform troubleshooting
- reproducible workflow design

## Next Step

The validated BAM files will undergo gene-level quantification using
**featureCounts** with:

```text
Reference:       GRCh38
Annotation:      GENCODE v48
Feature:         exon
Gene attribute:  gene_id
Library:         paired-end
Strandedness:    reverse (-s 2)
```

The resulting raw count matrix will be used for expression QC,
normalization, PCA, and differential expression analysis.