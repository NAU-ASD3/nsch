year <- NULL
get_all_years <- function(
    data.path = file.path("NSCH_data", "00_original_Stata"),
    years = NULL,
    download = FALSE
) {
  if (download) {
    index.dt <- nsch::get_nsch_index()
    if (!is.null(years)) {
      index.dt <- index.dt[year %in% as.integer(years)]
    }
    for (i in seq_len(nrow(index.dt))) {
      nsch::get_year(index.dt[["url"]][i], data.path = data.path)
    }
  }
  ## Discover .dta and .do files via glob (handles 2024's nsch_2024e_topical.dta).
  dt.list <- list()
  for (suffix in c("dta", "do")) {
    files <- Sys.glob(file.path(data.path, paste0("*topical*.", suffix)))
    if (length(files) == 0L) {
      stop("No .", suffix, " files found in data.path: ", data.path)
    }
    file.years <- as.integer(regmatches(
      basename(files), regexpr("[0-9]{4}", basename(files))))
    col.name <- paste0(suffix, ".path")
    dt.list[[suffix]] <- data.table::data.table(
      year = file.years, V1 = files)
    data.table::setnames(dt.list[[suffix]], "V1", col.name)
  }
  result <- merge(dt.list[["dta"]], dt.list[["do"]], by = "year")
  if (!is.null(years)) {
    result <- result[year %in% as.integer(years)]
  }
  if (nrow(result) == 0L) {
    stop("No matching data files found for the requested years")
  }
  result
}