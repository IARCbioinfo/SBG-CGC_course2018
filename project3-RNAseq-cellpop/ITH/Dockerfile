FROM r-base
MAINTAINER lsoudade <lsoudade@gmail.com>
RUN wget http://pages.jh.edu/~fxie5/Research/BayCount_0.1.0.tar.gz && \
Rscript -e 'install.packages(c("combinat", "RcppArmadillo", "RColorBrewer", "gplots", "optparse"));install.packages("./BayCount_0.1.0.tar.gz",repos = NULL)' && \

wget https://raw.githubusercontent.com/IARCbioinfo/SBG-CGC_course2018/master/project3-RNAseq-cellpop/ITH/BayCount.R && \
mv BayCount.R /bin/
