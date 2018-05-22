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
    
    colnames(pids) <- c("data", "metadata", "resource_map")
    
    if(nrow(pids) > 1){
        warning("Multiple data pids were matched.")
        
        # It seems that on PASTA, data objects get slightly new pids (/1/, /2/, etc)
        # when the metadata is updated
    }
    
    return(pids)
}

#' Check pid version
#'
#' This function takes a pid and checks to see if it has been obsoleted.
#'
#' @param pid (character) The pid to a data, metadata, or resource map object on a DataONE member node
#'
#' @importFrom dataone CNode getSystemMetadata
#'
#' @export
#'
#' @examples
#' \dontrun{
#'    pid <- "https://pasta.lternet.edu/package/data/eml/edi/195/2/51abf1c7a36a33a2a8bb05ccbf8c81c6"
#'    pid <- "doi:10.18739/A2HF7Z"
#'    
#'    check_version(pid)
#' }
#'

check_version <- function(pid){
    sysmeta <- dataone::getSystemMetadata(dataone::CNode("PROD"), pid)
    
    if(is.na(sysmeta@obsoletedBy)){
        print("This is the latest version of the pid.")
    } else {
        print(paste("The pid has been obsoleted by", sysmeta@obsoletedBy))
    }
}
