#' glue together parameters and cwpuzzle template
#'
#' @param cw a crossword object
#' @param geometry_options comma separated options string directly passed
#'                         through to LaTeX geometry package
#' @export
cw_glue_head <- function(cw, geometry_options = "a4paper, margin=2cm"){
  paste0(
"\\documentclass{article}

\\usepackage{xcolor}
\\usepackage[",geometry_options,"]{geometry}
\\usepackage[unboxed]{cwpuzzle}

\\begin{document}
")
}
