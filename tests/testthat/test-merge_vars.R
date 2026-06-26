library(testthat)

test_that("columns are coalesced preferring column_preferred", {
  dt <- data.table::data.table(
    col_a = c(1, NA, 3),
    col_b = c(NA, 2, 4),
    col_a_label = c("one", NA, "three"),
    col_b_label = c(NA, "two", "four"))
  merges <- list(
    merged = list(
      years = "2016",
      column_preferred = "col_a",
      column_fallback = "col_b"))
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
      column_preferred = "col_a",
      column_fallback = "col_b"))
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
      column_preferred = "col_a",
      column_fallback = "col_b"))
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
      column_preferred = "not_here",
      column_fallback = "also_not"))
  expect_no_error(nsch::merge_vars(dt, merges, 2016L))
  expect_identical(names(dt), "x")
})
test_that("logical-skip sentinel 998 in column_preferred triggers fallback", {
  ## Regression test for the sleep-merge bug. read_dta() maps Stata's
  ## .l (logical skip) tagged-NA to 998 via na_tag_map. For
  ## age-bucketed merges like hoursleep / hoursleep05, the preferred
  ## column is logical-skipped (998) for respondents outside its age
  ## range, and the fallback holds their real answer. merge_vars must
  ## treat 998 as missing so the fallback fires.
  dt <- data.table::data.table(
    col_a = c(1, 998L, 998L, 3),
    col_b = c(NA, 2, NA, 4))
  merges <- list(
    merged = list(
      years = "2016",
      column_preferred = "col_a",
      column_fallback = "col_b"))
  nsch::merge_vars(dt, merges, 2016L)
  expect_identical(dt[["merged"]], c(1, 2, NA, 3))
})

test_that("non-logical-skip sentinels in column_preferred do not trigger fallback", {
  ## 998 (logical skip) is a routing signal: "the respondent was
  ## age-routed away from this column." 996 (no valid response),
  ## 997 (not in universe), and 999 (suppressed) are response-quality
  ## signals — the respondent was in the question's universe but no
  ## usable value is available. They stay on the preferred path and
  ## are mapped to NA later by apply_do_labels.
  dt <- data.table::data.table(
    col_a = c(996L, 997L, 999L),
    col_b = c(2, 3, 4))
  merges <- list(
    merged = list(
      years = "2016",
      column_preferred = "col_a",
      column_fallback = "col_b"))
  nsch::merge_vars(dt, merges, 2016L)
  expect_identical(dt[["merged"]], c(996, 997, 999))
})

test_that("label coalesce stays in sync with sentinel-triggered fallback", {
  dt <- data.table::data.table(
    col_a       = c(1,     998L,  998L),
    col_b       = c(NA,    2,     NA),
    col_a_label = c("one", NA,    NA),
    col_b_label = c(NA,    "two", NA))
  merges <- list(
    merged = list(
      years = "2016",
      column_preferred = "col_a",
      column_fallback = "col_b"))
  nsch::merge_vars(dt, merges, 2016L)
  expect_identical(dt[["merged"]],       c(1, 2, NA))
  expect_identical(dt[["merged_label"]], c("one", "two", NA))
})
