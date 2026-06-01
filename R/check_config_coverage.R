## Internal: try to find a rename rule that produces `var.name` for year `yr`.
## Returns a one-row data.table on match, or NULL.
find_rename_match <- function(var.name, yr, yr.char, renames, do.vars) {
  for (old.name in names(renames)) {
    entry <- renames[[old.name]]
    if (entry$new_name == var.name
        && yr.char %in% entry$years
        && old.name %in% do.vars) {
      return(data.table::data.table(
        variable = var.name,
        year = yr,
        status = "renamed",
        source = old.name
      ))
    }
  }
  NULL
}

## Internal: try to find a merge rule that produces `var.name` for year `yr`.
## Returns a one-row data.table on match, or NULL.
find_merge_match <- function(var.name, yr, yr.char, merges, do.vars) {
  for (merge.name in names(merges)) {
    entry <- merges[[merge.name]]
    if (merge.name == var.name && yr.char %in% entry$years) {
      col.preferred <- entry$column_preferred
      col.fallback <- entry$column_fallback
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
  }
  NULL
}

## Internal: classify a single variable for a single year against the
## three possible sources: direct presence, rename rule, or merge rule.
classify_variable <- function(var.name, yr, yr.char, renames, merges, do.vars) {
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
    list(fn = find_rename_match, rules = renames),
    list(fn = find_merge_match,  rules = merges))
  for (finder in finders) {
    match <- finder$fn(var.name, yr, yr.char, finder$rules, do.vars)
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
  ## Build reverse lookup: for each desired variable, which source
  ## variable + rule produces it?
  renames <- config$transformations$rename_columns
  merges <- config$transformations$merge_columns
  out.list <- vector("list", length(do.files) * length(desired))
  idx <- 0L
  for (i in seq_along(do.files)) {
    yr <- do.years[i]
    yr.char <- as.character(yr)
    ## Parse the .do file to get all defined variable names.
    do.lines <- readLines(do.files[i], warn = FALSE)
    var.lines <- grep("^label var ", do.lines, value = TRUE)
    do.vars <- sub("^label var ([^ ]+) .*", "\\1", var.lines)
    for (var.name in desired) {
      idx <- idx + 1L
      out.list[[idx]] <- classify_variable(
        var.name, yr, yr.char, renames, merges, do.vars
      )
    }
  }
  data.table::rbindlist(out.list[seq_len(idx)])
}