year <- n.na <- n.total <- .N <- NULL

check_na_rates <- function(dt) {
  if (!data.table::is.data.table(dt)) {
    stop("dt must be a data.table")
  }
  if (!("year" %in% names(dt))) {
    stop("Input data must contain a 'year' column")
  }
  var.names <- setdiff(names(dt), "year")
  out.list <- vector("list", length(var.names))
  for (i in seq_along(var.names)) {
    col <- var.names[i]
    out.list[[i]] <- dt[
      , list(n.na = sum(is.na(get(col))), n.total = .N), by = year][
        , list(variable = col, year, na.rate = n.na / n.total, n.total)]
  }
  data.table::rbindlist(out.list)
}