\name{harmonize_year}
\alias{harmonize_year}
\title{
  Harmonize one year of NSCH data
}
\description{
  Convenience wrapper that applies the full per-year harmonization
  sequence to a single year's raw \code{\link[data.table]{data.table}}:
  \code{\link{transform_values}} \enc{→}{->}
  \code{\link{rename_vars}} \enc{→}{->}
  \code{\link{merge_vars}} \enc{→}{->}
  \code{\link{subset_vars}} \enc{→}{->}
  \code{\link{apply_do_labels}}.

  Extracts the sub-elements from
  \code{config$transformations} and \code{config$desired_variables}
  internally.  This is the function called by the full pipeline for
  each year, and is also exported for custom pipelines.
}
\usage{
harmonize_year(dt, config, year, define.dt)
}
\arguments{
  \item{dt}{
    A \code{\link[data.table]{data.table}} of raw numeric survey data
    for a single year, as returned by \code{\link{read_dta}}.
  }
  \item{config}{
    The parsed harmonization config list returned by
    \code{\link{read_config}}.  Must contain
    \code{$desired_variables} (character vector) and
    \code{$transformations} (with sub-elements \code{$transform},
    \code{$rename_columns}, \code{$merge_columns}).
  }
  \item{year}{
    Integer survey year (e.g. \code{2016L}).
  }
  \item{define.dt}{
    A \code{\link[data.table]{data.table}} of factor-level definitions
    for this year, as returned by \code{\link{parse_do}()$define}.
  }
}
\value{
  A harmonized \code{\link[data.table]{data.table}} containing only the
  desired variables, with factor labels applied.  Columns not in
  \code{config$desired_variables} are dropped.
}
\author{
  Chris Reger
}