\name{validate_config}
\alias{validate_config}
\title{
  Validate a harmonization config for NSCH data
}
\description{
  Validates the structural integrity of a harmonization config as
  returned by \code{\link{read_config}}.  Checks:

  \enumerate{
    \item \code{desired_variables} is a non-empty character vector.
    \item Each \code{$transformations$transform} entry has
      equal-length \code{years}, \code{value}, \code{new_value}, and
      \code{new_label} vectors.
    \item Each \code{$transformations$rename_columns} entry has
      \code{years} and \code{new_name}.
    \item Each \code{$transformations$merge_columns} entry has
      \code{years}, \code{column_1}, and \code{column_2}.
  }

  If \code{do.list} is provided, additionally warns for any desired
  variable not found in any year's \code{.do} metadata.
}
\usage{
validate_config(config, do.list = NULL)
}
\arguments{
  \item{config}{
    A list as returned by \code{\link{read_config}}.
  }
  \item{do.list}{
    Optional named list of \code{\link{parse_do}} outputs keyed by
    year (as character, e.g. \code{"2016"}).  When supplied, the
    function cross-references \code{desired_variables} against the
    \code{$var} tables and issues a warning for each variable not
    found in any year.
  }
}
\value{
  Returns \code{TRUE} invisibly if the config is structurally valid.
  Stops with an informative error if any check fails.
}
\author{
  Chris Reger
}
\examples{

  config.path <- system.file(
    "extdata", "variable-config.json", package = "nsch")
  config <- nsch::read_config(config.path)
  nsch::validate_config(config)

}
