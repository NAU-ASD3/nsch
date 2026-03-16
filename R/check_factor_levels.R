check_factor_levels <- function(dt) {
  # Ensure dt is a data.table
  if (!data.table::is.data.table(dt)) {
  stop("dt must be a data.table")
}

  # Check required year column
  if (!("year" %in% names(dt))) {
    stop("Input data must contain a 'year' column")
  }

  # Identify factor columns
  factor_cols <- names(dt)[vapply(
    dt,
    function(x) is.factor(x) || is.ordered(x),
    logical(1L)
  )]

  # Empty output template
  empty_out <- data.table::data.table(
    variable = character(),
    level = character(),
    n.years.present = integer(),
    years.present = character(),
    total.count = integer()
  )

  # Return empty result if no factor columns exist
  if (length(factor_cols) == 0L) {
    empty_out
  }

  out_list <- vector("list", length(factor_cols))

  for (i in seq_along(factor_cols)) {
    col <- factor_cols[i]

    # Count occurrences by level and year
    tmp <- dt[
      !is.na(year) & !is.na(get(col)),
      .(count = .N),
      by = .(level = as.character(get(col)), year)
    ]

    # Skip if no non-missing data for this factor column
    if (nrow(tmp) == 0L) {
      next
    }

    # Summarize each level across years
    res <- tmp[
      ,
      .(
        n.years.present = as.integer(data.table::uniqueN(year)),
        years.present = paste(sort(unique(year)), collapse = ","),
        total.count = as.integer(sum(count))
      ),
      by = level
    ]

    # Add variable name and reorder columns
    res[, variable := col]
    data.table::setcolorder(
      res,
      c("variable", "level", "n.years.present", "years.present", "total.count")
    )

    out_list[[i]] <- res
  }

  # Remove NULL entries if some factor columns had only missing values
  out_list <- Filter(Negate(is.null), out_list)

  # Return empty output if nothing remains
  if (length(out_list) == 0L) {
    empty_out
  }

  # Combine all factor summaries
  result <- data.table::rbindlist(out_list, use.names = TRUE, fill = TRUE)

  result
}
