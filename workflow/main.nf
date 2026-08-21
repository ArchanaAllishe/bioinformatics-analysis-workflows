nextflow.enable.dsl=2


/*
 * ============================================================
 * PARAMETERS
 * ============================================================
 */

params.reads =
    "/Users/dbondage/rnaseq-download/*_R{1,2}.fastq.gz"

params.bams =
    "/Users/dbondage/rnaseq-analysis/GSE199679/alignment/*/*_Aligned.sortedByCoord.out.bam"

params.rseqc_bed =
    "/Users/dbondage/rnaseq-analysis/GSE199679/reference/gencode.v48.bed"

params.gtf =
    "/Users/dbondage/rnaseq-analysis/GSE199679/reference/gencode.v48.primary_assembly.annotation.gtf"

params.metadata =
    "/Users/dbondage/rnaseq-analysis/GSE199679/metadata/samples.tsv"


/*
 * ============================================================
 * PROCESS 1: FASTQC
 * ============================================================
 */

process FASTQC {

    tag "${sample_id}"

    container 'quay.io/biocontainers/fastqc:0.12.1--hdfd78af_0'

    input:
    tuple val(sample_id), path(reads)

    output:
    path "*_fastqc.html", emit: html
    path "*_fastqc.zip", emit: zip

    script:
    """
    fastqc ${reads}
    """
}


/*
 * ============================================================
 * PROCESS 2: MULTIQC
 * ============================================================
 */

process MULTIQC {

    container 'quay.io/biocontainers/multiqc:1.35--pyhdfd78af_0'

    input:
    path fastqc_files

    output:
    path "multiqc_report.html", emit: report
    path "multiqc_data", emit: data

    script:
    """
    multiqc . -o .
    """
}


/*
 * ============================================================
 * PROCESS 3: SAMTOOLS INDEX
 * ============================================================
 */

process SAMTOOLS_INDEX {

    tag "${sample_id}"

    container 'quay.io/biocontainers/samtools:1.22.1--h96c455f_0'

    input:
    tuple val(sample_id), path(bam)

    output:
    tuple val(sample_id),
          path(bam),
          path("${bam}.bai"),
          emit: indexed_bam

    script:
    """
    samtools index ${bam}
    """
}


/*
 * ============================================================
 * PROCESS 4: RSEQC
 * ============================================================
 */

process RSEQC_INFER_EXPERIMENT {

    tag "${sample_id}"

    container 'quay.io/biocontainers/rseqc:5.0.3--py39hf95cd2a_0'

    input:
    tuple val(sample_id), path(bam), path(bai)
    path bed

    output:
    tuple val(sample_id),
          path("${sample_id}_infer_experiment.txt"),
          emit: strandedness

    script:
    """
    infer_experiment.py \
        -r ${bed} \
        -i ${bam} \
        > ${sample_id}_infer_experiment.txt
    """
}


/*
 * ============================================================
 * PROCESS 5: FEATURECOUNTS
 * ============================================================
 */

process FEATURECOUNTS {

    tag "gene_quantification"

    container 'quay.io/biocontainers/subread:2.0.6--he4a0461_0'

    cpus 4

    input:
    path bams
    path gtf

    output:
    path "gene_counts.txt", emit: counts
    path "gene_counts.txt.summary", emit: summary

    script:
    """
    featureCounts \
        -T ${task.cpus} \
        -p \
        --countReadPairs \
        -s 2 \
        -t exon \
        -g gene_id \
        -a ${gtf} \
        -o gene_counts.txt \
        ${bams}
    """
}


/*
 * ============================================================
 * PROCESS 6: CLEAN FEATURECOUNTS
 * ============================================================
 */

process CLEAN_FEATURECOUNTS {

    tag "clean_count_matrix"

    input:
    path counts_file
    path clean_script

    output:
    path "gene_counts_matrix.tsv", emit: clean_counts

    script:
    """
    python3 ${clean_script} \
        ${counts_file} \
        gene_counts_matrix.tsv
    """
}


/*
 * ============================================================
 * PROCESS 7: FILTER COUNTS
 * ============================================================
 */

process FILTER_COUNTS {

    tag "filter_low_expression"

    input:
    path count_matrix
    path filter_script

    output:
    path "gene_counts_filtered.tsv", emit: filtered_counts

    script:
    """
    python3 ${filter_script} \
        ${count_matrix} \
        gene_counts_filtered.tsv
    """
}


/*
 * ============================================================
 * PROCESS 8: DESEQ2
 * ============================================================
 */

process RUN_DESEQ2 {

    tag "MP46_vs_NM"

    input:
    path filtered_counts
    path metadata
    path deseq_script

    output:
    path "deseq2_results/deseq2_MP46_vs_NM.tsv",
        emit: all_results

    path "deseq2_results/deseq2_MP46_vs_NM_significant.tsv",
        emit: significant_results

    path "deseq2_results/vst_expression.tsv",
        emit: vst_expression

    script:
    """
    mkdir -p deseq2_results

    Rscript ${deseq_script} \
        ${filtered_counts} \
        ${metadata} \
        deseq2_results
    """
}


/*
 * ============================================================
 * PROCESS 9: ANNOTATE DESEQ2
 * ============================================================
 */

process ANNOTATE_DESEQ2 {

    tag "annotate_MP46_vs_NM"

    input:
    path deseq_results
    path gtf
    path annotation_script

    output:
    path "deseq2_MP46_vs_NM_annotated.tsv",
        emit: annotated_results

    script:
    """
    python3 ${annotation_script} \
        ${gtf} \
        ${deseq_results} \
        deseq2_MP46_vs_NM_annotated.tsv
    """
}


/*
 * ============================================================
 * PROCESS 10: VOLCANO
 * ============================================================
 */

process PLOT_VOLCANO {

    tag "MP46_vs_NM"

    input:
    path annotated_results
    path volcano_script

    output:
    path "volcano_results/volcano_MP46_vs_NM.png",
        emit: png

    path "volcano_results/volcano_MP46_vs_NM.pdf",
        emit: pdf

    script:
    """
    mkdir -p volcano_results

    python3 ${volcano_script} \
        ${annotated_results} \
        volcano_results
    """
}


/*
 * ============================================================
 * PROCESS 11: MA PLOT
 * ============================================================
 */

process PLOT_MA {

    tag "MP46_vs_NM"

    input:
    path annotated_results
    path ma_script

    output:
    path "ma_results/MA_MP46_vs_NM.png",
        emit: png

    path "ma_results/MA_MP46_vs_NM.pdf",
        emit: pdf

    script:
    """
    mkdir -p ma_results

    python3 ${ma_script} \
        ${annotated_results} \
        ma_results
    """
}


/*
 * ============================================================
 * PROCESS 12: PCA
 * ============================================================
 */

process PLOT_PCA {

    tag "MP46_vs_NM"

    input:
    path vst_expression
    path metadata
    path pca_script

    output:
    path "pca_results/PCA_MP46_vs_NM.png",
        emit: png

    path "pca_results/PCA_MP46_vs_NM.pdf",
        emit: pdf

    path "pca_results/PCA_coordinates.tsv",
        emit: coordinates

    script:
    """
    mkdir -p pca_results

    python3 ${pca_script} \
        ${vst_expression} \
        ${metadata} \
        pca_results
    """
}


/*
 * ============================================================
 * PROCESS 13: TOP-30 DE HEATMAP
 * ============================================================
 */

process PLOT_DE_HEATMAP {

    tag "top30_DE"

    input:
    path annotated_results
    path vst_expression
    path heatmap_script

    output:
    path "heatmap_results/top30_DE_heatmap.png",
        emit: png

    path "heatmap_results/top30_DE_heatmap.pdf",
        emit: pdf

    script:
    """
    mkdir -p heatmap_results

    python3 ${heatmap_script} \
        ${annotated_results} \
        ${vst_expression} \
        heatmap_results
    """
}


/*
 * ============================================================
 * PROCESS 14: SAMPLE CORRELATION
 * ============================================================
 */

process SAMPLE_CORRELATION {

    tag "sample_correlation"

    input:
    path vst_expression
    path correlation_script

    output:
    path "sample_correlation.tsv",
        emit: correlation

    script:
    """
    python3 ${correlation_script} \
        ${vst_expression} \
        sample_correlation.tsv
    """
}


/*
 * ============================================================
 * PROCESS 15: CORRELATION HEATMAP
 * ============================================================
 */

process PLOT_CORRELATION {

    tag "sample_correlation"

    input:
    path correlation_matrix
    path plot_script

    output:
    path "correlation_results/sample_correlation_heatmap.png",
        emit: png

    path "correlation_results/sample_correlation_heatmap.pdf",
        emit: pdf

    script:
    """
    mkdir -p correlation_results

    python3 ${plot_script} \
        ${correlation_matrix} \
        correlation_results
    """
}


/*
 * ============================================================
 * PROCESS 16: FUNCTIONAL ENRICHMENT
 * ============================================================
 */

process FUNCTIONAL_ENRICHMENT {

    tag "MP46_vs_NM"

    input:
    path annotated_results
    path enrichment_script

    output:
    path "enrichment_results",
        emit: directory

    script:
    """
    mkdir -p enrichment_results

    Rscript ${enrichment_script} \
        ${annotated_results} \
        enrichment_results
    """
}


/*
 * ============================================================
 * PROCESS 17: ENRICHMENT SUMMARY PLOTS
 * ============================================================
 */

process PLOT_ENRICHMENT {

    tag "enrichment_summary"

    input:
    path enrichment_dir
    path plot_script

    output:
    path "enrichment_plots",
        emit: directory

    script:
    """
    mkdir -p enrichment_plots

    python3 ${plot_script} \
        ${enrichment_dir} \
        enrichment_plots
    """
}


/*
 * ============================================================
 * PROCESS 18: QUARTO REPORT
 * ============================================================
 */

process QUARTO_REPORT {

    tag "html_report"

    input:
    path report_source

    path multiqc_report
    path multiqc_data

    path pca_png
    path correlation_png
    path volcano_png
    path ma_png
    path heatmap_png

    path enrichment_plots

    output:
    path "report_work/_site",
        emit: site

    script:
    """
    cp -R ${report_source} report_work

    mkdir -p report_work/images


    # --------------------------------------------------
    # MultiQC
    # --------------------------------------------------

    cp ${multiqc_report} \
        report_work/multiqc_report.html

    cp -R ${multiqc_data} \
        report_work/multiqc_data


    # --------------------------------------------------
    # Expression QC figures
    # --------------------------------------------------

    cp ${pca_png} \
        report_work/images/pca_expression_qc.png

    cp ${correlation_png} \
        report_work/images/sample_correlation_heatmap.png


    # --------------------------------------------------
    # Differential-expression figures
    # --------------------------------------------------

    cp ${volcano_png} \
        report_work/images/volcano_MP46_vs_NM.png

    cp ${ma_png} \
        report_work/images/MA_MP46_vs_NM.png

    cp ${heatmap_png} \
        report_work/images/top30_DE_heatmap.png


    # --------------------------------------------------
    # Functional-enrichment figures
    # --------------------------------------------------

    cp ${enrichment_plots}/GO_BP_Higher_in_MP46_summary.png \
        report_work/images/GO_BP_Higher_in_MP46_summary.png

    cp ${enrichment_plots}/GO_BP_Higher_in_NM_summary.png \
        report_work/images/GO_BP_Higher_in_NM_summary.png

    cp ${enrichment_plots}/Reactome_Higher_in_NM_summary.png \
        report_work/images/Reactome_Higher_in_NM_summary.png


    # --------------------------------------------------
    # Render Quarto
    # --------------------------------------------------

    cd report_work

    quarto render


    # --------------------------------------------------
    # Include interactive MultiQC report in final site
    # --------------------------------------------------

    cp multiqc_report.html \
        _site/multiqc_report.html

    cp -R multiqc_data \
        _site/multiqc_data
    """
}


/*
 * ============================================================
 * WORKFLOW
 * ============================================================
 */

workflow {


    /*
     * FASTQ input
     */

    reads_ch = Channel.fromFilePairs(
        params.reads,
        checkIfExists: true
    )


    /*
     * FastQC + MultiQC
     */

    fastqc_results = FASTQC(
        reads_ch
    )

    multiqc_results = MULTIQC(
        fastqc_results.zip.collect()
    )


    /*
     * Existing validated STAR BAMs
     */

    bam_ch = Channel
        .fromPath(
            params.bams,
            checkIfExists: true
        )
        .map { bam ->

            def sample_id = bam.baseName.replace(
                "_Aligned.sortedByCoord.out",
                ""
            )

            tuple(
                sample_id,
                bam
            )
        }


    /*
     * SAMtools
     */

    indexed_bams = SAMTOOLS_INDEX(
        bam_ch
    )


    /*
     * RSeQC
     */

    rseqc_bed_ch = Channel.value(
        file(params.rseqc_bed)
    )

    rseqc_results = RSEQC_INFER_EXPERIMENT(
        indexed_bams.indexed_bam,
        rseqc_bed_ch
    )


    /*
     * GTF
     */

    gtf_ch = Channel.value(
        file(params.gtf)
    )


    /*
     * BAM collection
     */

    bam_files_ch = indexed_bams.indexed_bam
        .map { sample_id, bam, bai ->
            bam
        }
        .collect()


    /*
     * featureCounts
     */

    featurecounts_results = FEATURECOUNTS(
        bam_files_ch,
        gtf_ch
    )


    /*
     * Clean counts
     */

    clean_script_ch = Channel.value(
        file(
            "${projectDir}/../scripts/downstream/clean_featurecounts.py"
        )
    )

    clean_results = CLEAN_FEATURECOUNTS(
        featurecounts_results.counts,
        clean_script_ch
    )


    /*
     * Filter counts
     */

    filter_script_ch = Channel.value(
        file(
            "${projectDir}/../scripts/downstream/filter_counts.py"
        )
    )

    filtered_results = FILTER_COUNTS(
        clean_results.clean_counts,
        filter_script_ch
    )


    /*
     * Metadata
     */

    metadata_ch = Channel.value(
        file(params.metadata)
    )


    /*
     * DESeq2
     */

    deseq_script_ch = Channel.value(
        file(
            "${projectDir}/../scripts/differential-expression/run_deseq2.R"
        )
    )

    deseq_results = RUN_DESEQ2(
        filtered_results.filtered_counts,
        metadata_ch,
        deseq_script_ch
    )


    /*
     * Annotation
     */

    annotation_script_ch = Channel.value(
        file(
            "${projectDir}/../scripts/differential-expression/annotate_deseq2.py"
        )
    )

    annotation_results = ANNOTATE_DESEQ2(
        deseq_results.all_results,
        gtf_ch,
        annotation_script_ch
    )


    /*
     * Volcano
     */

    volcano_script_ch = Channel.value(
        file(
            "${projectDir}/../scripts/differential-expression/plot_volcano.py"
        )
    )

    volcano_results = PLOT_VOLCANO(
        annotation_results.annotated_results,
        volcano_script_ch
    )


    /*
     * MA
     */

    ma_script_ch = Channel.value(
        file(
            "${projectDir}/../scripts/differential-expression/plot_ma.py"
        )
    )

    ma_results = PLOT_MA(
        annotation_results.annotated_results,
        ma_script_ch
    )


    /*
     * PCA
     */

    pca_script_ch = Channel.value(
        file(
            "${projectDir}/../scripts/differential-expression/plot_pca.py"
        )
    )

    pca_results = PLOT_PCA(
        deseq_results.vst_expression,
        metadata_ch,
        pca_script_ch
    )


    /*
     * Top-30 DE heatmap
     */

    heatmap_script_ch = Channel.value(
        file(
            "${projectDir}/../scripts/differential-expression/plot_de_heatmap.py"
        )
    )

    heatmap_results = PLOT_DE_HEATMAP(
        annotation_results.annotated_results,
        deseq_results.vst_expression,
        heatmap_script_ch
    )


    /*
     * Sample correlation
     */

    correlation_script_ch = Channel.value(
        file(
            "${projectDir}/../scripts/downstream/sample_correlation.py"
        )
    )

    correlation_results = SAMPLE_CORRELATION(
        deseq_results.vst_expression,
        correlation_script_ch
    )


    /*
     * Correlation heatmap
     */

    correlation_plot_script_ch = Channel.value(
        file(
            "${projectDir}/../scripts/downstream/plot_correlation.py"
        )
    )

    correlation_plot_results = PLOT_CORRELATION(
        correlation_results.correlation,
        correlation_plot_script_ch
    )


    /*
     * Functional enrichment
     */

    enrichment_script_ch = Channel.value(
        file(
            "${projectDir}/../scripts/functional-enrichment/run_enrichment.R"
        )
    )

    enrichment_results = FUNCTIONAL_ENRICHMENT(
        annotation_results.annotated_results,
        enrichment_script_ch
    )


    /*
     * Enrichment summary plots
     */

    enrichment_plot_script_ch = Channel.value(
        file(
            "${projectDir}/../scripts/functional-enrichment/plot_enrichment.py"
        )
    )

    enrichment_plot_results = PLOT_ENRICHMENT(
        enrichment_results.directory,
        enrichment_plot_script_ch
    )


    /*
     * Quarto source directory
     */

    report_source_ch = Channel.value(
        file(
            "${projectDir}/../report"
        )
    )


    /*
     * Render final report
     */

report_results = QUARTO_REPORT(
    report_source_ch,
    multiqc_results.report,
    multiqc_results.data,
    pca_results.png,
    correlation_plot_results.png,
    volcano_results.png,
    ma_results.png,
    heatmap_results.png,
    enrichment_plot_results.directory
)


    /*
     * Important outputs
     */

    multiqc_results.report.view {
        f -> "MultiQC report: ${f}"
    }

    deseq_results.all_results.view {
        f -> "DESeq2 results: ${f}"
    }

    deseq_results.vst_expression.view {
        f -> "VST matrix: ${f}"
    }

    pca_results.png.view {
        f -> "PCA: ${f}"
    }

    correlation_plot_results.png.view {
        f -> "Correlation heatmap: ${f}"
    }

    volcano_results.png.view {
        f -> "Volcano: ${f}"
    }

    ma_results.png.view {
        f -> "MA plot: ${f}"
    }

    heatmap_results.png.view {
        f -> "DE heatmap: ${f}"
    }

    enrichment_results.directory.view {
        f -> "Enrichment results: ${f}"
    }

    enrichment_plot_results.directory.view {
        f -> "Enrichment figures: ${f}"
    }

    report_results.site.view {
        f -> "Quarto website: ${f}"
    }
}