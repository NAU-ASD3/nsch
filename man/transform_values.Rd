\name{transform_values}
\alias{transform_values}
\title{
  Remap numeric values and create label columns
}
\description{
  Applies value and label remapping rules to a single year's raw
  numeric \code{data.table}, modifying it by reference.  For each
  variable with rules applying to \code{year}: iterates over the
  paired \code{value}/\code{new_value}/\code{new_label} rows and
  replaces matching numeric values with their new values.  Also
  creates or updates a corresponding \code{_label} column with the
  \code{new_label} text for remapped rows.  Silently skips variables
  not present in \code{dt}.
}
\usage{
transform_values(dt, transform.dt, year)
}
\arguments{
  \item{dt}{
    A \code{data.table} with numeric columns, as returned by
    \code{\link{read_nsch_dta}}.
  }
  \item{transform.dt}{
    The long-format transform table from \code{config_to_dt()}: a
    \code{data.table} with one row per (variable, year, value) and
    columns \code{variable}, \code{year} (integer), \code{value},
    \code{new_value}, \code{new_label}.
  }
  \item{year}{
    Integer year to process.  Rows of \code{transform.dt} with a
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

  dt <- data.table::data.table(sex = c(1, 2, 1))
  transform.dt <- data.table::data.table(
    variable = "sex", year = 2016L,
    value = c("1", "2"),
    new_value = c("1", "2"),
    new_label = c("Male", "Female"))
  nsch::transform_values(dt, transform.dt, 2016L)
dt

}
