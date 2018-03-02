## DockerFile Neutrality
FROM r-base
MAINTAINER lsoudade <lsoudade@gmail.com>
RUN wget http://pages.jh.edu/~fxie5/Research/BayCount_0.1.0.tar.gz && \
Rscript -e "install.packages(c("combinat", "RcppArmadillo", "RColorBrewer", "gplots"));install.packages("./BayCount_0.1.0.tar.gz",repos = NULL)"
