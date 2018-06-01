## SAMPLE WORKFLOW

library(tidyverse)
library(dataimport)
library(parallel)
library(units)
library(downloadData) #maier-m/download_data
# library(tictoc) #for measuring code duration

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
# data <- read.csv(data_url, stringsAsFactors = FALSE, na.strings = "NAN")
# alternative: data <- get_object(pids$data) 
# another alternative (from Mitchell): get data with attribute info attached
d1_data <- get_D1Data(pids$data)
data <- read.csv(text = rawToChar(d1_data$data_objects[[1]]$data), stringsAsFactors = FALSE)
attr <- d1_data$data_objects[[1]]$attribute_metadata

match_attributes(data, attr) #generates script to add units

data <- data %>%
    as.tibble() %>% 
    mutate( Batt_Volt = set_units(Batt_Volt, 'volt'),
            PTemp_C = set_units(PTemp_C, 'celsius'),
            TargmV = set_units(TargmV, 'millivolt'),
            SBTempC = set_units(SBTempC, 'celsius'),
            TargTempC = set_units(TargTempC, 'celsius'),
            cnr4_T_C = set_units(cnr4_T_C, 'celsius'),
            cnr4_T_K = set_units(cnr4_T_K, 'kelvin'),
            Air_Temp = set_units(Air_Temp, 'celsius'),
            Dist_corr = set_units(Dist_corr, 'centimeter') ) 

#convert units
data <- data %>% 
    mutate( Batt_Volt = set_units(Batt_Volt, 'millivolt'),
            PTemp_C = set_units(PTemp_C, 'kelvin'),
            TargmV = set_units(TargmV, 'millivolt'),
            SBTempC = set_units(SBTempC, 'kelvin'),
            TargTempC = set_units(TargTempC, 'kelvin'),
            cnr4_T_C = set_units(cnr4_T_C, 'kelvin'),
            cnr4_T_K = set_units(cnr4_T_K, 'kelvin'),
            Air_Temp = set_units(Air_Temp, 'kelvin'),
            Dist_corr = set_units(Dist_corr, 'meter') )

# provide functionality for single-header

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

metadata <- get_metadata(data_full$metadata_pid)

#select relevant variables
metadata <- metadata %>% 
    select(metadata_pid, title, temporalCoverage.beginDate, temporalCoverage.endDate, url)

# join with data
# data pid to metadata
data_full_meta <- data_full %>% 
    left_join(metadata, by = "metadata_pid") 

####################

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