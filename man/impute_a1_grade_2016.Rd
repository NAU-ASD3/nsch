\name{impute_a1_grade_2016}
\alias{impute_a1_grade_2016}
\title{
  Redistribute coarse 2016 a1_grade imputation across fine categories
}
\description{
  In 2016, Census imputed \code{a1_grade} (Adult 1's highest education
  level) into 3 coarse categories stored in \code{a1_grade_i}, rather
  than the 9 fine-grained categories used in 2017 and later.  This
  function probabilistically redistributes those coarse categories
  across the fine categories using the distribution observed in
  non-2016 data.

  For each 2016 row where \code{a1_grade_if == 1} (imputed), the
  function looks up the coarse group from \code{a1_grade_i} in the
  raw 2016 \code{.dta} file, then samples a fine \code{a1_grade}
  category using proportions computed from all non-2016 rows in
  \code{combined.dt}.  It also updates \code{higrade} and
  \code{higrade_tvis} to be consistent with the newly assigned
  \code{a1_grade} value.

  Modifies \code{combined.dt} by reference.  Uses
  \code{\link{set.seed}} for reproducibility.
}
\usage{
impute_a1_grade_2016(combined.dt, dta.2016.path, seed = 1L)
}
\arguments{
  \item{combined.dt}{
    A \code{\link[data.table]{data.table}} of combined multi-year
    survey data, as returned by \code{combine_years}.  Must
    contain columns \code{year}, \code{hhid}, \code{a1_grade},
    \code{higrade}, and \code{higrade_tvis} (all factors).
  }
  \item{dta.2016.path}{
    Path to the raw 2016 Stata \code{.dta} file.  Must contain
    columns \code{hhid}, \code{a1_grade_if} (imputation flag), and
    \code{a1_grade_i} (coarse imputed category: 1 = less than high
    school, 2 = high school graduate, 3 = more than high school).
  }
  \item{seed}{
    Integer seed passed to \code{\link{set.seed}} before sampling.
    Default \code{1L}.
  }
}
\value{
  Returns \code{combined.dt} invisibly (modified by reference).
}
\author{
  Chris Reger
}