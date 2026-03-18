rename_vars <- function(dt, renames, year){
  for(old.name in names(renames)){
    details <- renames[[old.name]]
    if(as.character(year) %in% details$years &&
       old.name %in% names(dt)){
      new.name <- details$new_name
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