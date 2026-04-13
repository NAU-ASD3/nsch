\name{combine_years}
\alias{combine_years}
\title{
  Combine harmonized yearly data tables
}
\description{
  Row-binds a list of per-year
  \code{\link[data.table]{data.table}}s into a single combined
  dataset.  Uses \code{\link[data.table]{rbindlist}} with
  \code{use.names = TRUE} and \code{fill = TRUE} to handle columns
  that may exist in some years but not others (filled with \code{NA}).
  Verifies that all tables have a \code{year} column and that year
  values do not collide across tables.
}
\usage{
combine_years(year.list)
}
\arguments{
  \item{year.list}{
    A non-empty list of \code{\link[data.table]{data.table}}s, each
    containing a \code{year} column.  Typically the output of
    \code{\link{harmonize_year}} called on each year's data.
  }
}
\value{
  A single \code{\link[data.table]{data.table}} with all rows
  combined.  Columns present in some years but not others are filled
  with \code{NA}.
}
\author{
  Chris Reger
}