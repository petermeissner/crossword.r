#' function that turn matrix into a data.frame in long format
#'
#' @param x the data.frame to transform
#'
#' @export
#'
matrix_to_df <- function(x){
  data.frame(
    row = as.vector(row(x)),
    col = as.vector(col(x)),
    val = as.vector(x),
    stringsAsFactors = FALSE
  )
}

#' a vectorized version of grep
#' @inheritParams base::grepl
#' @export
greplv <-
  compiler::cmpfun(
    Vectorize(grepl, vectorize.args = "pattern")
  )

#' normalize words to be added to grid
#'
#' @param words character vector of words to normalize for crossword usage
#'
#' @export
#'
normalize_words <- function(words){

  # check for non
  iffer <- stringr::str_detect(words, "\\W")
  if ( sum(iffer) > 0 ){
    warning(
      "There are words containing non-letters: ",
      paste(words[iffer], collapse = "; ")
    )
  }


  words <- toupper(words)
  words <- stringr::str_replace_all(words, " +", "")
  words <- stringr::str_replace_all(words, "\u00c4", "AE")
  words <- stringr::str_replace_all(words, "\u00d6", "OE")
  words <- stringr::str_replace_all(words, "\u00dc", "UE")
  words <- stringr::str_replace_all(words, "\u00df", "SS")

  # add empty space before and after
  words <- paste0("#", words, "#")

  # return
  return(words)
}
