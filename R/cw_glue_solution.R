#' glue together parameters and cwpuzzle template
#'
#' @param cw crossword object
#'
#' @export
#'
cw_glue_solution <- function(cw){
  glue::glue(
    .open="<R>",
    .close="</R>",
"\\newpage
\\PuzzleSolution
\\begin{Puzzle}{<R>cw$columns</R>}{<R>cw$rows</R>}
<R>cw_glue_table(cw$letters)</R>
\\end{Puzzle}
\\end{document}
"
  )
}
