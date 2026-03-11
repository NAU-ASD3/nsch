harmonize_year <- function(dt, config, year, define.dt) {
  transform_values(dt, config$transformations$transform, year)
  rename_vars(dt, config$transformations$rename_columns, year)
  merge_vars(dt, config$transformations$merge_columns, year)
  dt <- subset_vars(dt, config$desired_variables)
  apply_do_labels(dt, define.dt)
  dt
}