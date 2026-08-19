# Ubuntu Linux Environment

## Overview

A local Ubuntu Linux environment was deployed on an **Apple M5 Pro MacBook Pro** using **UTM/QEMU virtualization**.

The environment provides a dedicated ARM64 Linux platform for development and execution of the reproducible RNA-seq workflow, including bioinformatics tools, shell-based processing, containerization, workflow automation, and remote HPC integration.

## Host System

| Component    | Configuration         |
| ------------ | --------------------- |
| Hardware     | Apple MacBook Pro     |
| Processor    | Apple M5 Pro          |
| Memory       | 24 GB                 |
| Host OS      | macOS Tahoe 26.6      |
| Build        | 25G72                 |
| Architecture | Apple Silicon / ARM64 |

## Virtualization

Ubuntu was deployed as a virtual machine using **UTM with QEMU virtualization**.

```text
Apple MacBook Pro
       │
       ▼
macOS Tahoe 26.6
       │
       ▼
UTM / QEMU
       │
       ▼
Ubuntu 26.04 LTS (ARM64)
```

This configuration preserves macOS as the host operating system while providing an isolated Linux environment for computational workflows.

## Verified Ubuntu Configuration

The running Ubuntu environment was validated from the Linux command line.

| Component                 | Verified Configuration                       |
| ------------------------- | -------------------------------------------- |
| Distribution              | Ubuntu 26.04 LTS                             |
| Codename                  | Resolute Raccoon                             |
| Architecture              | `aarch64`                                    |
| Allocated CPUs            | 6                                            |
| VM Memory                 | 12 GB configured / ~11 GiB visible to Ubuntu |
| Swap                      | 4.0 GiB                                      |
| Root Filesystem           | 146 GB                                       |
| Root Filesystem Used      | 11 GB                                        |
| Root Filesystem Available | 128 GB                                       |
| Virtual Disk Device       | `/dev/vda2`                                  |
| Networking                | UTM Shared Network (`virtio-net-pci`)        |

## System Validation

The environment was validated using:

```bash
cat /etc/os-release
uname -m
nproc
free -h
df -h /
```

The checks confirmed:

* Ubuntu 26.04 LTS installation
* ARM64 (`aarch64`) architecture
* 6 CPU cores available to the VM
* approximately 11 GiB of usable memory
* 4 GiB swap allocation
* 146 GB root filesystem

## System Update

Ubuntu package metadata and installed packages were updated using:

```bash
sudo apt update
sudo apt upgrade -y
```

This established an up-to-date base operating system before installation of workflow-specific software.

## Networking

The VM uses UTM shared networking through the `virtio-net-pci` virtual network interface.

Network connectivity supports:

* package installation
* Git/GitHub access
* public sequencing-data retrieval
* container image retrieval
* SSH-based remote computing

Connectivity can be verified with:

```bash
ping -c 4 github.com
```

## Automatic Suspend

Automatic suspend was disabled to prevent long-running local computational processes from being interrupted by Ubuntu power-management settings.

The configuration can be verified with:

```bash
gsettings get org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type
gsettings get org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type
```

A configured value of:

```text
'nothing'
```

indicates that automatic suspend is disabled for the corresponding power state.

## Project Workspace Integration

The project repository is maintained under Git/GitHub version control and made accessible to the Ubuntu environment for Linux-based workflow execution.

This allows source code and documentation to remain synchronized while computational tasks are executed within the Linux VM.

```text
GitHub Repository
       │
       ▼
MacBook Pro
       │
       ▼
Shared Project Workspace
       │
       ▼
Ubuntu VM
       │
       ▼
RNA-Seq Workflow
```

## Role in the RNA-Seq Workflow

The Ubuntu VM provides the local Linux execution environment for subsequent pipeline components:

```text
Ubuntu Linux
    │
    ├── Bash
    ├── Git / GitHub
    ├── SSH
    ├── FastQC / MultiQC
    ├── STAR
    ├── featureCounts
    ├── R
    ├── Docker
    └── Nextflow
         │
         ▼
Reproducible RNA-Seq Pipeline
```

Individual components are documented as they are implemented and validated.

## Outcome

A functional **Ubuntu 26.04 LTS ARM64** environment was established on an Apple M5 Pro MacBook Pro using UTM/QEMU virtualization.

The VM was configured with **6 CPUs, 12 GB memory, 4 GiB swap, and a 146 GB root filesystem**, providing a dedicated Linux platform for development, testing, and execution of the reproducible RNA-seq workflow.
