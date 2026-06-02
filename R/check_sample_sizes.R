year <- .N <- NULL

check_sample_sizes <- function(dt) {
  if (!data.table::is.data.table(dt)) {
    stop("dt must be a data.table")
  }
  if (!("year" %in% names(dt))) {
    stop("Input data must contain a 'year' column")
  }
  result <- dt[, list(n.rows = .N), by = year]
  data.table::setorderv(result, "year")
  result
}