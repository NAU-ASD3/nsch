\name{check_factor_levels}
\alias{check_factor_levels}
\title{Check factor levels across years}
\description{
Identify factor levels that appear only in some years of a dataset.
}
\usage{
check_factor_levels(dt)
}
\arguments{
  \item{dt}{A data.table containing a column named 'year'.}
}
\value{
A data.table summarizing factor levels and the years in which they appear.
}
\examples{
library(data.table)

dt <- data.table(
  year = c(2016, 2016, 2017, 2017),
  status = factor(c("A", "B", "A", "A"))
)

check_factor_levels(dt)
}
