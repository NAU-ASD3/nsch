apply_do_labels <- function(dt, define.dt) {
  ## Sentinel codes from na_tag_map (shared with read_dta).
  sentinel.codes <- unname(na_tag_map)
  
  ## The define.dt value strings that correspond to missing data.
  missing.values <- paste0(".", names(na_tag_map))
  
  ## Track which columns have define entries.
  defined.vars <- unique(define.dt$variable)
  for (col.name in names(dt)) {
    label.col <- paste0(col.name, "_label")
    if (col.name %in% defined.vars) {
      ## Get define rows for this variable.
      col.defs <- define.dt[define.dt$variable == col.name, ]
      
      ## Separate real values from missing-data codes.
      is.missing <- col.defs$value %in% missing.values
      real.defs <- col.defs[!is.missing, ]
      
      ## Skip variables that have only missing-data codes (no real values).
      if (nrow(real.defs) == 0) {
        ## Still replace sentinels with NA for numeric columns.
        if (is.numeric(dt[[col.name]])) {
          col.vec <- dt[[col.name]]
          is.sentinel <- col.vec %in% sentinel.codes
          if (any(is.sentinel, na.rm = TRUE)) {
            col.vec[is.sentinel] <- NA
            data.table::set(dt, j = col.name, value = col.vec)
          }
        }
        next
      }
      
      ## Build factor levels sorted by numeric value.
      real.nums <- as.numeric(real.defs$value)
      sort.order <- order(real.nums)
      factor.levels <- real.nums[sort.order]
      factor.labels <- real.defs$desc[sort.order]
      
      ## Check for _label companion column before factoring.
      has.label.col <- label.col %in% names(dt)
      if (has.label.col) {
        override.labels <- dt[[label.col]]
      }
      
      ## Convert to factor; sentinel codes become NA automatically
      ## because they are not in factor.levels.
      new.factor <- factor(dt[[col.name]], levels = factor.levels, labels = factor.labels)
      
      ## Apply _label overrides where non-NA.
      if (has.label.col) {
        override.rows <- which(!is.na(override.labels))
        if (length(override.rows) > 0) {
          override.vals <- override.labels[override.rows]
          
          ## Add any new levels introduced by _label overrides.
          current.levels <- levels(new.factor)
          new.levels <- setdiff(unique(override.vals), current.levels)
          if (length(new.levels) > 0) {
            levels(new.factor) <- c(current.levels, new.levels)
          }
          new.factor[override.rows] <- override.vals
        }
        
        ## Remove the _label column.
        data.table::set(dt, j = label.col, value = NULL)
      }
      
      ## Assign the completed factor to the data.table.
      data.table::set(dt, j = col.name, value = new.factor)
    } else if (is.numeric(dt[[col.name]])) {
      ## Numeric column with no define entries: replace sentinels with NA.
      col.vec <- dt[[col.name]]
      is.sentinel <- col.vec %in% sentinel.codes
      if (any(is.sentinel, na.rm = TRUE)) {
        col.vec[is.sentinel] <- NA
        data.table::set(dt, j = col.name, value = col.vec)
      }
    }
  }
  invisible(dt)
}