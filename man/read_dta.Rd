\name{read_dta}
\alias{read_dta}
\title{
  Read one year of NSCH Stata data
}
\description{
  Reads a single NSCH Stata \code{.dta} file and returns a
  \code{\link[data.table]{data.table}} with plain numeric and character
  columns.  Performs three cleaning steps during ingestion:

  \enumerate{
    \item Replaces Stata tagged \code{NA} values (\code{.m}, \code{.n},
      \code{.l}, \code{.d}) with integer sentinel codes 996, 997, 998,
      999 respectively.
    \item Strips \code{haven_labelled} classes so all columns are plain
      R types.
    \item Normalizes the \code{stratum} column by converting
      \code{"2A"} to numeric \code{2} (a known quirk in some NSCH
      years).
  }

  Factor labels are \emph{not} applied here; that is deferred to a
  later step using \code{\link{parse_do}} output.
}
\usage{
read_dta(dta.path)
}
\arguments{
  \item{dta.path}{
    Path to a Stata \code{.dta} file (one is included for each NSCH
    survey year inside the zip downloaded by \code{\link{get_year}}).
  }
}
\value{
  A \code{\link[data.table]{data.table}} with one row per survey
  respondent.  All columns are plain numeric or character (no
  \code{haven_labelled} classes).  A \code{year} column is present
  and integer-typed.
}
\author{
  Vincent Sutherland
}
\examples{

## First unzip the bundled 2024 test data.
files2024 <- system.file(
  package = "nsch", "extdata",
  c("datasets.2024.html", "nsch_2024_topical_Stata.zip"),
  mustWork = TRUE)
dir2024 <- tempfile()
dir.create(dir2024)
file.copy(files2024, dir2024)
nsch::get_year(
  "https://www.census.gov/programs-surveys/nsch/data/datasets.2024.html",
  dir2024)

## Now read the .dta file.
dta.path <- file.path(dir2024, "nsch_2024e_topical.dta")
dt <- nsch::read_dta(dta.path)
str(dt[, 1:5])

}