library(testthat)

test_that("values are remapped for matching year", {
  dt <- data.table::data.table(k2q01_d = c(1, 2, 3))
  transforms <- list(
    k2q01_d = list(
      years = c("2016", "2017"),
      value = "2",
      new_value = "1",
      new_label = "Yes"))
  result <- nsch::transform_values(dt, transforms, 2016L)
  expect_identical(dt[["k2q01_d"]], c(1, 1, 3))
  expect_identical(dt[["k2q01_d_label"]], c(NA_character_, "Yes", NA_character_))
})

test_that("no changes for non-matching year", {
  dt <- data.table::data.table(k2q01_d = c(1, 2, 3))
  transforms <- list(
    k2q01_d = list(
      years = "2016",
      value = "2",
      new_value = "1",
      new_label = "Yes"))
  nsch::transform_values(dt, transforms, 2020L)
  expect_identical(dt[["k2q01_d"]], c(1, 2, 3))
  expect_null(dt[["k2q01_d_label"]])
})

test_that("multiple values remapped in single variable", {
  dt <- data.table::data.table(family = c(1, 2, 3, 4))
  transforms <- list(
    family = list(
      years = "2016",
      value = c("1", "2", "3", "4"),
      new_value = c("1", "1", "2", "2"),
      new_label = c("Two parents", "Two parents",
                    "Other", "Other")))
  nsch::transform_values(dt, transforms, 2016L)
  expect_identical(dt[["family"]], c(1, 1, 2, 2))
  expect_identical(
    dt[["family_label"]],
    c("Two parents", "Two parents", "Other", "Other"))
})

test_that("label-only transforms work", {
  dt <- data.table::data.table(sex = c(1, 2))
  transforms <- list(
    sex = list(
      years = "2017",
      value = c("1", "2"),
      new_value = c("1", "2"),
      new_label = c("Male", "Female")))
  nsch::transform_values(dt, transforms, 2017L)
  expect_identical(dt[["sex"]], c(1, 2))
  expect_identical(dt[["sex_label"]], c("Male", "Female"))
})

test_that("missing variable in dt is silently skipped", {
  dt <- data.table::data.table(x = c(1, 2))
  transforms <- list(
    not_here = list(
      years = "2016",
      value = "1",
      new_value = "2",
      new_label = "Two"))
  expect_no_error(nsch::transform_values(dt, transforms, 2016L))
  expect_identical(names(dt), "x")
})
test_that("identity remap supplies labels without changing values (k2q01_d #60)", {
  ## Regression for #60: 2016 k2q01_d values 1-5 came out unlabeled because the
  ## 2016 .do attached an incomplete label set. The config supplies identity
  ## remaps (value == new_value) carrying the Excellent-Poor labels so the
  ## scale is labeled even when the .do define omits it.
  dt <- data.table::data.table(k2q01_d = c(1, 2, 3, 4, 5, 6))
  transforms <- list(
    k2q01_d = list(
      years = c("2016", "2017", "2018", "2019", "2020",
                "2021", "2022", "2023", "2024"),
      value = c("1", "2", "3", "4", "5", "6"),
      new_value = c("1", "2", "3", "4", "5", "6"),
      new_label = c("Excellent", "Very Good", "Good", "Fair", "Poor",
                    "This child does not have any teeth [T1 only]")))
  nsch::transform_values(dt, transforms, 2016L)
  ## Values unchanged (identity remap).
  expect_identical(dt[["k2q01_d"]], c(1, 2, 3, 4, 5, 6))
  ## Labels applied across the full scale.
  expect_identical(
    dt[["k2q01_d_label"]],
    c("Excellent", "Very Good", "Good", "Fair", "Poor",
      "This child does not have any teeth [T1 only]"))
})
