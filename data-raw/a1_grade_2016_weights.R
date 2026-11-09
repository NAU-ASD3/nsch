## Build inst/extdata/a1_grade_2016_weights.csv, the sampling weights that
## impute_a1_grade_2016() uses.
##
## In 2016 Census imputed missing a1_grade into three coarse groups only.
## impute_a1_grade_2016() assigns each of those rows a detailed category
## within its group, weighted by how often each category occurs among
## respondents whose a1_grade was itself imputed (a1_grade_if = 1) in
## 2017-2022, the years the original analysis used. The years are fixed so
## that 2016's values don't depend on which years a build includes.
##
## Usage, from the package root, with the raw Stata files in one folder:
##   Rscript data-raw/a1_grade_2016_weights.R <folder with the .dta files>

args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 1L) stop("usage: Rscript data-raw/a1_grade_2016_weights.R <data folder>")
years <- 2017:2022
files <- nsch::get_all_years(data.path = args[1], years = years)
if (!identical(sort(files[["year"]]), years)) {
  stop("need the .dta and .do files for every year in 2017-2022")
}

weights <- data.frame(
  code = 1:9,
  group = c(1L, 1L, 2L, 2L, 3L, 3L, 3L, 3L, 3L),
  label = c(
    "8th grade or less",
    "9th-12th grade; No diploma",
    "High School Graduate or GED Completed",
    "Completed a vocational, trade, or business school program",
    "Some College Credit, but no Degree",
    "Associate Degree (AA, AS)",
    "Bachelor's Degree (BA, BS, AB)",
    "Master's Degree (MA, MS, MSW, MBA)",
    "Doctorate (PhD, EdD) or Professional Degree (MD, DDS, DVM, JD)"
  ),
  n = 0L
)
all.n <- integer(9)

## The config relabels some a1_grade codes in every year (the .do wording
## varies); the harmonized label is the config's when it has one, otherwise
## the .do's. Each year's harmonized labels must match the labels above, so a
## .do that labels the codes in a different order stops the script.
config <- nsch::read_config(system.file("extdata", "variable-config.json", package = "nsch", mustWork = TRUE))
relabel <- config[["transformations"]][["transform"]][["a1_grade"]]

for (i in seq_len(nrow(files))) {
  yr <- files[["year"]][i]
  ## The .dta files carry no value labels; the .do files hold them. Every
  ## year must label the codes 1-9, and no others, for a1_grade.
  define <- nsch::parse_do(files[["do.path"]][i])[["define"]]
  a1.define <- define[define[["variable"]] == "a1_grade" & !startsWith(define[["value"]], "."), ]
  codes <- suppressWarnings(as.numeric(a1.define[["value"]]))
  if (!identical(sort(codes), as.numeric(1:9))) {
    stop(yr, ": the .do file does not label the codes 1-9, and no others, for a1_grade")
  }
  harmonized <- a1.define[["desc"]][match(1:9, codes)]
  if (as.character(yr) %in% relabel[["years"]]) {
    relabeled <- as.numeric(relabel[["value"]])
    harmonized[relabeled] <- relabel[["new_label"]]
  }
  mismatch <- which(harmonized != weights[["label"]])
  if (length(mismatch) > 0) {
    stop(yr, ": a1_grade code ", mismatch[1], " is labeled \"", harmonized[mismatch[1]],
         "\", expected \"", weights[["label"]][mismatch[1]], "\"")
  }
  raw <- haven::read_dta(files[["dta.path"]][i], col_select = c("a1_grade", "a1_grade_if"))
  grade <- as.numeric(haven::zap_labels(raw[["a1_grade"]]))
  flag <- as.numeric(haven::zap_labels(raw[["a1_grade_if"]]))
  if (!all(flag %in% c(0, 1, NA))) stop(yr, ": a1_grade_if has values other than 0 and 1")
  imputed <- grade[!is.na(flag) & flag == 1 & !is.na(grade)]
  if (!all(imputed %in% 1:9)) stop(yr, ": an imputed a1_grade is outside 1-9")
  year.n <- tabulate(imputed, nbins = 9)
  weights[["n"]] <- weights[["n"]] + year.n
  all.n <- all.n + tabulate(grade[grade %in% 1:9], nbins = 9)
  cat(sprintf("%d: %s imputed of %s with a grade\n", yr,
              format(sum(year.n), big.mark = ","),
              format(sum(grade %in% 1:9), big.mark = ",")))
}

out.path <- file.path("inst", "extdata", "a1_grade_2016_weights.csv")
## eol = "\n" keeps the file byte-identical to nsch-py's copy on Windows too.
write.csv(weights, out.path, row.names = FALSE, eol = "\n")
cat("wrote", out.path, "\n\n")

## For the record: shares within each coarse group under this pool and under
## all respondents (the pool the package used before).
share <- function(n) ave(n, weights[["group"]], FUN = function(x) x / sum(x))
comparison <- data.frame(
  code = weights[["code"]],
  group = weights[["group"]],
  imputed.pct = round(100 * share(weights[["n"]]), 1),
  all.pct = round(100 * share(all.n), 1)
)
comparison[["difference"]] <- comparison[["imputed.pct"]] - comparison[["all.pct"]]
print(comparison, row.names = FALSE)
