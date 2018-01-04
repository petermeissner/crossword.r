#' function implementing to_json method
#'
#' @param cw an object of class crossword
#' @param pretty should json formatted to be mor human readable or not
#'
cw_to_json <-
  function(cw, pretty = FALSE){
    res <- list()

    # prepare grid
    letters <- cw$letters[-1,-1]
    letters <- letters[-nrow(letters),-ncol(letters)]
    letters[letters == "#"] <- ""
    letters[letters == "."] <- ""

    res$grid <- letters

    # prepare words
    words        <- split(cw$words, seq_len(nrow(cw$words)))
    words        <- lapply(words, as.list)
    names(words) <- NULL

    res$words <- words


    jsonlite::toJSON(res, pretty = pretty, auto_unbox = TRUE)
  }