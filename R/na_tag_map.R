## Named integer vector mapping Stata tagged-NA letters to sentinel codes.
## Used by read_dta() during ingestion and by apply_do_labels() when
## converting sentinels back to factor NA.
##
## NSCH .dta files encode four types of missingness as Stata tagged NAs:
## .m (no valid response) -> 996
## .n (not in universe) -> 997
## .l (logical skip) -> 998
## .d (suppressed for confidentiality) -> 999
na_tag_map <- c(m = 996L, n = 997L, l = 998L, d = 999L)
