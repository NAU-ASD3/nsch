\name{get_nsch_index}
\alias{get_nsch_index}
\title{
  Get list of available years
}
\description{
Download and parse the NSCH index page, to obtain a list of years for
which survey data are available.
}
\usage{
get_nsch_index(local_html = tempfile())
}
\arguments{
  \item{local_html}{
Local file in which HTML will be downloaded, if it does not already exist.
}
}
\value{
data table with one row per year of data.
}
\author{
Toby Dylan Hocking
}
\examples{

get_nsch_index(system.file("extdata", "datasets.html", package="nsch"))

}
