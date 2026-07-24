# Fetch the hosted data, or skip the test if the data cannot be reached
# (e.g., offline, or the S3 object is not yet published). Only the classed
# download failure from fetch_parquet() skips; any other error (validation,
# schema mismatch, read failure) fails the test as a genuine regression.
fetch_or_skip <- function(...) {
  tryCatch(
    get_finance_data(..., quiet = TRUE),
    edfinr_download_error = function(e) {
      testthat::skip(paste0("Hosted data not reachable: ", conditionMessage(e)))
    }
  )
}
