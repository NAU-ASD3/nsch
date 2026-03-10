\name{transform_values}
\alias{transform_values}
\title{
  Remap numeric values and create label columns
}
\description{
  Applies value and label remapping rules to a single year's raw
  numeric \code{data.table}, modifying it by reference.  For each
  variable in \code{transforms} whose \code{years} vector includes
  \code{as.character(year)}: iterates over the paired
  \code{value}/\code{new_value}/\code{new_label} entries and replaces
  matching numeric values with their new values.  Also creates or
  updates a corresponding \code{_label} column with the
  \code{new_label} text for remapped rows.  Silently skips variables
  not present in \code{dt}.
}
\usage{
transform_values(dt, transforms, year)
}
\arguments{
  \item{dt}{
    A \code{data.table} with numeric columns, as returned by
    \code{\link{read_dta}}.
  }
  \item{transforms}{
    The \code{config$transformations$transform} list from
    \code{\link{read_config}} --- a named list where each element has
    \code{years}, \code{value}, \code{new_value}, \code{new_label}
    (all character vectors).
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

  dt <- data.table::data.table(sex = c(1, 2, 1))
  transforms <- list(sex = list(
    years = "2016",
    value = c("1", "2"),
    new_value = c("1", "2"),
    new_label = c("Male", "Female")))
  transform_values(dt, transforms, 2016L)
dt

}