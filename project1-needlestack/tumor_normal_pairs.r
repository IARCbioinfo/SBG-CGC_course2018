library("sevenbridges")

project="tumor-normal-association"

a <- Auth(token = "...", url = "https://cgc-api.sbgenomics.com/v2/")

p <- a$project(id = paste("gabriela/", project, sep=""))

my_bam = p$file("bam", complete = TRUE)
metadata=t(rbind(sapply(1:1000, function(i) unlist(my_bam[[i]]$meta()) )))
metadata2=t(rbind(sapply(1000:1152, function(i) unlist(my_bam[[i]]$meta()) )))

metadata=rbind(metadata,metadata2)
metadata=data.frame(metadata[,c("case_id","aliquot_id","sample_type")])
metadata2=data.frame(metadata2[,c("case_id","aliquot_id","sample_type")])

unique(metadata$sample_type)
metadata_normal=metadata[grepl("Normal",metadata$sample_type),]
metadata_tumor=metadata[grepl("Tumor",metadata$sample_type),]

merged_metadata=merge(metadata_tumor,metadata_normal,by="case_id",all.x = T,all.y = T)
pairs=merged_metadata[,c(2,4)]

tumor_ids=data.frame(sample=as.vector(metadata$aliquot_id[which(metadata$sample_type=="Primary Tumor")]),
                     case=metadata$case_id[which(metadata$sample_type=="Primary Tumor")])
save_noNormals=vector()
pairs_v2=data.frame(Tumor=vector(),Normal=vector())
for(i in 1:nrow(tumor_ids)){
  if("Blood Derived Normal" %in% metadata$sample_type[which(metadata$case_id==tumor_ids$case[i])]){
    n=as.vector(metadata$aliquot_id[which(metadata$sample_type=="Blood Derived Normal" & metadata$case_id==tumor_ids$case[i])])
    pairs_v2=rbind(pairs_v2,data.frame(Tumor=rep(tumor_ids$sample[i],length(n)),Normal=n))
  }else{
    if("Solid Tissue Normal" %in% metadata$sample_type[which(metadata$case_id==tumor_ids$case[i])]){
      n=as.vector(metadata$aliquot_id[which(metadata$sample_type=="Solid Tissue Normal" & metadata$case_id==tumor_ids$case[i])])
      pairs_v2=rbind(pairs_v2,data.frame(Tumor=rep(tumor_ids$sample[i],length(n)),Normal=n))
    }else{
      print(paste0("This samples has no normal sample: ",tumor_ids$sample[i]))
      save_noNormals=c(save_noNormals,tumor_ids$sample[i])
    }
  }
}

a$rate_limit()
