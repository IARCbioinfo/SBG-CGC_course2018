library("sevenbridges")

## Path & files config
setwd("/home/user/Workspace")
login_file = "./login.config"
token_file = "./token.config"
app_json   = "./ITH/app.json"

## Access config
project = "intra_tumor_heterogeneity"
login = readLines(login_file)
token = readLines(token_file)

## Load project
a <- Auth(token = token, url = "https://cgc-api.sbgenomics.com/v2/")
p <- a$project(id = paste(login, "/", project, sep=""))

## Load data
htseq_count_files = p$file("htseq.counts.gz", complete = TRUE)

## Run task
app = convert_app(app_json)
p$app_add("ITH_Rapi", app)

task = p$task_add(name = paste("intra_tumor_heterogeneity_run_", format(Sys.time(), "%d_%m_%Y_%H_%M_%S")),
                  description = "MESO - Identify intra-tumor heterogeneity",
                  app = "l.soudade/intra_tumor_heterogeneity/ITH_Rapi",
                  inputs = list(input_htseq = htseq_count_files,
                                output_file_name = paste("intra_tumor_heterogeneity_run_", format(Sys.time(), "%d_%m_%Y_%H_%M_%S"))))
task$run()