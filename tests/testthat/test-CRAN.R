library(testthat)
datasets.html <- system.file(
  package="nsch", "extdata", "datasets.html", mustWork = TRUE)
test_that("get_nsch_index() year column is int", {
  years_dt <- nsch::get_nsch_index(datasets.html)
  expect_identical(years_dt[["year"]], 2024:2016)
})

test_that("get_year() test 2024 data unzipped", {
  files2024 <- system.file(package="nsch", "extdata", c("datasets.2024.html", "nsch_2024_topical_Stata.zip"), mustWork=TRUE)
  dir2024 <- tempfile()
  dir.create(dir2024)
  file.copy(files2024, dir2024)
  nsch::get_year("https://www.census.gov/programs-surveys/nsch/data/datasets.2024.html", dir2024)
  expect_in(c("nsch_2024_topical.do", "nsch_2024e_topical.dta"), dir(dir2024))
})

test_that("get_year() error for html with no zip", {
  data.dir <- tempfile()
  dir.create(data.dir)
  cat("no links", file=file.path(data.dir, "datasets.html"))
  expect_error({
    nsch::get_year("https://www.census.gov/programs-surveys/nsch/data/datasets.html", data.dir)
    }, "expected 1 topical_Stata.zip url on https://www.census.gov/programs-surveys/nsch/data/datasets.html but found 0", fixed=TRUE)
})
