\name{merge_vars}
\alias{merge_vars}
\title{
  Coalesce paired columns into one
}
\description{
  Coalesces paired columns into a single column, modifying \code{dt}
  by reference.  For each entry in \code{merges} whose \code{years}
  includes \code{as.character(year)}: creates a new column (named
  after the merge key) taking the value from \code{column_1} where
  non-NA, falling back to \code{column_2}.  Performs the same
  coalesce on corresponding \code{_label} columns.  Removes the
  original source columns after merging.  Silently skips entries
  where source columns are absent.
}
\usage{
merge_vars(dt, merges, year)
}
\arguments{
  \item{dt}{
    A \code{data.table} with numeric columns, as returned by
    \code{\link{read_dta}}.
  }
  \item{merges}{
    The \code{config$transformations$merge_columns} list from
    \code{\link{read_config}} --- a named list keyed by the new
    column name, each with \code{years}, \code{column_1},
    \code{column_2}.
  }
  \item{year}{
    Integer year to process.  Compared against the config's string
    \code{years} vectors using \code{as.character(year)}.
  }
}
\value{
  Returns \code{dt} invisibly (modified by reference).
}
\author{
  Chris Reger
}
\examples{

  dt <- data.table::data.table(
    col_a = c(1, NA, 3),
    col_b = c(NA, 2, 4))
  merges <- list(combined = list(
    years = "2016",
    column_1 = "col_a",
    column_2 = "col_b"))
  merge_vars(dt, merges, 2016L)
  print(dt)

}