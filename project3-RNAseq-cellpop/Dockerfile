FROM icbi/quantiseq:latest
CMD ["/bin/bash"]

# File Author / Maintainer
MAINTAINER Nicolas Alcala <alcalan@fellows.iarc.fr>

RUN	DEBIAN_FRONTEND=noninteractive yum install -y wget && \
	yum install -y ncurses-devel && \
	yum install -y wget bzip2 && \

wget https://raw.githubusercontent.com/IARCbioinfo/SBG-CGC_course2018/master/project3-RNAseq-cellpop/quanTIseq_pipeline_CGC.sh && \
mv quanTIseq_pipeline_CGC.sh /bin/ && \
chmod 755 /bin/quanTIseq_pipeline_CGC.sh && \
mkdir /home/Input && \
mkdir /home/user_output && \

wget https://github.com/samtools/samtools/releases/download/1.3.1/samtools-1.3.1.tar.bz2 && \
  tar -jxf samtools-1.3.1.tar.bz2 && \
  cd samtools-1.3.1 && \
  make && \
  make install && \
  cd .. && \
rm -rf samtools-1.3.1 samtools-1.3.1.tar.bz2
