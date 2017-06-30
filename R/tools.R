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
  iffer <- str_detect(words, "\\W")
  if ( sum(iffer) > 0 ){
    warning(
      "There are words containing non-letters: ",
      paste(words[iffer], collapse = "; ")
    )
  }


  words <- toupper(words)
  words <- str_replace_all(words, " +", "")
  words <- str_replace_all(words, "Ä", "AE")
  words <- str_replace_all(words, "Ö", "OE")
  words <- str_replace_all(words, "Ü", "UE")
  words <- str_replace_all(words, "ß", "SS")

  # add empty space before and after
  words <- paste0("#", words, "#")

  # return
  return(words)
}