#' function that turn matrix into a data.frame in long format
#'
#' @param x the data.frame to transform
#'
#'
cw_matrix_to_df <- function(x){
  data.frame(
    row = as.vector(row(x)),
    col = as.vector(col(x)),
    val = as.vector(x),
    stringsAsFactors = FALSE
  )
}

