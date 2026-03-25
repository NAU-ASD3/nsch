get_year <- function(year_url,
                     data.path = file.path("NSCH_data", "00_original_Stata")) {

  # Validate inputs
  if (!is.character(year_url) || length(year_url) != 1L || is.na(year_url)) {
    stop("year_url must be a single non-NA character string")
  }

  if (!is.character(data.path) || length(data.path) != 1L || is.na(data.path)) {
    stop("data.path must be a single non-NA character string")
  }

  # Create directory if needed
  if (!dir.exists(data.path)) {
    dir.create(data.path, recursive = TRUE, showWarnings = FALSE)
  }

  file_name <- basename(year_url)
  dest_file <- file.path(data.path, file_name)

  # Download file
  utils::download.file(year_url, destfile = dest_file, mode = "wb")

  # Check download success
  if (!file.exists(dest_file)) {
    stop("Download failed: file was not created")
  }

  # Unzip if needed
  if (grepl("\\.zip$", dest_file, ignore.case = TRUE)) {
    utils::unzip(dest_file, exdir = data.path)
  }

  dest_file
}
