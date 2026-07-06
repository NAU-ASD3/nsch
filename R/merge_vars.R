## `merge.dt` is the long-format merge table from config_to_dt():
## columns out_name | year | column_preferred | column_fallback,
## one row per (rule, year).
merge_vars <- function(dt, merge.dt, year){
  yr <- year  # avoid year-column vs year-argument clash in the subset
  rules <- merge.dt[year == yr]
  for(i in seq_len(nrow(rules))){
    variable.name <- rules$out_name[i]
    col.preferred <- rules$column_preferred[i]
    col.fallback <- rules$column_fallback[i]
    if(col.preferred %in% names(dt) &&
       col.fallback %in% names(dt)){
      ## Coalesce data columns: prefer column_preferred where it has a
      ## real value. Treat the logical-skip sentinel (998, from
      ## na_tag_map) as missing for fallback purposes — this is the
      ## routing signal that "the respondent was age-routed away from
      ## this column, the fallback may have their answer." Other
      ## sentinels (996 no valid response, 997 not in universe, 999
      ## suppressed) are response-quality signals, not routing signals;
      ## they stay on the preferred path and get mapped to NA by
      ## apply_do_labels() later.
      vec.preferred <- dt[[col.preferred]]
      vec.fallback <- dt[[col.fallback]]
      logical.skip <- nsch::na_tag_map[["l"]]
      use.fallback <- is.na(vec.preferred) | vec.preferred == logical.skip
      merged.vals <- ifelse(use.fallback, vec.fallback, vec.preferred)
      data.table::set(dt, j = variable.name, value = as.numeric(merged.vals))
      ## Coalesce _label companion columns if they exist; use the same
      ## use.fallback boolean so data and label stay in sync.
      label.preferred <- paste0(col.preferred, "_label")
      label.fallback <- paste0(col.fallback, "_label")
      label.col <- paste0(variable.name, "_label")
      if(label.preferred %in% names(dt) && label.fallback %in% names(dt)){
        lab.preferred <- dt[[label.preferred]]
        lab.fallback <- dt[[label.fallback]]
        data.table::set(
          dt, j = label.col,
          value = ifelse(use.fallback, lab.fallback, lab.preferred))
      }
      ## Remove original source columns and their _label companions.
      for(col in c(col.preferred, col.fallback, label.preferred, label.fallback)){
        if(col %in% names(dt)){
          data.table::set(dt, j = col, value = NULL)
        }
      }
    }
  }
  invisible(dt)
}
