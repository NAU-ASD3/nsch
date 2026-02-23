get_years_csv <- function(NSCH_data.path="NSCH_data", verbose=FALSE){
  original_Stata <- file.path(NSCH_data.path, "00_original_Stata")
  dir.create(original_Stata, showWarnings = FALSE, recursive = TRUE)
  csv_dir <- file.path(NSCH_data.path, "01_cleanTypes_csv")
  index_dt <- nsch::get_nsch_index(file.path(original_Stata, "datasets.html"))
  size_dt_list <- list()
  for(year_i in 1:nrow(index_dt)){
    index_row <- index_dt[year_i]
    nsch::get_year(index_row$url, original_Stata, verbose)
    year_dt <- nsch::Stata2csv_year(
      index_row$year, original_Stata, csv_dir, verbose)
    size_dt_list[[year_i]] <- data.table(
      index_row, year_dt)
  }
  size_dt <- data.table::rbindlist(size_dt_list)
  sizes.csv <- file.path(NSCH_data.path, "01_cleanTypes_sizes.csv")
  data.table::fwrite(size_dt, sizes.csv)
  size_dt
}
