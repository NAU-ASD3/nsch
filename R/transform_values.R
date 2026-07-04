## `transform.dt` is the long-format transform table from config_to_dt():
## columns variable | year | value | new_value | new_label,
## one row per (rule, year, value).
transform_values <- function(dt, transform.dt, year) {
  variable <- NULL  # for R CMD check
  yr <- year  # avoid year-column vs year-argument clash in the subset
  year.rules <- transform.dt[year == yr]
  for (variable.name in unique(year.rules$variable)) {
    if (variable.name %in% names(dt)) {
      rules <- year.rules[variable == variable.name]
      label.col <- paste0(variable.name, "_label")
      ## Initialize _label column if it does not yet exist.
      if (!(label.col %in% names(dt))) {
        data.table::set(dt, j = label.col, value = NA_character_)
      }
      old.vals <- as.numeric(rules$value)
      new.vals <- as.numeric(rules$new_value)
      idx <- match(dt[[variable.name]], old.vals)
      matched <- which(!is.na(idx))
      if (length(matched) > 0) {
        data.table::set(dt,
                        i = matched,
                        j = variable.name,
                        value = new.vals[idx[matched]])
        data.table::set(dt,
                        i = matched,
                        j = label.col,
                        value = rules$new_label[idx[matched]])
      }
    }
  }
  invisible(dt)
}
