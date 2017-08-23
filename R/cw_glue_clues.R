#' glue together parameters and cwpuzzle template
#'
#' @param cw
#'
#'
cw_glue_clues <- function(cw){
  c(
    "\\begin{PuzzleClues}{\\textbf{Across}}",
    glue::glue_data(
      .open  = "<R>",
      .close = "</R>",
      .x     = cw_words_add_id(cw$words)[cw$words$direction=="right",],
      "\\Clue{(<R>id</R>)}{<R>word</R>}{<R>clue</R>}"
    ),
    "\\end{PuzzleClues}",
    "\\begin{PuzzleClues}{\\textbf{Down}}",
    glue::glue_data(
      .open  = "<R>",
      .close = "</R>",
      .x     = cw_words_add_id(cw$words)[cw$words$direction=="down",],
      "\\Clue{(<R>id</R>)}{<R>word</R>}{<R>clue</R>}"
    ),
    "\\end{PuzzleClues}"
  )
}

