library(testthat)
library(data.table)

## Helper: create a synthetic 2016 .dta with hhid, a1_grade_if, a1_grade_i.
make_2016_dta <- function(n = 10) {
  tf <- tempfile(fileext = ".dta")
  df <- data.frame(
    year = 2016L,
    hhid = seq_len(n),
    a1_grade_if = rep(TRUE, n),
    a1_grade_i = sample(1:3, n, replace = TRUE)
  )
  haven::write_dta(df, tf)
  tf
}

## Helper: build a minimal combined.dt with 2016 (NA a1_grade) and
## non-2016 rows (populated a1_grade).
make_combined <- function(n.2016 = 10, n.other = 40) {
  a1_levels <- c(
    "8th grade or less",
    "9th-12th grade; No diploma",
    "High School Graduate or GED Completed",
    "Completed a vocational, trade, or business school program",
    "Some College Credit, but No Degree",
    "Associate Degree (AA, AS)",
    "Bachelor's Degree (BA, BS, AB)",
    "Master's Degree (MA, MS, MSW, MBA)",
    "Doctorate (PhD, EdD) or Professional Degree (MD, DDS, DVM, JD)"
  )
  higrade_levels <- c(
    "Less than high school",
    "High school (including vocational, trade, or business school)",
    "More than high school"
  )
  higrade_tvis_levels <- c(
    "Less than high school",
    "High school (including vocational, trade, or business school)",
    "Some college or Associate Degree",
    "College degree or higher"
  )
  ## Non-2016 rows with populated factors.
  other.grades <- sample(a1_levels, n.other, replace = TRUE)
  higrade.map <- c(
    "8th grade or less" = "Less than high school",
    "9th-12th grade; No diploma" = "Less than high school",
    "High School Graduate or GED Completed" = "High school (including vocational, trade, or business school)",
    "Completed a vocational, trade, or business school program" = "High school (including vocational, trade, or business school)",
    "Some College Credit, but No Degree" = "More than high school",
    "Associate Degree (AA, AS)" = "More than high school",
    "Bachelor's Degree (BA, BS, AB)" = "More than high school",
    "Master's Degree (MA, MS, MSW, MBA)" = "More than high school",
    "Doctorate (PhD, EdD) or Professional Degree (MD, DDS, DVM, JD)" = "More than high school"
  )
  tvis.map <- c(
    "8th grade or less" = "Less than high school",
    "9th-12th grade; No diploma" = "Less than high school",
    "High School Graduate or GED Completed" = "High school (including vocational, trade, or business school)",
    "Completed a vocational, trade, or business school program" = "High school (including vocational, trade, or business school)",
    "Some College Credit, but No Degree" = "Some college or Associate Degree",
    "Associate Degree (AA, AS)" = "Some college or Associate Degree",
    "Bachelor's Degree (BA, BS, AB)" = "College degree or higher",
    "Master's Degree (MA, MS, MSW, MBA)" = "College degree or higher",
    "Doctorate (PhD, EdD) or Professional Degree (MD, DDS, DVM, JD)" = "College degree or higher"
  )
  other.higrade <- higrade.map[other.grades]
  other.tvis <- tvis.map[other.grades]
  dt.other <- data.table(
    year = rep(2017L, n.other),
    hhid = seq_len(n.other) + 1000L,
    a1_grade = factor(other.grades, levels = a1_levels),
    higrade = factor(other.higrade, levels = higrade_levels),
    higrade_tvis = factor(other.tvis, levels = higrade_tvis_levels)
  )
  ## 2016 rows with NA in a1_grade, higrade, higrade_tvis.
  dt.2016 <- data.table(
    year = rep(2016L, n.2016),
    hhid = seq_len(n.2016),
    a1_grade = factor(NA_character_, levels = a1_levels),
    higrade = factor(NA_character_, levels = higrade_levels),
    higrade_tvis = factor(NA_character_, levels = higrade_tvis_levels)
  )
  rbind(dt.2016, dt.other)
}

test_that("reproducible with same seed", {
  dta.path <- make_2016_dta(10)
  dt1 <- make_combined(10, 40)
  dt2 <- data.table::copy(dt1)
  nsch::impute_a1_grade_2016(dt1, dta.path, seed = 42L)
  nsch::impute_a1_grade_2016(dt2, dta.path, seed = 42L)
  expect_identical(dt1, dt2)
})

test_that("different seed produces different assignment", {
  dta.path <- make_2016_dta(100)
  dt1 <- make_combined(100, 400)
  dt2 <- data.table::copy(dt1)
  nsch::impute_a1_grade_2016(dt1, dta.path, seed = 1L)
  nsch::impute_a1_grade_2016(dt2, dta.path, seed = 2L)
  expect_false(identical(dt1, dt2))
})

test_that("only 2016 imputed rows are modified", {
  dta.path <- make_2016_dta(10)
  dt <- make_combined(10, 40)
  other.before <- data.table::copy(dt[year != 2016L])
  nsch::impute_a1_grade_2016(dt, dta.path, seed = 1L)
  other.after <- dt[year != 2016L]
  expect_identical(other.before, other.after)
})

test_that("no NA in a1_grade after imputation", {
  dta.path <- make_2016_dta(10)
  dt <- make_combined(10, 40)
  nsch::impute_a1_grade_2016(dt, dta.path, seed = 1L)
  expect_false(any(is.na(dt[year == 2016L, a1_grade])))
  expect_false(any(is.na(dt[year == 2016L, higrade])))
  expect_false(any(is.na(dt[year == 2016L, higrade_tvis])))
})

test_that("non-imputed 2016 rows are not modified", {
  tf <- tempfile(fileext = ".dta")
  imputed.hhids <- 1:3
  non.imputed.hhids <- 4:6
  df <- data.frame(
    year = 2016L,
    hhid = c(imputed.hhids, non.imputed.hhids),
    a1_grade_if = c(rep(TRUE, length(imputed.hhids)),
                    rep(FALSE, length(non.imputed.hhids))),
    a1_grade_i = c(1L, 2L, 3L, 1L, 2L, 3L)
  )
  haven::write_dta(df, tf)
  dt <- make_combined(6, 40)
  ## Give the non-imputed rows real values.
  a1.lvls <- levels(dt[["a1_grade"]])
  hi.lvls <- levels(dt[["higrade"]])
  tv.lvls <- levels(dt[["higrade_tvis"]])
  non.imp <- which(dt[, year == 2016L & hhid %in% non.imputed.hhids])
  data.table::set(dt, i = non.imp, j = "a1_grade",
                  value = factor("8th grade or less", levels = a1.lvls))
  data.table::set(dt, i = non.imp, j = "higrade",
                  value = factor("Less than high school", levels = hi.lvls))
  data.table::set(dt, i = non.imp, j = "higrade_tvis",
                  value = factor("Less than high school", levels = tv.lvls))
  before <- data.table::copy(dt[year == 2016L & hhid %in% non.imputed.hhids])
  nsch::impute_a1_grade_2016(dt, tf, seed = 1L)
  after <- dt[year == 2016L & hhid %in% non.imputed.hhids]
  expect_identical(before, after)
})