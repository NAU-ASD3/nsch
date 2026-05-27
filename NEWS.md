# nsch news and updates

## 2026.5.21 (PR#45)

- Fixed `apply_do_labels()` failing to label columns whose names changed via `rename_vars()` or `merge_vars()`.  Added an optional `alias` parameter that maps post-rename / post-merge column names to the original variable names used in `define.dt`.  `harmonize_year()` now builds this map from the rename and merge config and passes it through.  Previously, columns like `family` (renamed from `family_r`), `diabetes` (from `k2q41a`), `eyedoctor` (from `k4q31_r`), `k4q02_r` (from `gowhensick` in 2023+), and `sleep` (merged from `hoursleep`/`hoursleep05`) ended up as raw integer codes in harmonized output instead of labeled factors, for years where the rename or merge applied.

## 2026.5.21 (PR#36)

- Config: added 2024 to `family_r` rename/transform, `sleep` merge, `hoursleep`/`hoursleep05`/`hospitaler`/`gowhensick` transforms, `family_r` value collapse, and `gowhensick` rename.
- Config: extended 998-remap transforms (`k4q20r`, `dentistvisit`, `bestforchild`, `discussopt`, `k5q11`, `k5q20_r`, `k5q21`, `k5q31_r`, `k5q40`, `k5q41`, `k5q42`, `k5q43`, `k5q44`) to include 2024 — these were previously scoped to 2016-2023, causing 2024 logical-skip respondents to incorrectly fall through to NA in the harmonized output instead of receiving their override factor level.
- Fixed `k5q11` 998→5 remap to avoid colliding with native value 4 ("It was not possible to get a referral") that has existed since 2018.

## 2026.5.14 (PR#43)

- Fixed `read_dta()` silently dropping the data.table over-allocation (truelength) by using base R `[[<-` assignment to coerce the `year` column to integer.  The lost over-allocation caused downstream `set()` calls in `transform_values()` to hit a function-boundary reallocation issue: new `_label` companion columns were visible inside the function but not to the caller, so `apply_do_labels()` received a data.table without them.  This produced `NA` for every config entry with a value remap and `new_label` (k4q20r, dentistvisit, bestforchild, discussopt, k5q11, k5q20_r, k5q21, k5q31_r, k5q40, k5q41, k5q42, k5q43, k5q44).  Replaced `[[<-` with `data.table::set()` which preserves truelength.

## 2026.4.27 (PR#34)

- `get_all_years()` discovers NSCH .dta and .do files in a data directory, returning a data.table mapping each year to its file paths.
- `get_clean_data()` runs the full harmonization pipeline: read, transform, rename, merge, subset, label, combine, and optionally impute 2016 a1_grade.

## 2026.3.14 (PR#26)

- `combine_years()` row-binds a list of per-year data.tables into a single combined dataset with validation for year columns and duplicate detection.

## 2026.3.13 (PR#25)

- `harmonize_year()` convenience wrapper applying the full per-year harmonization sequence: transform_values → rename_vars → merge_vars → subset_vars → apply_do_labels. \## 2026.3.12 (PR#27)

- `impute_a1_grade_2016()` redistributes coarse 2016 a1_grade imputation across fine 9-category levels using proportions from non-2016 data, and updates higrade and higrade_tvis to match.

## 2026.3.10 (PR#6)

- `read_config()` reads a JSON harmonization config and returns the parsed R list preserving the original structure.
- `validate_config()` checks structural integrity of a harmonization config and optionally cross-references against `.do` metadata.

## 2026.2.21 (PR#15)

- `apply_do_labels()` converts numeric columns to R factors using .do label definitions, maps sentinel codes 996-999 to NA, and applies \_label overrides from `transform_values()`.
- `na_tag_map` exported named integer vector shared by `read_dta()` and `apply_do_labels()`.

## 2026.2.20 (PR#14)

- Renamed merge_columns config fields column_1/column_2 to column_preferred/column_fallback for clarity.
- Renamed internal merge_vars() variables (col1, col2, vec1, vec2, lab1, lab2) to descriptive dot-notation names (col.preferred, col.fallback, vec.preferred, vec.fallback, lab.preferred, lab.fallback).

## 2026.2.23 (PR#20)

- `get_years_csv()` downloads all available years of NSCH data, and converts from Stata to CSV.

## 2026.2.19 (PR#12)

- `Stata2csv_year()` converts one year of NSCH data from Stata to CSV.

## 2026.2.18 (PR#7)

- `transform_values()` remaps numeric values and creates \_label columns per JSON config rules.
- `rename_vars()` renames columns (and \_label companions) per JSON config rules.
- `merge_vars()` coalesces paired columns into one, removing originals.
- `subset_vars()` selects desired columns plus any \_label companions.

## 2026.2.16 (PR#4)

- `read_dta()` reads one NSCH Stata .dta file into a clean data.table with tagged NAs replaced by sentinel codes.
- `na_tag_map` exported named integer vector mapping Stata tagged-NA letters to sentinel codes (996–999) for reuse by downstream functions.

## 2026.2.13 (PR#2)

- `get_year()` downloads and unzips a zip file for one year of NSCH data.

## 2026.2.12 (PR#3)

- `parse_do()` computes a list of two data tables from a Stata do file.

## 2026.1.13 (PR#1)

- `get_nsch_index()` computes a table with one row per year of data available on the NSCH index web page.
