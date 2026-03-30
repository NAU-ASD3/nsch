get_clean_data <- function(
    config.path = system.file("extdata", "variable-config.json", package = "nsch"),
    data.path = file.path("NSCH_data", "00_original_Stata"),
    years = NULL,
    download = FALSE,
    impute.2016 = TRUE,
    seed = 1L
) {
  config <- nsch::read_config(config.path)
  nsch::validate_config(config)
  files.dt <- nsch::get_all_years(
    data.path = data.path, years = years, download = download)
  ## Process each year through the harmonization pipeline.
  year.list <- lapply(seq_len(nrow(files.dt)), function(i) {
    yr <- files.dt[["year"]][i]
    message("Processing year ", yr, "...")
    dt <- nsch::read_dta(files.dt[["dta.path"]][i])
    do.list <- nsch::parse_do(files.dt[["do.path"]][i])
    nsch::harmonize_year(dt, config, yr, do.list$define)
  })
  ## Combine all years.
  combined.dt <- nsch::combine_years(year.list)
  ## Optionally impute 2016 a1_grade.
  if (impute.2016 && 2016L %in% combined.dt[["year"]]) {
    dta.2016.path <- files.dt[files.dt[["year"]] == 2016L][["dta.path"]]
    nsch::impute_a1_grade_2016(combined.dt, dta.2016.path, seed = seed)
  }
  combined.dt
}