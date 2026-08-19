#!/usr/bin/env python3

import pandas as pd
from pathlib import Path

base = Path.home() / "rnaseq-analysis/GSE199679"

input_file = (
    base /
    "results/differential_expression/"
    "deseq2_MP46_vs_NM_annotated.tsv"
)

output_dir = (
    base /
    "results/functional_enrichment"
)

output_dir.mkdir(
    parents=True,
    exist_ok=True
)

# Read annotated DESeq2 results
df = pd.read_csv(
    input_file,
    sep="\t"
)

# Significant genes
significant = df[
    df["padj"].notna() &
    (df["padj"] < 0.05) &
    (df["log2FoldChange"].abs() >= 1)
].copy()

# Higher in MP46
mp46 = significant[
    significant["log2FoldChange"] >= 1
].copy()

# Higher in NM
nm = significant[
    significant["log2FoldChange"] <= -1
].copy()

# Save complete directional tables
mp46.to_csv(
    output_dir / "genes_higher_in_MP46.tsv",
    sep="\t",
    index=False
)

nm.to_csv(
    output_dir / "genes_higher_in_NM.tsv",
    sep="\t",
    index=False
)

# Save simple gene-symbol lists for enrichment
mp46["GeneSymbol"].dropna().drop_duplicates().to_csv(
    output_dir / "genes_higher_in_MP46.txt",
    index=False,
    header=False
)

nm["GeneSymbol"].dropna().drop_duplicates().to_csv(
    output_dir / "genes_higher_in_NM.txt",
    index=False,
    header=False
)

print("\nGene sets created.\n")

print(
    "Higher in MP46:",
    len(mp46)
)

print(
    "Higher in NM:",
    len(nm)
)

print(
    "Total significant:",
    len(significant)
)

print(
    "\nOutput directory:",
    output_dir
)
