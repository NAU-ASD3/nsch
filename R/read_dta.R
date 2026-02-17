read_dta <- function(dta.path){
  if(!file.exists(dta.path)){
    stop(
      "dta.path should be the path to a Stata .dta file, ",
      "but this file does not exist: ", dta.path)
  }
  raw <- haven::read_dta(dta.path)
  ## Replace tagged NA values with integer sentinel codes.
  ## NSCH .dta files use four tagged NA types:
  ##   .m (no valid response) -> 996
  ##   .n (not in universe)   -> 997
  ##   .l (logical skip)      -> 998
  ##   .d (suppressed)        -> 999
  tag_map <- c(m=996L, n=997L, l=998L, d=999L)
  for(col in names(raw)){
    col_vec <- raw[[col]]
    for(tag in names(tag_map)){
      is_tag <- is_tagged_na(col_vec, tag)
      if(any(is_tag)){
        if(!is.numeric(col_vec)){
          col_vec <- as.numeric(col_vec)
        }
        col_vec[is_tag] <- tag_map[[tag]]
      }
    }
    ## Strip haven_labelled class so columns are plain numeric/character.
    if(inherits(col_vec, "haven_labelled")){
      col_vec <- as.vector(col_vec)
    }
    raw[[col]] <- col_vec
  }
  ## Normalize stratum column: some years have "2A" which must become
  ## numeric 2 for consistency.
  if("stratum" %in% names(raw)){
    s <- as.character(raw[["stratum"]])
    s[grepl("^2[aA]?$", s)] <- "2"
    raw[["stratum"]] <- as.numeric(s)
  }
  dt <- data.table(raw)
  ## Verify year column exists (the entire pipeline depends on it).
  if(!("year" %in% names(dt))){
    stop("dta file does not contain a 'year' column: ", dta.path)
  }
  dt[["year"]] <- as.integer(dt[["year"]])
  dt
}