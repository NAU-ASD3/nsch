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
  ## Synthetic define.dt with entries for both sc_sex (unrenamed) and
  ## fam_count (the pre-rename name of family).
  define.dt <- data.table(
    variable = c("sc_sex", "sc_sex",
                 "fam_count", "fam_count", "fam_count"),
    value = c("1", "2", "1", "2", "3"),
    desc = c("Male", "Female", "One", "Two", "Three")
  )
  ## Manual pipeline on dt1, using the same alias map harmonize_year builds.
  nsch::transform_values(dt1, config$transformations$transform, 2099L)
  nsch::rename_vars(dt1, config$transformations$rename_columns, 2099L)
  nsch::merge_vars(dt1, config$transformations$merge_columns, 2099L)
  dt1 <- nsch::subset_vars(dt1, config$desired_variables)
  alias <- list(family = "fam_count")
  nsch::apply_do_labels(dt1, define.dt, alias)
  ## harmonize_year on dt2 should produce identical output.
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

test_that("renamed column gets labeled from pre-rename define entries", {
  ## Regression test for the rename + apply_do_labels interaction bug
  ## (see issue #44): apply_do_labels looks up labels by column name,
  ## but renamed columns have names that aren't in define.dt.  The
  ## alias map fixes this by mapping post-rename names to their
  ## pre-rename equivalents.
  dt <- data.table(
    year = 2099L,
    fam_count = c(1, 2, 3, 1)
  )
  config <- list(
    desired_variables = "family",
    transformations = list(
      transform = list(),
      rename_columns = list(
        fam_count = list(
          years = "2099",
          new_name = "family"
        )
      ),
      merge_columns = list()
    )
  )
  ## define.dt has entries for fam_count (the original .do variable name),
  ## NOT for family (the post-rename name).
  define.dt <- data.table(
    variable = c("fam_count", "fam_count", "fam_count"),
    value = c("1", "2", "3"),
    desc = c("One", "Two", "Three")
  )
  result <- nsch::harmonize_year(dt, config, 2099L, define.dt)
  ## The harmonized column must be a labeled factor, not raw integers.
  expect_is(result[["family"]], "factor")
  expect_identical(
    as.character(result[["family"]]),
    c("One", "Two", "Three", "One")
  )
})

test_that("merge output column gets labeled from preferred source define entries", {
  ## Regression test (issue #44): merge outputs (e.g., sleep <-
  ## hoursleep | hoursleep05) have a name that doesn't exist in
  ## define.dt.  Labels must be looked up under the column_preferred
  ## name via the alias map.
  dt <- data.table(
    year = 2099L,
    pref_col = c(1, NA, 2, NA),
    fall_col = c(NA, 2, NA, 1)
  )
  config <- list(
    desired_variables = "merged_col",
    transformations = list(
      transform = list(),
      rename_columns = list(),
      merge_columns = list(
        merged_col = list(
          years = "2099",
          column_preferred = "pref_col",
          column_fallback = "fall_col"
        )
      )
    )
  )
  ## define.dt has entries for pref_col only — merged_col is not a
  ## real .do variable name.
  define.dt <- data.table(
    variable = c("pref_col", "pref_col"),
    value = c("1", "2"),
    desc = c("One", "Two")
  )
  result <- nsch::harmonize_year(dt, config, 2099L, define.dt)
  expect_is(result[["merged_col"]], "factor")
  expect_identical(
    as.character(result[["merged_col"]]),
    c("One", "Two", "Two", "One")
  )
})

test_that("regression: handles truelength=0 input via read_nsch_dta path", {
  ## Guards against re-introduction of the bug where harmonize_year
  ## did not capture return values from transform_values etc., which
  ## fails when transform_values needs to add a _label companion
  ## column on a truelength=0 input.  This test uses the real
  ## haven::write_dta + nsch::read_nsch_dta path to produce that state,
  ## matching how the bug actually manifested with NSCH data.
  tf <- tempfile(fileext = ".dta")
  haven::write_dta(
    data.frame(year = 2099L, test_var = c(1, 2, 998)),
    tf
  )
  dt <- nsch::read_nsch_dta(tf)
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
  expect_identical(
    as.character(result[["test_var"]]),
    c("One", "Two", "Override label")
  )
})