#!/bin/bash

set -euo pipefail

ANALYSIS_DIR="$HOME/rnaseq-analysis/GSE199679"
IMAGE="rnaseq-star"

samples=(
    "NM_4"
    "NM_5"
    "NM_6"
    "MP46_1"
    "MP46_2"
    "MP46_3"
)

mkdir -p "$ANALYSIS_DIR/counts"

bam_files=()

for sample in "${samples[@]}"
do
    bam_files+=(
        "/analysis/alignment/${sample}/${sample}_Aligned.sortedByCoord.out.bam"
    )
done

docker run --rm \
    -v "$ANALYSIS_DIR:/analysis" \
    "$IMAGE" \
    featureCounts \
        -T 6 \
        -p \
        --countReadPairs \
        -s 2 \
        -t exon \
        -g gene_id \
        -a /analysis/reference/gencode.v48.primary_assembly.annotation.gtf \
        -o /analysis/counts/gene_counts.txt \
        "${bam_files[@]}"

echo "featureCounts completed successfully."
echo "Counts: $ANALYSIS_DIR/counts/gene_counts.txt"
echo "Summary: $ANALYSIS_DIR/counts/gene_counts.txt.summary"
