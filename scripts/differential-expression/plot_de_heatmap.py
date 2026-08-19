#!/usr/bin/env python3

import pandas as pd
import matplotlib.pyplot as plt
from pathlib import Path

base = Path.home() / "rnaseq-analysis/GSE199679"

de_file = (
    base /
    "results/differential_expression/"
    "deseq2_MP46_vs_NM_annotated.tsv"
)

expression_file = (
    base /
    "counts/gene_counts_log2.tsv"
)

output_dir = (
    base /
    "results/differential_expression"
)

# Read data
de = pd.read_csv(de_file, sep="\t")
expression = pd.read_csv(expression_file, sep="\t")

# Keep significant DE genes
significant = de[
    (de["padj"] < 0.05) &
    (de["log2FoldChange"].abs() >= 1)
].copy()

# Select top 30 by adjusted p-value
top = significant.nsmallest(30, "padj")

# Get expression for those genes
heatmap = expression[
    expression["Geneid"].isin(top["Geneid"])
].copy()

# Add gene symbols and preserve DE ranking
heatmap = top[["Geneid", "GeneSymbol"]].merge(
    heatmap,
    on="Geneid"
)

heatmap = heatmap.set_index("GeneSymbol")

# Remove Geneid before plotting
heatmap = heatmap.drop(columns="Geneid")

# Row-wise Z-score
heatmap_z = heatmap.sub(
    heatmap.mean(axis=1),
    axis=0
)

heatmap_z = heatmap_z.div(
    heatmap.std(axis=1),
    axis=0
)

# Plot
fig, ax = plt.subplots(figsize=(8, 11))

image = ax.imshow(
    heatmap_z,
    aspect="auto"
)

ax.set_xticks(range(len(heatmap_z.columns)))
ax.set_xticklabels(
    heatmap_z.columns,
    rotation=45,
    ha="right"
)

ax.set_yticks(range(len(heatmap_z.index)))
ax.set_yticklabels(
    heatmap_z.index,
    fontsize=8
)

fig.colorbar(
    image,
    ax=ax,
    label="Row Z-score"
)

ax.set_title(
    "Top 30 Differentially Expressed Genes"
)

ax.set_xlabel("Sample")
ax.set_ylabel("Gene")

plt.tight_layout()

png_file = output_dir / "top30_DE_heatmap.png"
pdf_file = output_dir / "top30_DE_heatmap.pdf"

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

print("\nDE heatmap created.")
print(png_file)
print(pdf_file)
