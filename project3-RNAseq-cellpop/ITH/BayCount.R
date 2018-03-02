# script for ITH estimation using package BayCount
library("optparse")

option_list = list(
  make_option(c("-r", "--reads"), type="character", default=".", help="folder with count files [default= %default]", metavar="character"),
  make_option(c("-o", "--out"), type="character", default="out", help="output directory name [default= %default]", metavar="character")
); 

opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);

# 
system(paste("gunzip",opt$reads,"/*.gz"))
fi = grep( "counts" , list.files(opt$reads,full.names = T) ,value=T)
Y = sapply(fi, function(x) read.table(x,row.names = 1)[,1] )

library(Rcpp)
library(combinat)
library(RColorBrewer)
library(gplots)
require(BayCount)
hyper=NULL
hyper$eta = 0.1
hyper$a0 = 0.01
hyper$b0 = 0.01
hyper$e0 = 1
hyper$f0 = 1
hyper$g0 = 1
hyper$h0 = 1
hyper$u0 = hyper$v0 = 100
B = 100
nmc = 100
K_range = 1:8
sample_ind = (B + 1):(B + nmc)

###############################################################
# Run the BayCount model selection to determine K             #
###############################################################
G = dim(Y)[1]
S = dim(Y)[2]
K0 = dim(Phi)[2]
BayCount_model = BayCount(Y, B, nmc, hyper, K_range)
K = BayCount_model$K
BayCount_inference = BayCount_model$model
BayCount_inference = BayCount_match_lable(BayCount_inference, simu_truth = synthetic_data)
Phi_hat = apply(BayCount_inference$Phi[, , sample_ind], c(1, 2), mean)
Theta_hat_norm = apply(BayCount_inference$Theta_norm[, , sample_ind], c(1, 2), mean)

###############################################################
# Compare subclonal proportions (Figure 2 in the manuscript)
###############################################################
pdf("Figure_2.pdf", width = 10, height = 12)
par(mfrow=c(K, 1))
for (k in 1:K){
  theta_k_estimate = Theta_hat_norm[k, ]
  theta_k_CI_upper = apply(BayCount_inference$Theta_norm[k, , sample_ind], 1, quantile, 0.975)
  theta_k_CI_lower = apply(BayCount_inference$Theta_norm[k, , sample_ind], 1, quantile, 0.025)
  plot(1:S, type = "n", xlab = "Samples", ylab = "Proportions",
       ylim = c(min(theta_k_CI_lower), max(theta_k_CI_upper) + 0.4),
       main = paste("Subclone ",k, " Proportion", sep = ""), cex.main = 2, cex.axis = 1.5, cex.lab = 1.5)
  grid(nx = 10, ny = 5, lwd = 1)
  polygon(c(1:S, rev(1:S)), c(theta_k_CI_lower, rev(theta_k_CI_upper)),col = "grey80", border = T)
  points(1:S, theta_k_estimate, type="b", pch = 1, lwd = 3, col = "green", lty = 1)
  points(1:S, synthetic_data$Theta_norm[k, ], type = "b",pch = 2, col = "red", lwd = 3, lty = 1)
  legend("topleft", legend = c("Estimates","True Values"), lwd = c(3, 3),
         pch = c(1, 2), col = c("green","red"), cex = 1.5, bty = "n")
}
dev.off()

###############################################################
# Heatmaps of gene expression data (Figure 3 in the manuscript)
###############################################################
sd_gene = apply(synthetic_data$Phi_norm, 1, sd)
tau_sd = 1/G
diff_exp_gene = which(sd_gene > tau_sd)
my_palette = brewer.pal(9, "Blues")
pdf("Figure_3a.pdf", width = 5, height = 9)
heatmap.2(synthetic_data$Phi[diff_exp_gene, ], trace = "none", Rowv = NULL, Colv = NULL,
          dendrogram = "none", col = my_palette, key = TRUE, margins = c(3, 0),
          key.par = list(mar = c(2, 0,3, 0)), denscol = "black", key.xlab = "", key.ylab = "",
          key.title = "", labRow = "", cexCol = 4, lhei = c(0.8, 5), lwid = c(0.2, 1.2, 0.2),
          lmat=rbind(c(5, 4, 2), c(6, 1, 3)))
dev.off()
pdf("Figure_3b.pdf", width = 5, height = 9)
heatmap.2(Phi_hat[diff_exp_gene, ], trace = "none", Rowv = NULL, Colv = NULL,
          dendrogram = "none", col = my_palette, key = TRUE, margins = c(3, 0),
          key.par = list(mar = c(2, 0,3, 0)), denscol = "black", key.xlab = "", key.ylab = "",
          key.title = "", labRow = "", cexCol = 4, lhei = c(0.8, 5), lwid = c(0.2, 1.2, 0.2),
          lmat=rbind(c(5, 4, 2), c(6, 1, 3)))
dev.off()

write(BayCount_model,BayCount_inference,"BayRes.Rdata")
