library(testthat)
library(data.table)

## Helper: unzip the bundled 2024 data into a temp dir once for all tests.
dir2024 <- tempfile()
dir.create(dir2024)
files2024 <- system.file(
  package = "nsch", "extdata",
  c("datasets.2024.html", "nsch_2024_topical_Stata.zip"),
  mustWork = TRUE)
file.copy(files2024, dir2024)
nsch::get_year(
  "https://www.census.gov/programs-surveys/nsch/data/datasets.2024.html",
  dir2024)
dta2024 <- file.path(dir2024, "nsch_2024e_topical.dta")

test_that("read_dta returns a data.table", {
  dt <- nsch::read_dta(dta2024)
  expect_true(is.data.table(dt))
})

test_that("year column is integer", {
  dt <- nsch::read_dta(dta2024)
  expect_true("year" %in% names(dt))
  expect_true(is.integer(dt[["year"]]))
})

test_that("no haven_labelled columns remain", {
  dt <- nsch::read_dta(dta2024)
  labelled_cols <- names(dt)[sapply(dt, inherits, "haven_labelled")]
  expect_identical(labelled_cols, character(0))
})

test_that("tagged NAs are replaced with sentinel codes", {
  ## The bundled 2024 .dta has no tagged NAs, so we create a small
  ## synthetic .dta with known tagged NAs to verify the mapping.
  tf <- tempfile(fileext = ".dta")
  test_df <- data.frame(
    year = 2099L,
    x = haven::labelled(
      c(1, 2, haven::tagged_na("m"), haven::tagged_na("n"),
        haven::tagged_na("l"), haven::tagged_na("d")),
      labels = c(Yes = 1, No = 2)
    )
  )
  haven::write_dta(test_df, tf)
  dt <- nsch::read_dta(tf)
  expect_identical(dt[["x"]], c(1, 2, 996, 997, 998, 999))
})

test_that("stratum is numeric", {
  dt <- nsch::read_dta(dta2024)
  if("stratum" %in% names(dt)){
    expect_true(is.numeric(dt[["stratum"]]))
  }
})

test_that("informative error for missing dta file", {
  does.not.exist <- tempfile(fileext = ".dta")
  expect_error({
    nsch::read_dta(does.not.exist)
  }, paste(
    "dta.path should be the path to a Stata .dta file,",
    "but this file does not exist:",
    does.not.exist
  ), fixed = TRUE)
})