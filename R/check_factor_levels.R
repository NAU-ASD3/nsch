utils::globalVariables(c(".N", ":=", "count", "level", "variable", "year"))

check_factor_levels <- function(dt) {
  if (!data.table::is.data.table(dt)) {
    stop("dt must be a data.table")
  }

  if (!("year" %in% names(dt))) {
    stop("Input data must contain a 'year' column")
  }

  factor_cols <- names(dt)[vapply(
    dt,
    function(x) is.factor(x) || is.ordered(x),
    logical(1L)
  )]

  empty_out <- data.table::data.table(
    variable = character(),
    level = character(),
    n.years.present = integer(),
    years.present = character(),
    total.count = integer()
  )

  if (length(factor_cols) == 0L) {
    return(empty_out)
  }

  out_list <- vector("list", length(factor_cols))

  for (i in seq_along(factor_cols)) {
    col <- factor_cols[i]

    tmp <- dt[
      !is.na(year) & !is.na(get(col)),
      .(count = .N),
      by = .(level = as.character(get(col)), year)
    ]

    if (nrow(tmp) == 0L) {
      next
    }

    res <- tmp[
      ,
      .(
        n.years.present = as.integer(data.table::uniqueN(year)),
        years.present = paste(sort(unique(year)), collapse = ","),
        total.count = as.integer(sum(count))
      ),
      by = level
    ]

    res[, variable := col]
    data.table::setcolorder(
      res,
      c("variable", "level", "n.years.present", "years.present", "total.count")
    )

    out_list[[i]] <- res
  }

  out_list <- Filter(Negate(is.null), out_list)

  if (length(out_list) == 0L) {
    return(empty_out)
  }

  data.table::rbindlist(out_list, use.names = TRUE, fill = TRUE)
}
