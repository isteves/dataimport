library(eml2)
library(tidyverse)
# not run yet...
eml_path <- system.file("dummy_eml_w_attributes.xml", package = "datamgmt")


entity <- eml_get(eml, "dataTable")
entity2 <- eml_get(eml, "otherEntity")


parsed <- parse_attributes(entity)
parsed <- parse_attributes(entity2)


parse_attributes <- function(entity) {
    attr_table_long <- entity$attributeList$attribute %>% 
        enframe() %>% 
        mutate(value = map(value, unlist),
               value_names = map(value, names)) %>% 
        unnest()
    
    if(nrow(attr_table_long) == 0){
        stop("There is no attribute information for the entity with name ",
             entity$entityName)
    }
    
    #regular attributes
    attrib <- attr_table_long %>% 
        filter(!str_detect(value_names, "enumerated")) %>% 
        spread(value_names, value, fill = NA) %>% 
        gather(measurementScale, value, contains("measurementScale")) %>% 
        filter(!is.na(value)) %>% 
        mutate(measurementScale = str_replace(measurementScale, 
                                              "measurementScale.", 
                                              ""))
    
    #enumerated domains
    enum <- attr_table_long %>% 
        filter(str_detect(value_names, "enumerated")) %>% 
        mutate(value_names = str_extract(value_names, "[a-zA-Z]+$"),
               name2 = rep(1:(length(name)/2), each = 2)) %>% 
        spread(value_names, value) %>% 
        select(-name2)
    
    #add entity name/description/physical
    phys <- entity$physical %>% 
        unlist() %>% 
        enframe()
    
    list(entityName = entity$entityName,
         entityDescription = entity$entityDescription,
         physical = phys,
         attribute = attrib,
         enumeratedDomain = enum)
    
}




#is there a better way of taking advantage of lists?
#how to associate pids with attr tables
#better way of extracting attr tables?