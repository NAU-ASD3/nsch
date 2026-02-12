nsch_url_prefix <- "https://www.census.gov/programs-surveys/nsch/data/datasets."
nsch_data_url <- paste0(nsch_url_prefix, "html")
get_nsch_index <- function(local_html.path = tempfile()){
  if(!file.exists(local_html.path)){
    download.file(nsch_data_url, local_html.path, quiet = TRUE)
  }
  ## capture one or more digits, convert to integer.
  digits_to_int = list("[0-9]+", as.integer)
  year_dt <- nc::capture_all_str(
    local_html.path,
    url=list(
      nsch_url_prefix,
      year=digits_to_int,
      ".html"))
  unique(year_dt)
}

