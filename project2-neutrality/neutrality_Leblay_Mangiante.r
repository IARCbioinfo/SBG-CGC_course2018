#!/usr/bin/env Rscript

###########################################################
###       Script to perform Neutrality                  ###
### Tiffany Delhomme, Noemie Leblay, and Lise Mangiante ###
###########################################################


# get options
library("optparse")

option_list = list(
  make_option( c("-V","--vaf_max"), type="numeric", default=0.12, help="Maximun AF to consider a mutation [default= %default]", metavar="numeric"),
  make_option(c("-v", "--vaf_min"), type="numeric", default=0.25, help="Minimun AF to consider a mutation [default= %default]", metavar="numeric"),
  make_option(c("-r", "--min_r2"), type="numeric", default=0.9, help="Minimun r2  to compute a coeff [default= %default]", metavar="numeric"),
  make_option(c("-p", "--min_nb_point"), type="numeric", default=12, help="Minimun number of point use for the regression [default= %default]", metavar="numeric"),
  make_option(c("-d", "--dp_min"), type="numeric", default=50, help="Minimun coverage to consider a mutation [default= %default]", metavar="numeric"),
  make_option(c("-m", "--maf"), type="character", default=".", help="Name of the compresed maf file used for the analysis [default= %default]", metavar="character")
); 


opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);

vaf_max=opt$vaf_max #vaf_max = 0.25
print(vaf_max)
vaf_min=opt$vaf_min #vaf_min=0.10
print(vaf_min)
min_r2=opt$min_r2 #min_r2=0.9
print(min_r2)
min_nb_points=opt$min_nb_point #min_nb_points = 10
print(min_nb_points)
DP_min=opt$dp_min #DP_min = 50
print(DP_min)
MAF=opt$maf #MAF="/home/user/Desktop/Neutrality/TCGA.LUAD.mutect.81ccaef3-4550-494d-882c-895fb5a3de3b.DR-7.0.somatic.maf.gz"
print(MAF)

at = c(1/0.25, 1/0.2, 1/0.15, 1/0.10)
labels = c("1/0.25","1/0.2","1/0.15","1/0.10")
xlim=c(1/vaf_max, 1/vaf_min)

maf=read.table(gzfile(MAF),stringsAsFactors=F,header=T,sep="\t")
#maf=read.table(gzfile("/home/user/Desktop/Neutrality/TCGA.LUAD.mutect.81ccaef3-4550-494d-882c-895fb5a3de3b.DR-7.0.somatic.maf.gz"),stringsAsFactors=F,header=T,sep="\t")

all_r2=c()
all_a = c()


pdf(paste(strsplit(MAF,".muse")[[1]][1],"_Neutrality_test.pdf",sep=""),10,7) #Mettre dans le output avec le nom du MAF
par(mfrow=c(2,2))




sample=unique(maf$Tumor_Sample_Barcode)


for( s in sample){
  maf1=maf[which(maf$Tumor_Sample_Barcode==s),]
  maf1$vaf<-(maf1$t_alt_count/maf1$t_depth)
  new_maf1 = maf1[which(maf1$vaf>=vaf_min & maf1$vaf<=vaf_max & maf1$t_depth>DP_min),] #S?lectionne les lignes avec les crit?res souhait?s 
  vaf =new_maf1$vaf
  vaf = sort(vaf)
  if (sum(is.na(vaf))>0){
    vaf = vaf[-which(is.na(vaf))]}
  if(length(vaf) >= min_nb_points){
    inv_af = 1/vaf[length(vaf):1]
    cumsum_naf = ecdf(vaf)(vaf)*length(vaf)
    cumsum_inv = (length(vaf) - cumsum_naf + 1)[length(vaf):1]
    lm = lm(cumsum_inv ~ inv_af)
    r2= round(summary(lm)$adj.r.squared,4)
    if(r2>=min_r2) { a = summary(lm)$coefficients[2,1] } else { a=NA }
    plot(inv_af, cumsum_inv, main=s,xlab="Inverse allelic frequency 1/f",ylab="Cumulative number of mutations", xaxt='n', xlim=xlim)
    text(par("usr")[1] + (par("usr")[2] - par("usr")[1]) * 0.15 , par("usr")[4] - (par("usr")[4] - par("usr")[3]) * 0.03, labels = bquote(R^2 == .(r2)))
    axis(side=1, at=at, labels=labels)
    if (sum(is.na(lm$coefficients)) == 0) abline(lm, col="red", lwd=2)
    all_r2=c(all_r2,r2)
    all_a = c(all_a,a)
  } else {
    plot(0, main=s,xlab="Inverse allelic frequency 1/f",ylab="Cumulative number of mutations", xaxt='n',yaxt='n', xlim=xlim)
    text(par("usr")[1] + (par("usr")[2] - par("usr")[1]) * 0.15 , par("usr")[4] - (par("usr")[4] - par("usr")[3]) * 0.03, labels = bquote(R^2 == .("NA")))
    axis(side=1, at=at, labels=labels)
    all_r2=c(all_r2,NA)
    all_a=c(all_a,NA)

  }
}

dev.off()


R2 = all_r2
save(R2,file = paste("R2_",strsplit(MAF,".muse")[[1]][1],".Rdata", sep=""))
A = all_a
save(A,file = paste("a_",strsplit(MAF,".muse")[[1]][1],".Rdata", sep=""))

