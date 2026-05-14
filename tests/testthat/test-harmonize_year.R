library(testthat)
library(data.table)

test_that("produces same result as calling steps manually", {
  ## Synthetic data: 3 rows, year 2099, two categorical variables.
  dt1 <- data.table(
    year = 2099L,
    sc_sex = c(1, 2, 1),
    fam_count = c(1, 2, 3)
  )
  dt2 <- data.table::copy(dt1)
  ## Minimal config with one transform, one rename, one merge, desired vars.
  config <- list(
    desired_variables = c("sc_sex", "family"),
    transformations = list(
      transform = list(
        fam_count = list(
          years = "2099",
          value = c("3"),
          new_value = c("2"),
          new_label = c("Two or more")
        )
      ),
      rename_columns = list(
        fam_count = list(
          years = "2099",
          new_name = "family"
        )
      ),
      merge_columns = list()
    )
  )
  ## Synthetic define.dt from parse_do()$define.
  define.dt <- data.table(
    variable = c("sc_sex", "sc_sex"),
    value = c("1", "2"),
    desc = c("Male", "Female")
  )
  ## Manual pipeline on dt1.  Capture return values from each step to
  ## ensure new columns added via data.table::set() are preserved even
  ## when truelength is exhausted.
  dt1 <- nsch::transform_values(dt1, config$transformations$transform, 2099L)
  dt1 <- nsch::rename_vars(dt1, config$transformations$rename_columns, 2099L)
  dt1 <- nsch::merge_vars(dt1, config$transformations$merge_columns, 2099L)
  dt1 <- nsch::subset_vars(dt1, config$desired_variables)
  dt1 <- nsch::apply_do_labels(dt1, define.dt)
  ## harmonize_year on dt2.
  result <- nsch::harmonize_year(dt2, config, 2099L, define.dt)
  expect_identical(result, dt1)
})

test_that("works with empty transform rules", {
  dt <- data.table(
    year = 2099L,
    sc_sex = c(1, 2)
  )
  config <- list(
    desired_variables = c("sc_sex"),
    transformations = list(
      transform = list(),
      rename_columns = list(),
      merge_columns = list()
    )
  )
  define.dt <- data.table(
    variable = c("sc_sex", "sc_sex"),
    value = c("1", "2"),
    desc = c("Male", "Female")
  )
  result <- nsch::harmonize_year(dt, config, 2099L, define.dt)
  expect_identical(result[["sc_sex"]], factor(c("Male", "Female"), c("Male", "Female")))
})

test_that("preserves _label override through full pipeline (regression for return-capture bug)", {
  ## This test guards against a bug where transform_values() adds a
  ## `_label` companion column via data.table::set(), but the new
  ## column is silently dropped if harmonize_year() does not capture
  ## the return value.  The bug manifests as the remapped rows
  ## becoming NA in the final factor instead of receiving the
  ## override label from `new_label`.
  dt <- data.table(
    year = 2099L,
    test_var = c(1, 2, 998, 998, 998)
  )
  config <- list(
    desired_variables = "test_var",
    transformations = list(
      transform = list(
        test_var = list(
          years = "2099",
          value = c("998"),
          new_value = c("5"),
          new_label = c("Override label")
        )
      ),
      rename_columns = list(),
      merge_columns = list()
    )
  )
  define.dt <- data.table(
    variable = c("test_var", "test_var"),
    value = c("1", "2"),
    desc = c("One", "Two")
  )
  result <- nsch::harmonize_year(dt, config, 2099L, define.dt)
  ## The override label must appear as a real factor level, not NA.
  expect_in("Override label", levels(result[["test_var"]]))
  ## Three rows of value 998 should have been remapped to "Override label".
  expect_identical(
    as.character(result[["test_var"]]),
    c("One", "Two", "Override label", "Override label", "Override label")
  )
})