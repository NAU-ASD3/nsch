nsch_url_prefix <- "https://www.census.gov/programs-surveys/nsch/data/datasets"
nsch_data_url <- paste0(nsch_url_prefix, ".html")
get_nsch_index <- function(local_html = tempfile()){
  if(!file.exists(local_html)){
    download.file(nsch_data_url, local_html, quiet = TRUE)
  }
  year_dt <- nc::capture_all_str(
    local_html,
    url=list(
      nsch.prefix,
      year="[0-9]+",
      ".html"))
  unique(year_dt)
}

