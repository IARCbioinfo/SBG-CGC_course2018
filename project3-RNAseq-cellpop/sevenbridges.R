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

## Run task
app = convert_app(app_json)
p$app_add("ICF_Rapi", app)

for(i in 5:6){
data_file = bam_files[[i]]
task = p$task_add(name = paste("immune_cell_fractions_run_", format(Sys.time(), "%d_%m_%Y_%H_%M_%S")),
                  description = "MESO - Identify immune cell fractions",
                  app = "l.soudade/immune-cell-fractions/ICF_Rapi", 
                  #use_interruptible_instances = TRUE,  # does not work here
                  inputs = list(input_BAM = data_file,
                                output_file_name = paste("immune_cell_fractions_run_", format(Sys.time(), "%d_%m_%Y_%H_%M_%S"))))
task$use_interruptible_instances = TRUE
task$run()
}
