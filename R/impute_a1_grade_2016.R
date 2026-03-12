impute_a1_grade_2016 <- function(combined.dt, dta.2016.path, seed = 1L) {
  a1_grade_if <- year <- NULL ## for R CMD check
  if (!("year" %in% names(combined.dt))) {
    stop("combined.dt must contain a 'year' column")
  }
  if (!("hhid" %in% names(combined.dt))) {
    stop("combined.dt must contain an 'hhid' column")
  }
  
  ## Read the raw 2016 .dta to access the imputation flag (a1_grade_if)
  ## and coarse imputed category (a1_grade_i).  These columns are not
  ## carried through harmonization, so we must read the original file.
  raw.2016 <- read_dta(dta.2016.path)
  needed <- c("hhid", "a1_grade_if", "a1_grade_i")
  if (!all(needed %in% names(raw.2016))) {
    stop("2016 .dta must contain hhid, a1_grade_if, and a1_grade_i columns")
  }
  
  imp.dt <- raw.2016[, needed, with = FALSE]
  ## a1_grade_if is numeric after read_dta (0 = not imputed, 1 = imputed;
  ## tagged NAs become sentinels 996-999).  Comparing with TRUE matches
  ## only the numeric 1 values, which is what we want.
  imputed.hhids <- imp.dt[a1_grade_if == TRUE][["hhid"]]
  
  ## Find 2016 rows in the combined data that were imputed.
  rows.2016 <- which(combined.dt[["year"]] == 2016L &
                       combined.dt[["hhid"]] %in% imputed.hhids)
  if (length(rows.2016) == 0)
    return(invisible(combined.dt))
  
  ## Mapping from coarse a1_grade_i categories (1, 2, 3) to the fine
  ## 9-category a1_grade levels used in 2017+.
  ##   1 = "Less than High School"  -> codes 1-2
  ##   2 = "High School Graduate"   -> codes 3-4
  ##   3 = "More than High School"  -> codes 5-9
  a1.groups <- list(
    "1" = c("8th grade or less", "9th-12th grade; No diploma"),
    "2" = c(
      "High School Graduate or GED Completed",
      "Completed a vocational, trade, or business school program"
    ),
    "3" = c(
      "Some College Credit, but No Degree",
      "Associate Degree (AA, AS)",
      "Bachelor's Degree (BA, BS, AB)",
      "Master's Degree (MA, MS, MSW, MBA)",
      "Doctorate (PhD, EdD) or Professional Degree (MD, DDS, DVM, JD)"
    )
  )
  
  ## Mapping from fine a1_grade labels to the 3-level higrade variable.
  fine.to.higrade <- c(
    "8th grade or less" = "Less than high school",
    "9th-12th grade; No diploma" = "Less than high school",
    "High School Graduate or GED Completed" =
      "High school (including vocational, trade, or business school)",
    "Completed a vocational, trade, or business school program" =
      "High school (including vocational, trade, or business school)",
    "Some College Credit, but No Degree" = "More than high school",
    "Associate Degree (AA, AS)" = "More than high school",
    "Bachelor's Degree (BA, BS, AB)" = "More than high school",
    "Master's Degree (MA, MS, MSW, MBA)" = "More than high school",
    "Doctorate (PhD, EdD) or Professional Degree (MD, DDS, DVM, JD)" =
      "More than high school"
  )
  
  ## Mapping from fine a1_grade labels to the 4-level higrade_tvis
  ## (a more detailed breakdown than higrade).
  fine.to.tvis <- c(
    "8th grade or less" = "Less than high school",
    "9th-12th grade; No diploma" = "Less than high school",
    "High School Graduate or GED Completed" =
      "High school (including vocational, trade, or business school)",
    "Completed a vocational, trade, or business school program" =
      "High school (including vocational, trade, or business school)",
    "Some College Credit, but No Degree" = "Some college or Associate Degree",
    "Associate Degree (AA, AS)" = "Some college or Associate Degree",
    "Bachelor's Degree (BA, BS, AB)" = "College degree or higher",
    "Master's Degree (MA, MS, MSW, MBA)" = "College degree or higher",
    "Doctorate (PhD, EdD) or Professional Degree (MD, DDS, DVM, JD)" =
      "College degree or higher"
  )
  
  ## Compute the distribution of fine a1_grade categories from non-2016
  ## rows.  These proportions are used as sampling weights to
  ## redistribute the coarse 2016 categories across fine categories.
  other.grades <- as.character(
    combined.dt[year != 2016L][["a1_grade"]])
  other.grades <- other.grades[!is.na(other.grades)]
  grade.counts <- table(other.grades)
  
  ## Build per-group weight vectors.  If a group has zero observations
  ## in non-2016 data (unlikely), fall back to uniform weights.
  group.weights <- lapply(a1.groups, function(fine.levels) {
    counts <- grade.counts[fine.levels]
    counts[is.na(counts)] <- 0
    counts <- as.numeric(counts)
    if (sum(counts) == 0)
      rep(1, length(fine.levels))
    else
      counts
  })
  
  ## Look up each 2016 imputed row's coarse group from the raw data,
  ## matching on hhid.
  imp.lookup <- imp.dt[a1_grade_if == TRUE]
  imp.lookup.key <- imp.lookup[["hhid"]]
  imp.coarse <- as.character(imp.lookup[["a1_grade_i"]][match(combined.dt[["hhid"]][rows.2016], imp.lookup.key)])
  
  ## Probabilistically assign fine categories within each coarse group.
  set.seed(seed)
  new.a1 <- character(length(rows.2016))
  for (g in names(a1.groups)) {
    idx <- which(imp.coarse == g)
    if (length(idx) > 0) {
      new.a1[idx] <- sample(
        a1.groups[[g]],
        size = length(idx),
        replace = TRUE,
        prob = group.weights[[g]]
      )
    }
  }
  
  ## Update combined.dt by reference, preserving existing factor levels.
  a1.levels <- levels(combined.dt[["a1_grade"]])
  hi.levels <- levels(combined.dt[["higrade"]])
  tvis.levels <- levels(combined.dt[["higrade_tvis"]])
  data.table::set(
    combined.dt,
    i = rows.2016,
    j = "a1_grade",
    value = factor(new.a1, levels = a1.levels)
  )
  data.table::set(
    combined.dt,
    i = rows.2016,
    j = "higrade",
    value = factor(fine.to.higrade[new.a1], levels = hi.levels)
  )
  data.table::set(
    combined.dt,
    i = rows.2016,
    j = "higrade_tvis",
    value = factor(fine.to.tvis[new.a1], levels = tvis.levels)
  )
  invisible(combined.dt)
}