#' Get a DataONE data object
#'
#' This function download a DataONE data object into the R environment
#'
#' @param data_pid (character) The data object PID
#' @param as desired type of output: raw, text or parsed. content attempts to automatically figure out which one is most appropriate, based on the content-type. (based on \code{httr::content()})
#'
#' @export
#'
#' @examples
#' \dontrun{
#'    get_object("urn:uuid:a81f49db-5841-4095-aee2-b0cad7a35cc0")
#' }
#'

get_object <- function(data_pid, as = "parsed"){
    cn <- dataone::CNode()
    sysmeta <- getSystemMetadata(cn, data_pid)
    #marginally faster than using getSystemMetadata
    # rbenchmark::benchmark("resolve" = {resolve(dataone::CNode(), data_pid)$data$nodeIdentifier},
    #                       "sysmeta" = {getSystemMetadata(dataone::CNode(), data_pid)@originMemberNode},
    #                       replications = 5)
    mn <- dataone::getMNode(cn, sysmeta@originMemberNode)
    
    
    raw <- dataone::getObject(mn, data_pid)
    text <- rawToChar(raw)
    
    if(as == "parsed"){
        #try parsing
        
        if(sysmeta@formatId == "text/csv"){
            out <- read.csv(text = text)
        } else if(grepl("eml", sysmeta@formatId)){
            tmp <- tempfile(fileext = ".xml")
            writeBin(raw, tmp)
            out <- EML::read_eml(tmp)
            file.remove(tmp)
            #add for text/csv
        } else {
            out <- raw
        }
        
        return(out)
        
    } else if(as == "text"){
        return(text)
        
    } else {
        return(raw)
    }
}






