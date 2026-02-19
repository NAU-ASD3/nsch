library(testthat)

test_that("columns are coalesced preferring column_1", {
  dt <- data.table::data.table(
    col_a = c(1, NA, 3),
    col_b = c(NA, 2, 4),
    col_a_label = c("one", NA, "three"),
    col_b_label = c(NA, "two", "four"))
  merges <- list(
    merged = list(
      years = "2016",
      column_1 = "col_a",
      column_2 = "col_b"))
  nsch::merge_vars(dt, merges, 2016L)
  expect_identical(dt[["merged"]], c(1, 2, 3))
  ## Source columns should be removed.
  expect_false("col_a" %in% names(dt))
  expect_false("col_b" %in% names(dt))
})

test_that("label columns are also coalesced", {
  dt <- data.table::data.table(
    col_a = c(1, NA),
    col_b = c(NA, 2),
    col_a_label = c("one", NA),
    col_b_label = c(NA, "two"))
  merges <- list(
    merged = list(
      years = "2016",
      column_1 = "col_a",
      column_2 = "col_b"))
  nsch::merge_vars(dt, merges, 2016L)
  expect_identical(dt[["merged_label"]], c("one", "two"))
  ## Source label columns should also be removed.
  expect_false("col_a_label" %in% names(dt))
  expect_false("col_b_label" %in% names(dt))
})

test_that("no merge for non-matching year", {
  dt <- data.table::data.table(
    col_a = c(1, NA),
    col_b = c(NA, 2))
  merges <- list(
    merged = list(
      years = "2016",
      column_1 = "col_a",
      column_2 = "col_b"))
  nsch::merge_vars(dt, merges, 2020L)
  expect_true("col_a" %in% names(dt))
  expect_true("col_b" %in% names(dt))
  expect_false("merged" %in% names(dt))
})

test_that("missing source columns are silently skipped", {
  dt <- data.table::data.table(x = c(1, 2))
  merges <- list(
    merged = list(
      years = "2016",
      column_1 = "not_here",
      column_2 = "also_not"))
  expect_no_error(nsch::merge_vars(dt, merges, 2016L))
  expect_identical(names(dt), "x")
})