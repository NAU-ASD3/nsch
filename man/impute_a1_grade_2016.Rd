\name{impute_a1_grade_2016}
\alias{impute_a1_grade_2016}
\title{
  Redistribute coarse 2016 a1_grade imputation across fine categories
}
\description{
  In 2016, Census imputed \code{a1_grade} (Adult 1's highest education
  level) into 3 coarse categories stored in \code{a1_grade_i}, rather
  than the 9 fine-grained categories used in 2017 and later.

  This function cannot use the standard config-driven transform
  pipeline because it requires cross-year proportion computation
  and probabilistic redistribution — operations that the per-year
  transform/rename/merge system does not support.

  For each 2016 row where the imputation flag is set, the function
  reads the coarse group from the raw 2016 \code{.dta} file, then
  uses \code{\link{sample}} with weights derived from the non-2016
  \code{a1_grade} distribution to assign a fine category.
  Reproducible given the same \code{seed} via \code{\link{set.seed}}.

  After assigning fine \code{a1_grade} values, the function
  deterministically updates \code{higrade} (3-level) and
  \code{higrade_tvis} (4-level) to be consistent, using the same
  mappings that \code{apply_do_labels} derives from the \code{.do}
  files.

  Modifies \code{combined.dt} by reference.
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
\examples{
\dontrun{
## Requires combined multi-year data and the raw 2016 .dta file.
## Run after get_clean_data(impute.2016 = FALSE):
dta.2016.path <- "NSCH_data/00_original_Stata/nsch_2016_topical.dta"
nsch::impute_a1_grade_2016(clean.dt, dta.2016.path, seed = 1L)
}
}