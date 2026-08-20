#!/usr/bin/env python3

import sys
import pandas as pd
from pathlib import Path


# --------------------------------------------------
# Command-line arguments
# --------------------------------------------------

if len(sys.argv) != 3:
    sys.exit(
        "Usage: python3 sample_correlation.py "
        "<vst_expression.tsv> "
        "<sample_correlation.tsv>"
    )

input_file = Path(sys.argv[1])
output_file = Path(sys.argv[2])


# --------------------------------------------------
# Read DESeq2 VST expression matrix
# --------------------------------------------------

df = pd.read_csv(
    input_file,
    sep="\t"
)


# --------------------------------------------------
# Remove gene IDs
# --------------------------------------------------

expression = df.drop(
    columns="Geneid"
)


# --------------------------------------------------
# Pearson correlation between samples
# --------------------------------------------------

correlation = expression.corr(
    method="pearson"
)


# --------------------------------------------------
# Save matrix
# --------------------------------------------------

correlation.to_csv(
    output_file,
    sep="\t"
)


print(
    "\nSample-to-sample Pearson correlation:\n"
)

print(
    correlation.round(3)
)

print("\nOutput:")
print(output_file)