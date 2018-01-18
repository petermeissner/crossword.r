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

    expect_true({
      cw_normalize_words(paste(letters, collapse = "")) ==
        cw_normalize_words(paste(LETTERS, collapse = ""))
    })

    expect_true({
      cw_normalize_words("") == "##"
    })

    expect_true({
      cw_normalize_words(c("öäüßÖÄÜ")) == "#OEAEUESSOEAEUE#"
    })

    expect_warning({
      cw_normalize_words("data-science")
    })


    expect_error({
      cw <- Crossword$new(rows = 10, columns = 10)
      cw$add_words()
    })

    expect_silent({
      cw <- Crossword$new(rows = 2, columns = 2)
      cw$add_words("a", "b")
      cw$add_words(letters[1:10], LETTERS[1:10])
      cw$add_words("meineomafährtimhühnerstallmotorad")
    })

    expect_true({
        cw$print()
        cw$density()
        TRUE
      })

  }
)

