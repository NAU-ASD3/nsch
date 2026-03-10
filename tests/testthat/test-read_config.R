library(testthat)

test_that("parses bundled config into expected structure", {
  config.path <- system.file(
    package = "nsch", "extdata", "variable-config.json",
    mustWork = TRUE)
  config <- nsch::read_config(config.path)
  expect_true(is.list(config))
  expect_identical(sort(names(config)), c("desired_variables", "transformations"))
  expect_identical(
    sort(names(config$transformations)),
    c("merge_columns", "rename_columns", "transform"))
})

test_that("desired_variables is a character vector", {
  config.path <- system.file(
    package = "nsch", "extdata", "variable-config.json",
    mustWork = TRUE)
  config <- nsch::read_config(config.path)
  expect_true(is.character(config$desired_variables))
  expect_true(length(config$desired_variables) > 0)
})

test_that("transform entries have required fields", {
  config.path <- system.file(
    package = "nsch", "extdata", "variable-config.json",
    mustWork = TRUE)
  config <- nsch::read_config(config.path)
  required <- c("years", "value", "new_value", "new_label")
  for(var.name in names(config$transformations$transform)){
    entry <- config$transformations$transform[[var.name]]
    for(field in required){
      expect_true(
        field %in% names(entry),
        info = paste("transform entry", var.name, "missing field", field))
    }
  }
})

test_that("error for non-existent file", {
  does.not.exist <- tempfile(fileext = ".json")
  expect_error(
    nsch::read_config(does.not.exist),
    "config.path should be the path to a JSON config file",
    fixed = TRUE)
})

test_that("error for malformed JSON", {
  bad.json <- tempfile(fileext = ".json")
  writeLines("{ not valid json !!!", bad.json)
  expect_error(
    nsch::read_config(bad.json),
    "config.path should contain valid JSON")
})