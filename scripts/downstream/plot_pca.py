#!/usr/bin/env python3

import pandas as pd
import matplotlib.pyplot as plt
from pathlib import Path

base = Path.home() / "rnaseq-analysis/GSE199679"

input_file = base / "counts/pca_coordinates.tsv"
output_dir = base / "results/expression_qc"

output_dir.mkdir(parents=True, exist_ok=True)

df = pd.read_csv(input_file, sep="\t")

fig, ax = plt.subplots(figsize=(7, 5))

markers = {
    "NM": "o",
    "MP46": "s"
}

for group in ["NM", "MP46"]:
    subset = df[df["Group"] == group]

    ax.scatter(
        subset["PC1"],
        subset["PC2"],
        label=group,
        marker=markers[group],
        s=90
    )

    for _, row in subset.iterrows():
        ax.annotate(
            row["Sample"],
            (row["PC1"], row["PC2"]),
            xytext=(6, 5),
            textcoords="offset points"
        )

ax.set_xlabel("PC1 (88.79% variance)")
ax.set_ylabel("PC2 (3.73% variance)")
ax.set_title("PCA of RNA-seq Expression Profiles")

ax.axhline(0, linewidth=0.5)
ax.axvline(0, linewidth=0.5)

ax.legend(title="Group")

plt.tight_layout()

plt.savefig(
    output_dir / "pca_expression_qc.png",
    dpi=300
)

plt.savefig(
    output_dir / "pca_expression_qc.pdf"
)

plt.close()

print("PCA figures created:")
print(output_dir / "pca_expression_qc.png")
print(output_dir / "pca_expression_qc.pdf")
