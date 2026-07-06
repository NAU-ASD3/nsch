## Reshape the nested rename/merge/transform config sections into long-format
## data.tables: one row per (rule, year) for rename/merge, and per
## (rule, year, value) for transform. The config is small (a few dozen rules),
## so these are plain unkeyed data.tables - readability, not lookup speed, is
## the point. Consumers subset by year with dt[year == yr].
##
## Expects the nested config as returned by read_config(), already checked by
## validate_config(). Returns the config with its three transformation sections
## replaced by data.tables.
config_to_dt <- function(config) {
  renames    <- config$transformations$rename_columns
  merges     <- config$transformations$merge_columns
  transforms <- config$transformations$transform

  ## Empty-typed prototypes so every section is a well-formed data.table with
  ## the right columns even when a config section is empty. Consumers can then
  ## always rely on the columns existing (e.g. rename.dt[new_name == x]).
  rename.proto <- data.table::data.table(
    old_name = character(), year = integer(), new_name = character())
  merge.proto <- data.table::data.table(
    out_name = character(), year = integer(),
    column_preferred = character(), column_fallback = character())
  transform.proto <- data.table::data.table(
    variable = character(), year = integer(), value = character(),
    new_value = character(), new_label = character())

  ## rename: old_name | year | new_name
  rename.dt <- data.table::rbindlist(c(list(rename.proto),
    lapply(names(renames), function(old.name) {
      entry <- renames[[old.name]]
      data.table::data.table(
        old_name = old.name,
        year     = as.integer(entry$years),
        new_name = entry$new_name)
    })))

  ## merge: out_name | year | column_preferred | column_fallback
  merge.dt <- data.table::rbindlist(c(list(merge.proto),
    lapply(names(merges), function(out.name) {
      entry <- merges[[out.name]]
      data.table::data.table(
        out_name         = out.name,
        year             = as.integer(entry$years),
        column_preferred = entry$column_preferred,
        column_fallback  = entry$column_fallback)
    })))

  ## transform: variable | year | value | new_value | new_label
  ## Each rule's parallel value/new_value/new_label arrays apply in every listed
  ## year, so cross each year with the value rows.
  transform.dt <- data.table::rbindlist(c(list(transform.proto),
    lapply(names(transforms), function(var.name) {
      entry <- transforms[[var.name]]
      data.table::rbindlist(lapply(as.integer(entry$years), function(yr) {
        data.table::data.table(
          variable  = var.name,
          year      = yr,
          value     = entry$value,
          new_value = entry$new_value,
          new_label = entry$new_label)
      }))
    })))

  config$transformations$rename_columns <- rename.dt
  config$transformations$merge_columns  <- merge.dt
  config$transformations$transform      <- transform.dt
  config
}
