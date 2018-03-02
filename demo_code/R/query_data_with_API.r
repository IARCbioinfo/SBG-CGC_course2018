# identify to datasets API
a = Auth(url = "https://cgc-datasets-api.sbgenomics.com/datasets/tcga/v0", token = "")

# look at the type of data available for queries
names(a$api()$"_links")

# look at schema for a particular type of data (here: files), i.e. available attributes to query on

# make a query based on these attributes

body = list(
  entity = "files",
  hasExperimentalStrategy = "RNA-Seq",
  hasDiseaseType = "Mesothelioma",
  hasDataFormat = "BAM")

query = a$api(path = "query", body = body, method = "POST")

# following part would get query files IDs, and copy them into a project

# create a function to get IDs of files

get_id = function(obj){
  sapply(obj$"_embedded"$files, function(x) x$id)
}

ids = get_id(res)

# authentify to the platform API and copy the files

a_cgc = Auth(url = "https://cgc-api.sbgenomics.com/v2/", token = a$token)

a_cgc$copyFile(id = my_ids, project = "my_project_name")
