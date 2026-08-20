#!/usr/bin/env python3

import sys
import pandas as pd
import matplotlib.pyplot as plt
from pathlib import Path


# --------------------------------------------------
# Command-line arguments
# --------------------------------------------------

if len(sys.argv) != 3:
    sys.exit(
        "Usage: python3 plot_correlation.py "
        "<sample_correlation.tsv> "
        "<output_dir>"
    )

input_file = Path(sys.argv[1])
output_dir = Path(sys.argv[2])

output_dir.mkdir(
    parents=True,
    exist_ok=True
)


# --------------------------------------------------
# Read correlation matrix
# --------------------------------------------------

corr = pd.read_csv(
    input_file,
    sep="\t",
    index_col=0
)


# --------------------------------------------------
# Plot
# --------------------------------------------------

fig, ax = plt.subplots(
    figsize=(7, 6)
)

image = ax.imshow(
    corr,
    vmin=0,
    vmax=1
)


# Sample labels

ax.set_xticks(
    range(len(corr.columns))
)

ax.set_xticklabels(
    corr.columns,
    rotation=45,
    ha="right"
)

ax.set_yticks(
    range(len(corr.index))
)

ax.set_yticklabels(
    corr.index
)


# Correlation values

for i in range(len(corr.index)):

    for j in range(len(corr.columns)):

        ax.text(
            j,
            i,
            f"{corr.iloc[i, j]:.2f}",
            ha="center",
            va="center"
        )


fig.colorbar(
    image,
    ax=ax,
    label="Pearson correlation"
)

ax.set_title(
    "Sample-to-Sample Expression Correlation"
)

plt.tight_layout()


# --------------------------------------------------
# Save
# --------------------------------------------------

png_file = (
    output_dir /
    "sample_correlation_heatmap.png"
)

pdf_file = (
    output_dir /
    "sample_correlation_heatmap.pdf"
)

plt.savefig(
    png_file,
    dpi=300,
    bbox_inches="tight"
)

plt.savefig(
    pdf_file,
    bbox_inches="tight"
)

plt.close()


print(
    "Correlation heatmap created:"
)

print(png_file)
print(pdf_file)