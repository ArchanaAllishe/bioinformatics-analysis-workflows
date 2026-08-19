#!/usr/bin/env python3

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from pathlib import Path

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

df = pd.read_csv(input_file, sep="\t")

df = df.dropna(
    subset=["baseMean", "log2FoldChange"]
).copy()

# Avoid log10(0)
df = df[df["baseMean"] > 0]

# Significant DE genes
df["Significant"] = (
    (df["padj"] < 0.05) &
    (df["log2FoldChange"].abs() >= 1)
)

fig, ax = plt.subplots(figsize=(8, 6))

# Non-significant genes
ns = df[~df["Significant"]]

ax.scatter(
    np.log10(ns["baseMean"]),
    ns["log2FoldChange"],
    s=8,
    alpha=0.4,
    label="Not significant"
)

# Significant genes
sig = df[df["Significant"]]

ax.scatter(
    np.log10(sig["baseMean"]),
    sig["log2FoldChange"],
    s=8,
    alpha=0.5,
    label="Significant DE"
)

ax.axhline(
    0,
    linestyle="--",
    linewidth=1
)

ax.axhline(
    1,
    linestyle=":",
    linewidth=1
)

ax.axhline(
    -1,
    linestyle=":",
    linewidth=1
)

ax.set_xlabel(
    "log10 mean normalized expression"
)

ax.set_ylabel(
    "log2 Fold Change (MP46 vs NM)"
)

ax.set_title(
    "MA Plot: MP46 vs NM"
)

ax.legend(
    frameon=False
)

plt.tight_layout()

png_file = output_dir / "MA_MP46_vs_NM.png"
pdf_file = output_dir / "MA_MP46_vs_NM.pdf"

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

print("\nMA plot created.")
print(png_file)
print(pdf_file)
