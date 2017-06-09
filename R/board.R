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
      words        = NULL,
      restrictions_right = NULL,
      restrictions_down  = NULL,
      grid_data = NULL,

      # initilize
      initialize =
        function(rows = 10, columns = 10){

          ## data ##

          # rows
          self$rows    <- rows

          # columns
          self$columns <- columns

          # ?
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


          self$words <-
            data.frame(
              row              = integer(),
              col              = integer(),
              word             = character(),
              direction        = character(),
              clue             = character(),
              length           = integer(),
              stringsAsFactors = FALSE
            )

          self$restrictions_right <-
            matrix("", nrow = rows, ncol = columns)

          self$restrictions_down  <-
            matrix("", nrow = rows, ncol = columns)

          self$grid_data <- tmp
        },


      # put word on grid
      put_word_on_grid = function(word, row = 1, column = 1, horizontal = TRUE){
        if(horizontal){
          stopifnot( nchar(word) <= (self$columns - column + 1))
          self$letters[row, column:(column+nchar(word)-1)] <- unlist(strsplit(word, ""))
        }else{
          stopifnot( nchar(word) <= (self$rows - row + 1))
          self$letters[row:(row+nchar(word)-1), column] <- unlist(strsplit(word, ""))
        }
      },

      # update restrictions
      update_grid_data =
      function(){

        # make restrictions
        self$restrictions_right <- matrix("", nrow = self$rows, ncol = self$columns)
        self$restrictions_down  <- matrix("", nrow = self$rows, ncol = self$columns)

        # fill restrictions with letters
        for(rowi in seq_len(self$rows)){
          for(coli in seq_len(self$columns)){

            self$restrictions_right[rowi, coli] <-
              paste(self$letters[rowi, coli:self$columns], collapse = "")

            self$restrictions_down[rowi, coli]  <-
              paste(self$letters[rowi:self$rows, coli], collapse = "")

          }
        }

        # turn into data.frame
        self$restrictions_right <-
          matrix_to_df(self$restrictions_right)

        self$restrictions_down  <-
          matrix_to_df(self$restrictions_down)

        # add length
        self$restrictions_right$nchar <-
          nchar(self$restrictions_right$val)

        self$restrictions_down$nchar <-
          nchar(self$restrictions_down$val)

        # sort out word starts
        self$restrictions_down <-
          dplyr::anti_join(
            self$restrictions_down,
            self$words %>% dplyr::filter(direction=="down"),
            by = c("row", "col")
          )

        self$restrictions_right <-
          dplyr::anti_join(
            self$restrictions_right,
            self$words %>% dplyr::filter(direction=="right"),
            by = c("row", "col")
          )

        # return
        return(self)
      },


      # add word
      add_word =
        function(
          word,
          row       = NULL,
          column    = NULL,
          direction = c("right", "down")
        ){
          # check if it fits at all
          word <- word[nchar(word) <= self$columns & nchar(word) <= self$rows]

          # word does not fit at all
          if( length(word) == 0 ){
            self$message("word does not fit at all.")
            return(self)
          }

          # update restrictions
          self$update_grid_data()

          browser()


          # available places down
          down <-
            self$restrictions_down %>%
            dplyr::filter(nchar(val) >= nchar(word)) %>%
            dplyr::rename(length = nchar) %>%
            dplyr::mutate(
              direction = "down",
              clue      = "",
              word      = word,
              weight    = 1/nchar(val)
            )

          # available places right
          right <-
            self$restrictions_right %>%
            dplyr::filter(nchar(val) >= nchar(word)) %>%
            dplyr::rename(length = nchar) %>%
            dplyr::mutate(
              direction = "down",
              clue      = "",
              word      = word,
              weight    = 1/nchar(val)
            )

          #### dev! ###
          # word should fit pattern also


          # add word selection to words
          new_word <-
            rbind(right, down) %>%
            sample_n(1, weight = weight) %>%
            select(-val, -weight)
          self$words <-
            rbind(
              self$words,
              new_word
            )

          # add word to grid
          self$put_word_on_grid(
            word   = new_word$word,
            row    = new_word$row,
            column = new_word$col,
            horizontal =
              if( new_word$direction == "right" ){
                TRUE
              }else{
                FALSE
              }
          )

          # return for piping
          return(self)
        }

    ),
  private      = NULL,
  active       = NULL,
  inherit      = cw_r6_extended,
  lock_objects = TRUE,
  class        = TRUE,
  portable     = TRUE,
  lock_class   = FALSE,
  cloneable    = TRUE,
  parent_env   = parent.frame()
)

















