\name{rename_vars}
\alias{rename_vars}
\title{
  Rename columns per JSON config rules
}
\description{
  Renames columns in a \code{data.table} according to config
  \code{rename_columns} rules, modifying it by reference.  For each
  entry in \code{renames} whose \code{years} includes
  \code{as.character(year)}: renames the old column to
  \code{new_name} if it exists.  Also renames the corresponding
  \code{_label} companion column if present.  Silently skips entries
  whose old column is absent.
}
\usage{
rename_vars(dt, renames, year)
}
\arguments{
  \item{dt}{
    A \code{data.table} with numeric columns, as returned by
    \code{\link{read_dta}}.
  }
  \item{renames}{
    The \code{config$transformations$rename_columns} list from
    \code{\link{read_config}} --- a named list keyed by old column
    name, each with \code{years} (character vector) and
    \code{new_name} (string).
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

  dt <- data.table::data.table(old_var = c(1, 2))
  renames <- list(old_var = list(
    years = "2016", new_name = "new_var"))
  rename_vars(dt, renames, 2016L)
names(dt)

}