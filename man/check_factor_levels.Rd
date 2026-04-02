\name{check_factor_levels}
\alias{check_factor_levels}
\title{Check factor levels across years}
\description{
Summarize factor levels across survey years to help detect inconsistencies
in categorical NSCH variables. This is useful for finding cases where a
response level appears in some years but is missing in others, such as a
level like "Usually" being absent in early years of a variable like
interest_curiosity but present in later years.
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
  year = c(2016L, 2016L, 2017L, 2017L),
  status = factor(c("A", "B", "A", "A"))
)

check_factor_levels(dt)
}
