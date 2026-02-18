\name{read_config}
\alias{read_config}
\title{
  Read JSON harmonization config for NSCH data
}
\description{
  Reads a JSON harmonization specification file and returns the parsed
  R list with its original structure preserved.  The top-level elements
  are \code{$desired_variables} (a character vector of column names to
  retain) and \code{$transformations} (a list containing
  \code{$transform}, \code{$rename_columns}, and
  \code{$merge_columns}).

  Uses \code{\link[RJSONIO]{fromJSON}} internally.  No structural
  flattening is performed --- the returned object mirrors the JSON
  layout so users can cross-reference against the file.  See
  \code{\link{validate_config}} for structural validation.
}
\usage{
read_config(config.path)
}
\arguments{
  \item{config.path}{
    Path to a JSON config file.  The bundled default is
    \code{system.file("extdata", "variable-config.json",
    package = "nsch")}.
  }
}
\value{
  A list mirroring the JSON structure:

  \item{desired_variables}{Character vector of variable names to
    retain after harmonization.}
  \item{transformations}{A list with three sub-lists:
    \code{transform} (value and label remapping rules),
    \code{rename_columns} (column renaming rules), and
    \code{merge_columns} (column merging rules).  Each sub-list is
    keyed by variable name.}
}
\author{
  Chris Reger
}
\examples{

  config.path <- system.file(
    "extdata", "variable-config.json", package = "nsch")
  config <- nsch::read_config(config.path)
  str(config, max.level = 2)

}
