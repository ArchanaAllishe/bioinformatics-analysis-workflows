#!/usr/bin/env python3

import sys
import pandas as pd
import re
from pathlib import Path


# --------------------------------------------------
# Command-line arguments
# --------------------------------------------------

if len(sys.argv) != 4:
    sys.exit(
        "Usage: python3 annotate_deseq2.py "
        "<gencode.gtf> "
        "<deseq2_results.tsv> "
        "<output.tsv>"
    )

gtf_file = Path(sys.argv[1])
results_file = Path(sys.argv[2])
output_file = Path(sys.argv[3])


# --------------------------------------------------
# Extract gene annotations from GENCODE GTF
# --------------------------------------------------

annotations = []

with open(gtf_file) as gtf:

    for line in gtf:

        if line.startswith("#"):
            continue

        fields = line.rstrip().split("\t")

        if len(fields) < 9:
            continue

        feature = fields[2]

        # Keep one entry per gene
        if feature != "gene":
            continue

        attributes = fields[8]

        gene_id = re.search(
            r'gene_id "([^"]+)"',
            attributes
        )

        gene_name = re.search(
            r'gene_name "([^"]+)"',
            attributes
        )

        gene_type = re.search(
            r'gene_type "([^"]+)"',
            attributes
        )

        annotations.append({
            "Geneid": gene_id.group(1) if gene_id else None,
            "GeneSymbol": gene_name.group(1) if gene_name else None,
            "GeneType": gene_type.group(1) if gene_type else None
        })


annotation_df = pd.DataFrame(
    annotations
)


# --------------------------------------------------
# Read DESeq2 results
# --------------------------------------------------

results = pd.read_csv(
    results_file,
    sep="\t"
)


# --------------------------------------------------
# Add gene annotations
# --------------------------------------------------

annotated = results.merge(
    annotation_df,
    on="Geneid",
    how="left"
)


# --------------------------------------------------
# Reorder columns
# --------------------------------------------------

columns = [
    "Geneid",
    "GeneSymbol",
    "GeneType",
    "baseMean",
    "log2FoldChange",
    "lfcSE",
    "stat",
    "pvalue",
    "padj"
]

annotated = annotated[
    columns
]


# --------------------------------------------------
# Save output
# --------------------------------------------------

annotated.to_csv(
    output_file,
    sep="\t",
    index=False
)


print("\nGene annotation completed.")

print(
    "Genes:",
    len(annotated)
)

print(
    "Genes with symbols:",
    annotated["GeneSymbol"].notna().sum()
)

print(
    "Genes without symbols:",
    annotated["GeneSymbol"].isna().sum()
)

print("\nOutput:")
print(output_file)
