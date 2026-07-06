## `rename.dt` is the long-format rename table from config_to_dt():
## columns old_name | year | new_name, one row per (rule, year).
rename_vars <- function(dt, rename.dt, year){
  yr <- year  # avoid year-column vs year-argument clash in the subset
  rules <- rename.dt[year == yr]
  for(i in seq_len(nrow(rules))){
    old.name <- rules$old_name[i]
    new.name <- rules$new_name[i]
    if(old.name %in% names(dt)){
      data.table::setnames(dt, old.name, new.name)
      ## Rename companion _label column if it exists.
      old.label <- paste0(old.name, "_label")
      if(old.label %in% names(dt)){
        data.table::setnames(dt, old.label, paste0(new.name, "_label"))
      }
    }
  }
  invisible(dt)
}
