\name{get_all_years}
\alias{get_all_years}
\title{
  Discover NSCH data files for all available years
}
\description{
  Finds \code{.dta} and \code{.do} files in a data directory using glob
  patterns, returning a \code{\link[data.table]{data.table}} mapping each
  year to its file paths.  Handles non-standard filenames such as
  \code{nsch_2024e_topical.dta}.  Optionally downloads data first via
  \code{\link{get_year}}.
}
\usage{
get_all_years(
  data.path = file.path("NSCH_data", "00_original_Stata"),
  years = NULL,
  download = FALSE
)
}
\arguments{
  \item{data.path}{Directory containing NSCH \code{.dta} and \code{.do} files.}
  \item{years}{Optional integer vector of years to include.  If \code{NULL},
    all discovered years are returned.}
  \item{download}{If \code{TRUE}, downloads data via \code{\link{get_year}}
    before discovering files.}
}
\value{
  A \code{\link[data.table]{data.table}} with columns \code{year} (integer),
  \code{dta.path} (character), and \code{do.path} (character).
}
\author{
  Chris Reger
}
\examples{
## Create a temp directory with dummy NSCH files to demonstrate discovery.
test.dir <- tempfile()
dir.create(test.dir)
file.create(file.path(test.dir, "nsch_2016_topical.dta"))
file.create(file.path(test.dir, "nsch_2016_topical.do"))
file.create(file.path(test.dir, "nsch_2017_topical.dta"))
file.create(file.path(test.dir, "nsch_2017_topical.do"))
result <- nsch::get_all_years(data.path = test.dir, download = FALSE)
print(result)
unlink(test.dir, recursive = TRUE)
}
file.crea