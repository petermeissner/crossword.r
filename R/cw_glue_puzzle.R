#' glue together parameters and cwpuzzle template
#'
#' @param cw crossword object
#'
cw_glue_puzzle <- function(cw){
  glue::glue(
    .open = "<R>",
    .close = "</R>",
    columns = cw$columns,
    rows    = cw$rows,
  "
\\definecolor{gray}{gray}{.95}
\\PuzzleDefineColorCell{g}{gray}
\\begin{Puzzle}{<R>columns</R>}{<R>rows</R>}
<R>
cw_glue_table(cw$letters)
</R>
\\end{Puzzle}
")
}
