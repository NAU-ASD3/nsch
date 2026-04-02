\name{check_na_rates}
\alias{check_na_rates}
\title{
  Check NA rates per column per year
}
\description{
  Computes the proportion of \code{NA} values for each column, broken down
  by year.  Useful for identifying variables with high missingness in
  specific years, or for applying a threshold (e.g. exclude columns with
  >10\% missing) before downstream analysis.
}
\usage{
check_na_rates(dt)
}
\arguments{
  \item{dt}{A \code{\link[data.table]{data.table}} containing a column
    named \code{year}.}
}
\value{
  A \code{\link[data.table]{data.table}} with columns \code{variable}
  (character), \code{year} (integer), \code{na.rate} (numeric, 0--1),
  and \code{n.total} (integer, row count for that year).
}
\author{
  Chris Reger
}
\examples{
library(data.table)
dt <- data.table(
  year = c(2016L, 2016L, 2017L, 2017L),
  x = c(1, NA, 3, 4),
  y = c(NA, NA, 5, 6))
nsch::check_na_rates(dt)
}