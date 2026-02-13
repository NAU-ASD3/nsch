\name{get_nsch_index}
\alias{get_nsch_index}
\title{
  Get list of available years
}
\description{
  Download and parse the NSCH index web page,
  to obtain a list of years for which survey data are available.
  We can then do a loop over years,
  to download data from each available year.
}
\usage{
get_nsch_index(local_html.path = tempfile())
}
\arguments{
  \item{local_html.path}{
    Local file in which HTML will be downloaded,
    if it does not already exist.
  }
}
\value{
  data table with one row per year of data, and columns \code{url}, \code{year}.
}
\author{
Toby Dylan Hocking
}
\examples{

get_nsch_index(system.file(package="nsch", "extdata", "datasets.html"))

}
