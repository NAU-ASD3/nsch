library(testthat)
library(data.table)
test_that("parse_do #rows consistent with grep #lines", {
  year.do <- system.file(package="nsch", "extdata", "nsch_2024_topical.do")
  do_list <- nsch::parse_do(year.do)
  do_lines <- readLines(year.do)
  rows_dt_list <- list()
  for(data_type in c("define", "var")){
    pattern <- paste("label", data_type)
    label_lines <- grep(pattern, do_lines)
    rows_dt_list[[data_type]] <- data.table(
      data_type,
      computed=nrow(do_list[[data_type]]),
      expected=length(label_lines))
  }
  rows_dt <- rbindlist(rows_dt_list)
  rows_dt[, expect_identical(computed, expected)]
})
