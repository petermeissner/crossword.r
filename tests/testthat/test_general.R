context("general test")

test_that(
  "things work in general",
  {
    expect_true({
      cw <- Crossword$new(rows = 1, columns = 1)
      all(dim(cw$letters) == c(3,3))
    })

    expect_silent({
      cw <- Crossword$new(rows = 10, columns = 10)
      cw$add_words(words = c("ha", "albert"))
      jsonlite::fromJSON(cw$to_json())
    })

    expect_message({
      cw <- Crossword$new(rows = 10, columns = 10, verbose = TRUE)
      cw$add_words(words = c("ha"))
    })


  }
)

