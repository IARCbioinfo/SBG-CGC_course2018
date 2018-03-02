library("sevenbridges")

project="tumor-normal-association"

a <- Auth(token = "...", url = "https://cgc-api.sbgenomics.com/v2/")

p <- a$project(id = paste("gabriela/", project, sep=""))

my_files = p$file("bam", complete = TRUE)
# metadata=t(rbind(sapply(1:1000, function(i) unlist(my_bam[[i]]$meta()) )))

ref_file = p$file("GRCh38_full_analysis_set_plus_decoy_hla.phiX174.fa",exact = T)

f = "needlestack_sh.json"
needlestack_sh = convert_app(f)

p$app_add("needlestack-sh", needlestack_sh)

tsk = p$task_add(name = "test_needlestack",
                 description = "needlestack for IARC course",
                 app = "gabriela/tumor-normal-association/needlestack-sh",
                 inputs = list(region = "chr17:7573714-7573716",
                               ref =ref_file,
                               bam_folder=".",
                               output_vcf="ns_calling_test.vcf",
                               bam_list=my_files,
                               tags="--all_SNVs"
                 ))
tsk$run()

#a$rate_limit()

# a$copyFile(id = a$public_file(name = "Homo_sapiens_assembly38.fasta", exact = TRUE)$id, project = p$id)
# a$copyFile(id = a$public_file(name = "Homo_sapiens_assembly38.fasta.fai", exact = TRUE)$id, project = p$id)
