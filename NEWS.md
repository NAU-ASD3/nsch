# nsch news and updates

## 2026.3.31 (PR#35)

* Config: added 2024 to `family_r` rename/transform, `sleep` merge, `hoursleep`/`hoursleep05`/`hospitaler`/`gowhensick` transforms, and `gowhensick` rename. Fixed `k5q11` 998→5 remap to preserve semantic distinction from 2024's native value 4.

## 2026.3.12 (PR#XX)

* `impute_a1_grade_2016()` redistributes coarse 2016 a1_grade imputation across fine 9-category levels using proportions from non-2016 data, and updates higrade and higrade_tvis to match.

## 2026.3.10 (PR#6)

* `read_config()` reads a JSON harmonization config and returns the parsed R list preserving the original structure.
* `validate_config()` checks structural integrity of a harmonization config and optionally cross-references against `.do` metadata.

## 2026.2.21 (PR#15)

* `apply_do_labels()` converts numeric columns to R factors using .do label definitions, maps sentinel codes 996-999 to NA, and applies _label overrides from transform_values().
* `na_tag_map` exported named integer vector shared by read_dta() and apply_do_labels().

## 2026.2.20 (PR#14)
* Renamed merge_columns config fields column_1/column_2 to column_preferred/column_fallback for clarity.
* Renamed internal merge_vars() variables (col1, col2, vec1, vec2, lab1, lab2) to descriptive dot-notation names (col.preferred, col.fallback, vec.preferred, vec.fallback, lab.preferred, lab.fallback).

## 2026.2.23 (PR#20)

* `get_years_csv()` downloads all available years of NSCH data, and converts from Stata to CSV.

## 2026.2.19 (PR#12)

* `Stata2csv_year()` converts one year of NSCH data from Stata to CSV.

## 2026.2.18 (PR#7)

* `transform_values()` remaps numeric values and creates _label columns per JSON config rules.
* `rename_vars()` renames columns (and _label companions) per JSON config rules.
* `merge_vars()` coalesces paired columns into one, removing originals.
* `subset_vars()` selects desired columns plus any _label companions.

## 2026.2.16 (PR#4)

*   `read_dta()` reads one NSCH Stata .dta file into a clean data.table with tagged NAs replaced by sentinel codes.
*   `na_tag_map` exported named integer vector mapping Stata tagged-NA letters to sentinel codes (996–999) for reuse by downstream functions.

## 2026.2.13 (PR#2)

*   `get_year()` downloads and unzips a zip file for one year of NSCH data.

## 2026.2.12 (PR#3)

*   `parse_do()` computes a list of two data tables from a Stata do file.

## 2026.1.13 (PR#1)

*   `get_nsch_index()` computes a table with one row per year of data available on the NSCH index web page.
