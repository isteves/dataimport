#' Get tabular metadata
#' 
#' Gets tabular metadata from a list of metadata PIDs.
#'
#' @param meta_pids (character vector) Metadata PIDs
#' @param parallelize (logical) If TRUE, uses the parallel package to parallelize the proess. Default = FALSE.
#' @param full (logical) Whether to extract the full metadata. See \code{tidy_eml}. Default = FALSE.
#'
#' @export
#' 
#' @importFrom tidyr unnest
#'
#' @examples
#' \dontrun{
#' metadata <- get_metadata(c("doi:10.18739/A2K86G", "doi:10.18739/A2KG4S"), parallelize = TRUE)
#' }

get_metadata <- function(meta_pids, parallelize = FALSE, full = FALSE) {
    meta_pids <- unique(meta_pids)
    
    if(parallelize){
        no_cores <- parallel::detectCores() - 1 # number of ores
        cl <- parallel::makeCluster(no_cores) # initiate cluster
        eml_obj <- parallel::parLapply(cl, meta_pids, get_object, as = "raw")
        parallel::stopCluster(cl) #close connection
    } else {
        eml_obj <- lapply(meta_pids, get_object, as = "raw")
    }
    
    # alternative multiprocessing, but doesn't always work:
    # library(future)
    # library(furrr)
    # 
    # plan(multiprocess) #use `plan(sequential)` if you get errors
    # meta_full <- tibble(metadata_pid = unique(data_full$metadata_pid)) %>% 
    #     mutate(eml = future_map(metadata_pid, get_object)) %>% 
    #     mutate(eml_df = future_map(eml, tidy_eml))
    
    eml_df <- lapply(eml_obj, tidy_eml, full = full)
    
    meta_full <- tibble::tibble(metadata_pid = meta_pids,
                                eml_df = eml_df)  %>% 
        tidyr::unnest(eml_df) %>% 
        
        #account for fields that appear several times (attributes)
        dplyr::group_by(metadata_pid, name) %>% 
        dplyr::summarize(value = paste(value, collapse = " ")) %>% 
        
        tidyr::spread(name, value, fill = NA)
    
    return(meta_full)
}

