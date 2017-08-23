#' convert to cwpuzzle table
#'
#' Converts an R-crossword to a table that can be used with LaTeX cwpuzzle
#'
#' @param x the letters matrix of a crossword
#'
cw_glue_letters <- function(x){
  # apply to matrix
  if(is.matrix(x)){
    return(
      paste(
        paste(
          apply(
            apply(x, c(1,2), cw_glue_table),
            1,
            paste,
            collapse=" "
          ),
          "|. \n"
        ),
        collapse=""
      )
    )
  }

  # normal handling
  x <- stringr::str_replace(x, "\\.", "#") # DEV!!! # Todo: this should not be necessary
  if( x == "#" ){
    x <- "|{}"
  }else{
    x <- glue::glue("|[][gf]{x}")
  }

  return(x)
}
