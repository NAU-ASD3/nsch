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
parse_do(year.do.path)
}
\arguments{
  \item{year.do.path}{
    Path to do file (one is included for each NSCH survey year).
  }
}
\value{
  A named list with two elements, each a
  \code{\link[data.table]{data.table}}:

  \item{var}{One row per variable.  Columns: \code{variable} (character,
    the variable name) and \code{desc} (character, the label text).}
  \item{define}{One row per factor level.  Columns: \code{variable}
    (character, the variable name), \code{value} (character, the integer
    code), and \code{desc} (character, the level label).}
}
\author{
  Toby Dylan Hocking
}
\examples{

  year.do <- system.file(package="nsch", "extdata", "nsch_2024_topical.do")
  nsch::parse_do(year.do)

}
