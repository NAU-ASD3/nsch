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
  ## Manual pipeline on dt1.
  nsch::transform_values(dt1, config$transformations$transform, 2099L)
  nsch::rename_vars(dt1, config$transformations$rename_columns, 2099L)
  nsch::merge_vars(dt1, config$transformations$merge_columns, 2099L)
  dt1 <- nsch::subset_vars(dt1, config$desired_variables)
  nsch::apply_do_labels(dt1, define.dt)
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