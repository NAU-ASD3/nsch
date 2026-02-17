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
  dt <- nsch::read_dta(dta2024)
  ## The NSCH .dta files contain tagged NAs in many columns.
  ## After read_dta, those should be converted to 996-999.
  ## We check that at least one of the sentinel codes appears
  ## somewhere in the data (they are pervasive in NSCH).
  all_values <- unlist(lapply(dt, function(col){
    if(is.numeric(col)) col else NULL
  }))
  sentinel_codes <- c(996L, 997L, 998L, 999L)
  found <- sentinel_codes %in% all_values
  expect_true(any(found),
              info = "expected at least one sentinel code (996-999) in the data")
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