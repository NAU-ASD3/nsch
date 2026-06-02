# nsch news and updates

## 2026.5.28 (PR#XX)

- Config: resolved the remaining safe label-drift cases from #50, stacked on #51. Extended year coverage to 2016–2024 on four value-remap transforms (`a2_relation`, `arrangehc`, `athomehc`, `instype`) and one pure label override (`k8q30`). For the four remap transforms, the per-year `.do` define entries confirm each remap's source value (`a2_relation` 5, `arrangehc`/`athomehc` 1, `instype` 4) appears only in years already covered, so extending the year list harmonizes the drifted labels without firing any remap in a new year. `k8q30` value 4 ("Not at all" → "Not well at all") is a same-category rewording (confirmed). Added a source value-3 label override to `k5q20_r` so native value-3 entries collapse onto the same canonical label as the existing 998 remap. Leaves `hospitaler` (co

## 2026.5.27 (PR#51)

- Config: harmonized 33 label-drift cases across 15 variables surfaced by `audit-label-drift.R`. Added new `transform` entries for `a1_grade`, `a2_grade`, `k2q35a_1_years`, `k2q35d`, and `wgtconc` to override apostrophe and capitalization drift in their year-varying `.do` labels. Extended the existing `k4q02_r` transform to cover values 1 ("Doctor's Office") and 6 ("School (Nurse's Office, Athletic Trainer's Office)") which had 2016-only apostrophe-missing variants. Extended year coverage on nine existing transforms (`birthwt`, `currins`, `hcability`, `higrade`, `higrade_tvis`, `house_gen`, `k2q01_d`, `metro_yn`, `mpc_yn`) whose label overrides were scoped to 2016-only or 2016–2018 but whose variables continue in subsequent years with different `.do` label wording. These were all pure label overrides (no value remaps), so year-list extension is safe. Remaining drift cases — partially-handled transforms that include value remaps (`a2_relation`, `arrangehc`, `athomehc`, `instype`) and substantively-different wordings (`k11q43r` 13, `k5q20_r` 3, `hospitaler` 3, `k8q30` 4) — are deferred for per-case triage in #50.

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
