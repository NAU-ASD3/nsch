library(data.table)

## A small synthetic nested config exercising all three sections, including a
## multi-value / multi-year transform (the trickiest shape).
make_nested_config <- function() {
  list(
    desired_variables = c("a", "b"),
    transformations = list(
      rename_columns = list(
        old1 = list(years = c("2016", "2017"), new_name = "new1")),
      merge_columns = list(
        out1 = list(years = c("2016", "2017", "2018"),
                    column_preferred = "pref", column_fallback = "fb")),
      transform = list(
        v1 = list(years = c("2016", "2017"),
                  value = c("1", "2"), new_value = c("1", "2"),
                  new_label = c("Lab1", "Lab2")))))
}

test_that("rename section expands to one row per (rule, year)", {
  cfg <- nsch:::config_to_dt(make_nested_config())
  r <- cfg$transformations$rename_columns
  expect_is(r, "data.table")
  expect_identical(nrow(r), 2L)
  expect_identical(sort(names(r)), c("new_name", "old_name", "year"))
  expect_identical(r[order(year)]$year, c(2016L, 2017L))
  expect_identical(r$old_name, c("old1", "old1"))
  expect_identical(r$new_name, c("new1", "new1"))
})

test_that("merge section expands to one row per (rule, year)", {
  cfg <- nsch:::config_to_dt(make_nested_config())
  m <- cfg$transformations$merge_columns
  expect_identical(nrow(m), 3L)
  expect_identical(sort(names(m)),
                   c("column_fallback", "column_preferred", "out_name", "year"))
  expect_identical(m$column_preferred, c("pref", "pref", "pref"))
  expect_identical(m$column_fallback, c("fb", "fb", "fb"))
})

test_that("transform section expands to one row per (rule, year, value)", {
  cfg <- nsch:::config_to_dt(make_nested_config())
  t <- cfg$transformations$transform
  ## 2 values x 2 years = 4 rows
  expect_identical(nrow(t), 4L)
  expect_identical(sort(names(t)),
                   c("new_label", "new_value", "value", "variable", "year"))
  ## value/new_label stay aligned within each year
  y2016 <- t[year == 2016L][order(value)]
  expect_identical(y2016$value, c("1", "2"))
  expect_identical(y2016$new_label, c("Lab1", "Lab2"))
  ## same value rows repeated in the other year
  y2017 <- t[year == 2017L][order(value)]
  expect_identical(y2017$new_label, c("Lab1", "Lab2"))
})

test_that("year column is integer in all three tables", {
  cfg <- nsch:::config_to_dt(make_nested_config())
  expect_type(cfg$transformations$rename_columns$year, "integer")
  expect_type(cfg$transformations$merge_columns$year, "integer")
  expect_type(cfg$transformations$transform$year, "integer")
})

test_that("desired_variables passes through untouched", {
  cfg <- nsch:::config_to_dt(make_nested_config())
  expect_identical(cfg$desired_variables, c("a", "b"))
})
