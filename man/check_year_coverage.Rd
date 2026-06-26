\name{check_year_coverage}
\alias{check_year_coverage}
\title{
  Check which years each variable covers
}
\description{
  For each column (excluding \code{year}), checks whether it has at least
  one non-\code{NA} value in each year present in the data.  Flags
  variables that are entirely \code{NA} for one or more years, which
  typically indicates the variable does not exist in that year's survey
  or that a rename/merge rule is missing from the config.
}
\usage{
check_year_coverage(dt)
}
\arguments{
  \item{dt}{A \code{\link[data.table]{data.table}} containing a column
    named \code{year}.}
}
\value{
  A \code{\link[data.table]{data.table}} with columns \code{variable}
  (character), \code{n.years.data} (integer), \code{n.years.total}
  (integer), and \code{missing.years} (character, comma-separated year
  values or \code{""} if fully covered).
}
\author{
  Chris Reger
}
\examples{
library(data.table)
dt <- data.table(
  year = c(2016L, 2016L, 2017L, 2017L),
  x = c(1, 2, 3, 4),
  y = c(1, 2, NA, NA))
nsch::check_year_coverage(dt)
}