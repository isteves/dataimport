#' Get tidy (tabular) metadata
#'
#' This function takes a path to an EML (.xml) metadata file and returns a data frame.
#'
#' @param eml An EML class object, the path to an EML (.xml) metadata file, or a raw EML object
#' @param full (logical) Returns the most commonly used metadata fields by default. 
#' If \code{full = TRUE} is specified, the full set of metadata fields are returned.
#'
#' @export
#'
#' @import magrittr
#' @importFrom xml2 read_xml as_list
#' @importFrom tibble enframe
#' @import dplyr
#' @importFrom EML write_eml
#'
#' @examples
#' \dontrun{
#'    eml <- system.file("example-eml.xml", package = "arcticdatautils")
#'    tidy_eml(eml)
#'    tidy_eml(eml, full = TRUE)
#' }
#'

tidy_eml <- function(eml, full = FALSE){
    
    if(class(eml) == "eml"){
        temp_path <- tempfile(fileext = ".xml")
        EML::write_eml(eml, temp_path)
        eml_path <- temp_path
    } else {
        stopifnot(is.character(eml) | is.raw(eml))
        eml_path <- eml
    } 
    
    metadata <- eml_path %>% 
        xml2::read_xml() %>% 
        xml2::as_list() %>% 
        unlist() %>% 
        tibble::enframe()
    
    if(exists("temp_path")){
      file.remove(temp_path)
    }
    
    if(full == FALSE){
        metadata <- metadata %>% 
            dplyr::mutate(name = case_when(
                grepl("title", name) ~ "title",
                grepl("individualName", name) ~ "people",
                grepl("abstract", name) ~ "abstract",
                grepl("keyword", name) ~ "keyword",
                grepl("geographicDescription", name) ~ "geographicCoverage.geographicDescription",
                grepl("westBoundingCoordinate", name) ~ "geographicCoverage.westBoundingCoordinate",
                grepl("eastBoundingCoordinate", name) ~ "geographicCoverage.eastBoundingCoordinate",
                grepl("northBoundingCoordinate", name) ~ "geographicCoverage.northBoundingCoordinate",
                grepl("southBoundingCoordinate", name) ~ "geographicCoverage.southBoundingCoordinate",
                grepl("beginDate", name) ~ "temporalCoverage.beginDate",
                grepl("endDate", name) ~ "temporalCoverage.endDate",
                #taxonomicCoverage
                grepl("methods", name) ~ "methods",
                grepl("objectName", name) ~ "objectName",
                grepl("online.url", name) ~ "url"
            )) %>% 
            dplyr::filter(!is.na(name)) %>% 
            dplyr::group_by(name) %>% 
            dplyr::summarize(value = paste(value, collapse = " ")) 
    }
    
    return(metadata)
}
