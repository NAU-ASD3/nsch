\name{apply_do_labels}
\alias{apply_do_labels}
\title{Convert numeric columns to factors using Stata .do label definitions}
\description{
  Converts numeric columns in a \code{data.table} to R factors
  using label definitions from \code{\link{parse_do}()$define},
  modifying by reference.  For each variable present in both
  \code{dt} and \code{define.dt}, real value codes are mapped to
  factor levels and sentinel codes (996--999) become \code{NA}.
  If a \code{_label} companion column exists (created by
  \code{\link{transform_values}}), those labels override the
  .do-derived labels for matching rows, and the companion column
  is removed.  Columns with no matching define entries are left
  numeric, but sentinel codes are still replaced with \code{NA}.

  When a column's name in \code{dt} differs from the variable
  name in \code{define.dt} (because an upstream \code{rename_vars}
  or \code{merge_vars} step changed the column name), pass an
  \code{alias} map so labels can still be found under the
  original name.
}
\usage{
apply_do_labels(dt, define.dt, alias = list())
}
\arguments{
  \item{dt}{
    A \code{data.table} of raw numeric survey data, typically
    produced by the transform/rename/merge/subset pipeline.
  }
  \item{define.dt}{
    A \code{data.table} with columns \code{variable}, \code{value},
    and \code{desc}, as returned by \code{\link{parse_do}()$define}.
    Contains the value-to-label mapping for each survey variable.
  }
  \item{alias}{
    Optional named list mapping a column name in \code{dt} to the
    variable name to look up in \code{define.dt}.  Used by
    \code{\link{harmonize_year}} to handle columns whose names
    changed via \code{rename_vars} or \code{merge_vars}.  For
    example, \code{list(family = "family_r")} tells this function
    to label the \code{family} column using \code{family_r}'s
    define entries.  Default \code{list()} disables aliasing.
  }
}
\value{
  \code{dt} is modified by reference and returned invisibly.
  Categorical columns are converted to factors; continuous
  columns remain numeric with sentinel codes replaced by
  \code{NA}.
}
\author{
  Chris Reger
}
\examples{
  library(data.table)
  dt <- data.table(sc_sex = c(1, 2, 997))
  define.dt <- data.table(
    variable = rep("sc_sex", 5),
    value = c("1", "2", ".m", ".n", ".d"),
    desc = c("Male", "Female", "No valid response",
             "Not in universe", "Suppressed for confidentiality")
  )
  nsch::apply_do_labels(dt, define.dt)
  dt$sc_sex

  ## With alias for a renamed column:
  dt2 <- data.table(sex_renamed = c(1, 2))
  nsch::apply_do_labels(
    dt2, define.dt,
    alias = list(sex_renamed = "sc_sex"))
  dt2$sex_renamed
}