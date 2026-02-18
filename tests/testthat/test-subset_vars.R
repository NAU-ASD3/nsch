library(testthat)

test_that("only desired columns plus labels are retained", {
  dt <- data.table::data.table(
    a = 1:3,
    a_label = c("x", "y", "z"),
    b = 4:6,
    c = 7:9,
    c_label = c("p", "q", "r"))
  result <- nsch::subset_vars(dt, c("a", "c"))
  expect_identical(sort(names(result)), c("a", "a_label", "c", "c_label"))
  expect_identical(nrow(result), 3L)
})

test_that("warning for missing desired variable", {
  dt <- data.table::data.table(a = 1:3)
  expect_warning(
    nsch::subset_vars(dt, c("a", "not_here")),
    "not_here")
})