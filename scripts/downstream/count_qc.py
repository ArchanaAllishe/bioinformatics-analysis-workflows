#!/usr/bin/env python3

import pandas as pd
from pathlib import Path

input_file = (
    Path.home()
    / "rnaseq-analysis/GSE199679/counts/gene_counts_matrix.tsv"
)

output_file = (
    Path.home()
    / "rnaseq-analysis/GSE199679/counts/count_qc_summary.tsv"
)

# Read raw count matrix
df = pd.read_csv(input_file, sep="\t")

# Sample columns
samples = df.columns[1:]

# Library size = total assigned counts per sample
library_sizes = df[samples].sum()

# Number of genes with at least one count
detected_genes = (df[samples] > 0).sum()

# Number of genes with >= 10 counts
genes_ge_10 = (df[samples] >= 10).sum()

# Create QC summary
qc = pd.DataFrame({
    "Sample": samples,
    "Library_Size": library_sizes.values,
    "Genes_Detected": detected_genes.values,
    "Genes_Count_GE_10": genes_ge_10.values
})

qc.to_csv(output_file, sep="\t", index=False)

print("\nCount QC Summary\n")
print(qc.to_string(index=False))

print("\nTotal genes in matrix:", df.shape[0])

zero_all = (df[samples].sum(axis=1) == 0).sum()

print("Genes with zero counts in all samples:", zero_all)
print("\nOutput:", output_file)
