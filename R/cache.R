#' Set up local cache directory for the package
#'
#' @return Path to the cache directory
#' @keywords internal
#'
cache_path <- function() {
  # Use R's temporary directory for CRAN compliance
  # This ensures we don't write to user's home directory
  cache_dir <- file.path(tempdir(), "edfinr_cache")
  if (!dir.exists(cache_dir)) {
    dir.create(cache_dir, recursive = TRUE)
  }
  cache_dir
}

#' Get cache file path
#'
#' @param name Name of the cache file
#' @return Full path to the cache file
#' @keywords internal
#'
cache_file <- function(name) {
  file.path(cache_path(), name)
}

#' Check if a cached file exists and is recent
#'
#' @param name Name of the cache file
#' @param max_age Maximum age in days
#' @return TRUE if cache file exists and is recent, FALSE otherwise
#' @keywords internal
#'
is_cache_current <- function(name, max_age = 30) {
  cache_file_path <- cache_file(name)

  if (!file.exists(cache_file_path)) {
    return(FALSE)
  }

  # Check if file is older than max_age days
  file_age <- difftime(Sys.time(), file.mtime(cache_file_path), units = "days")
  return(file_age < max_age)
}

#' Download (with retries) and read a hosted parquet file
#'
#' Downloads `url` to the package cache when the cached copy is missing, stale,
#' or `refresh` is TRUE, then reads it with nanoparquet. The cache file name is
#' derived from `basename(url)` so the download target and cache key never drift.
#' Downloads go to a temporary file that is renamed into the cache only on
#' success, so an interrupted transfer can never leave a partial file that a
#' later call would treat as a current cache entry. `download.file()`'s timeout
#' is a cap on the whole transfer, and R's default of 60 seconds is too short
#' for the combined multi-year files on slow connections, so the timeout is
#' temporarily raised to at least 600 seconds (a user-set higher
#' `options(timeout = )` is respected). The terminal failure abort carries the
#' condition class `edfinr_download_error` so callers (and the test suite) can
#' distinguish download failures from other errors.
#' Progress/success messaging is left to the caller so a multi-file fetch reports
#' once for the whole set rather than once per file; only retry warnings and the
#' terminal failure abort are emitted here.
#'
#' @param url Full URL to a hosted parquet file.
#' @param refresh Logical; force a re-download even if the cache is current.
#' @param quiet Logical; suppress retry warnings and download warnings.
#' @return The parquet contents as read by [nanoparquet::read_parquet()].
#' @keywords internal
#'
fetch_parquet <- function(url, refresh = FALSE, quiet = FALSE) {
  cache_name <- basename(url)
  cache_file_path <- cache_file(cache_name)

  if (refresh || !is_cache_current(cache_name)) {
    tmp_path <- tempfile(pattern = cache_name, tmpdir = cache_path())
    on.exit(unlink(tmp_path), add = TRUE)

    old_timeout <- options(timeout = max(600, getOption("timeout")))
    on.exit(options(old_timeout), add = TRUE)

    download_success <- FALSE
    max_attempts <- 3
    attempt <- 1

    while (!download_success && attempt <= max_attempts) {
      tryCatch({
        withCallingHandlers(
          utils::download.file(url, tmp_path, mode = "wb", quiet = quiet),
          warning = function(w) {
            if (quiet) invokeRestart("muffleWarning")
          }
        )
        download_success <- TRUE
      }, error = function(e) {
        unlink(tmp_path)
        if (attempt < max_attempts) {
          if (!quiet) {
            cli::cli_alert_warning("Download attempt {attempt} failed. Retrying...")
          }
          Sys.sleep(2^(attempt - 1))  # backoff between attempts: 1s, 2s
        } else {
          cli::cli_abort(c(
            "Failed to download education finance data after {max_attempts} attempts.",
            "x" = "Error: {e$message}",
            "i" = "Check your internet connection and try again.",
            "i" = "On slow connections, raise the download timeout with options(timeout = ).",
            "i" = "If the problem persists, the data source may be temporarily unavailable."
          ), class = "edfinr_download_error")
        }
      })
      attempt <- attempt + 1
    }

    file.rename(tmp_path, cache_file_path)
  }

  tryCatch(
    nanoparquet::read_parquet(cache_file_path),
    error = function(e) {
      # a cached file that cannot be read is useless; remove it so the next
      # call re-downloads instead of failing on the same file
      unlink(cache_file_path)
      cli::cli_abort(c(
        "Cached data file {.file {cache_name}} could not be read and was removed.",
        "x" = "Error: {e$message}",
        "i" = "Retry the call to download a fresh copy."
      ), class = "edfinr_read_error")
    }
  )
}
