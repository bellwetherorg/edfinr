# These tests download the hosted parquet data. They are skipped on CRAN and
# skipped (not failed) if the data cannot be reached; see helper-fetch.R.

test_that("fetched dimensions match expectations", {
  skip_on_cran()
  sk <- fetch_or_skip(yr = "all", dataset_type = "skinny")
  fu <- fetch_or_skip(yr = "all", dataset_type = "full")
  expect_equal(ncol(sk), 56)
  expect_equal(ncol(fu), 121)
  expect_equal(nrow(sk), nrow(fu))
  expect_gt(nrow(fu), 190000)
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
