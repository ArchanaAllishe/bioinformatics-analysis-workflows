#!/usr/bin/env python3

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from pathlib import Path

# --------------------------------------------------
# Paths
# --------------------------------------------------

base = Path.home() / "rnaseq-analysis/GSE199679"

input_file = (
    base /
    "results/differential_expression/"
    "deseq2_MP46_vs_NM_annotated.tsv"
)

output_dir = (
    base /
    "results/differential_expression"
)

# --------------------------------------------------
# Read DESeq2 results
# --------------------------------------------------

df = pd.read_csv(
    input_file,
    sep="\t"
)

# Remove rows without adjusted p-values
df = df.dropna(
    subset=["padj", "log2FoldChange"]
).copy()

# Prevent log10(0)
df["padj_plot"] = df["padj"].clip(
    lower=np.finfo(float).tiny
)

df["minus_log10_padj"] = -np.log10(
    df["padj_plot"]
)

# --------------------------------------------------
# Classify genes
# --------------------------------------------------

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

# --------------------------------------------------
# Plot
# --------------------------------------------------

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

# Threshold lines
ax.axvline(
    -1,
    linestyle="--",
    linewidth=1
)

ax.axvline(
    1,
    linestyle="--",
    linewidth=1
)

ax.axhline(
    -np.log10(0.05),
    linestyle="--",
    linewidth=1
)

# --------------------------------------------------
# Label top genes
# --------------------------------------------------

significant = df[
    (df["padj"] < 0.05) &
    (abs(df["log2FoldChange"]) >= 1)
].copy()

top_genes = significant.nsmallest(
    10,
    "padj"
)

for _, row in top_genes.iterrows():

    ax.annotate(
        row["GeneSymbol"],
        (
            row["log2FoldChange"],
            row["minus_log10_padj"]
        ),
        fontsize=8,
        xytext=(3, 3),
        textcoords="offset points"
    )

# --------------------------------------------------
# Labels
# --------------------------------------------------

ax.set_xlabel(
    "log2 Fold Change (MP46 vs NM)"
)

ax.set_ylabel(
    "-log10 adjusted p-value"
)

ax.set_title(
    "Differential Expression: MP46 vs NM"
)

ax.legend(
    frameon=False
)

plt.tight_layout()

# --------------------------------------------------
# Save
# --------------------------------------------------

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
