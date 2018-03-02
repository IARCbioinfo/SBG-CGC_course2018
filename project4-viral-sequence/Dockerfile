################## BASE IMAGE ######################

FROM biocontainers/biocontainers:latest

################## METADATA ######################
LABEL base.image="biocontainers:latest"
LABEL version="1"
LABEL software="NCBI BLAST+ and samtools"
LABEL software.version="blast:last and samtools:1.4.1"
LABEL description="BLAST and Samtools"
LABEL tags="Genomics"

################## MAINTAINER ######################

MAINTAINER Alexis Robitaille <robitaillea@students.iarc.fr>

################## INSTALLATION ######################

RUN conda install -y blast
RUN conda install -y samtools=1.4.1

WORKDIR /data/

##  http://eln.iarc.fr/robitaillea/2017-09-26/thesis-virus-detection-try1-26-sept-2017/
