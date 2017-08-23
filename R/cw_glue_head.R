#' glue together parameters and cwpuzzle template
#'
#' @param cw
#'
cw_glue_head <- function(cw, geometry_options = "a4paper, margin=2cm"){
  paste0(
"\\documentclass{article}

\\usepackage{xcolor}
\\usepackage[",geometry_options,"]{geometry}
\\usepackage[unboxed]{cwpuzzle}

\\begin{document}
")
}
