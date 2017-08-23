#' function that takes a crossword and renders it as PDF
#'
#' @export
#'
cw_to_pdf <- function(cw, fname = NULL){

  # process fname input
  if( is.null(fname) )  {
    dir.create("rendering", showWarnings = FALSE)
    fname <- "rendering/crossword.tex"
  }

  # fnames
  fname_pdf <- stringr::str_replace(fname, "\\.\\w+$", ".pdf")
  fname_tex <- stringr::str_replace(fname, "\\.\\w+$", ".tex")

  # glue together latex document
  latex <-
    c(
      cw_glue_head(cw),
      cw_glue_puzzle(cw),
      cw_glue_clues(cw),
      cw_glue_solution(cw),
      cw_glue_clues(cw)
    )

  # write latex document to disk
  writeLines(latex, fname_tex, useBytes = TRUE)

  # render latex document
  system2(
    command = "pdflatex",
    args    = paste0(fname_tex,   " -output-directory ", dirname(fname_pdf))
  )

  # return path to pdf
  return(fname_pdf)
}



































