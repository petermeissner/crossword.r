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
      put_word_on_grid =
        function(
          word,
          row       = 1,
          column    = 1,
          direction = c("down", "right")
        ){
          cat(word, row, column, direction, "\n\n", sep=" / ")
        if( direction == "right"){
          stopifnot( nchar(word) <= (self$columns - column + 1))
          self$letters[row, column:(column+nchar(word)-1)] <- unlist(strsplit(word, ""))
        }else if ( direction == "down" ){
          stopifnot( nchar(word) <= (self$rows - row + 1))
          self$letters[row:(row+nchar(word)-1), column] <- unlist(strsplit(word, ""))
        }else{
          stop("direction neither 'down' nor 'right'")
        }

        # return
        return(self)
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
          clue
        ){
          word <- toupper(word)

          # check if it fits at all
          word <- word[nchar(word) <= self$columns & nchar(word) <= self$rows]

          # word does not fit at all
          if( length(word) == 0 ){
            self$message("word does not fit at all.")
            return(self)
          }

          # update restrictions
          self$update_grid_data()

          # available places down
          iffer <-
            greplv(substring(self$restrictions_down$val, 1, nchar(word)), word) &
            nchar(self$restrictions_down$val) >= nchar(word)

          down <-
            self$restrictions_down %>%
            dplyr::filter(
              iffer
            ) %>%
            dplyr::rename(length = nchar) %>%
            dplyr::mutate(
              direction = "down",
              clue      = clue,
              word      = word,
              val       = substring(val, 1, nchar(word))
            )


          # available places right
          iffer <-
            greplv(substring(self$restrictions_right$val, 1, nchar(word)), word) &
            nchar(self$restrictions_right$val) >= nchar(word)

          right <-
            self$restrictions_right %>%
            dplyr::filter(
              iffer
            ) %>%
            dplyr::rename(length = nchar) %>%
            dplyr::mutate(
              direction = "right",
              clue      = "",
              word      = word,
              val       = substring(val, 1, nchar(word))
            )


          if ( (nrow(right) + nrow(down)) > 0 ) {
            # select one of the possible places

            words_right <- length(self$words$direction == "right")
            words_down  <- length(self$words$direction == "down")

            # all possibilities
            tmp <- rbind(right, down)

            # basic weight
            tmp$weight <- 1

            # balancing right and down
            tmp$weight[tmp$direction=="right"] <-
              tmp$weight[tmp$direction=="right"] +
              max(words_down - words_right, 0)

            # balancing right and down
            tmp$weight[tmp$direction=="down"] <-
              tmp$weight[tmp$direction=="down"] +
              max(words_right - words_down, 0)

            # number of letters also occupying
            tmp$weight <-
              tmp$weight +
              str_count(tmp$val, pattern = "[[:alpha:]]")

            # distance to middle
            tmp$weight <- tmp$weight + (self$rows/2 - abs(self$rows/2 - 1:30)) / (self$rows/4)


            new_word <-
              tmp %>%
              dplyr::filter(weight == max(weight)) %>%
              dplyr::mutate(
                word   = stringr::str_replace_all(word, "([^[:alpha:]])", ""),
                length = nchar(word)
              ) %>%
              dplyr::slice(1) %>%
              dplyr::select(-val, -weight)

            # add word selection to words
            self$words <-
              rbind(
                self$words,
                new_word
              )

            # add word to grid
            self$put_word_on_grid(
              word      = new_word$word,
              row       = new_word$row,
              column    = new_word$col,
              direction = new_word$direction
            )
          }else{
            self$message("Could not place on grid - nothing that suffices restrictions")
          }

          # return for piping
          return(self)
        },

      add_words = function(words, clues){
        for ( i in seq_along(words) ) {
          self$add_word(
            word = words[i],
            clue = clues[i]
          )
        }
      },

      print = function(){
        apply(self$letters, 1, function(x){cat(x); cat("\n")})
        invisible(self)
      },

      density = function(){
        word_character <- sum(self$words$length)
        grid_width     <- max(self$words$col) - min(self$words$col) + 1
        grid_height    <- max(self$words$row) - min(self$words$row) + 1
        grid_letters   <- str_count(paste(self$letters, collapse = ""), "[[:alpha:]]")

        list(
          word_character = word_character,
          grid_width     = grid_width,
          grid_height    = grid_height,
          grid_letters   = grid_letters
        )
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

















