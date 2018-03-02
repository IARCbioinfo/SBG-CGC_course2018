library("sevenbridges")

project="tumor-normal-association"

a <- Auth(token = "...", url = "https://cgc-api.sbgenomics.com/v2/")

p <- a$project(id = paste("gabriela/", project, sep=""))

bed = p$file("bed_file.bed",exact = T)

f = "bed_split.json"
bed_split=convert_app(f)

p$app_add("bed_split", bed_split)

tsk = p$task_add(name = "test_bed_split",
                 description = "needlestack for IARC course",
                 app = "gabriela/tumor-normal-association/bed_split",
                 inputs = list(bed_file = bed,
                               nb_split =5
                 ))
tsk$run()
