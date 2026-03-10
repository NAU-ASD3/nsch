transform_values <- function(dt, transforms, year) {
  for (variable.name in names(transforms)) {
    details <- transforms[[variable.name]]
    if (as.character(year) %in% details$years &&
        variable.name %in% names(dt)) {
      label.col <- paste0(variable.name, "_label")
      ## Initialize _label column if it does not yet exist.
      if (!(label.col %in% names(dt))) {
        data.table::set(dt, j = label.col, value = NA_character_)
      }
      old.vals <- as.numeric(details$value)
      new.vals <- as.numeric(details$new_value)
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
                        value = details$new_label[idx[matched]])
      }
    }
  }
  invisible(dt)
}