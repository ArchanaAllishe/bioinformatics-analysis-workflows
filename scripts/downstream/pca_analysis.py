#!/usr/bin/env python3

import pandas as pd
from pathlib import Path
from sklearn.decomposition import PCA

base = Path.home() / "rnaseq-analysis/GSE199679/counts"

input_file = base / "gene_counts_log2.tsv"
output_file = base / "pca_coordinates.tsv"

# Read normalized log2 count matrix
df = pd.read_csv(input_file, sep="\t")

# Remove Geneid and transpose:
# rows = samples
# columns = genes
X = df.drop(columns="Geneid").T

# Perform PCA
pca = PCA(n_components=2, svd_solver="full")
coordinates = pca.fit_transform(X)

# Create results table
result = pd.DataFrame({
    "Sample": X.index,
    "Group": [
        "NM" if sample.startswith("NM_") else "MP46"
        for sample in X.index
    ],
    "PC1": coordinates[:, 0],
    "PC2": coordinates[:, 1]
})

# Save coordinates
result.to_csv(output_file, sep="\t", index=False)

print("\nPCA coordinates:\n")
print(result.to_string(index=False))

print("\nExplained variance:")
print(f"PC1: {pca.explained_variance_ratio_[0] * 100:.2f}%")
print(f"PC2: {pca.explained_variance_ratio_[1] * 100:.2f}%")

print("\nOutput:", output_file)
