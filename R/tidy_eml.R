#' Get tidy metadata
#'
#' This function takes a path to an EML (.xml) metadata file and returns a data frame. 
#'
#' @param eml_path (character) The path to an EML (.xml) metadata file
#' @param full (logical) Returns the most commonly used metadata fields by default. 
#' If \code{full = TRUE} is specified, the full set of metadata fields are returned.
#'
#' @export
#'
#' @examples
#' \dontrun{
#'    eml_path <- system.file("example-eml.xml", package = "arcticdatautils")
#'    tidy_eml(eml_path)
#' }
#'

tidy_eml <- function(eml_path, full = FALSE){
    metadata <- eml_path %>% 
        xml2::read_xml() %>% 
        xml2::as_list() %>% 
        unlist() %>% 
        tibble::enframe()
    
    if(full == FALSE){
        metadata <- metadata %>% 
            dplyr::mutate(category = case_when(
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
                grepl("online.url", name) ~ "url",
            )) %>% 
            dplyr::filter(!is.na(category)) %>% 
            dplyr::group_by(category) %>% 
            dplyr::summarize(value = paste(value, collapse = " ")) 
    }
    
    return(metadata)
}