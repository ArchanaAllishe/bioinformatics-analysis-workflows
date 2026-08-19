#!/usr/bin/env python3

import pandas as pd
from pathlib import Path

base = Path.home() / "rnaseq-analysis/GSE199679/counts"

input_file = base / "gene_counts_log2.tsv"
output_file = base / "sample_correlation.tsv"

# Read log2-normalized expression matrix
df = pd.read_csv(input_file, sep="\t")

# Remove gene IDs
expression = df.drop(columns="Geneid")

# Pearson correlation between samples
correlation = expression.corr(method="pearson")

# Save correlation matrix
correlation.to_csv(output_file, sep="\t")

print("\nSample-to-sample Pearson correlation:\n")
print(correlation.round(3))

print("\nOutput:")
print(output_file)
