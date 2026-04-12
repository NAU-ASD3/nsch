library(testthat)
library(data.table)

test_that("error when data path has no files", {
  test.dir <- tempfile()
  dir.create(test.dir)
  on.exit(unlink(test.dir, recursive = TRUE))
  expect_error(
    nsch::get_clean_data(data.path = test.dir, download = FALSE),
    "No .dta files found")
})