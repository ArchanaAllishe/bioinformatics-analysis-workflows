#!/bin/bash

set -euo pipefail

FASTQ_DIR="$HOME/rnaseq-download"
ANALYSIS_DIR="$HOME/rnaseq-analysis/GSE199679"
IMAGE="rnaseq-star"

samples=(
    "NM_5"
    "NM_6"
    "MP46_1"
    "MP46_2"
    "MP46_3"
)

for sample in "${samples[@]}"
do
    echo "========================================"
    echo "Aligning $sample"
    echo "========================================"

    mkdir -p "$ANALYSIS_DIR/alignment/$sample"

    docker run --rm \
      -v "$ANALYSIS_DIR:/analysis" \
      -v "$FASTQ_DIR:/fastq:ro" \
      "$IMAGE" \
      STAR \
      --runThreadN 6 \
      --genomeDir /analysis/star_index \
      --readFilesIn \
        "/fastq/${sample}_R1.fastq.gz" \
        "/fastq/${sample}_R2.fastq.gz" \
      --readFilesCommand zcat \
      --outFileNamePrefix "/analysis/alignment/${sample}/${sample}_" \
      --outSAMtype BAM SortedByCoordinate

    echo
    echo "STAR summary for $sample"
    grep -E \
    "Number of input reads|Uniquely mapped reads number|Uniquely mapped reads %|Number of reads mapped to multiple loci|% of reads mapped to multiple loci|% of reads unmapped" \
    "$ANALYSIS_DIR/alignment/$sample/${sample}_Log.final.out"

    echo
done

echo "========================================"
echo "All alignments completed."
echo "========================================"
