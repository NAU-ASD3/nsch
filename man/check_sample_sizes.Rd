\name{check_sample_sizes}
\alias{check_sample_sizes}
\title{
  Check row counts per year
}
\description{
  Returns the number of rows for each year in the dataset.  A quick
  sanity check that all expected years loaded and that no year has an
  unexpectedly small count.
}
\usage{
check_sample_sizes(dt)
}
\arguments{
  \item{dt}{A \code{\link[data.table]{data.table}} containing a column
    named \code{year}.}
}
\value{
  A \code{\link[data.table]{data.table}} with columns \code{year}
  (integer) and \code{n.rows} (integer), sorted by year.
}
\author{
  Chris Reger
}
\examples{
library(data.table)
dt <- data.table(
  year = c(2016L, 2016L, 2016L, 2017L, 2017L),
  x = 1:5)
nsch::check_sample_sizes(dt)
}