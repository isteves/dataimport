get_attributes <- function(meta_pid) {
    meta_raw <- get_object(meta_pid, as = "raw")
    
}

library(tictoc)
library(tidyverse)

meta_pid <- "doi:10.18739/A2K86G"

meta_raw <- get_object(meta_pid, as = "raw")
x <- read_xml(meta_raw) 
y <- xml_find_all(x, "//attributeList")
attr <- lapply(y, function(x) {x %>% as.character() %>% EML::read_eml() %>% EML::get_attributes()})
#slightly* faster than the alternative
# 
# meta_eml <- get_object(meta_pid)
# attr2 <- EML::eml_get(meta_eml, "attributeList")
# #29.8, 28.9

dt <- EML::eml_get(meta_eml, "dataTable")
oe <- EML::eml_get(meta_eml, "otherEntity")



beepr::beep("sword")

library(XML)
xx <- xmlParse(x)
t <- xmlToDataFrame(node = getNodeSet(xx, "//attributeList"))

y <- EML::eml_get(x, "attributeList")
y$attributes


map(x$dataset, "surName")
x$dataset


#is there a better way of taking advantage of lists?
#how to associate pids with attr tables
#better way of extracting attr tables?