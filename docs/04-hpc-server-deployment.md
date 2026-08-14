# Simulated HPC Server Deployment

## Overview

A local HPC-style environment was deployed to reproduce a typical institutional research-computing workflow.

The environment separates the researcher workstation from the remote Linux server and provides dedicated administrator and researcher accounts, SSH-based remote access, and shared research storage.

## Architecture

```text
MacBook Pro
│
├── Ubuntu Workstation VM
│      │
│      │ SSH
│      ▼
│
└── HPC Server VM
       Hostname: hpc-login
       │
       ├── hpcadmin
       │     Administrator account
       │
       ├── dev
       │     Researcher account
       │
       └── /shared
             ├── projects/
             ├── data/
             └── reference/
```

This separates local development from remote computational infrastructure.

## HPC Server

The server was deployed as a separate ARM64 virtual machine using UTM/QEMU on the Apple Silicon host.

Configuration:

```text
Operating system: Ubuntu Server 26.04 LTS
Architecture:     aarch64
Hostname:         hpc-login
CPU allocation:   4 cores
Memory:           6 GB
Virtual disk:     64 GB
Network:          UTM Shared Network
```

The server was installed without a macOS shared-directory mount so that access occurs through standard remote-computing mechanisms rather than direct host filesystem access.

## Account Separation

Two account roles were established.

### Administrator

```text
hpcadmin
```

The administrator account is responsible for system configuration, account provisioning, permissions, software installation, and HPC infrastructure management.

### Researcher

```text
dev
```

A separate non-administrative account was created for analysis work.

The researcher account does not require administrative privileges for normal project operations.

This models the separation commonly found on institutional HPC systems:

```text
System administration
        │
        ▼
    hpcadmin

Research computing
        │
        ▼
       dev
```

## Remote Access

OpenSSH Server was installed and enabled on `hpc-login`.

Initial connectivity was tested from the Ubuntu workstation using:

```bash
ssh dev@192.168.64.3
```

The connection was validated by checking:

```bash
whoami
hostname
pwd
```

which returned:

```text
dev
hpc-login
/home/dev
```

## SSH Key Authentication

An Ed25519 SSH key pair was generated on the Ubuntu workstation:

```bash
ssh-keygen -t ed25519 -C "dev-workstation"
```

The private key remains exclusively on the workstation:

```text
~/.ssh/id_ed25519
```

The corresponding public key was installed on the HPC researcher account using:

```bash
ssh-copy-id dev@192.168.64.3
```

This enabled key-based authentication between the workstation and HPC server.

## SSH Client Configuration

An SSH client alias was configured on the workstation in:

```text
~/.ssh/config
```

Configuration:

```text
Host hpc-login
    HostName 192.168.64.3
    User dev
    IdentityFile ~/.ssh/id_ed25519
```

The configuration file was protected with:

```bash
chmod 600 ~/.ssh/config
```

The researcher can therefore connect using:

```bash
ssh hpc-login
```

instead of specifying the username, IP address, and identity file manually.

## Research Group

A Linux group was configured for collaborative research access:

```text
bioinformatics
```

The researcher account `dev` was added to this group.

Group membership can be verified using:

```bash
groups
```

or:

```bash
getent group bioinformatics
```

## Shared HPC Storage

Shared research directories were established:

```text
/shared/
├── data/
├── projects/
│   └── reproducible-rnaseq-pipeline/
└── reference/
```

Their intended roles are:

```text
/shared/data
    Research datasets

/shared/reference
    Shared reference genomes and annotations

/shared/projects
    Collaborative analysis projects
```

The RNA-seq project workspace is:

```text
/shared/projects/reproducible-rnaseq-pipeline
```

## Ownership and Permissions

Shared directories are owned by:

```text
root:bioinformatics
```

Collaborative directories use:

```text
2775
```

permissions.

For example:

```bash
chmod 2775 /shared/projects/reproducible-rnaseq-pipeline
```

The leading `2` enables the setgid bit, causing newly created files and directories to inherit the `bioinformatics` group.

The resulting directory permissions were verified as:

```text
drwxrwsr-x root bioinformatics /shared/data
drwxrwsr-x root bioinformatics /shared/projects
drwxrwsr-x root bioinformatics /shared/projects/reproducible-rnaseq-pipeline
drwxrwsr-x root bioinformatics /shared/reference
```

## Researcher Write Validation

Write access was tested from the non-administrative `dev` account:

```bash
touch /shared/projects/reproducible-rnaseq-pipeline/test.txt
```

The resulting file ownership was:

```text
-rw-rw-r-- 1 dev bioinformatics ... test.txt
```

This confirmed that:

* the researcher can write to project storage;
* files remain owned by the researcher;
* files inherit the `bioinformatics` group;
* collaborative group write permissions are functioning.

The validation file was removed after testing.

## Resulting Workflow

The completed infrastructure supports the following workflow:

```text
Ubuntu Workstation
      │
      │ ssh hpc-login
      │ Ed25519 authentication
      ▼
HPC Login Server
      │
      ├── /home/dev
      │
      ├── /shared/data
      │
      ├── /shared/reference
      │
      └── /shared/projects
                │
                ▼
      reproducible-rnaseq-pipeline
```

The workstation is used for development and remote access, while analysis workloads and shared research resources are maintained within the HPC environment.

## Outcome

A functional HPC-style Linux environment was deployed and validated with:

* separate workstation and server systems;
* administrator and researcher account separation;
* OpenSSH remote access;
* Ed25519 key-based authentication;
* simplified SSH client configuration;
* research-group membership;
* shared project, data, and reference storage;
* group-based collaborative filesystem permissions.

This infrastructure provides the foundation for adding a workload scheduler and executing the RNA-seq pipeline through scheduled compute jobs rather than directly on the login environment.
