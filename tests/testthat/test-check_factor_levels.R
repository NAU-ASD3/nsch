library(testthat)
library(data.table)

test_that("check_factor_levels detects a level present in only some years", {
  dt <- data.table(
    year = c(2016, 2016, 2017, 2017),
    status = factor(c("A", "B", "A", "A"))
  )

  res <- check_factor_levels(dt)

  expect_true(data.table::is.data.table(res))

  b_row <- res[variable == "status" & level == "B"]

  expect_equal(nrow(b_row), 1L)
  expect_equal(b_row$n.years.present, 1L)
  expect_equal(b_row$years.present, "2016")
})

test_that("check_factor_levels returns empty output for numeric columns", {
  dt <- data.table(
    year = c(2016, 2017),
    age = c(5, 6),
    score = c(10, 20)
  )

  res <- check_factor_levels(dt)

  expect_equal(nrow(res), 0L)
})
