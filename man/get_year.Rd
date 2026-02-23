\name{get_year}
\alias{get_year}
\title{
  Download one year of NSCH data
}
\description{
  If the input web page does not exist in the \code{data.path}
  directory, then it will be downloaded. Looks on that web page for a
  link to a topical Stata zip file, and then downloads it if it does not
  exist in the \code{data.path} directory. Finally, the contents of the
  zip file are unzipped into the \code{data.path} directory.
}
\usage{
get_year(year_url, data.path = file.path("NSCH_data", "00_original_Stata"))
}
\arguments{
  \item{year_url}{
    URL to a NSCH year-specific data web page, as returned by \code{\link{get_nsch_index}}.
  }
  \item{data.path}{
    Local path where data files will be downloaded, default \code{"NSCH_data/00_original_Stata"}.
  }
}
\value{
  Value from \code{\link{unzip}}.
}
\author{
  Toby Dylan Hocking
}
\examples{

files2024 <- system.file(
  package="nsch", "extdata",
  c("datasets.2024.html", "nsch_2024_topical_Stata.zip"),
  mustWork=TRUE)
dir2024 <- tempfile()
dir.create(dir2024)
file.copy(files2024, dir2024)
nsch::get_year(
  "https://www.census.gov/programs-surveys/nsch/data/datasets.2024.html",
  dir2024)
dir(dir2024)

}

