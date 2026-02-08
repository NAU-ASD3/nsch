get_year <- function(year_url, data.dir=tempdir()){
  year.html <- basename(year_url)
  data.dir.year.html <- file.path(data.dir, year.html)
  if(!file.exists(data.dir.year.html)){
    download.file(year_url, data.dir.year.html)
  }
  url.dt <- nc::capture_all_str(
    data.dir.year.html,
    url="//.*?topical_Stata[.]zip")
  if(nrow(url.dt)==0)
    stop("no topical_Stata.zip urls on ", year_url)
  http_url <- paste0("http:", url.dt$url)
  year.zip <- basename(http_url)
  data.dir.year.zip <- file.path(data.dir, year.zip)
  if(!file.exists(data.dir.year.zip)){
    download.file(http_url, data.dir.year.zip)
  }
  unzip(data.dir.year.zip, exdir=data.dir)
}
