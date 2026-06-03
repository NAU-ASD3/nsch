year <- n.non.na <- .N <- NULL

check_year_coverage <- function(dt) {
  if (!data.table::is.data.table(dt)) {
    stop("dt must be a data.table")
  }
  if (!("year" %in% names(dt))) {
    stop("Input data must contain a 'year' column")
  }
  var.names <- setdiff(names(dt), "year")
  all.years <- sort(unique(dt[["year"]]))
  n.years.total <- length(all.years)
  out.list <- vector("list", length(var.names))
  for (i in seq_along(var.names)) {
    col <- var.names[i]
    year.counts <- dt[, list(n.non.na = sum(!is.na(get(col)))), by = year]
    years.with.data <- year.counts[n.non.na > 0L][["year"]]
    years.missing <- setdiff(all.years, years.with.data)
    out.list[[i]] <- data.table::data.table(
      variable = col,
      n.years.data = length(years.with.data),
      n.years.total = n.years.total,
      missing.years = if (length(years.missing) > 0L) {
        paste(sort(years.missing), collapse = ",")
      } else {
        ""
      }
    )
  }
  data.table::rbindlist(out.list)
}