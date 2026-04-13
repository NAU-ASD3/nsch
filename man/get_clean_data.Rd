\name{get_clean_data}
\alias{get_clean_data}
\title{
  Run the full NSCH harmonization pipeline
}
\description{
  Top-level convenience function that executes the complete data cleaning
  pipeline: discovers data files via \code{\link{get_all_years}}, reads each
  year's \code{.dta} and \code{.do} files, applies per-year harmonization
  via \code{\link{harmonize_year}} (transform, rename, merge, subset, label),
  combines all years via \code{\link{combine_years}}, and optionally imputes
  2016 \code{a1_grade} via \code{\link{impute_a1_grade_2016}}.
}
\details{
This function reads \code{.dta} and \code{.do} files directly rather
than the CSV files produced by \code{\link{Stata2csv_year}}.  Stata
\code{.dta} files encode four tagged NA types (\code{.m}, \code{.n},
\code{.l}, \code{.d}) that the pipeline maps to sentinel codes 996--999
(see \code{\link{na_tag_map}}).  These distinct missingness types are
used by downstream config transforms and by
\code{\link{apply_do_labels}} during factor conversion.  CSV export
collapses all four types to a single \code{NA}, losing that distinction.
}
\usage{
get_clean_data(
  config.path = system.file("extdata", "variable-config.json", package = "nsch"),
  data.path = file.path("NSCH_data", "00_original_Stata"),
  years = NULL,
  download = FALSE,
  impute.2016 = TRUE,
  seed = 1L
)
}
\arguments{
  \item{config.path}{Path to the JSON harmonization config file.}
  \item{data.path}{Directory containing NSCH \code{.dta} and \code{.do} files.}
  \item{years}{Optional integer vector of years to process.  If \code{NULL},
    all discovered years are processed.}
  \item{download}{If \code{TRUE}, downloads data via \code{\link{get_all_years}}
    before processing.}
  \item{impute.2016}{If \code{TRUE} and 2016 data is present, runs
    \code{\link{impute_a1_grade_2016}} on the combined dataset.}
  \item{seed}{Integer seed for reproducible 2016 imputation.}
}
\value{
  A \code{\link[data.table]{data.table}} with one row per child per year,
  harmonized columns as factors or numeric values.
}
\author{
  Chris Reger
}
\examples{
\dontrun{
## Requires NSCH .dta and .do files on disk.
## Download first, then process all years:
dt <- nsch::get_clean_data(download = TRUE)

## Process only specific years without downloading:
dt <- nsch::get_clean_data(
  data.path = "path/to/nsch/data",
  years = c(2016L, 2017L, 2024L),
  download = FALSE)
}
}