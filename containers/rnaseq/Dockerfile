FROM mambaorg/micromamba:latest

RUN micromamba install -y -n base \
    -c conda-forge \
    -c bioconda \
    star=2.7.11b \
    samtools \
    rseqc \
    ucsc-gtftogenepred \
    ucsc-genepredtobed \
    && micromamba clean --all --yes

CMD ["STAR", "--version"]
