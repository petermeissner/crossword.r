#' add an id unique for all unique combinations of row and column
#'
#' @param cw_words
#'
cw_words_add_id <- function(cw_words){
  transform(
    cw_words,
    id = as.numeric(factor(paste(row, col, sep = "_")))
  )
}


