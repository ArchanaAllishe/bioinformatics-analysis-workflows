#!/usr/bin/env python3

import sys
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from pathlib import Path


# --------------------------------------------------
# Command-line arguments
# --------------------------------------------------

if len(sys.argv) != 3:
    sys.exit(
        "Usage: python3 plot_enrichment.py "
        "<enrichment_input_dir> "
        "<output_dir>"
    )

input_dir = Path(sys.argv[1])
output_dir = Path(sys.argv[2])

output_dir.mkdir(
    parents=True,
    exist_ok=True
)


# --------------------------------------------------
# Plot function
# --------------------------------------------------

def make_plot(
    filename,
    title,
    output_name
):

    input_file = input_dir / filename

    if not input_file.exists():

        print(
            f"File not found: {input_file}"
        )

        return


    df = pd.read_csv(
        input_file,
        sep="\t"
    )


    if df.empty:

        print(
            f"No enriched terms: {filename}"
        )

        return


    # Significant enrichment terms

    df = df[
        df["p.adjust"].notna() &
        (df["p.adjust"] < 0.05)
    ].copy()


    if df.empty:

        print(
            f"No significant terms: {filename}"
        )

        return


    # Top 10 by adjusted p-value

    df = df.nsmallest(
        10,
        "p.adjust"
    )


    # Reverse order so strongest term appears on top

    df = df.sort_values(
        "p.adjust",
        ascending=False
    )


    df["minus_log10_padj"] = (
        -np.log10(
            df["p.adjust"]
        )
    )


    # --------------------------------------------------
    # Plot
    # --------------------------------------------------

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

    ax.set_title(
        title
    )


    plt.tight_layout()


    output_file = (
        output_dir /
        output_name
    )


    plt.savefig(
        output_file,
        dpi=300,
        bbox_inches="tight"
    )

    plt.close()


    print(
        "Created:",
        output_file
    )


# --------------------------------------------------
# Generate report figures
# --------------------------------------------------

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