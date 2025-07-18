#' Set up local cache directory for the package
#'
#' @return Path to the cache directory
#' @keywords internal
#'
cache_path <- function() {
  cache_dir <- rappdirs::user_cache_dir("edfinr")
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