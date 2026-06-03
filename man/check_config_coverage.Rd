\name{check_config_coverage}
\alias{check_config_coverage}
\title{
  Check config coverage against .do files
}
\description{
  For each year's \code{.do} file found in \code{data.path}, checks
  whether every variable in \code{config$desired_variables} is accounted
  for: either present directly in the \code{.do} file, produced by a
  rename rule, or produced by a merge rule.  Variables that cannot be
  found by any means are flagged as \code{"missing"}.  This automates
  the config audit process that should be performed whenever a new
  survey year is added.
}
\usage{
check_config_coverage(config, data.path)
}
\arguments{
  \item{config}{A config list as returned by \code{\link{read_config}}.}
  \item{data.path}{Directory containing NSCH \code{.do} files.}
}
\value{
  A \code{\link[data.table]{data.table}} with columns \code{variable}
  (character), \code{year} (integer), \code{status} (character, one of
  \code{"present"}, \code{"renamed"}, \code{"merged"}, or
  \code{"missing"}), and \code{source} (character, the original variable
  name for renamed/merged variables, or \code{NA}).
}
\author{
  Chris Reger
}
\examples{
## Create a temp directory with a minimal .do file.
test.dir <- tempfile()
dir.create(test.dir)
writeLines(c(
  'label var sc_sex "Sex of child"',
  'label define sc_sex_lab 1 "Male"',
  '    label define sc_sex_lab 2 "Female", add'
), file.path(test.dir, "nsch_2099_topical.do"))
file.create(file.path(test.dir, "nsch_2099_topical.dta"))
config <- list(
  desired_variables = c("year", "sc_sex"),
  transformations = list(
    transform = list(),
    rename_columns = list(),
    merge_columns = list()))
nsch::check_config_coverage(config, test.dir)
unlink(test.dir, recursive = TRUE)
}