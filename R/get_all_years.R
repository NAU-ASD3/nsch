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
  dta.files <- Sys.glob(file.path(data.path, "*topical*.dta"))
  do.files <- Sys.glob(file.path(data.path, "*topical*.do"))
  if (length(dta.files) == 0L) {
    stop("No .dta files found in data.path: ", data.path)
  }
  if (length(do.files) == 0L) {
    stop("No .do files found in data.path: ", data.path)
  }
  ## Extract year integers from filenames.
  dta.years <- as.integer(regmatches(
    basename(dta.files), regexpr("[0-9]{4}", basename(dta.files))))
  do.years <- as.integer(regmatches(
    basename(do.files), regexpr("[0-9]{4}", basename(do.files))))
  file.dt <- data.table::data.table(year = dta.years, dta.path = dta.files)
  do.dt <- data.table::data.table(year = do.years, do.path = do.files)
  result <- merge(file.dt, do.dt, by = "year")
  if (!is.null(years)) {
    result <- result[year %in% as.integer(years)]
  }
  if (nrow(result) == 0L) {
    stop("No matching data files found for the requested years")
  }
  result
}