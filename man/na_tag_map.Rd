\name{na_tag_map}
\alias{na_tag_map}
\title{
  Stata tagged NA to sentinel code mapping
}
\description{
  Named integer vector mapping the four Stata tagged-NA letters used in
  NSCH \code{.dta} files to the integer sentinel codes used inside this
  package.

  \tabular{rrl}{
    Tag \tab Code \tab Meaning \cr
    \code{.m} \tab 996 \tab No valid response \cr
    \code{.n} \tab 997 \tab Not in universe \cr
    \code{.l} \tab 998 \tab Logical skip \cr
    \code{.d} \tab 999 \tab Suppressed for confidentiality
  }
  
  These sentinel codes are a convention introduced by this package
  (originally by the predecessor script \code{data-cleanup.R}) and do
  not appear in the NSCH data or Stata files.  The highest real
  response code across all NSCH variables is 400, so values above 900
  are safe to use as sentinels.

  \code{\link{read_dta}} replaces tagged NAs with these codes at
  ingestion time so the four missingness types survive as distinct
  numeric values through the harmonization pipeline.  Downstream
  functions (e.g.\ \code{apply_do_labels}) use the same map to convert
  sentinels back to \code{NA} during factor creation.
}
\usage{
na_tag_map
}
\value{
  A named integer vector of length 4.  Names are the one-letter Stata
  tags (\code{"m"}, \code{"n"}, \code{"l"}, \code{"d"}); values are the
  corresponding sentinel codes (996, 997, 998, 999).
}
\author{
  Chris Reger
}
\examples{
nsch::na_tag_map
nsch::na_tag_map[["m"]]   ## 996
}
