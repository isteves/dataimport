#' Get pids
#'
#' This function takes a package DOI and optionally, a data URL and returns the associated pids. Alternative to \code{url_to_pid()}, based on \code{arcticdatautils::get_package()}.
#'
#' @param pkg_doi (character) The package DOI, or the metadata object PID on a DataONE member node #TODO: figure out terminology
#' @param data_url (character) Optional. The URL to the data object on a DataONE member node. If the data_url is passed, only the specified data object PIDs will be returned 
#'
#' @importFrom stringr str_extract
#' @importFrom dataone query CNode
#' @importFrom utils URLdecode read.csv
#' @importFrom purrr %||%
#'
#' @export
#'
#' @examples
#' \dontrun{
#' #get all pids in the data package
#' get_pids("https://doi.org/10.6073/pasta/cd7ec5009430eb78f464a66f6794579f")

#' #return only pids related to the specified data object
#' get_pids("doi:10.18739/A2PC2T79B", 
#'          "https://cn.dataone.org/cn/v2/resolve/urn:uuid#' :a81f49db-5841-4095-aee2-b0cad7a35cc0")
#' get_pids("https://doi.org/10.6073/pasta/cd7ec5009430eb78f464a66f6794579f", 
#'          "https://portal.lternet.edu/nis/dataviewer?packageid=knb-lter-luq.107.9996700&entityid=6c2bcaf6cdd5b365a51b1d3318f93eef")
#' }
#'

get_pids <- function(pkg_doi, data_url = NULL){
    # check pkg_doi and remove URL-specific aspects of DOI
    stopifnot(is.character(pkg_doi))
    pkg_doi <- stringr::str_replace(pkg_doi, ".org/", ":")
    pkg_doi <- stringr::str_replace(pkg_doi, "https://", "")
    
    # check data_url and decode; try to grab pid
    if(!is.null(data_url)){
        url_decoded <- URLdecode(data_url)
        data_id <- stringr::str_extract(url_decoded, "[0-9a-z:-]*$")
    } else {
        data_id <- NULL
    }
    
    # get package info based on resourceMap, like in arcticdatautils
    # if metadata pid provided, try to query it in the resourceMap field (works for cases where
    # the rm pid is just the metadata pid with a "resource_map_" prefix)
    # if no results are returned, try querying the metadata pid and returning rm_pid for further processing
    
    cn <- dataone::CNode("PROD")
    
    query_params <- list(q = sprintf('identifier:"%s"', pkg_doi),
                         fl = "identifier, formatType, resourceMap")
    pkg_pid <- dataone::query(cn, query_params, as = "data.frame")
    
    if(pkg_pid$formatType == "RESOURCE"){
        rm_pid <- pkg_pid$identifier
    } else if(pkg_pid$formatType == "METADATA"){
        rm_pid <- pkg_pid$resourceMap
    } else {
        stop("The data package could not be found. Please check the DOI and try again.")
        #TODO: test on pids that start with dx.doi
    }
    
    query_params <- list(q = sprintf('resourceMap:"%s"', rm_pid),
                         fl = "identifier, formatType", rows = 10000)
    pids <- dataone::query(cn, query_params, as = "data.frame")
    
    pid_list <- list(resource_map = rm_pid,
                     metadata = pids$identifier[pids$formatType == "METADATA"],
                     data = data_id %||% pids$identifier[pids$formatType == "DATA"])
    
    if(!is.null(data_id) & !any(stringr::str_detect(pids$identifier[pids$formatType == "DATA"], pid_list$data))){
        stop(sprintf("The data object, %s, is not part of the data package, %s.", data_url, pkg_doi))
    }
    
    return(pid_list)
}
