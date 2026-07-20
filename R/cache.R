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
#' Progress/success messaging is left to the caller so a multi-file fetch reports
#' once for the whole set rather than once per file; only retry warnings and the
#' terminal failure abort are emitted here.
#'
#' @param url Full URL to a hosted parquet file.
#' @param refresh Logical; force a re-download even if the cache is current.
#' @param quiet Logical; suppress retry warnings.
#' @return The parquet contents as read by [nanoparquet::read_parquet()].
#' @keywords internal
#'
fetch_parquet <- function(url, refresh = FALSE, quiet = FALSE) {
  cache_name <- basename(url)
  cache_file_path <- cache_file(cache_name)

  if (refresh || !is_cache_current(cache_name)) {
    download_success <- FALSE
    max_attempts <- 3
    attempt <- 1

    while (!download_success && attempt <= max_attempts) {
      tryCatch({
        utils::download.file(url, cache_file_path, mode = "wb", quiet = quiet)
        download_success <- TRUE
      }, error = function(e) {
        if (attempt < max_attempts) {
          if (!quiet) {
            cli::cli_alert_warning("Download attempt {attempt} failed. Retrying...")
          }
          Sys.sleep(2^(attempt - 1))  # exponential backoff: 1s, 2s, 4s
        } else {
          cli::cli_abort(c(
            "Failed to download education finance data after {max_attempts} attempts.",
            "x" = "Error: {e$message}",
            "i" = "Check your internet connection and try again.",
            "i" = "If the problem persists, the data source may be temporarily unavailable."
          ))
        }
      })
      attempt <- attempt + 1
    }
  }

  nanoparquet::read_parquet(cache_file_path)
}