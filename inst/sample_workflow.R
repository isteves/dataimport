## SAMPLE WORKFLOW

library(tidyverse)
library(dataimport)
# library(tictoc) #for measuring code duration
library(parallel)

# example: MISP Datalogger Barrow, Alaska, 2016 ==========
# get pids -----------
data_url <- "https://cn.dataone.org/cn/v2/resolve/urn:uuid:facd5242-b857-4880-8a0f-454c04d57d8e"
pids <- get_pids("doi:10.18739/A22Z9V", 
                 data_url)

# throws an error when there's a mismatch
# pids <- get_pids("doi:10.18739/A2ZG5K", 
#                  "https://cn.dataone.org/cn/v2/resolve/urn:uuid:facd5242-b857-4880-8a0f-454c04d57d8e")

# TODO: pick out the correct metadata pid
check_version(pids$data) #good to go!

# read data into R ---------
data <- read.csv(data_url, stringsAsFactors = FALSE, na.strings = "NAN")
# alternative: data <- get_object(pids$data) 

# do some wrangling/unit conversions
# provide functionality for single-header
# example of unit conversion with units package

# add pids - is it worth wrapping this into a fxn? ---------
data$data_pid <- pids$data
data$metadata_pid <- pids$metadata

# potentially write.csv() to save to disk

# example 2: MISP Datalogger Atqasuk, Alaska, Data 2015 =======
data_url2 <- "https://cn.dataone.org/cn/v2/resolve/urn:uuid:20704e01-df3f-45fc-8007-625062faf556"
pids2 <- get_pids("doi:10.18739/A2ZG5K", 
                 data_url2)
check_version(pids2$data)

data2 <- read.csv(data_url2, stringsAsFactors = FALSE, na.strings = "NAN")

data2$data_pid <- pids2$data
data2$metadata_pid <- pids2$metadata

## CONSOLIDATION ------
# consolidate wrangled datasets

# tips:
    # make sure all data are the same type. check especially for factors,
    # for columns that are read in as "chr" bc of NA strings ("NAN")
data_full <- dplyr::bind_rows(data, data2)

# get tabular metadata - weakspot: determining correct metadata pid

# parallel ==============
# http://gforge.se/2015/02/how-to-go-parallel-in-r-basics-tips/
# https://github.com/Science-for-Nature-and-People/2016-postdoc-training/blob/master/09-multicore-processing/1-multiprocessing-tools.md
# https://github.com/NCEAS/oss-lessons/blob/gh-pages/parallel-computing-in-r/parallel-computing-in-r.Rmd

meta_pids <- unique(data_full$metadata_pid)

# getting the metadata requires an internet connection

# tic()
no_cores <- detectCores() - 1 # number of ores
cl <- makeCluster(no_cores) # initiate cluster
eml_obj <- parLapply(cl, meta_pids, get_object, as = "raw")
stopCluster(cl) #close connection
# toc() #12 s

eml_tidy <- lapply(eml_obj, tidy_eml)

meta_full <- tibble(metadata_pid = unique(data_full$metadata_pid),
                    eml_df = eml_tidy)

# alternative multiprocessing, but doesn't always work:
    # library(future)
    # library(furrr)
    # 
    # plan(multiprocess) #use `plan(sequential)` if you get errors
    # meta_full <- tibble(metadata_pid = unique(data_full$metadata_pid)) %>% 
    #     mutate(eml = future_map(metadata_pid, get_object)) %>% 
    #     mutate(eml_df = future_map(eml, tidy_eml))

# this part is quick
metadata <- meta_full %>% 
    tidyr::unnest(eml_df) %>% 
    tidyr::spread(category, value, fill = NA)

# join with data
# data pid to metadata
data_full_meta <- data_full %>% 
    left_join(metadata, by = "metadata_pid") 

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