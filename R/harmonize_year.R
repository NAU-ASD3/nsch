## Internal: build the alias map passed to apply_do_labels.
## Maps each post-rename / post-merge column name in `dt` to the
## original variable name to look up in `define.dt`.
##
## - For each rename rule applying to `year`, alias[new_name] = old_name.
## - For each merge rule applying to `year`, alias[merge_output] = column_preferred.
##   (Merged columns inherit labels from the preferred source; the fallback
##   source's labels propagate via the _label companion column created by
##   merge_vars when both sources have transform-derived labels.)
build_alias_map <- function(renames, merges, year) {
  alias <- list()
  yr.char <- as.character(year)
  for (old.name in names(renames)) {
    entry <- renames[[old.name]]
    if (yr.char %in% entry$years) {
      alias[[entry$new_name]] <- old.name
    }
  }
  for (out.name in names(merges)) {
    entry <- merges[[out.name]]
    if (yr.char %in% entry$years) {
      alias[[out.name]] <- entry$column_preferred
    }
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