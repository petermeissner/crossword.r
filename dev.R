library(crossword)
library(dplyr)
library(stringr)


# words <-
#   read.csv(
#     file     = "../../wortschatz/deu_wikipedia_2016_10K-words.txt",
#     sep      = "\t",
#     encoding = "UTF-8"
#   ) %>%
#   `[[`(2) %>%
#   grep("^\\w+$", ., value = TRUE) %>%
#   unique() %>%
#   grep("^[[:upper:]]", ., value = TRUE)


grd <- cw_grid$new(10, 10)

grd$update_grid_data()
grd

grd$add_words(c("ganz", "kerze", "ganter"), rep("",3))

grd$add_word("ganz")
grd$add_word("kerze")
grd$add_word("ganter")


grd$add_word("dingsbums1")
grd$add_word("dings")

grd$add_word("ddubs")
grd$add_word("ddubs")
grd$add_word("ddubs")




