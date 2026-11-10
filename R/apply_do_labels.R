## Columns apply_do_labels() leaves unconverted in every year. stratum is 1
## or 2 in every year, and only the 2016 .do labels it ("Stratum 1",
## "Stratum 2"), so labeling it would make it a factor in 2016 and an integer
## in every other year.
unlabeled.columns <- "stratum"

apply_do_labels <- function(dt, define.dt, alias = list()) {
  ## Sentinel codes from na_tag_map (shared with read_nsch_dta).
  sentinel.codes <- unname(na_tag_map)
  
  ## The define.dt value strings that correspond to missing data.
  missing.values <- paste0(".", names(na_tag_map))
  
  ## Track which columns have define entries.
  defined.vars <- unique(define.dt$variable)
  for (col.name in names(dt)) {
    label.col <- paste0(col.name, "_label")
    ## Resolve the lookup name (post-rename/merge -> original define entry).
    lookup.name <- if (col.name %in% names(alias)) alias[[col.name]] else col.name
    ## Guard against year-list overshoot: if a rename/merge alias points at a
    ## name with no define entries this year, but the column's own name does
    ## have them, the rename did not fire (the column is natively named), so
    ## its own entries are the correct source. This only rescues the native-name
    ## case: a genuinely misconfigured alias whose column also lacks define
    ## entries still falls through to unlabeled, exactly as before.
    if (!(lookup.name %in% defined.vars) && col.name %in% defined.vars) {
      lookup.name <- col.name
    }
    if (lookup.name %in% defined.vars && !(col.name %in% unlabeled.columns)) {
      ## Get define rows for this variable (under its original name).
      col.defs <- define.dt[define.dt$variable == lookup.name, ]
      
      ## Separate real values from missing-data codes.
      is.missing <- col.defs$value %in% missing.values
      real.defs <- col.defs[!is.missing, ]
      
      ## Skip variables that have only missing-data codes (no real values).
      if (nrow(real.defs) == 0) {
        ## Still replace sentinels with NA for numeric columns.
        leave_unlabeled(dt, col.name, sentinel.codes)
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

      ## A factor keeps only the labeled values, so convert only when every
      ## non-missing value has a label (from the .do or a _label override).
      ## The decision is made per year, from that year's data.
      ## Some .do files label just the top or bottom code of a count or age,
      ## such as a1_age 70 "70 or older" or hhcount 10 "10 or more"; a factor
      ## would turn all the other values into NA, so those columns stay
      ## numeric, as they are in Stata.
      col.vec <- dt[[col.name]]
      if (is.numeric(col.vec)) {
        is.unlabeled <- !is.na(col.vec) &
          !(col.vec %in% sentinel.codes) &
          !(col.vec %in% factor.levels)
        if (has.label.col) {
          is.unlabeled <- is.unlabeled & is.na(override.labels)
        }
        if (any(is.unlabeled)) {
          leave_unlabeled(dt, col.name, sentinel.codes)
          next
        }
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
    } else {
      ## Column with no define entries: replace sentinels with NA.
      leave_unlabeled(dt, col.name, sentinel.codes)
    }
  }
  invisible(dt)
}

## Internal: leave a column unconverted, replacing sentinel codes with NA if
## it is numeric, and drop its _label companion. Those labels only take effect
## through a factor, so for a column that isn't converted they have nowhere
## to go.
leave_unlabeled <- function(dt, col.name, sentinel.codes) {
  col.vec <- dt[[col.name]]
  if (is.numeric(col.vec)) {
    is.sentinel <- col.vec %in% sentinel.codes
    if (any(is.sentinel, na.rm = TRUE)) {
      col.vec[is.sentinel] <- NA
      data.table::set(dt, j = col.name, value = col.vec)
    }
  }
  label.col <- paste0(col.name, "_label")
  if (label.col %in% names(dt)) {
    data.table::set(dt, j = label.col, value = NULL)
  }
  invisible(dt)
}