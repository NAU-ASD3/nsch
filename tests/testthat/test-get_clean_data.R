library(testthat)
library(data.table)

test_that("error when data path has no files", {
  tmp <- tempdir()
  test.dir <- file.path(tmp, "nsch_test_clean_empty")
  dir.create(test.dir, showWarnings = FALSE)
  on.exit(unlink(test.dir, recursive = TRUE))
  expect_error(
    nsch::get_clean_data(data.path = test.dir, download = FALSE),
    "No .dta files found")
})