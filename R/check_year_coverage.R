check_year_coverage <- function(dt) {
  if (!data.table::is.data.table(dt)) {
    stop("dt must be a data.table")
  }

  if (!("year" %in% names(dt))) {
    stop("dt must contain a 'year' column")
  }

  vars <- setdiff(names(dt), "year")
  all_years <- sort(unique(dt$year))
  n_years_total <- as.integer(length(all_years))

  empty_out <- data.table::data.table(
    variable = character(),
    n.years.data = integer(),
    n.years.total = integer(),
    missing.years = character()
  )

  if (length(vars) == 0L) {
    empty_out
  } else {
    result_list <- lapply(vars, function(v) {
      coverage <- dt[
        ,
        .(has_data = any(!is.na(get(v)))),
        by = year
      ]

      years_with_data <- sort(coverage[has_data == TRUE, year])
      missing_years <- setdiff(all_years, years_with_data)

      data.table::data.table(
        variable = v,
        n.years.data = as.integer(length(years_with_data)),
        n.years.total = n_years_total,
        missing.years = if (length(missing_years) == 0L) {
          ""
        } else {
          paste(missing_years, collapse = ",")
        }
      )
    })

    data.table::rbindlist(result_list, use.names = TRUE, fill = TRUE)
  }
}
