library(testthat)
library(data.table)

test_that("computes correct NA rates per year", {
  dt <- data.table(
    year = c(2016L, 2016L, 2017L, 2017L),
    x = c(1, NA, 3, 4),
    y = c(NA, NA, 5, 6))
  result <- nsch::check_na_rates(dt)
  expect_is(result, "data.table")
  expect_identical(
    names(result),
    c("variable", "year", "na.rate", "n.total"))
  x_2016 <- result[variable == "x" & year == 2016L]
  expect_identical(x_2016[["na.rate"]], 0.5)
  expect_identical(x_2016[["n.total"]], 2L)
  y_2016 <- result[variable == "y" & year == 2016L]
  expect_identical(y_2016[["na.rate"]], 1.0)
  x_2017 <- result[variable == "x" & year == 2017L]
  expect_identical(x_2017[["na.rate"]], 0.0)
})

test_that("excludes year column from output", {
  dt <- data.table(year = c(2016L, 2017L), x = c(1, 2))
  result <- nsch::check_na_rates(dt)
  expect_identical(unique(result[["variable"]]), "x")
})

test_that("error for missing year column", {
  dt <- data.table(x = 1:3)
  expect_error(nsch::check_na_rates(dt), "year")
})

test_that("error for non-data.table input", {
  expect_error(nsch::check_na_rates(data.frame(year = 2016L, x = 1)), "data.table")
})