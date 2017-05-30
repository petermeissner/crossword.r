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


cw <-
  crossword$new(10, 10)


grd <-
  cw_grid$new(10, 10)

grd$add_word("dingsbums1", 1, 1, TRUE)
grd$add_word("dings", 1, 1, FALSE)

grd$letters
grd$update_grid_data()
grd$restrictions_down
grd$restrictions_right

  "bärbel"

