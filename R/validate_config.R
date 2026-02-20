validate_config <- function(config, do.list = NULL){
  ## 1. desired_variables must be a non-empty character vector.
  dv <- config$desired_variables
  if(!is.character(dv) || length(dv) == 0){
    stop(
      "desired_variables should be a non-empty character vector, ",
      "but got length ", length(dv),
      " of class ", paste(class(dv), collapse = "/"))
  }
  ## 2. Each transform entry needs equal-length years, value,
  ##    new_value, new_label.
  transforms <- config$transformations$transform
  for(var.name in names(transforms)){
    entry <- transforms[[var.name]]
    lens <- c(
      value     = length(entry$value),
      new_value = length(entry$new_value),
      new_label = length(entry$new_label))
    if(length(unique(lens)) != 1){
      stop(
        "transform entry '", var.name,
        "' has mismatched length: ",
        paste(names(lens), lens, sep = "=", collapse = ", "))
    }
  }
  ## 3. Each rename_columns entry needs years and new_name.
  renames <- config$transformations$rename_columns
  for(var.name in names(renames)){
    entry <- renames[[var.name]]
    if(is.null(entry$years)){
      stop("rename_columns entry '", var.name, "' is missing 'years'")
    }
    if(is.null(entry$new_name)){
      stop("rename_columns entry '", var.name, "' is missing 'new_name'")
    }
  }
  ## 4. Each merge_columns entry needs years, column_1, column_2.
  merges <- config$transformations$merge_columns
  for(var.name in names(merges)){
    entry <- merges[[var.name]]
    for(field in c("years", "column_1", "column_2")){
      if(is.null(entry[[field]])){
        stop(
          "merge_columns entry '", var.name,
          "' is missing '", field, "'")
      }
    }
  }
  ## 5. Optional cross-reference against do.list metadata.
  if(!is.null(do.list)){
    ## Collect all variable names across all years' $var tables.
    all.do.vars <- unique(unlist(lapply(do.list, function(do.out){
      do.out$var$variable
    })))
    missing <- setdiff(dv, all.do.vars)
    for(m in missing){
      warning(
        "desired variable '", m,
        "' not found in any year's .do metadata")
    }
  }
  invisible(TRUE)
}