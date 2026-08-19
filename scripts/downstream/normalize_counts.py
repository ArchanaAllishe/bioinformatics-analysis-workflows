#!/usr/bin/env python3

import numpy as np
import pandas as pd
from pathlib import Path

base = Path.home() / "rnaseq-analysis/GSE199679/counts"

input_file = base / "gene_counts_filtered.tsv"
normalized_file = base / "gene_counts_normalized.tsv"
log_file = base / "gene_counts_log2.tsv"
size_factor_file = base / "normalization_size_factors.tsv"

# Read filtered raw counts
df = pd.read_csv(input_file, sep="\t")

gene_ids = df["Geneid"]
counts = df.drop(columns="Geneid")

# --------------------------------------------------
# Median-of-ratios normalization
# --------------------------------------------------

# Use genes with positive counts in every sample
positive = counts.loc[(counts > 0).all(axis=1)]

# Geometric mean for each eligible gene
geometric_means = np.exp(np.log(positive).mean(axis=1))

# Ratio of each sample count to gene geometric mean
ratios = positive.div(geometric_means, axis=0)

# Sample-specific size factors
size_factors = ratios.median(axis=0)

# Normalize counts
normalized = counts.div(size_factors, axis=1)

# Log2 transformation for PCA / visualization
log2_counts = np.log2(normalized + 1)

# Add Geneid back
normalized.insert(0, "Geneid", gene_ids)
log2_counts.insert(0, "Geneid", gene_ids)

# Save outputs
normalized.to_csv(normalized_file, sep="\t", index=False)
log2_counts.to_csv(log_file, sep="\t", index=False)

pd.DataFrame({
    "Sample": size_factors.index,
    "Size_Factor": size_factors.values
}).to_csv(size_factor_file, sep="\t", index=False)

print("Normalization completed.")
print("\nSize factors:")
print(size_factors)

print("\nGenes:", len(df))
print("Samples:", counts.shape[1])

print("\nOutputs:")
print(normalized_file)
print(log_file)
print(size_factor_file)
