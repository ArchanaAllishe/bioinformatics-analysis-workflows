#!/usr/bin/env python3

import sys
import pandas as pd
from pathlib import Path


# --------------------------------------------------
# Command-line arguments
# --------------------------------------------------

if len(sys.argv) != 3:
    sys.exit(
        "Usage: python3 filter_counts.py "
        "<gene_counts_matrix.tsv> <gene_counts_filtered.tsv>"
    )

input_file = Path(sys.argv[1])
output_file = Path(sys.argv[2])


# --------------------------------------------------
# Read count matrix
# --------------------------------------------------

df = pd.read_csv(
    input_file,
    sep="\t"
)

samples = df.columns[1:]


# --------------------------------------------------
# Low-expression filtering
#
# Keep genes with >=10 counts
# in at least 3 samples
# --------------------------------------------------

keep = (
    (df[samples] >= 10)
    .sum(axis=1)
    >= 3
)

filtered = df.loc[
    keep
].copy()


# --------------------------------------------------
# Save filtered matrix
# --------------------------------------------------

filtered.to_csv(
    output_file,
    sep="\t",
    index=False
)


print("Low-expression filtering completed.")
print("Genes before filtering:", len(df))
print("Genes after filtering:", len(filtered))
print(
    "Genes removed:",
    len(df) - len(filtered)
)
print("Output:", output_file)
