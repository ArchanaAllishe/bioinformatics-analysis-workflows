# Gene-Level Quantification with featureCounts

## Overview

Gene-level read counts were generated from the six STAR-aligned BAM files using **featureCounts** from the Subread package.

The same **GENCODE v48** annotation used during reference preparation and alignment was used for quantification.

```text
Coordinate-sorted BAM
        ↓
GENCODE v48 annotation
        ↓
featureCounts
        ↓
Raw gene-count matrix
```

## Counting Strategy

The RNA-seq libraries are paired-end and were experimentally determined to be **reverse-stranded** using RSeQC.

featureCounts was therefore configured with:

```text
-T 6               6 processing threads
-p                  paired-end data
--countReadPairs    count fragments/read pairs
-s 2                reverse-stranded
-t exon             count reads overlapping exons
-g gene_id          summarize exon counts by gene
```

Strandedness was determined before quantification rather than assumed, reducing the risk of incorrect gene assignment.

## Reference Annotation

```text
Genome:       GRCh38
Annotation:   GENCODE v48
Feature:      exon
Gene ID:      gene_id
Library:      paired-end
Strandedness: reverse (-s 2)
```

## Quantification Results

| Sample | Assigned Fragments | Assignment Rate |
|---|---:|---:|
| NM_4 | 4,420,467 | 85.18% |
| NM_5 | 4,382,360 | 84.37% |
| NM_6 | 4,422,841 | 84.40% |
| MP46_1 | 3,684,912 | 78.43% |
| MP46_2 | 3,987,554 | 77.28% |
| MP46_3 | 3,908,719 | 82.96% |

All six samples produced substantial numbers of gene-assigned fragments.

The NM samples showed highly consistent assignment rates of approximately **84–85%**. The MP46 samples showed greater variability, with assignment rates of approximately **77–83%**.

All samples were retained for downstream expression analysis. Sample-level differences will be evaluated further using expression QC, sample correlation, and PCA.

## Main Unassigned Categories

The major unassigned categories were:

- `Unassigned_MultiMapping` — fragments mapping to multiple genomic locations
- `Unassigned_NoFeatures` — fragments not overlapping an eligible annotated exon
- `Unassigned_Ambiguity` — fragments that could not be assigned unambiguously to a single feature

No additional counting options were introduced simply to increase assignment rates.

## Outputs

featureCounts generated:

```text
gene_counts.txt
gene_counts.txt.summary
```

`gene_counts.txt` contains gene-level raw counts for all six samples.

`gene_counts.txt.summary` contains the assignment statistics used for quantification QC.

Large intermediate alignment files are not stored in GitHub.

## Reproducibility

featureCounts is installed in the same Linux ARM64 Docker environment used for the alignment workflow.

The container definition is maintained at:

```text
containers/rnaseq/Dockerfile
```

The validated quantification script is stored separately at:

```text
scripts/quantification/run_featurecounts.sh
```

This keeps executable analysis code separate from documentation and software-environment definitions.

## Next Step

The raw featureCounts matrix will next be prepared for downstream expression analysis:

```text
Raw gene counts
      ↓
Count matrix cleanup
      ↓
Expression QC
      ↓
Normalization
      ↓
Sample correlation / PCA
      ↓
Differential expression
```