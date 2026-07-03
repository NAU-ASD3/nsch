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
  expect_identical(dt, data.table(birthwt = factor(
    c("Custom VLB Label", "Low birth weight", "Not low birth weight"),
    c("Very low birth weight", "Low birth weight",
      "Not low birth weight", "Custom VLB Label"))))
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
  expect_identical(dt$sc_sex, factor(sc_sex.vals$desc, sc_sex.vals$desc))
  ## year should remain numeric (no define entries for it)
  expect_identical(dt$year, rep(2024L, nrow(sc_sex.vals)))
})

test_that("alias year-list overshoot falls back to native name (#52)", {
  ## Scenario from #47/#52: eyedoctor is natively named in this year (it has its
  ## own define entries), but the alias still maps eyedoctor -> k4q31_r (the
  ## pre-rename name), which is absent from this year's define. The guard should
  ## fall back to eyedoctor's own entries and label it, rather than letting it
  ## drop through to unlabeled.
  dt <- data.table(eyedoctor = c(1, 2, 1))
  define.dt <- data.table(
    variable = rep("eyedoctor", 4),
    value = c("1", "2", ".m", ".n"),
    desc = c("Yes", "No", "No valid response", "Not in universe")
  )
  ## Alias points at a name NOT present in define.dt (rename overshoot).
  alias <- list(eyedoctor = "k4q31_r")
  nsch::apply_do_labels(dt, define.dt, alias)
  expect_identical(dt$eyedoctor,
                   factor(c("Yes", "No", "Yes"), c("Yes", "No")))
})

test_that("alias target absent AND column absent still falls through (#52)", {
  ## A genuinely misconfigured alias whose column also has no define entries
  ## must NOT be rescued by the guard - it should behave exactly as before
  ## (numeric sentinels to NA, no factor conversion).
  dt <- data.table(mystery = c(1, 2, 997))
  define.dt <- data.table(
    variable = "sc_sex",
    value = "1",
    desc = "Male"
  )
  alias <- list(mystery = "also_absent")
  nsch::apply_do_labels(dt, define.dt, alias)
  ## Unlabeled: stays numeric, sentinel 997 -> NA.
  expect_identical(dt$mystery, c(1, 2, NA))
})
