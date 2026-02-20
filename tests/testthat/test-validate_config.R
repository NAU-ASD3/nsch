library(testthat)

## Helper: minimal valid config for testing.
make_valid_config <- function(){
  list(
    desired_variables = c("year", "sc_sex"),
    transformations = list(
      transform = list(
        sc_sex = list(
          years = c("2016"),
          value = c("1"),
          new_value = c("1"),
          new_label = c("Male")
        )
      ),
      rename_columns = list(
        old_col = list(
          years = c("2016"),
          new_name = "new_col"
        )
      ),
      merge_columns = list(
        merged = list(
          years = c("2016"),
          column_1 = "col_a",
          column_2 = "col_b"
        )
      )
    )
  )
}

test_that("valid config passes silently", {
  config <- make_valid_config()
  result <- nsch::validate_config(config)
  expect_true(result)
})

test_that("empty desired_variables raises error", {
  config <- make_valid_config()
  config$desired_variables <- character(0)
  expect_error(
    nsch::validate_config(config),
    "desired_variables")
})

test_that("non-character desired_variables raises error", {
  config <- make_valid_config()
  config$desired_variables <- 1:5
  expect_error(
    nsch::validate_config(config),
    "desired_variables")
})

test_that("mismatched transform vector lengths raise error", {
  config <- make_valid_config()
  config$transformations$transform$bad_var <- list(
    years = c("2016"),
    value = c("1", "2"),
    new_value = c("1"),
    new_label = c("A", "B")
  )
  expect_error(
    nsch::validate_config(config),
    "length")
})

test_that("missing rename_columns new_name raises error", {
  config <- make_valid_config()
  config$transformations$rename_columns$bad_rename <- list(
    years = c("2016")
    ## new_name is missing
  )
  expect_error(
    nsch::validate_config(config),
    "new_name")
})

test_that("missing merge_columns fields raise error", {
  config <- make_valid_config()
  config$transformations$merge_columns$bad_merge <- list(
    years = c("2016"),
    column_1 = "a"
    ## column_2 is missing
  )
  expect_error(
    nsch::validate_config(config),
    "column_2")
})

test_that("cross-reference with do.list warns for missing variable", {
  config <- make_valid_config()
  config$desired_variables <- c("year", "nonexistent_var")
  ## Fake do.list: one year with a $var data.table containing only "year".
  fake.do <- list(
    "2016" = list(
      var = data.table::data.table(
        variable = "year",
        desc = "Survey year")
    )
  )
  expect_warning(
    nsch::validate_config(config, do.list = fake.do),
    "nonexistent_var")
})

test_that("bundled config passes validation", {
  config.path <- system.file(
    package = "nsch", "extdata", "variable-config.json",
    mustWork = TRUE)
  config <- nsch::read_config(config.path)
  result <- nsch::validate_config(config)
  expect_true(result)
})