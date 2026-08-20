#!/usr/bin/env python3

import sys
import pandas as pd
import matplotlib.pyplot as plt
from pathlib import Path
from sklearn.decomposition import PCA


# --------------------------------------------------
# Command-line arguments
# --------------------------------------------------

if len(sys.argv) != 4:
    sys.exit(
        "Usage: python3 plot_pca.py "
        "<vst_expression.tsv> "
        "<samples.tsv> "
        "<output_dir>"
    )

expression_file = Path(sys.argv[1])
metadata_file = Path(sys.argv[2])
output_dir = Path(sys.argv[3])

output_dir.mkdir(
    parents=True,
    exist_ok=True
)


# --------------------------------------------------
# Read VST expression matrix
# --------------------------------------------------

expression = pd.read_csv(
    expression_file,
    sep="\t",
    index_col=0
)


# --------------------------------------------------
# Read metadata
# --------------------------------------------------

metadata = pd.read_csv(
    metadata_file,
    sep="\t",
    index_col=0
)


# --------------------------------------------------
# Transpose expression matrix
#
# Before:
# genes = rows
# samples = columns
#
# PCA needs:
# samples = rows
# genes = columns
# --------------------------------------------------

X = expression.T


# --------------------------------------------------
# Match metadata to samples
# --------------------------------------------------

metadata = metadata.loc[X.index]


# --------------------------------------------------
# PCA
# --------------------------------------------------

pca = PCA(
    n_components=2
)

components = pca.fit_transform(X)

percent = (
    pca.explained_variance_ratio_
    * 100
)


# --------------------------------------------------
# PCA results table
# --------------------------------------------------

pca_df = pd.DataFrame(
    {
        "Sample": X.index,
        "PC1": components[:, 0],
        "PC2": components[:, 1]
    }
)

pca_df["Group"] = metadata["Group"].values


# --------------------------------------------------
# Plot
# --------------------------------------------------

fig, ax = plt.subplots(
    figsize=(8, 6)
)

for group in pca_df["Group"].unique():

    subset = pca_df[
        pca_df["Group"] == group
    ]

    ax.scatter(
        subset["PC1"],
        subset["PC2"],
        s=80,
        label=group
    )

    for _, row in subset.iterrows():

        ax.annotate(
            row["Sample"],
            (
                row["PC1"],
                row["PC2"]
            ),
            xytext=(5, 5),
            textcoords="offset points",
            fontsize=9
        )


ax.set_xlabel(
    f"PC1 ({percent[0]:.1f}% variance)"
)

ax.set_ylabel(
    f"PC2 ({percent[1]:.1f}% variance)"
)

ax.set_title(
    "PCA of VST-transformed RNA-seq Counts"
)

ax.legend(
    title="Group",
    frameon=False
)

plt.tight_layout()


# --------------------------------------------------
# Save plot
# --------------------------------------------------

png_file = output_dir / "PCA_MP46_vs_NM.png"
pdf_file = output_dir / "PCA_MP46_vs_NM.pdf"

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


# --------------------------------------------------
# Save PCA coordinates
# --------------------------------------------------

coordinates_file = (
    output_dir /
    "PCA_coordinates.tsv"
)

pca_df.to_csv(
    coordinates_file,
    sep="\t",
    index=False
)


print("\nPCA completed.")
print(
    f"PC1 variance: {percent[0]:.2f}%"
)
print(
    f"PC2 variance: {percent[1]:.2f}%"
)
print("\nOutputs:")
print(png_file)
print(pdf_file)
print(coordinates_file)
