# nsch news and updates

2026.2.20 (PR#23)

• check_factor_levels() adds validation utility to detect inconsistent factor levels across years.

## 2026.2.19 (PR#12)

* `Stata2csv_year()` converts one year of NSCH data from Stata to CSV.

## 2026.2.16 (PR#4)

-   `read_dta()` reads one NSCH Stata .dta file into a clean data.table with tagged NAs replaced by sentinel codes.
-   `na_tag_map` exported named integer vector mapping Stata tagged-NA letters to sentinel codes (996–999) for reuse by downstream functions.

## 2026.2.13 (PR#2)

-   `get_year()` downloads and unzips a zip file for one year of NSCH data.

## 2026.2.12 (PR#3)

-   `parse_do()` computes a list of two data tables from a Stata do file.

## 2026.1.13 (PR#1)

-   `get_nsch_index()` computes a table with one row per year of data available on the NSCH index web page.
