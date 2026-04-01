library(testthat)
library(data.table)

test_that("identifies variable entirely NA in one year", {
  dt <- data.table(
    year = c(2016L, 2016L, 2017L, 2017L),
    x = c(1, 2, 3, 4),
    y = c(1, 2, NA, NA))
  result <- nsch::check_year_coverage(dt)
  expect_is(result, "data.table")
  expect_identical(
    names(result),
    c("variable", "n.years.data", "n.years.total", "missing.years"))
  y_row <- result[variable == "y"]
  expect_identical(y_row[["n.years.data"]], 1L)
  expect_identical(y_row[["n.years.total"]], 2L)
  expect_identical(y_row[["missing.years"]], "2017")
})

test_that("fully covered variable has empty missing.years", {
  dt <- data.table(
    year = c(2016L, 2017L),
    x = c(1, 2))
  result <- nsch::check_year_coverage(dt)
  expect_identical(result[variable == "x"][["missing.years"]], "")
})

test_that("error for missing year column", {
  dt <- data.table(x = 1:3)
  expect_error(nsch::check_year_coverage(dt), "year")
})

test_that("error for non-data.table input", {
  expect_error(
    nsch::check_year_coverage(data.frame(year = 2016L, x = 1)),
    "data.table")
})