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
  expect_true(is.factor(dt$sc_sex))
  expect_equal(levels(dt$sc_sex), c("Male", "Female"))
  expect_equal(as.character(dt$sc_sex), c("Male", "Female", "Male", "Female"))
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
  expect_true(is.factor(dt$sc_sex))
  expect_equal(sum(is.na(dt$sc_sex)), 4L)
  expect_equal(as.character(dt$sc_sex[1]), "Male")
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
  expect_true(is.factor(dt$birthwt))
  ## Row 1 should use the _label override
  expect_equal(as.character(dt$birthwt[1]), "Custom VLB Label")
  ## Rows 2-3 should use the .do-derived labels
  expect_equal(as.character(dt$birthwt[2]), "Low birth weight")
  expect_equal(as.character(dt$birthwt[3]), "Not low birth weight")
  ## _label column should be removed
  expect_false("birthwt_label" %in% names(dt))
  expect_true("Custom VLB Label" %in% levels(dt$birthwt))
})

test_that("numeric columns without define entries are untouched", {
  dt <- data.table(fpl_i1 = c(100, 200, 997))
  define.dt <- data.table(
    variable = "sc_sex",
    value = "1",
    desc = "Male"
  )
  nsch::apply_do_labels(dt, define.dt)
  expect_true(is.numeric(dt$fpl_i1))
  expect_true(is.na(dt$fpl_i1[3]))
  expect_equal(dt$fpl_i1[1], 100)
  expect_equal(dt$fpl_i1[2], 200)
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
  expect_true(is.factor(dt$sc_sex))
  expect_equal(length(levels(dt$sc_sex)), nrow(sc_sex.vals))
  ## year should remain numeric (no define entries for it)
  expect_true(is.numeric(dt$year) || is.integer(dt$year))
})
