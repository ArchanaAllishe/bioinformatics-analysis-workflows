# Shared macOS–Ubuntu Project Workspace

## Overview

A shared project workspace was configured between the macOS host and the Ubuntu virtual machine so the same RNA-seq project files can be accessed from both environments.

This avoids maintaining duplicate copies of the repository and allows:

* editing and Git operations from macOS
* Linux-based workflow execution from Ubuntu
* consistent access to the same project files
* simplified synchronization between development and analysis environments

## Architecture

```text
GitHub
  │
  ▼
macOS Project Directory
  │
  ▼
UTM Shared Directory
  │
  ▼
9p Filesystem
  │
  ▼
Ubuntu Mount Point
  │
  ▼
bindfs User Mapping
  │
  ▼
Ubuntu Project Workspace
```

## Shared Directory

The UTM shared directory is mounted inside Ubuntu at:

```text
/mnt/reproducible-rnaseq-pipeline
```

The shared filesystem uses the 9p protocol through UTM/QEMU.

The mounted filesystem can be verified with:

```bash
mount | grep reproducible
```

The shared directory is expected to appear as a 9p mount similar to:

```text
share on /mnt/reproducible-rnaseq-pipeline type 9p
```

## User-Accessible Project Mount

The shared directory is exposed inside the Ubuntu user's home directory using `bindfs`:

```text
/home/dev/reproducible-rnaseq-pipeline
```

This provides a convenient project path for command-line work while maintaining access to the original shared directory.

The mount can be verified with:

```bash
mount | grep reproducible
```

A successful configuration shows both:

```text
share on /mnt/reproducible-rnaseq-pipeline type 9p
```

and:

```text
/mnt/reproducible-rnaseq-pipeline on /home/dev/reproducible-rnaseq-pipeline type fuse.bindfs
```

## Persistent Mount Configuration

The shared workspace was configured in `/etc/fstab` so the project filesystem is automatically mounted when Ubuntu starts.

### UTM 9p Mount

The macOS shared directory is mounted in Ubuntu using the 9p filesystem:

```text
share /mnt/reproducible-rnaseq-pipeline 9p trans=virtio,version=9p2000.L,msize=104857600,cache=mmap,access=client,nofail 0 0
```

This establishes the UTM/QEMU shared filesystem at:

```text
/mnt/reproducible-rnaseq-pipeline
```

### bindfs User Mapping

A second mount exposes the shared project directory within the Ubuntu user's home directory:

```text
/mnt/reproducible-rnaseq-pipeline /home/dev/reproducible-rnaseq-pipeline fuse.bindfs map=502/1000:@20/@1000,nofail,x-systemd.requires-mounts-for=/mnt/reproducible-rnaseq-pipeline 0 0
```

The `bindfs` layer maps the macOS-side file ownership to the Ubuntu user and group, allowing the project files to be accessed from Ubuntu through:

```text
/home/dev/reproducible-rnaseq-pipeline
```

The `x-systemd.requires-mounts-for` option ensures that the underlying 9p filesystem is available before the `bindfs` mount is established.

The `nofail` option prevents a missing shared directory from blocking Ubuntu startup.

## Validation

The active mounts were verified with:

```bash
mount | grep reproducible
```

The configuration confirmed two filesystem layers:

```text
macOS Project Directory
        │
        ▼
UTM / QEMU
        │
        ▼
9p mount
/mnt/reproducible-rnaseq-pipeline
        │
        ▼
bindfs ownership mapping
        │
        ▼
/home/dev/reproducible-rnaseq-pipeline
```

This provides Ubuntu with a persistent, user-accessible view of the same project files maintained on the macOS host.


## Validation

The shared workspace was validated by confirming that both mounts were active:

```bash
mount | grep reproducible
```

The final configuration showed:

```text
share on /mnt/reproducible-rnaseq-pipeline type 9p
/mnt/reproducible-rnaseq-pipeline on /home/dev/reproducible-rnaseq-pipeline type fuse.bindfs
```

This confirmed that the macOS project directory was successfully exposed to Ubuntu through the UTM shared-folder mechanism.

## Role in the RNA-Seq Project

The shared workspace supports a clean separation of responsibilities:

```text
macOS
├── Git
├── GitHub
├── Documentation
└── Project Management

Ubuntu
├── Bash
├── FastQC
├── MultiQC
├── STAR
├── featureCounts
├── R
├── Docker
└── Nextflow
```

Both environments operate on the same underlying project files.

## Outcome

A persistent shared workspace was established between macOS and Ubuntu using UTM 9p file sharing and `bindfs`.

The configuration allows the RNA-seq repository to remain synchronized across the host and Linux environments without maintaining duplicate project copies.
