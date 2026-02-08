\name{parse_do}
\alias{parse_do}
\title{
  Parse NSCH do file
}
\description{
  NSCH data contain a do file for every year.
  Each file contains two pieces of information:
  variable names, and factor levels.
}
\usage{
parse_do(year.do)
}
\arguments{
  \item{year.do}{
    Path to do file.
  }
}
\value{
  \item{var}{data table with one row per variable, and columns
    \code{variable} and \code{desc}.}
  \item{define}{data table with one row per factor level, and columns
    \code{variable}, \code{value}, \code{desc}.}
}
\author{
  Toby Dylan Hocking
}
\examples{

  year.do <- system.file(package="nsch", "extdata", "nsch_2024_topical.do")
  nsch::parse_do(year.do)

}
