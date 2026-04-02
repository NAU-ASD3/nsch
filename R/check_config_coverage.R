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
    for (var in desired) {
      idx <- idx + 1L
      ## Check 1: variable exists directly in .do file.
      if (var %in% do.vars) {
        out.list[[idx]] <- data.table::data.table(
          variable = var,
          year = yr,
          status = "present",
          source = NA_character_
        )
        next
      }
      ## Check 2: a rename rule produces this variable for this year.
      found.rename <- FALSE
      for (old.name in names(renames)) {
        entry <- renames[[old.name]]
        if (entry$new_name == var && yr.char %in% entry$years) {
          if (old.name %in% do.vars) {
            out.list[[idx]] <- data.table::data.table(
              variable = var,
              year = yr,
              status = "renamed",
              source = old.name
            )
            found.rename <- TRUE
            break
          }
        }
      }
      if (found.rename)
        next
      ## Check 3: a merge rule produces this variable for this year.
      found.merge <- FALSE
      for (merge.name in names(merges)) {
        entry <- merges[[merge.name]]
        if (merge.name == var && yr.char %in% entry$years) {
          col1.name <- if (!is.null(entry$column_preferred))
            entry$column_preferred
          else
            entry$column_1
          col2.name <- if (!is.null(entry$column_fallback))
            entry$column_fallback
          else
            entry$column_2
          if (col1.name %in% do.vars || col2.name %in% do.vars) {
            sources <- intersect(c(col1.name, col2.name), do.vars)
            out.list[[idx]] <- data.table::data.table(
              variable = var,
              year = yr,
              status = "merged",
              source = paste(sources, collapse = "+")
            )
            found.merge <- TRUE
            break
          }
        }
      }
      if (found.merge)
        next
      ## Not found by any means.
      out.list[[idx]] <- data.table::data.table(
        variable = var,
        year = yr,
        status = "missing",
        source = NA_character_
      )
    }
  }
  data.table::rbindlist(out.list[seq_len(idx)])
}