merge_vars <- function(dt, merges, year){
  for(variable.name in names(merges)){
    details <- merges[[variable.name]]
    col.preferred <- details$column_preferred
    col.fallback <- details$column_fallback
    if(as.character(year) %in% details$years &&
       col.preferred %in% names(dt) &&
       col.fallback %in% names(dt)){
      ## Coalesce data columns: prefer column_preferred where non-NA.
      vec.preferred <- dt[[col.preferred]]
      vec.fallback <- dt[[col.fallback]]
      merged.vals <- ifelse(is.na(vec.preferred), vec.fallback, vec.preferred)
      data.table::set(dt, j = variable.name, value = as.numeric(merged.vals))
      ## Coalesce _label companion columns if they exist.
      label.preferred <- paste0(col.preferred, "_label")
      label.fallback <- paste0(col.fallback, "_label")
      label.col <- paste0(variable.name, "_label")
      if(label.preferred %in% names(dt) && label.fallback %in% names(dt)){
        lab.preferred <- dt[[label.preferred]]
        lab.fallback <- dt[[label.fallback]]
        data.table::set(
          dt, j = label.col,
          value = ifelse(is.na(vec.preferred), lab.fallback, lab.preferred))
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