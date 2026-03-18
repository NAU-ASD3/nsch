library(data.table)

test_that("numeric column is converted to factor with correct levels", {
  dt <- data.table(sc_sex = c(1, 2, 1, 2))
  define.dt <- data.table(
    variable = rep("sc_sex", 5),
    value = c("1", "2", ".m", ".n", ".d"),
    desc = c("Male", "Female", "No valid response",
                     "Not in universe", "Suppressed for confidentiality")
  )
  nsch::apply_do_labels(dt, define.dt)
  expect_identical(dt$sc_sex,
                   factor(c("Male", "Female", "Male", "Female"),
                          c("Male", "Female")))
})

test_that("sentinel codes 996-999 all map to NA", {
  dt <- data.table(sc_sex = c(1, 996, 997, 998, 999))
  define.dt <- data.table(
    variable = rep("sc_sex", 6),
    value = c("1", "2", ".m", ".n", ".l", ".d"),
    desc = c("Male", "Female", "No valid response",
                     "Not in universe", "Logical skip",
                     "Suppressed for confidentiality")
  )
  nsch::apply_do_labels(dt, define.dt)
  expect_identical(dt$sc_sex,
                   factor(c("Male", NA, NA, NA, NA),
                          c("Male", "Female")))
})

test_that("_label column takes priority over do-derived labels", {
  dt <- data.table(
    birthwt = c(1, 2, 3),
    birthwt_label = c("Custom VLB Label", NA, NA)
  )
  define.dt <- data.table(
    variable = rep("birthwt", 6),
    value = c("1", "2", "3", ".m", ".n", ".d"),
    desc = c("Very low birth weight", "Low birth weight",
                     "Not low birth weight", "No valid response",
                     "Not in universe", "Suppressed for confidentiality")
  )
  nsch::apply_do_labels(dt, define.dt)
  expect_identical(
    as.character(dt$birthwt),
    c("Custom VLB Label", "Low birth weight", "Not low birth weight"))
  ## _label column should be removed
  expect_false("birthwt_label" %in% names(dt))
  expect_in("Custom VLB Label", levels(dt$birthwt))
})

test_that("numeric columns without define entries are untouched", {
  dt <- data.table(fpl_i1 = c(100, 200, 997))
  define.dt <- data.table(
    variable = "sc_sex",
    value = "1",
    desc = "Male"
  )
  nsch::apply_do_labels(dt, define.dt)
  expect_identical(dt$fpl_i1, c(100, 200, NA))
})

test_that("works with 2024 .do data", {
  skip_if_not_installed("nsch")
  do.path <- system.file(
    package = "nsch", "extdata", "nsch_2024_topical.do", mustWork = TRUE
  )
  do.list <- nsch::parse_do(do.path)
  define.dt <- do.list$define
  ## Create synthetic numeric data with a few 2024 variable names
  sc_sex.vals <- define.dt[variable == "sc_sex" & !grepl("^\\.", value)]
  dt <- data.table(
    sc_sex = as.numeric(sc_sex.vals$value),
    year = rep(2024L, nrow(sc_sex.vals))
  )
  nsch::apply_do_labels(dt, define.dt)
  expect_is(dt$sc_sex, "factor")
  expect_identical(length(levels(dt$sc_sex)), nrow(sc_sex.vals))
  ## year should remain numeric (no define entries for it)
  expect_is(dt$year, "integer")
})
