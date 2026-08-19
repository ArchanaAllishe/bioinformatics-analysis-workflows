#!/usr/bin/env python3

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from pathlib import Path

base = Path.home() / "rnaseq-analysis/GSE199679"

input_dir = base / "results/functional_enrichment"
output_dir = input_dir


def make_plot(filename, title, output_name):

    df = pd.read_csv(
        input_dir / filename,
        sep="\t"
    )

    if df.empty:
        print(f"No enriched terms: {filename}")
        return

    # Keep significant terms and select top 10 by adjusted p-value
    df = df[
        df["p.adjust"].notna() &
        (df["p.adjust"] < 0.05)
    ].copy()

    df = df.nsmallest(
        10,
        "p.adjust"
    )

    # Reverse order so strongest term appears at top
    df = df.sort_values(
        "p.adjust",
        ascending=False
    )

    df["minus_log10_padj"] = -np.log10(
        df["p.adjust"]
    )

    fig, ax = plt.subplots(
        figsize=(10, 6)
    )

    ax.barh(
        df["Description"],
        df["minus_log10_padj"]
    )

    ax.set_xlabel(
        "-log10 adjusted p-value"
    )

    ax.set_ylabel("")

    ax.set_title(title)

    plt.tight_layout()

    plt.savefig(
        output_dir / output_name,
        dpi=300,
        bbox_inches="tight"
    )

    plt.close()

    print(
        "Created:",
        output_dir / output_name
    )


make_plot(
    "GO_BP_Higher_in_MP46.tsv",
    "GO Biological Processes — Higher in MP46",
    "GO_BP_Higher_in_MP46_summary.png"
)

make_plot(
    "GO_BP_Higher_in_NM.tsv",
    "GO Biological Processes — Higher in NM",
    "GO_BP_Higher_in_NM_summary.png"
)

make_plot(
    "Reactome_Higher_in_NM.tsv",
    "Reactome Pathways — Higher in NM",
    "Reactome_Higher_in_NM_summary.png"
)
