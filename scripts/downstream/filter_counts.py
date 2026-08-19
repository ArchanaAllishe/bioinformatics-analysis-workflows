#!/usr/bin/env python3

import pandas as pd
from pathlib import Path

input_file = (
    Path.home()
    / "rnaseq-analysis/GSE199679/counts/gene_counts_matrix.tsv"
)

output_file = (
    Path.home()
    / "rnaseq-analysis/GSE199679/counts/gene_counts_filtered.tsv"
)

# Read raw count matrix
df = pd.read_csv(input_file, sep="\t")

samples = df.columns[1:]

# Filtering rule:
# Keep genes with >=10 counts in at least 3 samples
keep = (df[samples] >= 10).sum(axis=1) >= 3

filtered = df.loc[keep].copy()

filtered.to_csv(
    output_file,
    sep="\t",
    index=False
)

print("Low-expression filtering completed.")
print("Genes before filtering:", len(df))
print("Genes after filtering:", len(filtered))
print("Genes removed:", len(df) - len(filtered))
print("Output:", output_file)
