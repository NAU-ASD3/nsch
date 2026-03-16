test_that("check_year_coverage detects missing years", {

  dt <- data.table::data.table(
    year = c(2016, 2016, 2017, 2017),
    a = c(1, 2, NA, NA),
    b = c(NA, NA, 3, 4)
  )

  result <- check_year_coverage(dt)

  expect_true("a" %in% result$variable)
  expect_true("b" %in% result$variable)

})
