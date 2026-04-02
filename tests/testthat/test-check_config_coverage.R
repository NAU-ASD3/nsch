library(testthat)
library(data.table)

test_that("detects variable present directly in .do file", {
  tmp <- tempdir()
  test.dir <- file.path(tmp, "nsch_test_config_cov")
  dir.create(test.dir, showWarnings = FALSE)
  on.exit(unlink(test.dir, recursive = TRUE))
  ## Create a minimal .do file with sc_sex defined.
  writeLines(c(
    'label var sc_sex "Sex of child"',
    'label define sc_sex_lab 1 "Male"',
    '    label define sc_sex_lab 2 "Female", add'
  ), file.path(test.dir, "nsch_2099_topical.do"))
  file.create(file.path(test.dir, "nsch_2099_topical.dta"))
  config <- list(
    desired_variables = c("year", "sc_sex"),
    transformations = list(
      transform = list(),
      rename_columns = list(),
      merge_columns = list()))
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
  config <- list(
    desired_variables = c("year", "family"),
    transformations = list(
      transform = list(),
      rename_columns = list(
        family_r = list(years = "2099", new_name = "family")),
      merge_columns = list()))
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
  config <- list(
    desired_variables = c("year", "sc_sex", "nonexistent"),
    transformations = list(
      transform = list(),
      rename_columns = list(),
      merge_columns = list()))
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
  config <- list(
    desired_variables = c("year", "sleep"),
    transformations = list(
      transform = list(),
      rename_columns = list(),
      merge_columns = list(
        sleep = list(
          years = "2099",
          column_preferred = "hoursleep",
          column_fallback = "hoursleep05"))))
  result <- nsch::check_config_coverage(config, test.dir)
  sleep_row <- result[variable == "sleep" & year == 2099L]
  expect_identical(sleep_row[["status"]], "merged")
})

test_that("error for non-existent data.path", {
  config <- list(
    desired_variables = "year",
    transformations = list(
      transform = list(),
      rename_columns = list(),
      merge_columns = list()))
  expect_error(
    nsch::check_config_coverage(config, "/fake/path"),
    "No .do files found")
})