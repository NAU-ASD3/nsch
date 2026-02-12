library(testthat)

test_that("year column is int", {
  years_dt <- nsch::get_nsch_index(system.file(
    package="nsch", "extdata", "datasets.html", mustWork = TRUE))
  expect_identical(years_dt[["year"]], 2024:2016)
})
