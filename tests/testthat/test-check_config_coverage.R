library(testthat)
library(data.table)

## Helper: build a nested config and run it through config_to_dt(), matching
## the real pipeline path (read_config -> validate_config -> config_to_dt).
make_config <- function(desired, renames = list(), merges = list()) {
  nsch:::config_to_dt(list(
    desired_variables = desired,
    transformations = list(
      transform = list(),
      rename_columns = renames,
      merge_columns = merges)))
}

test_that("detects variable present directly in .do file", {
  tmp <- tempdir()
  test.dir <- file.path(tmp, "nsch_test_config_cov")
  dir.create(test.dir, showWarnings = FALSE)
  on.exit(unlink(test.dir, recursive = TRUE))
  writeLines(c(
    'label var sc_sex "Sex of child"',
    'label define sc_sex_lab 1 "Male"',
    '    label define sc_sex_lab 2 "Female", add'
  ), file.path(test.dir, "nsch_2099_topical.do"))
  file.create(file.path(test.dir, "nsch_2099_topical.dta"))
  config <- make_config(c("year", "sc_sex"))
  result <- nsch::check_config_coverage(config, test.dir)
  expect_is(result, "data.table")
  sc_sex_row <- result[variable == "sc_sex" & year == 2099L]
  expect_identical(sc_sex_row[["status"]], "present")
})

test_that("detects variable produced by rename", {
  tmp <- tempdir()
  test.dir <- file.path(tmp, "nsch_test_config_rename")
  dir.create(test.dir, showWarnings = FALSE)
  on.exit(unlink(test.dir, recursive = TRUE))
  writeLines(c(
    'label var family_r "Family Structure"',
    'label define family_r_lab 1 "Two parents"'
  ), file.path(test.dir, "nsch_2099_topical.do"))
  file.create(file.path(test.dir, "nsch_2099_topical.dta"))
  config <- make_config(
    c("year", "family"),
    renames = list(family_r = list(years = "2099", new_name = "family")))
  result <- nsch::check_config_coverage(config, test.dir)
  family_row <- result[variable == "family" & year == 2099L]
  expect_identical(family_row[["status"]], "renamed")
  expect_identical(family_row[["source"]], "family_r")
})

test_that("flags missing variable", {
  tmp <- tempdir()
  test.dir <- file.path(tmp, "nsch_test_config_missing")
  dir.create(test.dir, showWarnings = FALSE)
  on.exit(unlink(test.dir, recursive = TRUE))
  writeLines(c(
    'label var sc_sex "Sex of child"'
  ), file.path(test.dir, "nsch_2099_topical.do"))
  file.create(file.path(test.dir, "nsch_2099_topical.dta"))
  config <- make_config(c("year", "sc_sex", "nonexistent"))
  result <- nsch::check_config_coverage(config, test.dir)
  missing_row <- result[variable == "nonexistent" & year == 2099L]
  expect_identical(missing_row[["status"]], "missing")
})

test_that("detects variable produced by merge", {
  tmp <- tempdir()
  test.dir <- file.path(tmp, "nsch_test_config_merge")
  dir.create(test.dir, showWarnings = FALSE)
  on.exit(unlink(test.dir, recursive = TRUE))
  writeLines(c(
    'label var hoursleep "Hours of sleep"',
    'label var hoursleep05 "Hours of sleep age 0-5"'
  ), file.path(test.dir, "nsch_2099_topical.do"))
  file.create(file.path(test.dir, "nsch_2099_topical.dta"))
  config <- make_config(
    c("year", "sleep"),
    merges = list(sleep = list(
      years = "2099",
      column_preferred = "hoursleep",
      column_fallback = "hoursleep05")))
  result <- nsch::check_config_coverage(config, test.dir)
  sleep_row <- result[variable == "sleep" & year == 2099L]
  expect_identical(sleep_row[["status"]], "merged")
})

test_that("error for non-existent data.path", {
  config <- make_config("year")
  expect_error(
    nsch::check_config_coverage(config, "/fake/path"),
    "No .do files found")
})
