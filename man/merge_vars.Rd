\name{merge_vars}
\alias{merge_vars}
\title{
Coalesce paired columns into one
}
\description{
Coalesces paired columns into a single column, modifying \code{dt}
by reference. For each entry in \code{merges} whose \code{years}
includes \code{as.character(year)}: creates a new column (named
after the merge key) taking the value from \code{column_preferred}
where it has a real value, falling back to \code{column_fallback}.
The preferred column is considered missing when its value is
\code{NA} or matches the logical-skip sentinel \code{998} from
\code{\link{na_tag_map}} --- the sentinel \code{\link{read_nsch_dta}}
assigns when a respondent was age-routed away from a question.
Other sentinels (\code{996} no valid response, \code{997} not in
universe, \code{999} suppressed) indicate that the respondent was
in the question's universe but the response was unavailable; they
stay on the preferred path and are mapped to \code{NA} later by
\code{\link{apply_do_labels}}. Performs the same coalesce on
corresponding \code{_label} columns using the same per-row decision
so data and labels stay in sync. Removes the original source columns
after merging. Silently skips entries where source columns are
absent.
}
\usage{
merge_vars(dt, merges, year)
}
\arguments{
  \item{dt}{
    A \code{data.table} with numeric columns, as returned by
    \code{\link{read_nsch_dta}}.
  }
  \item{merges}{
    The \code{config$transformations$merge_columns} list from
    \code{\link{read_config}} --- a named list keyed by the new
    column name, each with \code{years}, \code{column_preferred},
    \code{column_fallback}.
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
  col_a = c(1, 998L, NA, 3),
  col_b = c(NA, 2, NA, 4))
merges <- list(combined = list(
  years = "2016",
  column_preferred = "col_a",
  column_fallback = "col_b"))
nsch::merge_vars(dt, merges, 2016L)
dt

}
