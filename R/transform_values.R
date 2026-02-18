transform_values <- function(dt, transforms, year){
  for(variable.name in names(transforms)){
    details <- transforms[[variable.name]]
    if(as.character(year) %in% details$years &&
       variable.name %in% names(dt)){
      label.col <- paste0(variable.name, "_label")
      ## Initialize _label column if it does not yet exist.
      if(!(label.col %in% names(dt))){
        data.table::set(dt, j = label.col, value = NA_character_)
      }
      for(i in seq_along(details$value)){
        old.val <- as.numeric(details$value[i])
        new.val <- as.numeric(details$new_value[i])
        new.label <- details$new_label[i]
        rows <- which(dt[[variable.name]] == old.val)
        if(length(rows) > 0){
          data.table::set(dt, i = rows, j = variable.name, value = new.val)
          data.table::set(dt, i = rows, j = label.col, value = new.label)
        }
      }
    }
  }
  invisible(dt)
}