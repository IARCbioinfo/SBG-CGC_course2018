library("sevenbridges")

project="iarc-course-tutorial"

a <- Auth(token = "", url = "https://cgc-api.sbgenomics.com/v2/")

p <- a$project(id = paste("tdelhomme/", project, sep=""))

my_bam = p$file("bam", complete = TRUE)[1]

f = "samtools_header.json"
samtools_header = convert_app(f)

p$app_add("header_Rapi", samtools_header)

tsk = p$task_add(name = "test_header",
                 description = "samtools header for IARC course",
                 app = "tdelhomme/iarc-course-tutorial/header_Rapi",
                 inputs = list(input_BAM = my_bam,
                               output_file_name="test_header_from_Rapi.txt"
                               ))
tsk$run()
