Thank you for following these guidelines!

## Pull requests

Please avoid pushing commits directly to the main branch.
Instead, please create a new branch, push commits to that branch, then send a minimal Pull Request (PR) to main ([video demonstration](https://vimeo.com/1159760944)).
Before merging any PR, there should be one other project member that reviews and approves the proposed changes.

* Documentation should be written directly in man/*.Rd files. Examples should use the `nsch::` prefix (e.g., `nsch::read_dta()`).
* Any new functionality should have an example and test. Test files for new functions should mirror the function file name (`test-foo.R` for `R/foo.R`).
* Increase the version number in NEWS.md and DESCRIPTION, based on the current date.
* Add an item in NEWS.md to describe the changes, referencing the PR number.
* Each PR should be minimal, which means there should be one (not multiple) new feature or bug fix, so that the PR is easy to review. Please indicate in the PR title whether the PR is a bugfix, a feature, or a documentation update, etc.
* Run `R CMD build` and `R CMD check` locally before pushing. The project standard is `RCMDCHECK_ERROR_ON: note`, so all NOTEs must be resolved — new code using data.table NSE typically needs `globalVariables` declarations or `var <- NULL` in the function body.

### Stacked PRs

When a PR depends on changes from another open PR, branch the new work off the parent branch (not main), and note this clearly at the top of the PR description:

> ⚠️ Stacked PR — branches from `parent_branch` (#XX). Only files listed below are new; others belong to parent PR.

List the new files explicitly so reviewers can check the Files Changed tab without re-reviewing the parent PR's work.

## Coding style

* function arguments that are local file paths should have the `.path` suffix, like `local_html.path` and `year.do.path`.
* For general R style, see [@tdhock's R General Usage Rubric](https://docs.google.com/document/d/1W6-HdQLgHayOFXaQtscO5J5yf05G7E6KeXyiBJFcT7A/edit?tab=t.0#heading=h.pekgvy78tviz).

## Tests

* Prefer `expect_identical` over `expect_true`/`expect_equal`. For factor columns, compare the full factor object: `expect_identical(dt$col, factor(expected_values, expected_levels))`.
* Use `expect_is(x, "factor")` rather than `expect_true(is.factor(x))`, and `expect_in()` for membership rather than `expect_true(x %in% ...)`.
* Test full vectors, not indexed subsets: `expect_identical(dt$col, c("A", "B", "C"))` rather than separate `expect_equal(dt$col[1], "A")` calls.
* Use the data.table NSE idiom: `dt[year == 2016L, a1_grade]` rather than `dt[year == 2016L][["a1_grade"]]`.
* Add `var1 <- var2 <- NULL` at the top of function bodies that use data.table NSE, to avoid R CMD check NOTEs about undefined globals.
* Use named variables for test data identifiers (e.g., `imputed.hhids <- 1:3`) rather than bare numeric literals like `4:6`.
