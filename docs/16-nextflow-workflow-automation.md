# Nextflow Workflow Automation

## Overview

The RNA-seq analysis was first developed and validated as individual
command-line, Python, and R analysis steps. **Nextflow** was then used to
connect these validated components into an automated workflow.

The workflow is defined in:

```text
workflow/main.nf
workflow/nextflow.config
```

`main.nf` defines the analysis processes and data dependencies, while
`nextflow.config` controls workflow configuration and output publication.

The current implementation automates sequencing QC and the downstream RNA-seq
analysis while **reusing previously generated and validated STAR BAM files**
rather than repeating alignment.

---

## Why Nextflow Was Used

Running analysis stages manually requires the user to keep track of input
files, output locations, execution order, and dependencies between tools.

Nextflow manages these relationships automatically.

For example:

```text
featureCounts
      ↓
clean count matrix
      ↓
filter low-expression genes
      ↓
DESeq2
      ↓
annotation
      ↓
plots and enrichment
      ↓
Quarto report
```

A downstream process runs only when its required upstream inputs are
available.

This provides:

- automated data flow between analysis stages
- consistent execution of validated scripts
- fewer manual file-handling steps
- process-level reproducibility
- execution tracking
- caching of completed tasks
- workflow restart with `-resume`
- organized output publication

---

## Workflow Architecture

The implemented workflow follows:

```text
Paired-end FASTQ files
        │
        ├───────────────┐
        ↓               ↓
     FastQC           FastQC
      (R1)             (R2)
        └───────┬───────┘
                ↓
             MultiQC


Validated STAR BAM files
                ↓
         SAMtools indexing
                ↓
       RSeQC strandedness
                ↓
          featureCounts
                ↓
      count-matrix cleaning
                ↓
      low-expression filtering
                ↓
              DESeq2
                │
       ┌────────┼─────────────┐
       ↓        ↓             ↓
      PCA    DE plots    sample correlation
       │        │             │
       └────────┼─────────────┘
                ↓
          gene annotation
                ↓
      functional enrichment
                ↓
       enrichment figures
                ↓
          Quarto report
```

FASTQ files are used for sequencing-quality assessment, while validated STAR
BAM files provide the starting point for the automated downstream alignment-
based analysis.

---

## Nextflow DSL2

The workflow uses **Nextflow DSL2**:

```groovy
nextflow.enable.dsl=2
```

DSL2 allows the workflow to be organized as separate processes connected
through channels.

Each process defines:

```text
input
  ↓
command / script
  ↓
output
```

The output of one process can then become the input of another process.

---

## Input Parameters

The current workflow defines parameters for the principal analysis inputs:

```groovy
params.reads
params.bams
params.rseqc_bed
params.gtf
params.metadata
```

These represent:

| Parameter | Purpose |
|---|---|
| `params.reads` | Paired-end FASTQ files used for sequencing QC |
| `params.bams` | Validated STAR BAM files used for downstream analysis |
| `params.rseqc_bed` | BED annotation used by RSeQC |
| `params.gtf` | GENCODE GTF annotation used for quantification and gene annotation |
| `params.metadata` | Sample metadata used for differential-expression analysis |

The current implementation was developed for the GSE199679/GSE198801 case
study. A future workflow update will move remaining dataset-specific settings
into reusable parameters so that the same workflow can be applied to other
paired-end RNA-seq experiments without modifying the workflow code.

---

## FASTQ Sample Discovery

Paired-end FASTQ files are discovered with:

```groovy
Channel.fromFilePairs(
    params.reads,
    checkIfExists: true
)
```

For a naming pattern such as:

```text
*_R{1,2}.fastq.gz
```

Nextflow associates matching `R1` and `R2` files by their shared filename
prefix.

For example:

```text
NM_4_R1.fastq.gz
NM_4_R2.fastq.gz
        ↓
sample_id = NM_4
```

The resulting channel contains the sample identifier together with its paired
FASTQ files.

Conceptually:

```text
(sample_id, [R1, R2])
```

This removes the need to manually list each FASTQ pair in the workflow.

---

## Validated BAM Input

STAR alignment was performed and validated before the current downstream
Nextflow workflow was implemented.

The workflow therefore discovers existing coordinate-sorted BAM files using:

```groovy
Channel.fromPath(
    params.bams,
    checkIfExists: true
)
```

The sample identifier is recovered from each BAM filename by removing:

```text
_Aligned.sortedByCoord.out
```

For example:

```text
NM_4_Aligned.sortedByCoord.out.bam
                ↓
             NM_4
```

Nextflow then carries the BAM as:

```text
(sample_id, BAM)
```

This preserves the relationship between each alignment file and its biological
sample.

---

# Workflow Processes

## 1. FASTQC

The `FASTQC` process performs sequencing-quality assessment on the paired-end
FASTQ input.

Container:

```text
FastQC 0.12.1
```

The process receives:

```text
sample_id + paired FASTQ files
```

and generates:

```text
*_fastqc.html
*_fastqc.zip
```

The sample ID is used as the Nextflow process tag, making individual sample
tasks easier to identify in execution logs.

---

## 2. MULTIQC

The `MULTIQC` process collects the FastQC outputs and generates a combined QC
report.

Container:

```text
MultiQC 1.35
```

Command:

```bash
multiqc . -o .
```

Outputs:

```text
multiqc_report.html
multiqc_data/
```

The interactive HTML report provides a dataset-level view of sequencing
quality, while `multiqc_data/` contains the underlying structured QC results.

---

## 3. SAMTOOLS_INDEX

The `SAMTOOLS_INDEX` process creates an index for each validated STAR BAM file.

Container:

```text
SAMtools 1.22.1
```

Command:

```bash
samtools index sample.bam
```

Conceptually:

```text
(sample_id, BAM)
       ↓
SAMTOOLS_INDEX
       ↓
(sample_id, BAM, BAI)
```

The `.bai` index allows downstream tools to access genomic regions in a BAM
file efficiently.

---

## 4. RSEQC_INFER_EXPERIMENT

The indexed BAM files are passed to **RSeQC `infer_experiment.py`** to assess
library strandedness.

Container:

```text
RSeQC 5.0.3
```

The process receives:

```text
sample_id
BAM
BAI
reference BED
```

and generates:

```text
<sample_id>_infer_experiment.txt
```

The strandedness assessment supported reverse-stranded counting for this
dataset, which was carried forward to featureCounts.

---

## 5. FEATURECOUNTS

The indexed BAM files are collected and passed together to **featureCounts** to
generate one gene-level count matrix across the samples.

Container:

```text
Subread / featureCounts 2.0.6
```

The analysis uses:

```text
paired-end fragment counting
reverse-stranded mode
exon features
gene_id summarization
```

Outputs:

```text
gene_counts.txt
gene_counts.txt.summary
```

`gene_counts.txt` contains the raw gene-by-sample counts, while the summary
file records read-assignment statistics.

---

## 6. CLEAN_FEATURECOUNTS

The raw featureCounts output contains genomic annotation columns and
BAM-derived sample names.

The `CLEAN_FEATURECOUNTS` process calls:

```text
scripts/downstream/clean_featurecounts.py
```

to:

- remove featureCounts annotation columns not required by DESeq2
- convert BAM-derived column names to sample identifiers
- create a clean gene-by-sample count matrix

Output:

```text
gene_counts_matrix.tsv
```

---

## 7. FILTER_COUNTS

The cleaned count matrix is passed directly to:

```text
scripts/downstream/filter_counts.py
```

Genes are retained when they contain:

```text
≥ 10 raw counts in at least 3 samples
```

Output:

```text
gene_counts_filtered.tsv
```

This filtered raw-count matrix becomes the input for DESeq2.

---

## 8. RUN_DESEQ2

The `RUN_DESEQ2` process combines:

```text
filtered count matrix
        +
sample metadata
        +
run_deseq2.R
```

The process executes:

```text
scripts/differential-expression/run_deseq2.R
```

DESeq2 performs count normalization, negative-binomial modeling, and
differential-expression testing.

Important outputs include:

```text
deseq2_MP46_vs_NM.tsv
deseq2_MP46_vs_NM_significant.tsv
vst_expression.tsv
```

The raw counts are used for statistical modeling, while the
variance-stabilized expression matrix is used for sample-level QC and
visualization.

---

## 9. ANNOTATE_DESEQ2

DESeq2 results initially contain gene identifiers.

The `ANNOTATE_DESEQ2` process combines:

```text
DESeq2 results
      +
GENCODE GTF
      ↓
gene annotation
```

using:

```text
scripts/differential-expression/annotate_deseq2.py
```

The resulting table adds gene information required for interpretation and
functional enrichment.

---

## 10. PLOT_VOLCANO

The annotated DESeq2 results are passed to:

```text
scripts/differential-expression/plot_volcano.py
```

to generate the volcano plot.

The plot uses the project-wide differential-expression criterion:

```text
padj < 0.05
AND
|log2FoldChange| ≥ 1
```

---

## 11. PLOT_MA

The same annotated DESeq2 results are passed to:

```text
scripts/differential-expression/plot_ma.py
```

to visualize fold-change behavior across the range of average gene
expression.

---

## 12. PLOT_PCA

The DESeq2 variance-stabilized expression matrix and sample metadata are passed
to:

```text
scripts/differential-expression/plot_pca.py
```

Outputs include:

```text
PCA_MP46_vs_NM.png
PCA_MP46_vs_NM.pdf
PCA_coordinates.tsv
```

PCA provides a sample-level view of major expression variation and replicate
relationships.

---

## 13. PLOT_DE_HEATMAP

The workflow combines:

```text
annotated DESeq2 results
          +
VST expression matrix
          ↓
top-30 DE heatmap
```

using:

```text
scripts/differential-expression/plot_de_heatmap.py
```

The heatmap displays expression patterns of the top differentially expressed
genes across individual samples.

---

## 14. SAMPLE_CORRELATION

The variance-stabilized expression matrix is also passed to:

```text
scripts/downstream/sample_correlation.py
```

to calculate pairwise sample-expression correlations.

Output:

```text
sample_correlation.tsv
```

---

## 15. PLOT_CORRELATION

The correlation matrix is passed to:

```text
scripts/downstream/plot_correlation.py
```

to generate:

```text
sample_correlation_heatmap.png
sample_correlation_heatmap.pdf
```

This provides a visual assessment of similarity among biological replicates
and experimental groups.

---

## 16. FUNCTIONAL_ENRICHMENT

The annotated differential-expression results are passed to:

```text
scripts/functional-enrichment/run_enrichment.R
```

Significant genes are separated according to expression direction:

```text
Higher in MP46
Higher in NM
```

and analyzed with:

```text
Gene Ontology Biological Process
Reactome
```

The DESeq2-tested genes with available gene symbols are used as the enrichment
background.

---

## 17. PLOT_ENRICHMENT

The enrichment result directory is passed to:

```text
scripts/functional-enrichment/plot_enrichment.py
```

to generate summary figures for the major enriched processes and pathways.

These figures are subsequently incorporated into the final report.

---

## 18. QUARTO_REPORT

The final process assembles the principal analysis outputs into the
collaborator-facing Quarto website.

Inputs include:

```text
Quarto report source
MultiQC report
PCA figure
sample-correlation heatmap
volcano plot
MA plot
top-30 DE heatmap
functional-enrichment figures
```

The process creates a temporary report workspace, copies the analysis figures
into the expected report locations, and runs:

```bash
quarto render
```

The interactive MultiQC report is also copied into the final website.

The final site is produced under:

```text
report_work/_site/
```

and can then be published as the project results website.

---

# Data Flow Between Processes

A major benefit of Nextflow is that output files are passed between processes
through **channels** rather than manually locating and copying intermediate
files.

For example:

```text
FEATURECOUNTS
      │
      │ gene_counts.txt
      ↓
CLEAN_FEATURECOUNTS
      │
      │ gene_counts_matrix.tsv
      ↓
FILTER_COUNTS
      │
      │ gene_counts_filtered.tsv
      ↓
RUN_DESEQ2
      │
      ├── DESeq2 results
      │       ↓
      │   annotation
      │       ↓
      │   DE plots
      │       ↓
      │   enrichment
      │
      └── VST expression
              ↓
          PCA + correlation
```

This explicitly records the dependency between stages and reduces manual
handoff errors.

---

# Script Integration

The workflow does not duplicate the statistical and plotting logic inside
`main.nf`.

Instead, Nextflow executes the existing validated scripts stored under:

```text
scripts/
├── downstream/
├── differential-expression/
└── functional-enrichment/
```

For example:

```groovy
file(
    "${projectDir}/../scripts/differential-expression/run_deseq2.R"
)
```

This separation keeps:

```text
workflow orchestration → Nextflow
analysis logic         → Python / R scripts
software environment   → containers
reporting              → Quarto
```

Each component can therefore be maintained independently.

---

# Running the Workflow

From the repository root:

```bash
nextflow run workflow/main.nf \
    -c workflow/nextflow.config \
    -resume
```

The `-c` option specifies the project configuration file.

The `-resume` option allows Nextflow to reuse previously completed processes
when their inputs, scripts, and configuration have not changed.

---

## Why `-resume` Matters

Nextflow stores process execution information in its cache and `work/`
directory.

If a workflow fails late in the analysis or only a downstream script is
changed, it is often unnecessary to rerun all upstream processes.

For example:

```text
FastQC              cached
MultiQC             cached
featureCounts       cached
DESeq2              cached
volcano plot        changed
        ↓
only affected downstream tasks rerun
```

The workflow can therefore be restarted with:

```bash
nextflow run workflow/main.nf \
    -c workflow/nextflow.config \
    -resume
```

This can substantially reduce unnecessary computation.

---

# The Nextflow `work/` Directory

Nextflow executes each process inside a unique task directory under:

```text
work/
```

These directories contain staged inputs, generated outputs, command scripts,
and execution logs.

Important debugging files commonly include:

```text
.command.sh
.command.run
.command.out
.command.err
.command.log
.exitcode
```

For example:

```bash
cat work/<task-id>/.command.sh
cat work/<task-id>/.command.err
```

These files are useful when investigating a failed process.

The `work/` directory is part of Nextflow's execution cache and should not be
treated as the final results directory.

---

# Published Results

Final user-facing outputs are organized separately from the temporary
Nextflow `work/` directories.

This keeps:

```text
work/       → execution cache and intermediate task directories
results/    → organized analysis outputs
report/     → scientific report source
```

separate from one another.

This separation makes it easier to retain the analysis products that matter
while allowing temporary workflow files to be managed independently.

---

# Monitoring Workflow Execution

Nextflow reports each process as it is submitted and completed.

Process tags make sample-level tasks easier to identify. For example:

```text
FASTQC (NM_4)
SAMTOOLS_INDEX (NM_4)
RSEQC_INFER_EXPERIMENT (NM_4)
```

Important final outputs are also displayed by the workflow, including:

```text
MultiQC report
DESeq2 results
VST matrix
PCA
correlation heatmap
volcano plot
MA plot
DE heatmap
enrichment results
enrichment figures
Quarto website
```

This provides a quick confirmation that the expected downstream products were
generated.

---

# Troubleshooting

## Input files are not found

The workflow uses:

```groovy
checkIfExists: true
```

for major file inputs.

If the FASTQ or BAM pattern does not match existing files, Nextflow stops
rather than continuing with an empty input channel.

Check the configured paths and file naming patterns.

---

## A process fails

Inspect the failed task directory reported by Nextflow:

```bash
cat work/<task-id>/.command.err
cat work/<task-id>/.command.out
cat work/<task-id>/.command.sh
```

`.command.sh` shows the exact command executed by Nextflow, which is
particularly useful for reproducing the command manually during debugging.

---

## A changed script does not appear to run

Run the workflow again with:

```bash
nextflow run workflow/main.nf \
    -c workflow/nextflow.config \
    -resume
```

Nextflow evaluates whether the process inputs or script have changed and
reruns affected tasks while reusing valid cached results.

---

## Final results differ from the manual analysis

The automated workflow should reproduce the same validated analysis logic.

Check:

```text
input files
reference annotation
sample metadata
strandedness
count-filtering criteria
DESeq2 contrast
significance thresholds
software versions
```

before attributing a difference to Nextflow itself.

---

# Current Scope

The workflow currently demonstrates automation using the
**GSE199679/GSE198801 paired-end RNA-seq case study**.

The implemented workflow:

- performs FastQC and MultiQC from paired-end FASTQ files
- reuses validated STAR BAM files
- indexes BAM files
- assesses strandedness
- performs gene quantification
- cleans and filters the count matrix
- runs DESeq2
- annotates differential-expression results
- generates expression-QC and DE visualizations
- performs functional enrichment
- generates enrichment figures
- builds the Quarto report

Some dataset-specific assumptions remain, including the current MP46-versus-NM
contrast, output names, reference paths, and reverse-stranded featureCounts
setting.

These will be parameterized in the next workflow revision to support
**different paired-end RNA-seq datasets and variable sample numbers without
modifying the workflow code**.

---

# Reproducibility Benefits

Nextflow provides the orchestration layer that connects the individual
analysis components.

Together with version-controlled scripts and containerized software, the
project separates:

```text
Analysis methods
     ↓
Python + R + bioinformatics tools

Workflow orchestration
     ↓
Nextflow

Software environments
     ↓
Docker / versioned containers

Computing infrastructure
     ↓
Local Linux or HPC

Scientific reporting
     ↓
Quarto
```

This makes the analysis easier to trace, rerun, debug, and extend while
reducing manual handling between computational stages.
