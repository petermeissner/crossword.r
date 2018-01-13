#' a vectorized version of grep
#' @inheritParams base::grepl
#'
#'
cw_greplv <-
  compiler::cmpfun(
    Vectorize(grepl, vectorize.args = "pattern")
  )

