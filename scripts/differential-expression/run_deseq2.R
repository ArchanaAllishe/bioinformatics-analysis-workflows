#!/usr/bin/env Rscript

library(DESeq2)


# --------------------------------------------------
# Command-line arguments
# --------------------------------------------------

args <- commandArgs(trailingOnly = TRUE)

if (length(args) != 3) {
  stop(
    "Usage: Rscript run_deseq2.R ",
    "<gene_counts_filtered.tsv> ",
    "<samples.tsv> ",
    "<output_dir>"
  )
}

counts_file <- args[1]
metadata_file <- args[2]
output_dir <- args[3]


dir.create(
  output_dir,
  recursive = TRUE,
  showWarnings = FALSE
)


# --------------------------------------------------
# Read filtered raw count matrix
# --------------------------------------------------

counts <- read.delim(
  counts_file,
  row.names = 1,
  check.names = FALSE
)


# --------------------------------------------------
# Read sample metadata
# --------------------------------------------------

metadata <- read.delim(
  metadata_file,
  row.names = 1
)


# --------------------------------------------------
# Match metadata to count columns
# --------------------------------------------------

metadata <- metadata[
  colnames(counts),
  ,
  drop = FALSE
]


# --------------------------------------------------
# Set NM as reference group
# --------------------------------------------------

metadata$Group <- factor(
  metadata$Group,
  levels = c(
    "NM",
    "MP46"
  )
)


# --------------------------------------------------
# Create DESeq2 dataset
# --------------------------------------------------

dds <- DESeqDataSetFromMatrix(
  countData = round(counts),
  colData = metadata,
  design = ~ Group
)


# --------------------------------------------------
# Run DESeq2
#
# Includes:
# size-factor estimation
# normalization
# dispersion estimation
# negative-binomial model fitting
# statistical testing
# --------------------------------------------------

dds <- DESeq(dds)


# --------------------------------------------------
# Differential-expression results
# --------------------------------------------------

results_table <- results(
  dds,
  contrast = c(
    "Group",
    "MP46",
    "NM"
  ),
  alpha = 0.05
)


results_df <- as.data.frame(
  results_table
)


results_df$Geneid <- rownames(
  results_df
)


results_df <- results_df[
  ,
  c(
    "Geneid",
    "baseMean",
    "log2FoldChange",
    "lfcSE",
    "stat",
    "pvalue",
    "padj"
  )
]


# Sort by adjusted p-value
results_df <- results_df[
  order(results_df$padj),
]


# --------------------------------------------------
# Save complete DESeq2 results
# --------------------------------------------------

write.table(
  results_df,
  file = file.path(
    output_dir,
    "deseq2_MP46_vs_NM.tsv"
  ),
  sep = "\t",
  quote = FALSE,
  row.names = FALSE
)


# --------------------------------------------------
# Significant genes
# --------------------------------------------------

significant <- subset(
  results_df,
  !is.na(padj) &
  padj < 0.05 &
  abs(log2FoldChange) >= 1
)


write.table(
  significant,
  file = file.path(
    output_dir,
    "deseq2_MP46_vs_NM_significant.tsv"
  ),
  sep = "\t",
  quote = FALSE,
  row.names = FALSE
)


# --------------------------------------------------
# Variance-stabilizing transformation
#
# Used for:
# PCA
# sample correlation
# heatmaps
#
# NOT used for DESeq2 statistical testing
# --------------------------------------------------

vsd <- vst(
  dds,
  blind = FALSE
)


vst_matrix <- assay(vsd)


vst_df <- data.frame(
  Geneid = rownames(vst_matrix),
  vst_matrix,
  check.names = FALSE
)


write.table(
  vst_df,
  file = file.path(
    output_dir,
    "vst_expression.tsv"
  ),
  sep = "\t",
  quote = FALSE,
  row.names = FALSE
)


# --------------------------------------------------
# Summary
# --------------------------------------------------

upregulated <- sum(
  significant$log2FoldChange >= 1
)


downregulated <- sum(
  significant$log2FoldChange <= -1
)


cat(
  "\nDifferential expression completed.\n\n"
)


cat(
  "Total genes tested:",
  nrow(results_df),
  "\n"
)


cat(
  "Significant genes:",
  nrow(significant),
  "\n"
)


cat(
  "Upregulated in MP46:",
  upregulated,
  "\n"
)


cat(
  "Downregulated in MP46:",
  downregulated,
  "\n"
)


cat(
  "VST genes:",
  nrow(vst_df),
  "\n"
)


cat(
  "VST samples:",
  ncol(vst_df) - 1,
  "\n"
)


cat(
  "\nResults directory:\n",
  output_dir,
  "\n"
)