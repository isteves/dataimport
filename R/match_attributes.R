#' Match attributes to data
#' 
#' Match attribute metadata to data. Returns a dplyr expression that can be proofed and pasted into a script.
#'
#' @param data (data.frame) Data frame to match with attribute metadata
#' @param attributes (data.frame) Attribute metadata
#'
#' @export

match_attributes <- function(data, attributes){
    #check if units can be set
    validate_unit <- function(x){
        yy <- tryCatch(units::as_units(x),
                       error = function(e) {FALSE})
        if(class(yy) == "units"){yy <- TRUE}
        return(yy)
    }
    
    ref <- tibble(colnames_data = colnames(data)) %>% 
        mutate(attr_units = purrr::map_chr(colnames_data, ~attributes$unit[attributes$attributeName == .x])) %>% 
        mutate(valid_units = purrr::map_lgl(attr_units, validate_unit)) %>% 
        filter(valid_units)
    
    mutate_exp <- sprintf("%s = units::set_units(%s, '%s')",
                          ref$colnames_data, ref$colnames_data, ref$attr_units)
    
    cat(deparse(substitute(data)), "%>%\n tibble::as.tibble() %>% \n dplyr::mutate(", paste(mutate_exp, collapse = ",\n\t\t"), ")")
}
