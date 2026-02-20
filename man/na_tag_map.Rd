\name{na_tag_map}
\alias{na_tag_map}
\title{Sentinel codes for Stata tagged NA values}
\description{
  Named integer vector mapping Stata tagged-NA letters to the
  sentinel codes used by \code{\link{read_dta}} and
  \code{\link{apply_do_labels}}.  NSCH \code{.dta} files encode
  four types of missingness as Stata tagged NAs which are
  converted to these integer codes during ingestion.
}
\usage{
na_tag_map
}
\value{
  A named integer vector of length 4:
  \code{c(m = 996L, n = 997L, l = 998L, d = 999L)}.

  \describe{
    \item{m (996)}{No valid response}
    \item{n (997)}{Not in universe}
    \item{l (998)}{Logical skip}
    \item{d (999)}{Suppressed for confidentiality}
  }
}
\examples{
  na_tag_map
  na_tag_map["m"]  ## 996
}
