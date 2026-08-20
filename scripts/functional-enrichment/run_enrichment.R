#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(clusterProfiler)
  library(org.Hs.eg.db)
  library(ReactomePA)
  library(ggplot2)
})


# --------------------------------------------------
# Command-line arguments
# --------------------------------------------------

args <- commandArgs(trailingOnly = TRUE)

if (length(args) != 2) {
  stop(
    "Usage: Rscript run_enrichment.R ",
    "<annotated_deseq2.tsv> ",
    "<output_dir>"
  )
}

de_file <- args[1]
output_dir <- args[2]

dir.create(
  output_dir,
  recursive = TRUE,
  showWarnings = FALSE
)


# --------------------------------------------------
# Read annotated DESeq2 results
# --------------------------------------------------

de <- read.delim(
  de_file,
  check.names = FALSE
)


# --------------------------------------------------
# Define gene sets
# --------------------------------------------------

# Background = all genes tested by DESeq2 that have symbols

universe_symbols <- unique(
  de$GeneSymbol[
    !is.na(de$GeneSymbol) &
    de$GeneSymbol != ""
  ]
)


# Higher in MP46

mp46_symbols <- unique(
  de$GeneSymbol[
    !is.na(de$padj) &
    de$padj < 0.05 &
    de$log2FoldChange >= 1 &
    !is.na(de$GeneSymbol) &
    de$GeneSymbol != ""
  ]
)


# Higher in NM

nm_symbols <- unique(
  de$GeneSymbol[
    !is.na(de$padj) &
    de$padj < 0.05 &
    de$log2FoldChange <= -1 &
    !is.na(de$GeneSymbol) &
    de$GeneSymbol != ""
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


universe_entrez <- unique(
  universe_map$ENTREZID
)

mp46_entrez <- unique(
  mp46_map$ENTREZID
)

nm_entrez <- unique(
  nm_map$ENTREZID
)


# --------------------------------------------------
# GO Biological Process
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

  result_df <- as.data.frame(result)

  table_file <- file.path(
    output_dir,
    paste0(
      "GO_BP_",
      label,
      ".tsv"
    )
  )

  write.table(
    result_df,
    table_file,
    sep = "\t",
    quote = FALSE,
    row.names = FALSE
  )


  if (nrow(result_df) > 0) {

    png_file <- file.path(
      output_dir,
      paste0(
        "GO_BP_",
        label,
        "_top15.png"
      )
    )

    pdf_file <- file.path(
      output_dir,
      paste0(
        "GO_BP_",
        label,
        "_top15.pdf"
      )
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

    ggsave(
      pdf_file,
      p,
      width = 9,
      height = 7
    )
  }

  return(result)
}


# --------------------------------------------------
# Reactome
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

  result_df <- as.data.frame(result)

  table_file <- file.path(
    output_dir,
    paste0(
      "Reactome_",
      label,
      ".tsv"
    )
  )

  write.table(
    result_df,
    table_file,
    sep = "\t",
    quote = FALSE,
    row.names = FALSE
  )


  if (nrow(result_df) > 0) {

    png_file <- file.path(
      output_dir,
      paste0(
        "Reactome_",
        label,
        "_top15.png"
      )
    )

    pdf_file <- file.path(
      output_dir,
      paste0(
        "Reactome_",
        label,
        "_top15.pdf"
      )
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

    ggsave(
      pdf_file,
      p,
      width = 9,
      height = 7
    )
  }

  return(result)
}


# --------------------------------------------------
# Run enrichment
# --------------------------------------------------

cat("\nRunning GO Biological Process enrichment...\n")

go_mp46 <- run_go(
  mp46_entrez,
  "Higher_in_MP46"
)

go_nm <- run_go(
  nm_entrez,
  "Higher_in_NM"
)


cat("\nRunning Reactome enrichment...\n")

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

cat(
  "\nFunctional enrichment completed.\n\n"
)

cat(
  "DESeq2 background genes:",
  length(universe_symbols),
  "\n"
)

cat(
  "Higher in MP46:",
  length(mp46_symbols),
  "\n"
)

cat(
  "Higher in NM:",
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
  "\nOutput directory:\n",
  output_dir,
  "\n"
)