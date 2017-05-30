#' Title
#'
#' Description
#'
#' @section Usage:
#' \preformatted{
#'   cw <- crossword$new()
#' }
#'
#' @section Arguments:
#' \describe{
#'   \item{p}{A \code{process} object.}
#' }
#'
#' @section Details:
#' \code{$new()} starts a new process, it uses \code{\link[base]{pipe}}.
#' R does \emph{not} wait for the process to finish, but returns
#' immediately.
#'
#' \code{$is_alive()} checks if the process is alive. Returns a logical
#' scalar.
#'
#'
#' @importFrom R6 R6Class
#' @name crossword
#' @examples
#' p <- crossword$new(rows = 10, columns = 10)
#'
NULL


#' @export
crossword <-
  R6::R6Class(
    classname = "crossword",
    public =
      list(
        initialize = function(rows = 10, columns = 10){
          self$grid$rows    <- rows
          self$grid$columns <- columns
        },
        grid = list()
      ),
    private      = NULL,
    active       = NULL,
    inherit      = r6extended,
    lock_objects = TRUE,
    class        = TRUE,
    portable     = TRUE,
    lock_class   = FALSE,
    cloneable    = TRUE,
    parent_env   = parent.frame()
  )




#' dings
#' @name cw_grid
NULL

#' @export
cw_grid <-
  R6::R6Class(
  classname = "cw_grid",
  public =
    list(
      # data fields
      rows         = NULL,
      columns      = NULL,
      letters      = NULL,
      restrictions_right = NULL,
      restrictions_down  = NULL,
      grid_data = NULL,

      # initilize
      initialize =
        function(rows = 10, columns = 10){
          self$rows    <- rows
          self$columns <- columns
          tmp <-
            data.frame(
              row              = rep(seq_len(rows), columns),
              col              = rep(seq_len(columns), each=rows),
              space_right      = NA,
              space_down       = NA,
              stringsAsFactors = FALSE
            )
          tmp$space_right       <- columns - tmp$col + 1
          tmp$space_down        <- rows    - tmp$row + 1

          self$letters <-
            matrix(".", nrow = rows, ncol = columns)

          self$restrictions_right <-
            matrix("", nrow = rows, ncol = columns)

          self$restrictions_down  <-
            matrix("", nrow = rows, ncol = columns)

          self$grid_data <- tmp
        },

      # updating data
      update_grid_data =
        function(){
          for(rowi in seq_len(self$rows)){
            for(coli in seq_len(self$columns)){
              self$restrictions_right[rowi, coli] <- paste(self$letters[rowi, coli:self$columns], collapse = "")
              self$restrictions_down[rowi, coli]  <- paste(self$letters[rowi:self$rows, coli], collapse = "")
            }
          }
          # return
          return(self)
        },

      # add word
      add_word = function(word, row = 1, column = 1, horizontal = TRUE){
        if(horizontal){
          stopifnot( nchar(word) <= (self$columns - column + 1))
          self$letters[row, column:(column+nchar(word)-1)] <- unlist(strsplit(word, ""))
        }else{
          stopifnot( nchar(word) <= (self$rows - row + 1))
          self$letters[row:(row+nchar(word)-1), column] <- unlist(strsplit(word, ""))
        }

        # return
        return(self)
      }

    ),
  private = NULL,
  active = NULL,
  inherit      = r6extended,
  lock_objects = TRUE,
  class = TRUE,
  portable   = TRUE,
  lock_class = FALSE,
  cloneable  = TRUE,
  parent_env = parent.frame()
)

















