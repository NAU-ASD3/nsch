subset_vars <- function(dt, desired.variables){
  ## Warn for each desired variable not found in dt.
  present <- desired.variables[desired.variables %in% names(dt)]
  missing <- desired.variables[!(desired.variables %in% names(dt))]
  for(m in missing){
    warning(
      "desired variable '", m,
      "' not found in dt")
  }
  ## Collect the data columns plus any _label companions.
  label.cols <- paste0(present, "_label")
  label.cols <- label.cols[label.cols %in% names(dt)]
  keep <- c(present, label.cols)
  dt[, keep, with = FALSE]
}