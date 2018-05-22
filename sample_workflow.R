## SAMPLE WORKFLOW

library(tidyverse)

#get pid from URL
data_url <- "https://cn.dataone.org/cn/v2/resolve/urn:uuid:a81f49db-5841-4095-aee2-b0cad7a35cc0"
# try other urls...
pids <- url_to_pid(data_url)

data <- read.csv(data_url)
data <- get_object(pids$data) #alternative

# do some wrangling/unit conversions
# provide functionality for single-header
# show unit conversion

# get tabular metadata
eml <- get_object("doi:10.18739/A2PC2T79B")
meta <- tidy_eml(eml)

# join with data
# data pid to metadata
