\name{subset_vars}
\alias{subset_vars}
\title{
  Select desired columns plus label companions
}
\description{
  Returns a new \code{data.table} containing only the columns listed
  in \code{desired.variables}, plus any corresponding \code{_label}
  companion columns that exist.  Issues a \code{warning()} for each
  variable in \code{desired.variables} not found in \code{dt}
  (expected when a variable does not exist in a particular year).
  Does not modify \code{dt} by reference.
}
\usage{
subset_vars(dt, desired.variables)
}
\arguments{
  \item{dt}{
    A \code{data.table} to subset.
  }
  \item{desired.variables}{
    Character vector of column names to retain.  Typically extracted
    from \code{config$desired_variables} by the caller.
  }
}
\value{
  A new \code{data.table} containing only the desired columns and
  their \code{_label} companions.
}
\author{
  Chris Reger
}
\examples{

  dt <- data.table::data.table(
    a = 1:3, a_label = c("x", "y", "z"),
    b = 4:6, c = 7:9)
  result <- subset_vars(dt, c("a", "c"))
names(result)

}