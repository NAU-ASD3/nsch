get_year <- function(year_url,
                     data.path = file.path("NSCH_data", "00_original_Stata"),
                     verbose = FALSE) {
  if (!is.character(year_url) || length(year_url) != 1L || is.na(year_url)) {
    stop("year_url must be a single non-NA character string")
  }

  if (!is.character(data.path) || length(data.path) != 1L || is.na(data.path)) {
    stop("data.path must be a single non-NA character string")
  }

  if (!is.logical(verbose) || length(verbose) != 1L || is.na(verbose)) {
    stop("verbose must be a single non-NA logical value")
  }

  dir.create(data.path, recursive = TRUE, showWarnings = FALSE)

  year.html <- basename(year_url)
  data.path.year.html <- file.path(data.path, year.html)

  if (!file.exists(data.path.year.html)) {
    utils::download.file(
      year_url,
      data.path.year.html,
      quiet = !verbose
    )
  }

  url.dt <- nc::capture_all_str(
    data.path.year.html,
    url = "//.*?topical_Stata[.]zip"
  )

  if (nrow(url.dt) != 1L) {
    stop(
      "expected 1 topical_Stata.zip url on ",
      year_url,
      " but found ",
      nrow(url.dt)
    )
  }

  http.url <- paste0("http:", url.dt$url)
  year.zip <- basename(http.url)
  data.path.year.zip <- file.path(data.path, year.zip)

  if (!file.exists(data.path.year.zip)) {
    utils::download.file(
      http.url,
      data.path.year.zip,
      mode = "wb",
      quiet = !verbose
    )
  }

  utils::unzip(data.path.year.zip, exdir = data.path)

  data.path.year.zip
}
