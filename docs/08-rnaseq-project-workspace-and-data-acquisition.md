# RNA-Seq Project Workspace and Data Acquisition

## Objective

Establish a reproducible RNA-seq analysis workspace, select a resource-appropriate public dataset, define the experimental design, acquire sequencing reads, and transfer validated FASTQ files to HPC shared storage.

RNA-seq is used as the first demonstration workflow for the broader reproducible genomic analysis platform.

---

## Dataset

Public RNA-seq data were obtained from NCBI GEO/SRA and the European Nucleotide Archive (ENA).

The selected experiment contains human paired-end RNA-seq data.

For this demonstration, six biological samples were selected:

| Sample | Run Accession | Group |
|---|---|---|
| NM_4 | SRR18355076 | Normal |
| NM_5 | SRR18355077 | Normal |
| NM_6 | SRR18355078 | Normal |
| MP46_1 | SRR18355085 | MP46 |
| MP46_2 | SRR18355074 | MP46 |
| MP46_3 | SRR18355081 | MP46 |

Experimental design:

```text
Normal                     MP46
──────                     ──────
NM_4                       MP46_1
NM_5          vs           MP46_2
NM_6                       MP46_3

3 biological samples       3 biological samples
```

The sample metadata were reviewed before analysis to ensure that the selected samples represented independent biological samples rather than technical replicates.

---

## Resource-Aware Dataset Strategy

The original sequencing runs contain tens of millions of reads per sample and require substantially more storage and compute resources than necessary for demonstrating the workflow.

The local development environment has limited resources compared with a production HPC cluster.

Therefore, a controlled subset of:

```text
5,000,000 paired-end reads per sample
```

was used.

For each sample:

```text
R1 = 5,000,000 reads
R2 = 5,000,000 reads
```

Across six samples, the demonstration dataset contains approximately:

```text
30 million read pairs
60 million individual reads
```

This preserves realistic RNA-seq file structure and workflow behavior while keeping storage, alignment time, and memory requirements appropriate for the local environment.

The subset is intended for workflow development and demonstration rather than reproduction of the complete biological study.

---

## Project Storage Structure

Sequencing data and reference resources are stored outside the Git repository.

HPC shared storage:

```text
/shared/
├── data/
│   └── GSE199679/
│       └── raw_fastq/
│
├── projects/
│   └── reproducible-rnaseq-pipeline/
│
└── reference/
    └── GRCh38/
```

This separates:

- raw sequencing data
- reference resources
- analysis code
- documentation
- generated results

Large sequencing files are not tracked with Git.

---

## Data Acquisition Strategy

Initial testing used NCBI SRA Toolkit:

```text
prefetch
fasterq-dump
```

The HPC environment could access general HTTPS services, but SRA accession resolution experienced network timeouts.

ENA was therefore used as an alternative public source for the same sequencing runs.

Direct ENA access from the HPC environment was also restricted by the local virtualized network configuration.

Rather than modifying the functioning HPC network solely for data acquisition, the workflow was separated into two stages:

```text
Public sequencing archive
          │
          ▼
      macOS host
   Data acquisition
          │
          ▼
   FASTQ subsetting
          │
          ▼
     Validation
          │
       SCP transfer
          ▼
  HPC shared storage
          │
          ▼
   SLURM analysis
```

This separation reflects a common computational pattern in which data acquisition, data transfer, and scheduled analysis can occur on different systems.

---

## ENA FASTQ Retrieval

ENA run metadata were queried using the ENA API.

Example:

```bash
curl \
"https://www.ebi.ac.uk/ena/portal/api/filereport?accession=SRR18355076&result=read_run&fields=run_accession,library_layout,fastq_ftp,fastq_bytes&format=tsv"
```

The response confirmed:

- paired-end sequencing
- R1 FASTQ location
- R2 FASTQ location
- compressed file sizes

Using archive-provided URLs avoids hard-coding assumptions about FASTQ storage locations.

---

## Controlled FASTQ Subsetting

Instead of permanently downloading the complete sequencing runs, FASTQ data were streamed from ENA.

For example:

```bash
curl -L \
"https://ftp.sra.ebi.ac.uk/.../SRR18355076_1.fastq.gz" \
| gzip -dc \
| head -n 20000000 \
| gzip > NM_4_R1.fastq.gz
```

FASTQ contains four lines per read:

```text
5,000,000 reads × 4 lines/read
= 20,000,000 FASTQ lines
```

The same procedure was performed independently for R1 and R2.

The resulting files were named according to their biological sample rather than archive accession:

```text
NM_4_R1.fastq.gz
NM_4_R2.fastq.gz
```

This makes downstream analysis outputs easier to interpret.

### Streaming behavior

When `head` reaches 20,000,000 lines, it intentionally closes the pipeline.

Because `curl` may still be sending the original full FASTQ stream, it can report:

```text
curl: (23) Failure writing output to destination
```

In this context, the message results from intentional early termination of the stream. Output files were therefore accepted only after explicit integrity and read-count validation.

---

## FASTQ Validation

Each compressed FASTQ was checked for gzip integrity:

```bash
gzip -t NM_4_R1.fastq.gz
gzip -t NM_4_R2.fastq.gz
```

A successful check produces no error message.

Read counts were then verified without extracting the FASTQ files to disk:

```bash
gzip -dc NM_4_R1.fastq.gz | wc -l
```

Expected:

```text
20000000
```

which corresponds to:

```text
20,000,000 / 4 = 5,000,000 reads
```

Both R1 and R2 were required to contain exactly 5,000,000 reads.

The complete local dataset consists of:

```text
NM_4_R1.fastq.gz
NM_4_R2.fastq.gz

NM_5_R1.fastq.gz
NM_5_R2.fastq.gz

NM_6_R1.fastq.gz
NM_6_R2.fastq.gz

MP46_1_R1.fastq.gz
MP46_1_R2.fastq.gz

MP46_2_R1.fastq.gz
MP46_2_R2.fastq.gz

MP46_3_R1.fastq.gz
MP46_3_R2.fastq.gz
```

Total:

```text
6 biological samples
12 compressed FASTQ files
5 million read pairs per sample
```

---

## Transfer to HPC Shared Storage

Validated FASTQ files were transferred from the macOS host to the HPC environment using secure copy (`scp`):

```bash
scp *.fastq.gz \
dev@192.168.64.3:/shared/data/GSE199679/raw_fastq/
```

The transferred files were stored under:

```text
/shared/data/GSE199679/raw_fastq/
```

The number of FASTQ files was verified:

```bash
ls *.fastq.gz | wc -l
```

Expected:

```text
12
```

Compression integrity was checked again after transfer:

```bash
for f in *.fastq.gz
do
    echo "Checking $f"
    gzip -t "$f" || echo "FAILED: $f"
done
```

This provides an additional integrity check between data acquisition and analysis.

---

## Reproducibility Considerations

Several practices were incorporated into the acquisition workflow:

- archive run accessions are recorded in project metadata
- biological sample names are mapped to archive accessions
- paired-end layout is explicitly verified
- sequencing data are separated from source code
- FASTQ files are validated before analysis
- read counts are standardized for the demonstration dataset
- data transfer is separated from HPC computation
- large sequencing files are excluded from Git
- acquisition procedures are documented and scriptable

The complete public runs can be substituted for the demonstration subsets without changing the overall downstream pipeline structure.

---

## Workflow Status

Completed:

```text
✓ Public RNA-seq dataset identified
✓ Experimental metadata reviewed
✓ Biological samples selected
✓ 3 vs 3 experimental design established
✓ Paired-end sequencing confirmed
✓ HPC data directories created
✓ ENA FASTQ locations identified
✓ Resource-aware FASTQ subsets generated
✓ 5 million reads retained per mate
✓ FASTQ gzip integrity validated
✓ Read counts validated
✓ FASTQ files transferred to HPC shared storage
```

The validated dataset is now ready for the next stage:

```text
Raw FASTQ
   │
   ▼
FastQC
   │
   ▼
MultiQC
   │
   ▼
Read QC assessment
   │
   ▼
HISAT2 alignment
```

---

## Skills Demonstrated

- Public genomic dataset acquisition
- GEO/SRA/ENA metadata interpretation
- RNA-seq experimental design
- Biological replicate selection
- Paired-end FASTQ handling
- Bash scripting
- Streaming Unix pipelines
- Resource-aware data subsampling
- Data integrity validation
- Linux file management
- Secure data transfer with SCP
- HPC shared-storage organization
- Reproducible bioinformatics workflow design