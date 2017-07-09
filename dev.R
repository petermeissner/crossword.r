library(crossword)
library(dplyr)
library(stringr)
library(googlesheets)

set.seed(3)

# get words
googlesheets::gs_auth()
googlesheets::gs_ls()

gs_crossword  <- gs_title("kreuzworträtsel")
word_list     <- gs_read_csv(gs_crossword, ws=1)[, c("Wort", "Hinweis")]
fillword_list <- gs_read_csv(gs_crossword, ws=2)[, c("Wort", "Hinweis")]

# get words when here is no inerne access
if( !exists("word_list") ){
  word_list <- readRDS("word_list.rds")
}
if( !exists("fillword_list") ){
  fillword_list <- readRDS("fillword_list.rds")
}


# prepare
word_list <- word_list[sample(seq_len(nrow(word_list))),]


# gen grid
grd <- crossword$new(30, 30)
grd

# add words
grd$add_words(word_list$Wort, word_list$Hinweis)
grd$add_words(fillword_list$Wort, fillword_list$Hinweis)
grd

# check result
grd$words
grd$density()
grd

df <- as.data.frame(grd$letters)

gs_crossword <- gs_title("kreuzworträtsel")
ws_index     <- length(gs_ws_ls(ss = gs_crossword)) + 1
ws_name      <- paste0("kwr_", ws_index)
gs_ws_new(ss = gs_crossword, ws_title = ws_name)

gs_crossword <- gs_title("kreuzworträtsel")
gs_edit_cells(ss = gs_crossword, ws = ws_index, input = as.data.frame(grd$letters), trim = TRUE)


