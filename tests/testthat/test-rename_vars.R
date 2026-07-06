library(testthat)
library(data.table)

test_that("column is renamed for matching year", {
  dt <- data.table(
    old_col = c(1, 2),
    old_col_label = c("a", "b"))
  rename.dt <- data.table(
    old_name = "old_col", year = 2016L, new_name = "new_col")
  nsch::rename_vars(dt, rename.dt, 2016L)
  expect_true("new_col" %in% names(dt))
  expect_false("old_col" %in% names(dt))
  expect_true("new_col_label" %in% names(dt))
  expect_false("old_col_label" %in% names(dt))
})

test_that("no rename for non-matching year", {
  dt <- data.table(old_col = c(1, 2))
  rename.dt <- data.table(
    old_name = "old_col", year = 2016L, new_name = "new_col")
  nsch::rename_vars(dt, rename.dt, 2020L)
  expect_true("old_col" %in% names(dt))
  expect_false("new_col" %in% names(dt))
})

test_that("missing column is silently skipped", {
  dt <- data.table(x = c(1, 2))
  rename.dt <- data.table(
    old_name = "not_here", year = 2016L, new_name = "also_not")
  expect_no_error(nsch::rename_vars(dt, rename.dt, 2016L))
  expect_identical(names(dt), "x")
})

test_that("label column renamed alongside data column", {
  dt <- data.table(
    var1 = c(1, 2),
    var1_label = c("Yes", "No"))
  rename.dt <- data.table(
    old_name = "var1", year = c(2017L, 2018L), new_name = "var1_new")
  nsch::rename_vars(dt, rename.dt, 2017L)
  expect_identical(sort(names(dt)), c("var1_new", "var1_new_label"))
  expect_identical(dt[["var1_new_label"]], c("Yes", "No"))
})
