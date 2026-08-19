#!/usr/bin/env python3

import pandas as pd
import matplotlib.pyplot as plt
from pathlib import Path

base = Path.home() / "rnaseq-analysis/GSE199679"

input_file = base / "counts/sample_correlation.tsv"
output_dir = base / "results/expression_qc"

output_dir.mkdir(parents=True, exist_ok=True)

# Read correlation matrix
corr = pd.read_csv(
    input_file,
    sep="\t",
    index_col=0
)

fig, ax = plt.subplots(figsize=(7, 6))

image = ax.imshow(
    corr,
    vmin=0,
    vmax=1
)

# Sample labels
ax.set_xticks(range(len(corr.columns)))
ax.set_xticklabels(corr.columns, rotation=45, ha="right")

ax.set_yticks(range(len(corr.index)))
ax.set_yticklabels(corr.index)

# Display correlation values
for i in range(len(corr.index)):
    for j in range(len(corr.columns)):
        ax.text(
            j,
            i,
            f"{corr.iloc[i, j]:.2f}",
            ha="center",
            va="center"
        )

fig.colorbar(image, ax=ax, label="Pearson correlation")

ax.set_title("Sample-to-Sample Expression Correlation")

plt.tight_layout()

plt.savefig(
    output_dir / "sample_correlation_heatmap.png",
    dpi=300
)

plt.savefig(
    output_dir / "sample_correlation_heatmap.pdf"
)

plt.close()

print("Correlation heatmap created:")
print(output_dir / "sample_correlation_heatmap.png")
print(output_dir / "sample_correlation_heatmap.pdf")
