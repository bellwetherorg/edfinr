# edfinr 0.2.0

* **`list_variables()` gains an `f33_item` column** recording the F-33 survey
  item(s) each F-33-sourced variable is drawn from (e.g., `"F12"`,
  `"TCAPOUT / V33"`); `NA` for non-F-33 sources and edfinr-adjusted measures.
  The "Data Sources and Methodology" vignette's crosswalk table is built from
  it. Also fixes a typo in the `rev_state_unadj` description (TSTREV).
* **Documentation overhaul.** The "Basic usage" vignette is now the package's
  "Get started" page. "Capital and Facilities" and "CWIFT" moved to
  pkgdown-only articles (no longer shipped in the CRAN package), joined by
  four new articles: "Data Quality and Comparability", "COVID Relief
  Spending", "Community and Economic Context", and "Mapping School Finance
  Data". CRAN vignettes now skip evaluation on CRAN machines.
* **FY2023 data.** Coverage now extends through the 2022-23 school year (fiscal
  year 2023). `get_finance_data()` defaults to `yr = "2023"` and accepts years
  2012-2023 (including `cpi_adj` base years).
* **Capital, debt, and fund-balance variables (F-33).** Added 17 columns: total
  capital outlay (`exp_cap_total`, `exp_cap_total_pp`) and its components
  (`exp_cap_construction`, `exp_cap_land`, `exp_cap_equip_instr`,
  `exp_cap_equip_other`, `exp_cap_equip_nonspec`), interest on debt
  (`exp_debt_interest`), long/short-term debt stocks (`debt_lt_begin`,
  `debt_lt_issued`, `debt_lt_retired`, `debt_lt_end`, `debt_st_begin`,
  `debt_st_end`), and fund balances (`fund_bal_debt_svc`, `fund_bal_bond`,
  `fund_bal_other`). `exp_cap_total` and `exp_cap_total_pp` are in the skinny
  dataset; the rest are full-only. See the new "Capital and Facilities" vignette.
* **CWIFT.** Added the NCES EDGE Comparable Wage Index for Teachers: `cwift_est`,
  `cwift_se`, `cwift_imputed`, and `cwift_impute_method` (`cwift_est` and
  `cwift_imputed` are in the skinny dataset). See the new "CWIFT" vignette.
* **Additional ACS and anomaly fields (skinny).** `mean_hhi`, `gini`,
  `owner_pct`, `snap_pct`, `unemp_rate`, unadjusted per-pupil revenue
  (`rev_state_unadj_pp`, `rev_local_unadj_pp`), raw NCES locale codes
  (`urbanicity_raw`, `urbanicity_raw_cat`), and the state-revenue anomaly fields
  `osp_pct` and `c11_spike_flag`.
* **`cpi_adj` scope.** Revenue, current/capital expenditure flows,
  `exp_debt_interest`, and income variables are adjusted. Debt and fund-balance
  **stocks** (`debt_*`, `fund_bal_*`) and the **CWIFT index** are returned
  nominal (never CPI-adjusted).
* **New dictionary categories.** `list_variables()` now includes `"debt"` and
  `"cwift"` categories and lists all 121 variables (56 in the skinny dataset).
* **Behavior change: NA propagation in `exp_cur_total`.** Missing F-33 items now
  propagate to `NA` rather than being treated as zero, so totals differ from
  0.1.x for districts with incomplete reporting. Use caution comparing
  `rev_state_pp` across years alongside `c11_spike_flag`.
* **Hosted data format.** The hosted datasets are now gzip-compressed Parquet
  (read with `nanoparquet`) instead of `.rds`. This is transparent to callers.
* **Per-year downloads.** `get_finance_data()` now downloads only the requested
  year(s) -- each year is a separate hosted file of roughly 3-6 MB -- so
  single-year and short-range requests transfer far less than the full panel.
  `yr = "all"` still fetches the entire history from one combined file.

# edfinr 0.1.1

* CRAN release.

# edfinr 0.1.0

* Initial package version.
