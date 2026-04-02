year <- NULL

check_label_consistency <- function(dt) {
  if (!data.table::is.data.table(dt)) {
    stop("dt must be a data.table")
  }
  if (!("year" %in% names(dt))) {
    stop("Input data must contain a 'year' column")
  }
  factor.cols <- names(dt)[vapply(dt, function(x)
    is.factor(x) || is.ordered(x), logical(1L))]
  empty.out <- data.table::data.table(
    variable = character(),
    is.consistent = logical(),
    n.level.sets = integer(),
    levels.by.year = character()
  )
  if (length(factor.cols) == 0L) {
    return(empty.out)
  }
  all.years <- sort(unique(dt[["year"]]))
  out.list <- vector("list", length(factor.cols))
  for (i in seq_along(factor.cols)) {
    col <- factor.cols[i]
    ## For each year, get the sorted unique non-NA levels actually observed.
    level.sets <- list()
    year.labels <- character()
    for (yr in all.years) {
      yr.vals <- dt[year == yr][[col]]
      observed <- sort(unique(as.character(yr.vals[!is.na(yr.vals)])))
      key <- paste(observed, collapse = "|")
      level.sets[[as.character(yr)]] <- key
      year.labels <- c(year.labels, paste0(yr, "={", key, "}"))
    }
    unique.sets <- unique(unlist(level.sets))
    out.list[[i]] <- data.table::data.table(
      variable = col,
      is.consistent = length(unique.sets) <= 1L,
      n.level.sets = as.integer(length(unique.sets)),
      levels.by.year = paste(year.labels, collapse = "; ")
    )
  }
  data.table::rbindlist(out.list)
}