## R CMD check results

0 errors | 0 warnings | 0 notes

* This is an update release (0.1.1 -> 0.2.0). It extends data coverage
  through FY2023, adds capital/debt/fund-balance and CWIFT variables, moves
  hosted data to per-year parquet files, and hardens the download path
  (atomic cache writes, larger download timeout).
* Checked locally with `--as-cran` on macOS (aarch64, R 4.5.1).
* The package downloads hosted data. Examples that download are wrapped in
  `\donttest{}`, tests that download are skipped on CRAN, and the vignettes
  that download data skip chunk evaluation on CRAN machines.

## Reverse dependencies

There are no reverse dependencies.
