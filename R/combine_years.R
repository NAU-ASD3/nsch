combine_years <- function(year.list) {
  if (!is.list(year.list) || length(year.list) == 0) {
    stop("year.list must be a non-empty list of data.tables")
  }
  for (i in seq_along(year.list)) {
    if (!("year" %in% names(year.list[[i]]))) {
      stop("element ", i, " of year.list does not contain a 'year' column")
    }
  }
  all.years <- unlist(lapply(year.list, function(dt)
    unique(dt[["year"]])))
  if (anyDuplicated(all.years)) {
    stop("duplicate year values across tables: ",
         paste(all.years[duplicated(all.years)], collapse = ", "))
  }
  data.table::rbindlist(year.list, use.names = TRUE, fill = TRUE)
}