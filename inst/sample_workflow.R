## SAMPLE WORKFLOW

library(dataimport)

# example: Mobile Instrumented Sensor Platform (MISP) Datalogger Barrow, Alaska, 2016
# get pid from URL
data_url <- "https://cn.dataone.org/cn/v2/resolve/urn:uuid:facd5242-b857-4880-8a0f-454c04d57d8e"
# try other urls...
pids <- url_to_pid(data_url)
# TODO: pick out the correct metadata pid

# read data into R
data <- read.csv(data_url)
data <- get_object(pids$data) #alternative
data$data_pid <- pids$data

# do some wrangling/unit conversions
# provide functionality for single-header
# example of unit conversion with units package

# potentially write.csv() to save to disk

# example 2: Mobile Instrumented Sensor Platform (MISP) Datalogger Atqasuk, Alaska, Data 2015. Arctic Data Center
data_url2 <- "https://cn.dataone.org/cn/v2/resolve/urn:uuid:20704e01-df3f-45fc-8007-625062faf556"
pids2 <- url_to_pid(data_url2)
data2 <- read.csv(data_url)
data2$data_pid <- pids2$data

## CONSOLIDATION ------
# consolidate wrangled datasets

data_full <- bind_rows(data, data2)

# get tabular metadata - weakspot: determining correct metadata pid

# takes a bit of processing time...
library(furrr) 

future::plan(multiprocess) #may fail on R 3.3
meta_full <- tibble(meta_pid = c("doi:10.18739/A22Z9V", 
                                 "doi:10.18739/A2ZG5K")) %>% 
    mutate(eml = furrr::future_map(meta_pid, get_object, as = "raw")) %>% 
    mutate(eml_df = furrr::future_map(eml, tidy_eml))

# this part is quick
metadata <- meta_full %>% 
    unnest(eml_df) %>% 
    spread(category, value, fill = NA)

# join with data
# data pid to metadata
metadata <- metadata %>% 
    mutate(data_pid = c("urn:uuid:facd5242-b857-4880-8a0f-454c04d57d8e",
                        "urn:uuid:20704e01-df3f-45fc-8007-625062faf556")) 

data_full_meta <- data_full %>% 
  as.tibble() %>% 
  left_join(metadata, by = "data_pid")

# TODO: 
# more specific version of getDataPackage
# use file structure to groupe package objects
# file name - DOI_PID_filename.csv / DOI_PID.Rdata

# download_data (ADC permafrost group, already done)
# files downloaded with DOI and PID
# how to we get back to metadata from DOI

# workflows:
# data from internet
# data from disk
