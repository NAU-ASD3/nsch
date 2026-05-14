harmonize_year <- function(dt, config, year, define.dt) {
  ## Capture return values from all pipeline steps. Most modify `dt` by
  ## reference, but `set()` calls that introduce new columns can fall back
  ## to copy-on-allocate if the data.table lacks truelength headroom — in
  ## which case the new column appears only on the returned object.
  ## `subset_vars()` always returns a new data.table.
  dt <- transform_values(dt, config$transformations$transform, year)
  dt <- rename_vars(dt, config$transformations$rename_columns, year)
  dt <- merge_vars(dt, config$transformations$merge_columns, year)
  dt <- subset_vars(dt, config$desired_variables)
  dt <- apply_do_labels(dt, define.dt)
  dt
}