\name{get_years_csv}
\alias{get_years_csv}
\title{
  Download all years and convert to CSV
}
\description{
  First runs \code{\link{get_nsch_index}} to obtain a list of currently
  available years of NSCH data. Then on eack year, we run
  \code{\link{get_year}} to 
  download the data to the \code{"00_original_Stata"} sub-directory of
  \code{data_dir}, and
  \code{\link{Stata2csv_year}} to convert to CSV in the
  \code{"01_cleanTypes_csv"} sub-directory.
}
\usage{
get_years_csv(NSCH_data.path = "NSCH_data", verbose = FALSE)
}
\arguments{
  \item{NSCH_data.path}{
    path to directory which will be created (default \code{"NSCH_data"},
    in which NSCH data will be downloaded and converted.
  }
  \item{verbose}{
    logical: emit messages about number of rows read and written?
    (passed to \code{\link{Stata2csv_year}})
  }
}
\value{
  Data table with one row per CSV file written (3 rows per year), and
  columns \code{url}, \code{year}, \code{in_file}, \code{out.csv},
  \code{data_type}, \code{rows}, \code{cols}. This meta-data is also
  written to \code{"01_cleanTypes_sizes.csv"} in the data directory.
}
\author{
Toby Dylan Hocking
}
