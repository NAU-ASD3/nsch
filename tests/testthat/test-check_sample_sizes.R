library(testthat)
library(data.table)

test_that("returns correct row counts per year", {
  dt <- data.table(
    year = c(2016L, 2016L, 2016L, 2017L, 2017L),
    x = 1:5)
  result <- nsch::check_sample_sizes(dt)
  expect_is(result, "data.table")
  expect_identical(names(result), c("year", "n.rows"))
  expect_identical(result[year == 2016L][["n.rows"]], 3L)
  expect_identical(result[year == 2017L][["n.rows"]], 2L)
})

test_that("years are sorted", {
  dt <- data.table(
    year = c(2017L, 2016L, 2018L),
    x = 1:3)
  result <- nsch::check_sample_sizes(dt)
  expect_identical(result[["year"]], c(2016L, 2017L, 2018L))
})

test_that("error for missing year column", {
  dt <- data.table(x = 1:3)
  expect_error(nsch::check_sample_sizes(dt), "year")
})

test_that("error for non-data.table input", {
  expect_error(
    nsch::check_sample_sizes(data.frame(year = 2016L, x = 1)),
    "data.table")
})