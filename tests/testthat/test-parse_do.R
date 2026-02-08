library(testthat)
library(data.table)
test_that("parse_do #rows consistent with grep #lines", {
  year.do <- system.file(package="nsch", "extdata", "nsch_2024_topical.do")
  do_list <- nsch::parse_do(year.do)
  do_lines <- readLines(year.do)
  rows_dt <- data.table(data_type=c("define", "var"))[, {
    pattern <- paste("label", data_type)
    label_lines <- grep(pattern, do_lines)
    data.table(
      computed=nrow(do_list[[data_type]]),
      expected=length(label_lines))
  }, by=data_type]
  rows_dt[, expect_identical(computed, expected)]
})
