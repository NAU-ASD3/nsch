library(testthat)
library(data.table)

test_that("discovers dta and do files with standard naming", {
  test.dir <- tempfile()
  dir.create(test.dir)
  on.exit(unlink(test.dir, recursive = TRUE))
  file.create(file.path(test.dir, "nsch_2016_topical.dta"))
  file.create(file.path(test.dir, "nsch_2016_topical.do"))
  file.create(file.path(test.dir, "nsch_2017_topical.dta"))
  file.create(file.path(test.dir, "nsch_2017_topical.do"))
  result <- nsch::get_all_years(data.path = test.dir, download = FALSE)
  expect_is(result, "data.table")
  expect_identical(sort(result[["year"]]), c(2016L, 2017L))
  expect_identical(names(result), c("year", "dta.path", "do.path"))
})

test_that("discovers files with non-standard naming (2024e)", {
  test.dir <- tempfile()
  dir.create(test.dir)
  on.exit(unlink(test.dir, recursive = TRUE))
  file.create(file.path(test.dir, "nsch_2024e_topical.dta"))
  file.create(file.path(test.dir, "nsch_2024_topical.do"))
  result <- nsch::get_all_years(data.path = test.dir, download = FALSE)
  expect_identical(result[["year"]], 2024L)
})

test_that("filters to requested years", {
  test.dir <- tempfile()
  dir.create(test.dir)
  on.exit(unlink(test.dir, recursive = TRUE))
  for (yr in 2016:2018) {
    file.create(file.path(test.dir, paste0("nsch_", yr, "_topical.dta")))
    file.create(file.path(test.dir, paste0("nsch_", yr, "_topical.do")))
  }
  result <- nsch::get_all_years(
    data.path = test.dir, years = c(2016L, 2017L), download = FALSE)
  expect_identical(sort(result[["year"]]), c(2016L, 2017L))
})

test_that("error when no dta files found", {
  test.dir <- tempfile()
  dir.create(test.dir)
  on.exit(unlink(test.dir, recursive = TRUE))
  expect_error(
    nsch::get_all_years(data.path = test.dir, download = FALSE),
    "No .dta files found")
})