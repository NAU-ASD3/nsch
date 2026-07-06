\name{rename_vars}
\alias{rename_vars}
\title{
  Rename columns per config rules
}
\description{
  Renames columns in a \code{data.table} according to the config
  \code{rename_columns} rules, modifying it by reference.  For each
  rule applying to \code{year}: renames the old column to
  \code{new_name} if it exists.  Also renames the corresponding
  \code{_label} companion column if present.  Silently skips entries
  whose old column is absent.
}
\usage{
rename_vars(dt, rename.dt, year)
}
\arguments{
  \item{dt}{
    A \code{data.table} with numeric columns, as returned by
    \code{\link{read_nsch_dta}}.
  }
  \item{rename.dt}{
    The long-format rename table from \code{config_to_dt()}: a
    \code{data.table} with one row per (rule, year) and columns
    \code{old_name}, \code{year} (integer), \code{new_name}.
  }
  \item{year}{
    Integer year to process.  Rows of \code{rename.dt} with a
    matching \code{year} are applied.
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
  rename.dt <- data.table::data.table(
    old_name = "old_var", year = 2016L, new_name = "new_var")
  nsch::rename_vars(dt, rename.dt, 2016L)
names(dt)

}
