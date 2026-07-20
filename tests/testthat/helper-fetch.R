# Fetch the hosted data, or skip the test if the data cannot be reached
# (e.g., offline, or the S3 object is not yet published). Expectations placed
# after the fetch still run, so genuine regressions (wrong dims/types) fail.
fetch_or_skip <- function(...) {
  tryCatch(
    get_finance_data(..., quiet = TRUE),
    error = function(e) {
      testthat::skip(paste0("Hosted data not reachable: ", conditionMessage(e)))
    }
  )
}
