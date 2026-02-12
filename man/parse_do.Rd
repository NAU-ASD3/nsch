\name{parse_do}
\alias{parse_do}
\title{
  Parse Stata do file for NSCH variable metadata
}
\description{
  Parses a Stata \code{.do} file distributed with the National Survey
  of Children's Health (NSCH) to extract variable labels and factor
  level definitions.  Uses \code{\link[nc]{capture_all_str}} to match
  two kinds of \code{label} commands:

  \itemize{
    \item \code{label var VARIABLE "description"} — associates a
      human-readable description with each variable name.
    \item \code{label define VARIABLE_lab VALUE "description"} —
      associates a human-readable description with each integer-coded
      factor level.
  }
}
\usage{
parse_do(year.do)
}
\arguments{
  \item{year.do}{
    Path to do file (one is included for each NSCH survey year).
  }
}
\value{
  \item{var}{data table with one row per variable, and columns
    \code{variable} and \code{desc}.}
  \item{define}{data table with one row per factor level, and columns
    \code{variable}, \code{value}, \code{desc}.}
}
\author{
  Toby Dylan Hocking
}
\examples{

  year.do <- system.file(package="nsch", "extdata", "nsch_2024_topical.do")
  nsch::parse_do(year.do)

}
