## Internal: try to find a rename rule that produces `var.name` for year `yr`.
## `rename.dt` is the long-format rename table from config_to_dt().
## Returns a one-row data.table on match, or NULL.
find_rename_match <- function(var.name, yr, rename.dt, do.vars) {
  new_name <- year <- old_name <- NULL  # for R CMD check
  yr.val <- yr  # avoid year-column vs year-argument clash
  hits <- rename.dt[new_name == var.name & year == yr.val & old_name %in% do.vars]
  if (nrow(hits) > 0) {
    return(data.table::data.table(
      variable = var.name,
      year = yr,
      status = "renamed",
      source = hits$old_name[1]
    ))
  }
  NULL
}

## Internal: try to find a merge rule that produces `var.name` for year `yr`.
## `merge.dt` is the long-format merge table from config_to_dt().
## Returns a one-row data.table on match, or NULL.
find_merge_match <- function(var.name, yr, merge.dt, do.vars) {
  out_name <- year <- NULL  # for R CMD check
  yr.val <- yr  # avoid year-column vs year-argument clash
  hits <- merge.dt[out_name == var.name & year == yr.val]
  if (nrow(hits) > 0) {
    col.preferred <- hits$column_preferred[1]
    col.fallback <- hits$column_fallback[1]
    if (col.preferred %in% do.vars || col.fallback %in% do.vars) {
      sources <- intersect(c(col.preferred, col.fallback), do.vars)
      return(data.table::data.table(
        variable = var.name,
        year = yr,
        status = "merged",
        source = paste(sources, collapse = "+")
      ))
    }
  }
  NULL
}

## Internal: classify a single variable for a single year against the
## three possible sources: direct presence, rename rule, or merge rule.
classify_variable <- function(var.name, yr, rename.dt, merge.dt, do.vars) {
  ## Check 1: variable exists directly in .do file.
  if (var.name %in% do.vars) {
    return(data.table::data.table(
      variable = var.name,
      year = yr,
      status = "present",
      source = NA_character_
    ))
  }
  ## Checks 2 and 3: a rename or merge rule produces this variable.
  finders <- list(
    list(fn = find_rename_match, rules = rename.dt),
    list(fn = find_merge_match,  rules = merge.dt))
  for (finder in finders) {
    match <- finder$fn(var.name, yr, finder$rules, do.vars)
    if (!is.null(match)) {
      return(match)
    }
  }
  ## Not found by any means.
  data.table::data.table(
    variable = var.name,
    year = yr,
    status = "missing",
    source = NA_character_
  )
}

check_config_coverage <- function(config, data.path) {
  ## Discover .do files in data.path.
  do.files <- Sys.glob(file.path(data.path, "*topical*.do"))
  if (length(do.files) == 0L) {
    stop("No .do files found in data.path: ", data.path)
  }
  ## Extract years from filenames.
  do.years <- as.integer(regmatches(basename(do.files), regexpr("[0-9]{4}", basename(do.files))))
  ## Variables to check (exclude "year" — it's always present).
  desired <- setdiff(config$desired_variables, "year")
  ## Accept the nested config from read_config() and convert to the long-format
  ## data.tables the finders use. config_to_dt() is internal, so callers pass
  ## the nested shape and we convert here.
  config <- config_to_dt(config)
  rename.dt <- config$transformations$rename_columns
  merge.dt <- config$transformations$merge_columns
  out.list <- vector("list", length(do.files) * length(desired))
  idx <- 0L
  for (i in seq_along(do.files)) {
    yr <- do.years[i]
    ## Parse the .do file to get all defined variable names.
    do.lines <- readLines(do.files[i], warn = FALSE)
    var.lines <- grep("^label var ", do.lines, value = TRUE)
    do.vars <- sub("^label var ([^ ]+) .*", "\\1", var.lines)
    for (var.name in desired) {
      idx <- idx + 1L
      out.list[[idx]] <- classify_variable(
        var.name, yr, rename.dt, merge.dt, do.vars
      )
    }
  }
  data.table::rbindlist(out.list[seq_len(idx)])
}
