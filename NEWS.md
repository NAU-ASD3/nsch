# nsch news and updates

## 2026.2.18 (PR#7)

* `transform_values()` remaps numeric values and creates _label columns per JSON config rules.
* `rename_vars()` renames columns (and _label companions) per JSON config rules.
* `merge_vars()` coalesces paired columns into one, removing originals.
* `subset_vars()` selects desired columns plus any _label companions.

## 2026.2.17 (PR#6)

* `read_config()` reads a JSON harmonization config and returns the
  parsed R list preserving the original structure.
* `validate_config()` checks structural integrity of a harmonization
  config and optionally cross-references against `.do` metadata.

## 2026.2.16 (PR#5)

* `read_dta()` reads one NSCH Stata .dta file into a clean data.table
  with tagged NAs replaced by sentinel codes.

## 2026.2.13 (PR#2)

* `get_year()` downloads and unzips a zip file for one year of NSCH data.

## 2026.2.12 (PR#3)

* `parse_do()` computes a list of two data tables from a Stata do file.

## 2026.1.13 (PR#1)

* `get_nsch_index()` computes a table with one row per year of data available on the NSCH index web page.
