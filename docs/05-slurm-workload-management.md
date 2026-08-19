# SLURM Workload Management

## Overview

SLURM was deployed on the simulated HPC environment to provide scheduler-managed execution of computational workloads.

This changes the workflow from running analysis commands directly on the HPC login environment to submitting jobs with defined CPU, memory, and runtime requirements.

## Architecture

The current single-node HPC simulation uses `hpc-login` for both SLURM controller and compute services.

```text
Ubuntu Workstation
        │
        │ SSH
        ▼
    hpc-login
        │
        │ sbatch
        ▼
┌───────────────────────┐
│ SLURM                 │
│                       │
│ slurmctld             │
│ Scheduler/controller  │
│        │              │
│        ▼              │
│ slurmd                │
│ Compute execution     │
└───────────┬───────────┘
            │
            ▼
       Batch job
```

This provides a functional SLURM environment while remaining small enough to run locally.

## SLURM Installation

SLURM and Munge were installed by the HPC administrator:

```bash
sudo apt update
sudo apt install slurm-wlm munge -y
```

Munge provides authentication between SLURM components.

## Hardware Detection

The compute resources available to SLURM were detected using:

```bash
slurmd -C
```

The server reported:

```text
NodeName=hpc-login
CPUs=4
Boards=1
SocketsPerBoard=1
CoresPerSocket=4
ThreadsPerCore=1
RealMemory=5386
```

These values were used to configure the SLURM node rather than manually estimating the available resources.

## Cluster Configuration

The simulated cluster was configured as:

```text
ClusterName: local-hpc
Controller:  hpc-login
Node:        hpc-login
Partition:   compute
CPUs:        4
RealMemory:  5386 MB
```

The main configuration is maintained in:

```text
/etc/slurm/slurm.conf
```

The node definition reflects the resources detected by `slurmd -C`.

## SLURM Services

The environment uses three primary services:

```text
munge
slurmctld
slurmd
```

Their roles are:

```text
munge
  └── authentication

slurmctld
  └── cluster controller and scheduler

slurmd
  └── executes jobs on compute resources
```

Service availability was verified with:

```bash
systemctl is-active munge
systemctl is-active slurmctld
systemctl is-active slurmd
```

## Compute Partition

A SLURM partition named:

```text
compute
```

was configured for scheduled workloads.

Cluster resources can be inspected using:

```bash
sinfo
```

When available for jobs, `hpc-login` is reported by SLURM in the `idle` state.

## Researcher Job Submission

SLURM functionality was validated from the non-administrative `dev` researcher account.

A test batch script was created:

```bash
nano hello-hpc.sh
```

with:

```bash
#!/bin/bash

#SBATCH --job-name=hello-hpc
#SBATCH --partition=compute
#SBATCH --cpus-per-task=1
#SBATCH --mem=512M
#SBATCH --time=00:05:00
#SBATCH --output=hello-hpc-%j.out

echo "Hello from SLURM"
echo "User: $USER"
echo "Host: $(hostname)"
echo "Job ID: $SLURM_JOB_ID"
echo "CPUs: $SLURM_CPUS_PER_TASK"
date
```

The job requested:

```text
Partition:       compute
CPU:             1
Memory:          512 MB
Maximum runtime: 5 minutes
```

## Job Submission

The researcher submitted the job using:

```bash
sbatch hello-hpc.sh
```

SLURM accepted the request as:

```text
Submitted batch job 1
```

This assigned the workload:

```text
Job ID: 1
```

## Queue Monitoring

Active and pending jobs can be inspected using:

```bash
squeue -u dev
```

The validation job completed quickly, so it was no longer present when the queue was inspected.

This demonstrates an important distinction:

```text
squeue
   │
   └── pending and running jobs

completed job
   │
   └── no longer displayed by squeue
```

## Job Output Validation

SLURM created:

```text
hello-hpc-1.out
```

The output was inspected using:

```bash
cat hello-hpc-*.out
```

Actual output:

```text
Hello from SLURM
User: dev
Host: hpc-login
Job ID: 1
CPUs: 1
Fri Aug 14 06:29:31 PM UTC 2026
```

This confirmed that:

* the job was accepted by SLURM;
* the job executed as the `dev` researcher;
* SLURM assigned Job ID `1`;
* one CPU was allocated as requested;
* execution occurred on `hpc-login`;
* scheduler-generated output was successfully written.

## SLURM Accounting

The command:

```bash
sacct
```

reported:

```text
Slurm accounting storage is disabled
```

SLURM accounting has therefore not yet been enabled in the current simulation.

This does not affect job scheduling or execution. Accounting can be added later to provide persistent job-history and resource-utilization records.

## HPC Execution Model

The validated workflow is:

```text
Ubuntu Workstation
        │
        │ ssh hpc-login
        ▼
dev@hpc-login
        │
        │ create batch script
        ▼
hello-hpc.sh
        │
        │ sbatch
        ▼
SLURM Controller
        │
        │ schedule resources
        ▼
Compute resources
        │
        │ execute
        ▼
hello-hpc-1.out
```

This establishes the execution model that will be used for subsequent bioinformatics workflows.

Instead of executing computationally intensive commands directly in the login session, workloads will be submitted to SLURM with explicit resource requirements.

For example:

```text
FastQC
   ↓
SLURM job

STAR
   ↓
SLURM job

featureCounts
   ↓
SLURM job

MultiQC
   ↓
SLURM job
```

## Current Limitation

The current environment is a **single-node HPC simulation**.

`hpc-login` currently provides both:

```text
SLURM controller
+
compute execution
```

A production institutional HPC would normally separate these responsibilities across login, controller, and multiple compute nodes.

The current architecture provides the same fundamental SLURM submission and scheduling workflow while remaining practical for local deployment.

## Outcome

A functional SLURM workload-management environment was deployed and validated.

The environment now supports:

* scheduler-controlled job execution;
* CPU and memory requests;
* runtime limits;
* batch job submission with `sbatch`;
* queue inspection with `squeue`;
* researcher-level job execution;
* SLURM job IDs;
* scheduler-generated output files;
* partition-based resource scheduling.

The first researcher batch job completed successfully as **SLURM Job 1**.

This establishes the workload-management layer required for running the RNA-seq pipeline as scheduled HPC jobs rather than interactive login-node processes.
