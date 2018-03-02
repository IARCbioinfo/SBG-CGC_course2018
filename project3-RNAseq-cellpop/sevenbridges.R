library("sevenbridges")

## Path & files config
setwd("/home/user/Workspace")
login_file = "./login.config"
token_file = "./token.config"
app_json   = "./app.json"

## Access config
project = "immune-cell-fractions"
login = readLines(login_file)
token = readLines(token_file)

## Load project
a <- Auth(token = token, url = "https://cgc-api.sbgenomics.com/v2/")
p <- a$project(id = paste(login, "/", project, sep=""))

## Load data
bam_files = p$file("bam", complete = TRUE)
data_file = bam_files[1]

## Run task
app = convert_app(app_json)
p$app_add("ICF_Rapi", app)

task = p$task_add(name = paste("immune_cell_fractions_run_", format(Sys.time(), "%d_%m_%Y_%H_%M_%S")),
                  description = "MESO - Identify immune cell fractions",
                  app = "l.soudade/immune_cell_fractions/ICF_Rapi",
                  inputs = list(input_BAM = data_file,
                                output_file_name = paste("immune_cell_fractions_run_", format(Sys.time(), "%d_%m_%Y_%H_%M_%S"))))
task$run()