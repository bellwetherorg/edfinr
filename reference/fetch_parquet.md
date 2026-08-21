# Download (with retries) and read a hosted parquet file

Downloads `url` to the package cache when the cached copy is missing,
stale, or `refresh` is TRUE, then reads it with nanoparquet. The cache
file name is derived from `basename(url)` so the download target and
cache key never drift. Downloads go to a temporary file that is renamed
into the cache only on success, so an interrupted transfer can never
leave a partial file that a later call would treat as a current cache
entry. [`download.file()`](https://rdrr.io/r/utils/download.file.html)'s
timeout is a cap on the whole transfer, and R's default of 60 seconds is
too short for the combined multi-year files on slow connections, so the
timeout is temporarily raised to at least 600 seconds (a user-set higher
`options(timeout = )` is respected). The terminal failure abort carries
the condition class `edfinr_download_error` so callers (and the test
suite) can distinguish download failures from other errors.
Progress/success messaging is left to the caller so a multi-file fetch
reports once for the whole set rather than once per file; only retry
warnings and the terminal failure abort are emitted here.

## Usage

``` r
fetch_parquet(url, refresh = FALSE, quiet = FALSE)
```

## Arguments

- url:

  Full URL to a hosted parquet file.

- refresh:

  Logical; force a re-download even if the cache is current.

- quiet:

  Logical; suppress retry warnings and download warnings.

## Value

The parquet contents as read by
[`nanoparquet::read_parquet()`](https://nanoparquet.r-lib.org/reference/read_parquet.html).
