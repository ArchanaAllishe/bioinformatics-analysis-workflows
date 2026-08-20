#!/usr/bin/env python3

import sys
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from pathlib import Path

if len(sys.argv) != 3:
    sys.exit(
        "Usage: python3 plot_volcano.py "
        "<annotated_deseq2.tsv> <output_dir>"
    )

input_file = Path(sys.argv[1])
output_dir = Path(sys.argv[2])

output_dir.mkdir(parents=True, exist_ok=True)

df = pd.read_csv(input_file, sep="\t")

df = df.dropna(
    subset=["padj", "log2FoldChange"]
).copy()

df["padj_plot"] = df["padj"].clip(
    lower=np.finfo(float).tiny
)

df["minus_log10_padj"] = -np.log10(
    df["padj_plot"]
)

df["Status"] = "Not significant"

df.loc[
    (df["padj"] < 0.05) &
    (df["log2FoldChange"] >= 1),
    "Status"
] = "Higher in MP46"

df.loc[
    (df["padj"] < 0.05) &
    (df["log2FoldChange"] <= -1),
    "Status"
] = "Higher in NM"

fig, ax = plt.subplots(figsize=(8, 7))

for status in [
    "Not significant",
    "Higher in NM",
    "Higher in MP46"
]:
    subset = df[df["Status"] == status]

    ax.scatter(
        subset["log2FoldChange"],
        subset["minus_log10_padj"],
        s=10,
        alpha=0.6,
        label=status
    )

ax.axvline(-1, linestyle="--", linewidth=1)
ax.axvline(1, linestyle="--", linewidth=1)

ax.axhline(
    -np.log10(0.05),
    linestyle="--",
    linewidth=1
)

significant = df[
    (df["padj"] < 0.05) &
    (df["log2FoldChange"].abs() >= 1)
].copy()

top_genes = significant.nsmallest(
    10,
    "padj"
)

for _, row in top_genes.iterrows():

    label = row["GeneSymbol"]

    if pd.notna(label):
        ax.annotate(
            label,
            (
                row["log2FoldChange"],
                row["minus_log10_padj"]
            ),
            fontsize=8,
            xytext=(3, 3),
            textcoords="offset points"
        )

ax.set_xlabel(
    "log2 Fold Change (MP46 vs NM)"
)

ax.set_ylabel(
    "-log10 adjusted p-value"
)

ax.set_title(
    "Differential Expression: MP46 vs NM"
)

ax.legend(frameon=False)

plt.tight_layout()

png_file = output_dir / "volcano_MP46_vs_NM.png"
pdf_file = output_dir / "volcano_MP46_vs_NM.pdf"

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

print("\nVolcano plot created.")
print(png_file)
print(pdf_file)
