library(crossword)
library(dplyr)
library(stringr)
library(googlesheets)


# get words
googlesheets::gs_auth()
googlesheets::gs_ls()

gs_crossword <- gs_title("kreuzworträtsel")
lc_crossword <- gs_read_csv(gs_crossword)[, c("Wort", "Hinweis")]


# prepare


lc_crossword$Wort <- normalize_words(lc_crossword$Wort)

lc_crossword <- lc_crossword[sample(seq_len(nrow(lc_crossword))),]

grd <- cw_grid$new(30, 30)
grd$add_words(lc_crossword$Wort, lc_crossword$Hinweis)
grd$words
grd$density()
grd

df <- as.data.frame(grd$letters)
gs_add_row(gs_crossword, ws=2)
gs_edit_cells(ss = gs_crossword, ws = 2, input = as.data.frame(grd$letters), trim = TRUE)


