 get_year <- function(year_url, data.path=file.path("NSCH_data", "00_original_Stata")){
  ##Input validation
  if(!is.character(year_url) || length(year_url) != 1){
    stop("`year_url` must be a single character string.")
  }

  if(!is.character(data.path) || length(data.path) != 1){
    stop("`data.path` must be a single character string.")
  }

  dir.create(data.path, recursive = TRUE, showWarnings = FALSE)
  year.html <- basename(year_url)
  data.path.year.html <- file.path(data.path, year.html)
  if(!file.exists(data.path.year.html)){
    download.file(year_url, data.path.year.html)
  }
  html <- readLines(data.path.year.html)
  url.dt <- nc::capture_all_str(
    data.path.year.html,
    url="//.*?topical_Stata[.]zip")
  if(nrow(url.dt) != 1)
    stop("expected 1 topical_Stata.zip url on ", year_url, " but found ", nrow(url.dt))
  http_url <- paste0("http:", url.dt$url)
  year.zip <- basename(http_url)
  data.path.year.zip <- file.path(data.path, year.zip)
  if(!file.exists(data.path.year.zip)){
    download.file(http_url, data.path.year.zip, mode="wb")
  }
  unzip(data.path.year.zip, exdir=data.path)
}
  
