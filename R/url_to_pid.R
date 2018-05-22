#' Get pid from data URL
#'
#' This function takes a data URL and returns the data pid, as well as the associated metadata and resource map pids.
#'
#' @param url (character) The URL to the data object on a DataONE member node
#'
#' @importFrom stringr str_extract
#' @importFrom dataone query CNode
#'
#' @export
#'
#' @examples
#' \dontrun{
#'    url <- "https://pasta.lternet.edu/package/data/eml/edi/195/2/51abf1c7a36a33a2a8bb05ccbf8c81c6"
#'    url <- "https://arcticdata.io/metacat/d1/mn/v2/object/urn%3Auuid%3Aa81f49db-5841-4095-aee2-b0cad7a35cc0"
#'    
#'    url_to_pid(url)
#' }
#'

url_to_pid <- function(url){
    stopifnot(is.character(url))
    
    url_decoded <- URLdecode(url)
    id <- stringr::str_extract(url_decoded, "[0-9a-z:-]*$")
    
    pids <- dataone::query(dataone::CNode("PROD"), 
                           list(q = paste0('identifier:"', id, '"'),
                                fl = "identifier, resourceMap, isDocumentedBy"),
                           as = "data.frame")
    
    if(is.null(pids)){
        stop("The data PID could not be found. Please get the Online Distribution URL from the metadata record on the DataONE portal (https://search.dataone.org/#data) and try again.")
    }
    
    colnames(pids) <- c("data_pid", "metadata_pid", "resource_map_pid")
    
    if(nrow(pids) > 1){
        warning("Multiple data pids were matched.")
    }
    
    return(pids)
}
