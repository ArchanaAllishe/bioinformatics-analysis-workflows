#!/usr/bin/env python3

import pandas as pd
from pathlib import Path

# Input and output files
input_file = Path.home() / "rnaseq-analysis/GSE199679/counts/gene_counts.txt"
output_file = Path.home() / "rnaseq-analysis/GSE199679/counts/gene_counts_matrix.tsv"

# Read featureCounts output.
# The first line starts with "#" and contains the featureCounts command.
df = pd.read_csv(
    input_file,
    sep="\t",
    comment="#"
)

# Remove featureCounts annotation columns that are not needed
# in the expression count matrix.
df = df.drop(
    columns=["Chr", "Start", "End", "Strand", "Length"]
)

# Rename BAM-path columns to simple sample names.
new_names = {}

for column in df.columns:
    if column != "Geneid":
        sample = Path(column).name
        sample = sample.replace("_Aligned.sortedByCoord.out.bam", "")
        new_names[column] = sample

df = df.rename(columns=new_names)

# Put samples in the intended order.
sample_order = [
    "NM_4",
    "NM_5",
    "NM_6",
    "MP46_1",
    "MP46_2",
    "MP46_3"
]

df = df[["Geneid"] + sample_order]

# Save as tab-separated file.
df.to_csv(
    output_file,
    sep="\t",
    index=False
)

print("Count matrix created successfully.")
print(f"Genes: {df.shape[0]}")
print(f"Samples: {df.shape[1] - 1}")
print(f"Output: {output_file}")
