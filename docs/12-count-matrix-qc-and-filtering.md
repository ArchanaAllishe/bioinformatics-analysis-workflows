# Count Matrix QC and Filtering

## Overview

The featureCounts output was converted into an analysis-ready raw count
matrix and evaluated before normalization.

The workflow was:

```text
featureCounts output
        ↓
Count matrix cleanup
        ↓
Library-size and gene-detection QC
        ↓
Low-expression filtering
        ↓
Validated filtered count matrix
```

## Count Matrix Preparation

The featureCounts annotation columns (`Chr`, `Start`, `End`, `Strand`,
and `Length`) were removed and BAM file paths were converted to concise
sample names.

The resulting matrix contains:

```text
Geneid
NM_4
NM_5
NM_6
MP46_1
MP46_2
MP46_3
```

Raw integer counts were preserved without normalization or log
transformation.

Validated script:

```text
scripts/downstream/clean_featurecounts.py
```

## Count QC

Library size and gene detection were assessed before filtering.

| Sample | Library Size | Genes Detected | Genes ≥10 Counts |
|---|---:|---:|---:|
| NM_4 | 4,420,467 | 18,303 | 11,732 |
| NM_5 | 4,382,360 | 18,872 | 11,863 |
| NM_6 | 4,422,841 | 18,015 | 11,355 |
| MP46_1 | 3,684,912 | 20,528 | 12,208 |
| MP46_2 | 3,987,554 | 20,797 | 12,326 |
| MP46_3 | 3,908,719 | 21,322 | 12,693 |

The NM samples showed highly consistent library sizes. MP46 samples had
somewhat smaller libraries but a larger number of detected genes.

No sample was excluded based on these metrics.

Validated script:

```text
scripts/downstream/count_qc.py
```

## Low-Expression Filtering

Genes with very low expression provide limited information for
downstream analysis and were removed before normalization.

The filtering rule was:

```text
Keep genes with ≥10 raw counts in at least 3 samples.
```

Three samples were selected as the minimum because each experimental
group contains three biological samples.

Filtering results:

```text
Genes before filtering:  78,894
Genes after filtering:   12,728
Genes removed:           66,166
Genes retained:          ~16.1%
```

Validated script:

```text
scripts/downstream/filter_counts.py
```

## Matrix Validation

The filtered matrix was checked before downstream analysis:

```text
Shape:               12,728 genes × 6 samples
Duplicate Gene IDs:  0
Missing values:      0
Negative counts:     0
```

The resulting file is:

```text
gene_counts_filtered.tsv
```

The original raw featureCounts output and unfiltered count matrix are
retained separately.

## Next Step

The validated filtered raw-count matrix will be used for:

```text
Normalization
      ↓
Sample-level QC
      ↓
PCA and correlation
      ↓
Differential expression
```