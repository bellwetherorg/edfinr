# These tests download the hosted parquet data. They are skipped on CRAN and
# skipped (not failed) if the data cannot be reached; see helper-fetch.R.

test_that("fetched dimensions match expectations", {
  skip_on_cran()
  sk <- fetch_or_skip(yr = "all", dataset_type = "skinny")
  fu <- fetch_or_skip(yr = "all", dataset_type = "full")
  expect_equal(ncol(sk), 56)
  expect_equal(ncol(fu), 121)
  expect_equal(nrow(sk), nrow(fu))
  # yr = "all" still reads the combined file: full 2012-2023 panel
  expect_equal(nrow(fu), 192320L)
})

test_that("fetched columns and types match the dictionary", {
  skip_on_cran()
  for (dt in c("skinny", "full")) {
    d <- fetch_or_skip(yr = "all", dataset_type = dt)
    dict <- list_variables(dt)
    # names match as sets (dictionary order need not equal column order)
    expect_setequal(names(d), dict$name)
    # each variable's class matches its declared type
    fetched_type <- vapply(dict$name, function(n) class(d[[n]])[1], character(1))
    expect_equal(unname(fetched_type), dict$type)
  }
})

test_that("year is integer and 2023 is available", {
  skip_on_cran()
  d <- fetch_or_skip(yr = "2023", dataset_type = "skinny")
  expect_type(d$year, "integer")
  expect_true(all(d$year == 2023L))
  expect_gt(nrow(d), 0)
})

test_that("factor columns round-trip as factors", {
  skip_on_cran()
  d <- fetch_or_skip(yr = "2023", dataset_type = "full")
  for (col in c("urbanicity", "urbanicity_raw_cat", "lea_type")) {
    expect_s3_class(d[[col]], "factor")
  }
})

test_that("exp_cap_total_pp is present in the skinny dataset", {
  skip_on_cran()
  sk <- fetch_or_skip(yr = "2023", dataset_type = "skinny")
  expect_true("exp_cap_total_pp" %in% names(sk))
})

test_that("cpi_adj scales capital flows but leaves debt/fund stocks nominal", {
  skip_on_cran()
  raw <- fetch_or_skip(yr = "2019", dataset_type = "full", cpi_adj = "none")
  adj <- fetch_or_skip(yr = "2019", dataset_type = "full", cpi_adj = "2023")
  expect_true("cpi_adj_index" %in% names(adj))
  # capital outlay (a flow) is scaled by the adjustment index
  expect_equal(adj$exp_cap_total, raw$exp_cap_total * adj$cpi_adj_index)
  # debt and fund-balance stocks are returned nominal (unchanged)
  expect_equal(adj$debt_lt_end, raw$debt_lt_end)
  expect_equal(adj$fund_bal_bond, raw$fund_bal_bond)
})

test_that("cwift_impute_method uses only the documented labels", {
  skip_on_cran()
  d <- fetch_or_skip(yr = "all", dataset_type = "full")
  methods <- unique(d$cwift_impute_method[!is.na(d$cwift_impute_method)])
  expect_true(all(methods %in%
    c("observed", "interpolated_2019_2021", "carried_forward_2022")))
})

# --- per-year slice downloads --------------------------------------------
# The requests below pull per-year slice files and bind them; yr = "all"
# above still reads the single combined file.

test_that("a single-year slice equals the combined file filtered to that year", {
  skip_on_cran()
  slice <- fetch_or_skip(yr = "2023", dataset_type = "full")
  combined <- dplyr::filter(
    fetch_or_skip(yr = "all", dataset_type = "full"), year == 2023L
  )
  slice <- dplyr::arrange(slice, ncesid)
  combined <- dplyr::arrange(combined, ncesid)
  expect_equal(dim(slice), dim(combined))
  expect_equal(names(slice), names(combined))
  expect_equal(slice, combined)
})

test_that("a year range returns exactly those years and all their rows", {
  skip_on_cran()
  d <- fetch_or_skip(yr = "2020:2022", dataset_type = "skinny")
  expect_setequal(unique(d$year), 2020:2022)
  # per-year counts: 2020 = 16,604; 2021 = 16,637; 2022 = 16,651
  expect_equal(nrow(d), 16604L + 16637L + 16651L)
})

test_that("cpi_adj baseline outside the request is sourced then dropped", {
  skip_on_cran()
  d <- fetch_or_skip(yr = "2019", dataset_type = "full", cpi_adj = "2023")
  # only the requested year is returned (the 2023 baseline slice is dropped)
  expect_true(all(d$year == 2019L))
  expect_gt(nrow(d), 0)
  # the adjustment index is present, finite, and applied to a flow column
  expect_true("cpi_adj_index" %in% names(d))
  expect_true(all(is.finite(d$cpi_adj_index)))
  expect_true(all(is.finite(d$exp_cur_total[!is.na(d$exp_cur_total)])))
})

test_that("factor columns keep full, identical level sets after binding slices", {
  skip_on_cran()
  multi <- fetch_or_skip(yr = "2020:2022", dataset_type = "full")
  one <- fetch_or_skip(yr = "2023", dataset_type = "full")
  for (col in c("urbanicity", "urbanicity_raw_cat", "lea_type")) {
    expect_s3_class(multi[[col]], "factor")
    # every slice carries the full dictionary, so levels never drift
    expect_equal(levels(multi[[col]]), levels(one[[col]]))
  }
})

test_that("exp_cur_total (TCURELSC) covers non-ESSA-reporting states and years", {
  skip_on_cran()
  # NYC never reported the ESSA fund-type items before FY23, and FY12-15
  # predate them entirely; the TCURELSC-sourced total must cover both
  d <- fetch_or_skip(yr = "2012:2016", dataset_type = "skinny", geo = "NY")
  nyc <- d[d$ncesid == "3620580", ]
  expect_equal(nrow(nyc), 5)
  expect_true(all(is.finite(nyc$exp_cur_total)))
  expect_true(all(is.finite(nyc$exp_cur_pp)))
  # coverage: NA share should be small in every fetched year
  na_by_yr <- tapply(is.na(d$exp_cur_total), d$year, mean)
  expect_true(all(na_by_yr < 0.05))
  # the fund-type split stays NA where NY did not report it
  full <- fetch_or_skip(yr = "2016", dataset_type = "full", geo = "NY")
  expect_true(is.na(full$exp_cur_st_loc[full$ncesid == "3620580"]))
})
