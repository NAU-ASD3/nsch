library(testthat)
library(data.table)

test_that("detects inconsistent factor levels across years", {
  dt <- data.table(
    year = c(2016L, 2016L, 2017L, 2017L),
    status = factor(c("A", "B", "A", "C")))
  result <- nsch::check_label_consistency(dt)
  expect_is(result, "data.table")
  expect_identical(
    names(result),
    c("variable", "is.consistent", "n.level.sets", "levels.by.year"))
  status_row <- result[variable == "status"]
  expect_identical(status_row[["is.consistent"]], FALSE)
  expect_identical(status_row[["n.level.sets"]], 2L)
})

test_that("consistent levels across years returns TRUE", {
  dt <- data.table(
    year = c(2016L, 2016L, 2017L, 2017L),
    status = factor(c("A", "B", "A", "B")))
  result <- nsch::check_label_consistency(dt)
  expect_identical(result[variable == "status"][["is.consistent"]], TRUE)
  expect_identical(result[variable == "status"][["n.level.sets"]], 1L)
})

test_that("skips non-factor columns", {
  dt <- data.table(
    year = c(2016L, 2017L),
    x = c(1.0, 2.0),
    status = factor(c("A", "A")))
  result <- nsch::check_label_consistency(dt)
  expect_identical(unique(result[["variable"]]), "status")
})

test_that("returns empty table when no factors present", {
  dt <- data.table(year = c(2016L, 2017L), x = c(1, 2))
  result <- nsch::check_label_consistency(dt)
  expect_is(result, "data.table")
  expect_identical(nrow(result), 0L)
})

test_that("error for non-data.table input", {
  expect_error(
    nsch::check_label_consistency(data.frame(year = 2016L, x = "a")),
    "data.table")
})