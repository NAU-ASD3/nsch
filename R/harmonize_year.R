## Internal: build the alias map passed to apply_do_labels.
## Maps each post-rename / post-merge column name in `dt` to the
## original variable name to look up in `define.dt`.
##
## - For each rename rule applying to `year`, alias[new_name] = old_name.
## - For each merge rule applying to `year`, alias[merge_output] = column_preferred.
##   (Merged columns inherit labels from the preferred source; the fallback
##   source's labels propagate via the _label companion column created by
##   merge_vars when both sources have transform-derived labels.)
##
## `rename.dt` and `merge.dt` are the long-format config tables from
## config_to_dt(): one row per (rule, year).
build_alias_map <- function(rename.dt, merge.dt, year) {
  yr <- year  # local copy avoids the year-column vs year-argument name clash
  alias <- list()
  r <- rename.dt[year == yr]
  for (i in seq_len(nrow(r))) {
    alias[[r$new_name[i]]] <- r$old_name[i]
  }
  m <- merge.dt[year == yr]
  for (i in seq_len(nrow(m))) {
    alias[[m$out_name[i]]] <- m$column_preferred[i]
  }
  alias
}

harmonize_year <- function(dt, config, year, define.dt) {
  transform_values(dt, config$transformations$transform, year)
  rename_vars(dt, config$transformations$rename_columns, year)
  merge_vars(dt, config$transformations$merge_columns, year)
  dt <- subset_vars(dt, config$desired_variables)
  alias <- build_alias_map(
    config$transformations$rename_columns,
    config$transformations$merge_columns,
    year)
  apply_do_labels(dt, define.dt, alias)
  dt
}
