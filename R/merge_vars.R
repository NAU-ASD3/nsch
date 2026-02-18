merge_vars <- function(dt, merges, year){
  for(variable.name in names(merges)){
    details <- merges[[variable.name]]
    col1 <- details$column_1
    col2 <- details$column_2
    if(as.character(year) %in% details$years &&
       col1 %in% names(dt) &&
       col2 %in% names(dt)){
      ## Coalesce data columns: prefer column_1 where non-NA.
      vec1 <- dt[[col1]]
      vec2 <- dt[[col2]]
      merged.vals <- ifelse(is.na(vec1), vec2, vec1)
      data.table::set(dt, j = variable.name, value = as.numeric(merged.vals))
      ## Coalesce _label companion columns if they exist.
      label1 <- paste0(col1, "_label")
      label2 <- paste0(col2, "_label")
      label.col <- paste0(variable.name, "_label")
      if(label1 %in% names(dt) && label2 %in% names(dt)){
        lab1 <- dt[[label1]]
        lab2 <- dt[[label2]]
        data.table::set(
          dt, j = label.col,
          value = ifelse(is.na(vec1), lab2, lab1))
      }
      ## Remove original source columns and their _label companions.
      for(col in c(col1, col2, label1, label2)){
        if(col %in% names(dt)){
          data.table::set(dt, j = col, value = NULL)
        }
      }
    }
  }
  invisible(dt)
}