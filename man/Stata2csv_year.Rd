\name{Stata2csv_year}
\alias{Stata2csv_year}
\title{
  Convert one year of NSCH data from Stata to CSV
}
\description{
  Each year of data should have one do file and one dta file.
  The non-tabular plain text do file is converted to two CSV files,
  \code{define.csv} and \code{var.csv}.
  The binary dta file is converted to one CSV file, \code{surveys.csv}.
}
\usage{
Stata2csv_year(
  year,
  Stata.path = file.path("NSCH_data", "00_original_Stata"),
  csv.path = file.path("NSCH_data", "01_original_csv"),
  verbose = FALSE)
}
\arguments{
  \item{year}{year of data to convert}
  \item{Stata.path}{
    path to directory with Stata data files to read,
    default \code{"NSCH_data/00_original_Stata"}
  }
  \item{csv.path}{
    path to directory,
    default \code{"NSCH_data/01_original_csv"},
    where a year sub-directory will be created,
    in which CSV data files will be written.
  }
  \item{verbose}{logical: print messages?}
}
\value{
  Data table with one row per CSV file written (3 rows total), and
  columns \code{in_file}, \code{out.csv}, \code{data_type}, \code{rows},
  \code{cols}. 
}
\author{
  Toby Dylan Hocking
}
\examples{

files2024 <- system.file(package="nsch", "extdata", c("datasets.2024.html", "nsch_2024_topical_Stata.zip"), mustWork=TRUE)
NSCH_data.path <- tempfile()
original_Stata.path <- file.path(NSCH_data.path, "00_original_Stata")
original_csv.path <- file.path(NSCH_data.path, "01_original_csv")
dir.create(original_Stata.path, recursive=TRUE)
file.copy(files2024, original_Stata.path)
nsch::get_year("https://www.census.gov/programs-surveys/nsch/data/datasets.2024.html", original_Stata.path)
nsch::Stata2csv_year(2024, original_Stata.path, original_csv.path, verbose = TRUE)

}
