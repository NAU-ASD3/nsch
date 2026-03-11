library(testthat)
library(data.table)

test_that("combines multiple year tables correctly", {
  dt1 <- data.table(year = 2016L, x = 1:3)
  dt2 <- data.table(year = 2017L, x = 4:6)
  result <- nsch::combine_years(list(dt1, dt2))
  expect_equal(nrow(result), 6L)
  expect_identical(sort(unique(result[["year"]])), c(2016L, 2017L))
})

test_that("fill=TRUE handles columns missing in some years", {
  dt1 <- data.table(year = 2016L,
                    x = 1:2,
                    var2 = c(10, 20))
  dt2 <- data.table(year = 2017L, x = 3:4)
  result <- nsch::combine_years(list(dt1, dt2))
  expect_true("var2" %in% names(result))
  expect_identical(result[year == 2017L][["var2"]], c(NA_real_, NA_real_))
})

test_that("error for duplicate year values", {
  dt1 <- data.table(year = 2016L, x = 1:2)
  dt2 <- data.table(year = 2016L, x = 3:4)
  expect_error(nsch::combine_years(list(dt1, dt2)), "duplicate year")
})

test_that("error for missing year column", {
  dt1 <- data.table(x = 1:2)
  expect_error(nsch::combine_years(list(dt1)), "year")
})