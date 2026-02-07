datasets_url_prefix <-
  "http://www2.census.gov/programs-surveys/nsch/datasets"
get_year <- function(year, data.dir=tempdir()){
  if(!(
    is.integer(year) && length(year)==1 && is.finite(year)
  ))stop("year must be a single finite integer")
  year.zip <- sprintf("nsch_%d_topical_Stata.zip", year)
  data.dir.year.zip <- file.path(data.dir, year.zip)
  if(!file.exists(data.dir.year.zip)){
    u <- sprintf(
      "%s/%d/%s",
      datasets_url_prefix,
      year,
      year.zip)
    download.file(u, data.dir.year.zip)
  }
  unzip(year.zip, exdir=data.dir)
}
