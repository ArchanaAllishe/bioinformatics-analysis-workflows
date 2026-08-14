# Git and Version Control

## Overview

The RNA-seq project is maintained under Git version control and synchronized with a public GitHub repository.

Git is used to track source code, documentation, configuration files, workflow definitions, and analysis scripts while excluding large sequencing data and generated intermediate files.

## Repository

Repository:

```text
reproducible-rnaseq-pipeline
```

Remote hosting:

```text
GitHub
```

Primary branch:

```text
main
```

## Local Repository Setup

The repository was cloned to the macOS development environment using Git.

Example:

```bash
git clone https://github.com/<username>/reproducible-rnaseq-pipeline.git
```

The local repository was then verified with:

```bash
git status
```

A synchronized repository reports:

```text
On branch main
Your branch is up to date with 'origin/main'.

nothing to commit, working tree clean
```

## Remote Configuration

The configured remote repository can be checked with:

```bash
git remote -v
```

This confirms the relationship between the local project and the GitHub repository.

## Version-Control Workflow

The project follows a simple implementation workflow:

```text
Implement
   │
   ▼
Validate
   │
   ▼
Document
   │
   ▼
git add
   │
   ▼
git commit
   │
   ▼
git push
   │
   ▼
GitHub
```

This keeps documentation and implementation history synchronized.

## Commit Strategy

Commits are organized around completed project milestones rather than arbitrary file changes.

Examples include:

```text
Document Ubuntu ARM64 development environment
Document shared macOS Ubuntu project workspace
Add FastQC quality-control workflow
Add MultiQC reporting workflow
Add STAR alignment workflow
```

This produces a readable Git history that reflects the development of the pipeline.

## `.gitignore`

Files that should not be committed are excluded through `.gitignore`.

macOS metadata files are excluded using:

```text
.DS_Store
```

As the project expands, `.gitignore` will also exclude large or reproducible analysis files such as:

```text
*.fastq
*.fastq.gz
*.fq
*.fq.gz
*.bam
*.sam

data/raw/
reference/genome/
work/

.nextflow/
.nextflow.log*
```

Large sequencing data and generated intermediate files should not be stored directly in the Git repository.

Instead, the repository stores:

* scripts
* workflow definitions
* configuration
* metadata
* documentation
* lightweight summary results
* reproducibility information

## Repository Structure

The repository is organized so that documentation, code, configuration, data metadata, results, and reporting remain clearly separated.

```text
reproducible-rnaseq-pipeline/
│
├── README.md
├── LICENSE
├── .gitignore
│
├── docs/
│   ├── 01-ubuntu-environment.md
│   ├── 02-shared-project-workspace.md
│   └── 03-git-and-version-control.md
│
├── config/
├── workflow/
├── scripts/
├── containers/
├── data/
├── reference/
├── results/
└── report/
```

Directories are added when the corresponding workflow components are implemented.

## Synchronization

Before starting new work, repository status can be checked with:

```bash
git status
```

Remote changes can be integrated using:

```bash
git pull --rebase origin main
```

Completed changes are pushed using:

```bash
git push origin main
```

Using `--rebase` for routine synchronization keeps the project history linear when local and remote changes need to be reconciled.

## Validation

The Git/GitHub configuration is considered valid when:

```bash
git status
```

reports:

```text
On branch main
Your branch is up to date with 'origin/main'.

nothing to commit, working tree clean
```

and:

```bash
git remote -v
```

shows the expected GitHub repository for both fetch and push operations.

## Role in Reproducibility

Git provides the version-control layer of the RNA-seq project:

```text
Git / GitHub
     │
     ├── Documentation
     ├── Scripts
     ├── Workflow definitions
     ├── Configuration
     ├── Analysis code
     └── Change history
```

Together with containerization and workflow orchestration, version control provides a traceable record of how the analysis pipeline was built and modified.

## Outcome

A Git-based development workflow was established for the RNA-seq project, with the local repository synchronized to GitHub and project changes tracked through milestone-based commits.

The repository now provides a version-controlled foundation for subsequent quality-control, alignment, quantification, workflow automation, and reporting components.
