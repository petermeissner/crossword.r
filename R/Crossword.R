#' Crossword
#'
#' @format
#' An \code{\link{R6Class}} generator object for generating crosswords from word lists
#'
#'
#' @docType class
#'
#'
#' @format  Crossword$new(rows = 10, columns = 10, verbose = FALSE)
#'
#'
#' @section Methods:
#' \describe{
#'   \item{
#'     \code{add_words(words, clues = NULL)}}{
#'      this method will try to add words to the crossword by placing it on the grid;
#'      \code{clues} is optional and should be the same length;
#'
#'    }
#'  \item{\code{density()}}{
#'    gives back statistics on fill state of grid
#'  }
#'  \item{\code{to_json(pretty = FALSE)}}{
#'    thi exports grid and word list data to JSON for external usage; \code{pretty}
#'    parameter determines if this is done in a human readable or more machine
#'    efficient way
#'  }
#' }
#' @field letters a character matrix  representing the grid of the crossword
#' @field words a data.frame like (tibble) storing words, their position on
#'   the grid (row, col), their length in character, their direction ("right", "down")
#'   the word and the clue
#'
#' @importFrom R6 R6Class
#'
#' @export
#'
#' @name Crossword
#'
#'
#' @examples
#'
#' library(crossword.r)
#' cw <- Crossword$new(rows = 4, columns = 4)
#' cw$add_words(c("back", "nasa", "kick", "nuk", "ic", "sic"))
#' cw
#' cw$letters
#' cw$words
#' cw$density()
#'
Crossword <-
  R6::R6Class(
    private      =
      list(

        rows               = NULL, # number of rows
        columns            = NULL, # number of columns
        restrictions_right = NULL, # data.frame storing restrictions on placing a word for each coordinate of grid
        restrictions_down  = NULL, # data.frame storing restrictions on placing a word for each coordinate of grid

        # add word
        add_word =
          function(
            word,
            clue = ""
          ){
            word <- cw_normalize_words(word)

            # check if it fits at all
            word <- word[nchar(word) <= private$columns & nchar(word) <= private$rows]

            # word does not fit at all
            if( length(word) == 0 ){
              self$message("word does not fit at all.")
              return(self)
            }

            # update restrictions
            private$update_grid_data()

            # available places down
            iffer <-
              cw_greplv(
                substring(private$restrictions_down$val, 1, nchar(word)),
                word
              ) &
              nchar(private$restrictions_down$val) >= nchar(word)

            down <-
              private$restrictions_down %>%
              dplyr::filter(
                iffer
              ) %>%
              dplyr::rename(length = nchar) %>%
              dplyr::mutate(
                direction = "down",
                word      = word,
                clue      = clue,
                val       = substring(val, 1, nchar(word))
              )


            # available places right
            iffer <-
              cw_greplv(
                substring(private$restrictions_right$val, 1, nchar(word)),
                word
              ) &
              nchar(private$restrictions_right$val) >= nchar(word)

            right <-
              private$restrictions_right %>%
              dplyr::filter(
                iffer
              ) %>%
              dplyr::rename(length = nchar) %>%
              dplyr::mutate(
                direction = "right",
                word      = word,
                clue      = clue,
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
                stringr::str_count(tmp$val, pattern = "[[:alpha:]]")

              # distance to middle
              tmp$weight <-
                tmp$weight +
                (
                  abs(tmp$row - private$rows/2) + abs(tmp$col - private$columns/2)
                ) /
                (
                  private$rows/2 + private$columns/2
                )


              new_word <-
                tmp %>%
                dplyr::filter(weight == max(weight)) %>%
                dplyr::mutate(
                  word   = stringr::str_replace_all(word, "([^[:alpha:]])", ""),
                  length = nchar(word)
                ) %>%
                dplyr::slice(1) %>%
                dplyr::select(-val, -weight)


              # add word to grid
              private$put_word_on_grid(
                word      = paste0("#", new_word$word, "#"),
                row       = new_word$row,
                column    = new_word$col,
                direction = new_word$direction
              )

              # add word selection to words
              if( new_word$direction == "down" ){
                new_word$col <- new_word$col - 1L
              }else if( new_word$direction == "right" ){
                new_word$row <- new_word$row - 1L
              }

              self$words <-
                rbind(
                  self$words,
                  new_word
                )
            }else{
              self$message(
                "Could not place on grid - nothing that suffices restrictions"
              )
            }

            # return for piping
            return(self)
          },

        # put word on grid
        put_word_on_grid =
          function(
            word,
            row       = 1,
            column    = 1,
            direction = c("down", "right")
          ){
            self$message(c(word, row, column, direction, "\n\n", sep=" / "))

            if( direction == "right" ) {

              # check
              stopifnot( nchar(word) <= (private$columns - column + 1))

              # assignment
              self$letters[
                row,
                column:(column+nchar(word)-1)
                ] <-
                unlist(strsplit(word, ""))

            }else if ( direction == "down" ){

              # check
              stopifnot( nchar(word) <= (private$rows - row + 1))

              # assignment
              self$letters[
                row:(row+nchar(word)-1),
                column
                ] <-
                unlist(strsplit(word, ""))

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
            private$restrictions_right <- matrix("", nrow = private$rows, ncol = private$columns)
            private$restrictions_down  <- matrix("", nrow = private$rows, ncol = private$columns)

            # fill restrictions with letters
            for(rowi in seq_len(private$rows)){
              for(coli in seq_len(private$columns)){

                private$restrictions_right[rowi, coli] <-
                  paste(self$letters[rowi, coli:private$columns], collapse = "")

                private$restrictions_down[rowi, coli]  <-
                  paste(self$letters[rowi:private$rows, coli], collapse = "")

              }
            }

            # turn into data.frame
            private$restrictions_right <-
              cw_matrix_to_df(private$restrictions_right)

            private$restrictions_down  <-
              cw_matrix_to_df(private$restrictions_down)

            # add length
            private$restrictions_right$nchar <-
              nchar(private$restrictions_right$val)

            private$restrictions_down$nchar <-
              nchar(private$restrictions_down$val)

            # sort out word starts
            private$restrictions_down <-
              dplyr::anti_join(
                private$restrictions_down,
                self$words %>% dplyr::filter(direction=="down"),
                by = c("row", "col")
              )

            private$restrictions_right <-
              dplyr::anti_join(
                private$restrictions_right,
                self$words %>% dplyr::filter(direction=="right"),
                by = c("row", "col")
              )

            # return
            return(self)
          }
      ),
    active       = NULL,
    lock_objects = TRUE,
    class        = TRUE,
    portable     = TRUE,
    lock_class   = FALSE,
    cloneable    = TRUE,

    parent_env = asNamespace('crossword.r'),

    classname    = "crossword",
    inherit      = r6extended::r6extended,

    public =

      list(
        # data fields
        letters            = NULL, # matrix of letters repsesenting the grid
        words              = NULL, # data.frame listing word coordinates and info

        # initilize
        initialize =
          function(rows = 10, columns = 10, verbose = FALSE){

            ## options ##
            self$options$verbose = verbose


            ## data ##

            # rows
            rows         <- rows + 2
            private$rows <- rows

            # columns
            columns      <- columns + 2
            private$columns <- columns

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

            # fill margins with "#"
            self$letters[1,] <- "#"
            self$letters[dim(self$letters)[1],] <- "#"

            self$letters[,1] <- "#"
            self$letters[,dim(self$letters)[2]] <- "#"


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

            private$restrictions_right <-
              matrix("", nrow = rows, ncol = columns)

            private$restrictions_down  <-
              matrix("", nrow = rows, ncol = columns)


            # return
            return(self)
          },

        # adding lists of words (and its clue)
        add_words = function(words, clues = NULL){
          # ensure matching length between words and clues for unset clues
          if( is.null(clues) ){
            clues <- rep("", length(words))
          }

          for ( i in seq_along(words) ) {
            private$add_word(
              word = words[i],
              clue = clues[i]
            )
          }
        },

        # the crosswords print method
        print = function(){
          tmp <-
            cbind(
              c(
                ".",
                head(
                  (seq_len(nrow(self$letters)) %% 10),
                  nrow(self$letters)-1)
                ),
              self$letters
            )

          tmp <-
            rbind(
              c(
                ".",
                ".",
                head(
                  seq_len(ncol(self$letters)) %% 10,
                  ncol(self$letters)-1)
                ),
              tmp
            )
          apply(tmp, 1, function(x){cat(x); cat("\n")})
          invisible(self)
        },


        # caculating the 'quality of the crossword'
        density = function(){
          word_character <- sum(self$words$length)
          grid_width     <- max(self$words$col) - min(self$words$col) + 1
          grid_height    <- max(self$words$row) - min(self$words$row) + 1
          grid_letters   <- stringr::str_count(paste(self$letters, collapse = ""), "[[:alpha:]]")

          list(
            word_character = word_character,
            grid_width     = grid_width,
            grid_height    = grid_height,
            grid_letters   = grid_letters
          )
        },

        # json export function
        to_json =
          function(pretty = FALSE){
            cw_to_json(self, pretty = pretty)
          }

      )
  )




