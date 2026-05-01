\name{check_label_consistency}
\alias{check_label_consistency}
\title{
  Check factor level consistency across years
}
\description{
  For each factor column, compares the set of observed (non-\code{NA})
  levels across years.  Reports whether all years have the same levels
  and, if not, shows the level set for each year.  Useful for detecting
  variables where the survey changed response options between years
  (e.g. a new category added in 2024).
}
\usage{
check_label_consistency(dt)
}
\arguments{
  \item{dt}{A \code{\link[data.table]{data.table}} containing a column
    named \code{year} and one or more factor columns.}
}
\value{
  A \code{\link[data.table]{data.table}} with columns \code{variable}
  (character), \code{is.consistent} (logical), \code{n.level.sets}
  (integer, number of distinct level sets across years), and
  \code{levels.by.year} (character, showing levels per year).
  Returns an empty table if no factor columns are present.
}
\author{
  Chris Reger
}
\examples{
library(data.table)
dt <- data.table(
  year = c(2016L, 2016L, 2017L, 2017L),
  status = factor(c("A", "B", "A", "C")))
nsch::check_label_consistency(dt)
}