################## BASE IMAGE ######################

FROM biocontainers/biocontainers:latest

################## METADATA ######################
LABEL base.image="biocontainers:latest"
LABEL version="1"
LABEL software="NCBI BLAST+ adn samtools"
LABEL software.version="2.2.31"
LABEL description="basic local alignment search tool"
LABEL website="http://blast.ncbi.nlm.nih.gov/Blast.cgi?CMD=Web&PAGE_TYPE=BlastHome"
LABEL documentation="http://blast.ncbi.nlm.nih.gov/Blast.cgi?CMD=Web&PAGE_TYPE=BlastHome"
LABEL license="http://blast.ncbi.nlm.nih.gov/Blast.cgi?CMD=Web&PAGE_TYPE=BlastHome"
LABEL tags="Genomics"

################## MAINTAINER ######################

MAINTAINER Alexis Robitaille <robitaillea@students.iarc.fr>

################## INSTALLATION ######################

RUN conda install -y blast
RUN conda install -y samtools=1.4.1

WORKDIR /data/
