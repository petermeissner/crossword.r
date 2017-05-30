library(crossword)
library(dplyr)
library(stringr)


words <-
  read.csv(
    file     = "../../wortschatz/deu_wikipedia_2016_10K-words.txt",
    sep      = "\t",
    encoding = "UTF-8"
  ) %>%
  `[[`(2) %>%
  grep("^\\w+$", ., value = TRUE) %>%
  unique() %>%
  grep("^[[:upper:]]", ., value = TRUE)



grd <- cw_grid$new(10, 10)

grd$update_grid_data()
grd$add_word("dingsbums1", 1, 1, TRUE)
grd$add_word("dings", 1, 1, TRUE)












grd$add_word("dingsbums1", 1, 1, TRUE)
grd$add_word("dings", 1, 1, FALSE)

grd$letters
grd$update_grid_data()
grd$restrictions_down
grd$restrictions_right

restrictions <-
  matrix_to_df(grd$restrictions_right)

restrictions[!grepl("^\\w", restrictions$val),]


# filter restrictions
#  - keine darf mit buchstaben anfangen
#  - alle müssen ein feld links/oben frei haben
#  - ab einem Buchstaben wird abgeschnitten (beachte regel 2)


word_fit <-
  Vectorize(
    function(regex, word){
      grepl(regex, word)
    },
    vectorize.args = "regex",
    #USE.NAMES      = FALSE,
    SIMPLIFY = FALSE
  )

word_fit(restrictions, c("bärbel", "dingsbums"))

"bärbel"

