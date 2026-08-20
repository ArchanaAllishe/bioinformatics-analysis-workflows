#!/usr/bin/env python3

import sys
import pandas as pd
from pathlib import Path


# --------------------------------------------------
# Command-line arguments
# --------------------------------------------------

if len(sys.argv) != 3:
    sys.exit(
        "Usage: python3 clean_featurecounts.py "
        "<gene_counts.txt> <gene_counts_matrix.tsv>"
    )

input_file = Path(sys.argv[1])
output_file = Path(sys.argv[2])


# --------------------------------------------------
# Read featureCounts output
# --------------------------------------------------

df = pd.read_csv(
    input_file,
    sep="\t",
    comment="#"
)


# --------------------------------------------------
# Remove featureCounts annotation columns
# --------------------------------------------------

df = df.drop(
    columns=[
        "Chr",
        "Start",
        "End",
        "Strand",
        "Length"
    ]
)


# --------------------------------------------------
# Rename BAM columns to sample names
# --------------------------------------------------

new_names = {}

for column in df.columns:

    if column != "Geneid":

        sample = Path(column).name

        sample = sample.replace(
            "_Aligned.sortedByCoord.out.bam",
            ""
        )

        new_names[column] = sample

df = df.rename(
    columns=new_names
)


# --------------------------------------------------
# Put samples in intended order
# --------------------------------------------------

sample_order = [
    "NM_4",
    "NM_5",
    "NM_6",
    "MP46_1",
    "MP46_2",
    "MP46_3"
]

df = df[
    ["Geneid"] + sample_order
]


# --------------------------------------------------
# Save cleaned matrix
# --------------------------------------------------

df.to_csv(
    output_file,
    sep="\t",
    index=False
)


print("Count matrix created successfully.")
print("Genes:", df.shape[0])
print("Samples:", df.shape[1] - 1)
print("Output:", output_file)
