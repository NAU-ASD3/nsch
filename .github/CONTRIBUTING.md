# Contributing to the nsch Package

Coding conventions, testing standards, and design principles for this
project. Based on [Toby Hocking's R General Usage Rubric](https://docs.google.com/document/d/1W6-HdQLgHayOFXaQtscO5J5yf05G7E6KeXyiBJFcT7A/edit),
[R Packages (2e)](https://r-pkgs.org/), and the
[rOpenSci Packaging Guide](https://devguide.ropensci.org/pkg_building.html).

## Contents

1. [PR Checklist](#pr-checklist) — start here
2. [R Style](#r-style) — naming, constants, formatting, functions
3. [data.table in Package Code](#datatable-in-package-code) — NSE, by-reference
4. [Testing](#testing) — assertions, what to test
5. [Design Principles](#design-principles) — why we make the choices we do
6. [Adding a New Survey Year](#adding-a-new-survey-year) — config audit process
7. [Git and GitHub](#git-and-github) — branches, commits, CI

---

## PR Checklist

Never push directly to `main`. Create a branch, push commits there,
then open a Pull Request
([video demo](https://vimeo.com/1159760944)). PRs require review and
approval from at least one other project member before merging.

Each PR should be **minimal** — one new feature or one bug fix, so it
is easy to review. Indicate the type in the PR title (e.g., "Feature:",
"Fix:", "Docs:").

Every PR needs:

- [ ] Version bump in `DESCRIPTION` (format `YYYY.M.DD`)
- [ ] `NEWS.md` entry with PR number
- [ ] Man page (`.Rd`) with `nsch::` prefix in examples (for new exported functions)
- [ ] `export()` in `NAMESPACE`
- [ ] Tests in `tests/testthat/`
- [ ] `R CMD build` + `R CMD check` with 0 errors, 0 warnings, 0 notes

**Development order: tests → implementation → man page → NEWS.**

Most PRs should target main branch.
A stacked PR is a PR to a branch other than main.
For stacked PRs, add at the top of the description:

> ⚠️ Stacked PR — branches from `parent_branch` (#XX). Only files
> listed below are new; others belong to parent PR.

---

## R Style

### Naming

**Lowercase dot-separated names.** Nouns for variables, verbs for
functions. Use type suffixes to make types self-documenting:

- `.dt` for data.tables, `.vec` for vectors, `.list` for lists
- `.path` for local file paths (e.g., `config.path`, `year.do.path`)

```r
## Good
result.dt <- compute_summary(input.vec)
config.path <- system.file("extdata", "variable-config.json", package = "nsch")

## Bad
x <- compute_summary(y)
cp <- "path/to/config.json"
```

**Never shadow base R functions** (`c`, `mean`, `file.info`, etc.).

**Don't create single-use variables.** If a value is used once
immediately after assignment, inline it.

### Constants

**Name constants instead of repeating literals.** If you wanted to
change a value, you should only need to change it in one place.

```r
## Bad — 100 repeated
X.train <- X[1:100, ]
y.train <- y[1:100]

## Good
n.train <- 100L
X.train <- X[1:n.train, ]
y.train <- y[1:n.train]
```

### Formatting

- 2-space indentation, lines under 80 characters
- `package::function()` in R source for non-imported functions
- `nsch::function_name()` in all man page examples
- `<-` for assignment (not `=`); `TRUE`/`FALSE` (never `T`/`F`)
- Documentation written directly in `man/*.Rd` files

### Functions

- **Implicit return** — no `return()` on the final expression. Use
  `return()` only for early exits.
- **Required arguments first** (typically `dt`, then specifiers, then
  options).
- **Don't overwrite variables** with new meanings — use distinct names
  for different stages of processing.
- **Validate inputs at the top** of every exported function before any
  computation. Use `stop()` with a message that describes what went
  wrong.
- **`vapply()` over `sapply()`** in package code — `sapply()` returns
  unpredictable types.
- **Vectorize** instead of scalar loops where possible.

---

## data.table in Package Code

### NSE and R CMD check

**Use `list()` not `.()` in data.table expressions.** `.()` triggers
R CMD check NOTEs, which fail CI (`RCMDCHECK_ERROR_ON: note`).

**Declare NSE symbols** at the top of each `.R` file:

```r
year <- n.na <- n.total <- .N <- NULL
```

Every column name used in NSE and every data.table symbol (`.N`, `.SD`,
`.I`, `.GRP`) needs this declaration.

### By-Reference Modification

Functions that modify input by reference (`set()`, `setnames()`, `:=`)
should document this in the man page and return the input invisibly.
Functions that inspect data (e.g., `check_na_rates()`) must never modify
it. Functions that produce new output should not modify the input — use
`copy()` if needed.

### Idioms

- `data.table::` prefix for non-imported functions
- `dt[["col"]]` over `dt$col` — avoids partial matching
- `dt[, list(col = expr), by = group]` for readable multi-line
  expressions

---

## Testing

### Organization

One test file per function (`test-function_name.R`). Any new
functionality should have both an example and a test. Always run
`R CMD check` before pushing, not just `test_file()`.

### Assertions

**Use the most specific assertion available:**

```r
## Exact comparison (preferred)
expect_identical(result[["year"]], c(2016L, 2017L))

## Class checks — note: integer ≠ numeric
expect_is(result, "data.table")
expect_is(dt[["status"]], "factor")

## Membership
expect_in("var_name", names(result))

## Avoid weaker alternatives
expect_true(is.data.table(result))  # use expect_is instead
expect_equal(nrow(result), 2L)      # use expect_identical instead
```

### What to Test

- **Full vectors**, not indexed subsets — `expect_identical(dt[["col"]],
  expected.vec)`, not `dt$col[1]`.
- **Complete output** when practical —
  `expect_identical(dt, data.table(...))`.
- **Input validation** — `expect_error(fn(bad.input), "expected msg")`.
- **Edge cases** — empty input, all-NA columns, single-row data.
- **`tempfile()`** for temporary paths, cleaned up with `on.exit()`.

---

## Design Principles

### Accept Diverse Input, Produce Consistent Output

Be liberal in what you accept; be conservative in what you produce
([Postel's Law](https://en.wikipedia.org/wiki/Robustness_principle)).
NSCH data varies across years — the pipeline absorbs that variation and
produces a consistently structured `data.table`.

### Composability

Each function takes a `data.table` and returns a `data.table`, enabling
composition via pipe or sequential calls. One function, one job.

### Reproducibility

Same inputs and configuration must always produce identical output.
No hidden dependence on global state, working directory, or call order.

### Data Fidelity

Prefer approaches that preserve the most information. The pipeline
reads `.dta`/`.do` files directly because Stata tagged NAs (`.m`, `.n`,
`.l`, `.d`) collapse to single `NA` in CSV. See `?na_tag_map` and the
`\details` section of `?get_clean_data` for the full rationale.

### Keep Data in Memory

Pipeline functions compose in memory, passing data through function
arguments rather than files. Intermediate steps should not write to
disk — users who want to audit intermediate results can write them
between calls. File I/O belongs at pipeline boundaries, not inside
transformation functions.

### Package Scope

The package handles harmonization. Derived columns, study-specific
joins, and threshold-based filtering belong in analysis scripts.

---

## Adding a New Survey Year

1. **Check variable names** — names change between years (e.g., 2024
   uses `gowhensick` not `k4q02_r`). Verify every `desired_variable`
   has a rename/merge rule.
2. **Check for new response values** — e.g., 2024 added "Urgent Care
   Center" (value 8) to `gowhensick`. Decide whether to remap.
3. **Check for semantic shifts** — the same numeric value can change
   meaning across years. Document in GitHub issues.
4. **Update the config** — add the new year to relevant `transform`,
   `rename_columns`, and `merge_columns` entries.
5. **Verify sentinel safety** — confirm the new `.do` file doesn't use
   values 996–999 as real response codes.
6. **Run `check_config_coverage()`** to verify all variables are
   accounted for.

---

## Git and GitHub

### Workflow

- Branch from `main`: `feature-name` or `fix-description`
- Present-tense commit messages: `"add check_na_rates stub and export"`
- Follow stub → tests → implementation → man → NEWS per commit

### CI

GitHub Actions runs `R CMD check` on macOS, Ubuntu (release + devel),
and Windows. NOTEs are treated as errors.

### Review

- Respond to all review comments
- Use GitHub's suggested changes for small fixes
- Re-request review after addressing feedback
- On stacked PRs, flag which files are new in the description

---

## Further Reading

- [R Packages (2e)](https://r-pkgs.org/)
- [Tidyverse Style Guide](https://style.tidyverse.org/)
- [data.table: Importing](https://rdatatable.gitlab.io/data.table/articles/datatable-importing.html)
- [Hocking R General Usage Rubric](https://docs.google.com/document/d/1W6-HdQLgHayOFXaQtscO5J5yf05G7E6KeXyiBJFcT7A/edit)
- [Tao Te Programming](https://www.burns-stat.com/documents/books/tao-te-programming/) — Burns
