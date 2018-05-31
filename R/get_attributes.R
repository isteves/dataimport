get_attributes <- function(meta_pid) {
    meta_raw <- get_object(meta_pid, as = "raw")
    
}

x <- read_xml(meta_raw) 

y <- xml_find_all(x, "//attributeList")
y[[1]]


y <- EML::eml_get(x, "attributeList")
y$attributes


map(x$dataset, "surName")
x$dataset
