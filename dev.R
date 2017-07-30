library(crossword)
library(dplyr)
library(stringr)
library(googlesheets)


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
set.seed(1032)
word_list <- word_list[sample(seq_len(nrow(word_list))),]


# gen grid
grd <- crossword$new(30, 40)
grd

# add words
grd$add_words(word_list$Wort, word_list$Hinweis)
grd$add_words(fillword_list$Wort, fillword_list$Hinweis)
grd



system.time({
  RES <- list()
  for(i in 1:1500){
    set.seed(1032)
    word_list <- word_list[sample(seq_len(nrow(word_list))),]
    grd       <- crossword$new(30, 40)
    grd$add_words(word_list$Wort, word_list$Hinweis)
    RES[[i]] <- grd$density()
  }
})

res <- do.call(rbind, RES)


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


