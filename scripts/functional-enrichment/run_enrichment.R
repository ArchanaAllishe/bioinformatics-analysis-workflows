#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(clusterProfiler)
  library(org.Hs.eg.db)
  library(ReactomePA)
  library(ggplot2)
})

base_dir <- file.path(
  Sys.getenv("HOME"),
  "rnaseq-analysis",
  "GSE199679"
)

de_file <- file.path(
  base_dir,
  "results",
  "differential_expression",
  "deseq2_MP46_vs_NM_annotated.tsv"
)

output_dir <- file.path(
  base_dir,
  "results",
  "functional_enrichment"
)

dir.create(
  output_dir,
  recursive = TRUE,
  showWarnings = FALSE
)

# --------------------------------------------------
# Read DESeq2 results
# --------------------------------------------------

de <- read.delim(
  de_file,
  check.names = FALSE
)

# Background universe:
# all genes tested in DESeq2
universe_symbols <- unique(
  de$GeneSymbol[!is.na(de$GeneSymbol)]
)

# Significant directional gene sets
mp46_symbols <- unique(
  de$GeneSymbol[
    !is.na(de$padj) &
    de$padj < 0.05 &
    de$log2FoldChange >= 1
  ]
)

nm_symbols <- unique(
  de$GeneSymbol[
    !is.na(de$padj) &
    de$padj < 0.05 &
    de$log2FoldChange <= -1
  ]
)

# --------------------------------------------------
# Convert SYMBOL -> ENTREZID
# --------------------------------------------------

universe_map <- bitr(
  universe_symbols,
  fromType = "SYMBOL",
  toType = "ENTREZID",
  OrgDb = org.Hs.eg.db
)

mp46_map <- bitr(
  mp46_symbols,
  fromType = "SYMBOL",
  toType = "ENTREZID",
  OrgDb = org.Hs.eg.db
)

nm_map <- bitr(
  nm_symbols,
  fromType = "SYMBOL",
  toType = "ENTREZID",
  OrgDb = org.Hs.eg.db
)

universe_entrez <- unique(universe_map$ENTREZID)
mp46_entrez <- unique(mp46_map$ENTREZID)
nm_entrez <- unique(nm_map$ENTREZID)

# --------------------------------------------------
# Function: GO Biological Process
# --------------------------------------------------

run_go <- function(genes, label) {

  result <- enrichGO(
    gene = genes,
    universe = universe_entrez,
    OrgDb = org.Hs.eg.db,
    keyType = "ENTREZID",
    ont = "BP",
    pAdjustMethod = "BH",
    pvalueCutoff = 0.05,
    qvalueCutoff = 0.05,
    readable = TRUE
  )

  table_file <- file.path(
    output_dir,
    paste0("GO_BP_", label, ".tsv")
  )

  write.table(
    as.data.frame(result),
    table_file,
    sep = "\t",
    quote = FALSE,
    row.names = FALSE
  )

  if (nrow(as.data.frame(result)) > 0) {

    png_file <- file.path(
      output_dir,
      paste0("GO_BP_", label, "_top15.png")
    )

    p <- barplot(
      result,
      showCategory = 15,
      title = paste(
        "GO Biological Process -",
        label
      )
    )

    ggsave(
      png_file,
      p,
      width = 9,
      height = 7,
      dpi = 300
    )
  }

  result
}

# --------------------------------------------------
# Function: Reactome
# --------------------------------------------------

run_reactome <- function(genes, label) {

  result <- enrichPathway(
    gene = genes,
    universe = universe_entrez,
    organism = "human",
    pvalueCutoff = 0.05,
    pAdjustMethod = "BH",
    qvalueCutoff = 0.05,
    readable = TRUE
  )

  table_file <- file.path(
    output_dir,
    paste0("Reactome_", label, ".tsv")
  )

  write.table(
    as.data.frame(result),
    table_file,
    sep = "\t",
    quote = FALSE,
    row.names = FALSE
  )

  if (nrow(as.data.frame(result)) > 0) {

    png_file <- file.path(
      output_dir,
      paste0("Reactome_", label, "_top15.png")
    )

    p <- barplot(
      result,
      showCategory = 15,
      title = paste(
        "Reactome Pathways -",
        label
      )
    )

    ggsave(
      png_file,
      p,
      width = 9,
      height = 7,
      dpi = 300
    )
  }

  result
}

# --------------------------------------------------
# Run enrichment
# --------------------------------------------------

cat("\nRunning GO enrichment...\n")

go_mp46 <- run_go(
  mp46_entrez,
  "Higher_in_MP46"
)

go_nm <- run_go(
  nm_entrez,
  "Higher_in_NM"
)

cat("Running Reactome enrichment...\n")

reactome_mp46 <- run_reactome(
  mp46_entrez,
  "Higher_in_MP46"
)

reactome_nm <- run_reactome(
  nm_entrez,
  "Higher_in_NM"
)

# --------------------------------------------------
# Summary
# --------------------------------------------------

cat("\nFunctional enrichment completed.\n\n")

cat(
  "DESeq2 background genes:",
  length(universe_symbols),
  "\n"
)

cat(
  "MP46 genes:",
  length(mp46_symbols),
  "\n"
)

cat(
  "NM genes:",
  length(nm_symbols),
  "\n\n"
)

cat(
  "GO BP terms - Higher in MP46:",
  nrow(as.data.frame(go_mp46)),
  "\n"
)

cat(
  "GO BP terms - Higher in NM:",
  nrow(as.data.frame(go_nm)),
  "\n"
)

cat(
  "Reactome pathways - Higher in MP46:",
  nrow(as.data.frame(reactome_mp46)),
  "\n"
)

cat(
  "Reactome pathways - Higher in NM:",
  nrow(as.data.frame(reactome_nm)),
  "\n"
)

cat(
  "\nResults directory:\n",
  output_dir,
  "\n"
)
