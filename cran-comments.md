## Test environments

* Local: macOS (aarch64, Tahoe), R 4.5.1, `R CMD check --as-cran --run-donttest`
* win-builder: R-devel and R-release
* GitHub Actions: macOS (release), Windows (release), Ubuntu (devel, release, oldrel-1)

## R CMD check results

0 errors | 0 warnings | 1 note

* The NOTE is in CRAN incoming feasibility: two nces.ed.gov URLs
  (https://nces.ed.gov/ccd/files.asp and
  https://nces.ed.gov/programs/edge/Economic/TeacherWage) are reported as
  possibly invalid with libcurl error 60. Both URLs are correct and load in
  browsers; they are authoritative citations for the package's federal data
  sources. The nces.ed.gov server currently serves an incomplete TLS
  certificate chain (the Sectigo intermediate is missing), which causes
  strict libcurl verification to fail. This is a server-side
  misconfiguration outside our control.

## Update summary

* This is an update release (0.1.1 -> 0.2.0). It extends data coverage
  through FY2023, adds capital/debt/fund-balance and CWIFT variables, moves
  hosted data to per-year parquet files, and hardens the download path
  (atomic cache writes, larger download timeout).
* New Imports dependency: nanoparquet, used to read the hosted data files,
  which moved from .rds to gzip-compressed parquet.
* The package downloads hosted data. Examples that download are wrapped in
  `\donttest{}`, tests that download are skipped on CRAN, and the vignettes
  that download data skip chunk evaluation on CRAN machines.

## Reverse dependencies

There are no reverse dependencies.
