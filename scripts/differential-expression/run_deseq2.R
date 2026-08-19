#!/usr/bin/env Rscript

library(DESeq2)

# -----------------------------
# File paths
# -----------------------------

base_dir <- file.path(
  Sys.getenv("HOME"),
  "rnaseq-analysis",
  "GSE199679"
)

counts_file <- file.path(
  base_dir,
  "counts",
  "gene_counts_filtered.tsv"
)

metadata_file <- file.path(
  base_dir,
  "metadata",
  "samples.tsv"
)

output_dir <- file.path(
  base_dir,
  "results",
  "differential_expression"
)

dir.create(
  output_dir,
  recursive = TRUE,
  showWarnings = FALSE
)

# -----------------------------
# Read count matrix
# -----------------------------

counts <- read.delim(
  counts_file,
  row.names = 1,
  check.names = FALSE
)

# -----------------------------
# Read metadata
# -----------------------------

metadata <- read.delim(
  metadata_file,
  row.names = 1
)

# Match metadata order to count columns
metadata <- metadata[colnames(counts), , drop = FALSE]

# Set NM as reference group
metadata$Group <- factor(
  metadata$Group,
  levels = c("NM", "MP46")
)

# -----------------------------
# Create DESeq2 dataset
# -----------------------------

dds <- DESeqDataSetFromMatrix(
  countData = round(counts),
  colData = metadata,
  design = ~ Group
)

# -----------------------------
# Differential expression
# -----------------------------

dds <- DESeq(dds)

results_table <- results(
  dds,
  contrast = c("Group", "MP46", "NM"),
  alpha = 0.05
)

results_df <- as.data.frame(results_table)

results_df$Geneid <- rownames(results_df)

# Put Geneid first
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

# -----------------------------
# Save full results
# -----------------------------

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

# -----------------------------
# Significant genes
# -----------------------------

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

# -----------------------------
# Summary
# -----------------------------

upregulated <- sum(
  significant$log2FoldChange >= 1
)

downregulated <- sum(
  significant$log2FoldChange <= -1
)

cat("\nDifferential expression completed.\n\n")

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
  "\nResults directory:\n",
  output_dir,
  "\n"
)
