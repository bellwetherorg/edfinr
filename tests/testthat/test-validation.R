# Input validation for get_finance_data(). All of these abort before any
# network access, so they are safe to run anywhere (including on CRAN).

test_that("years outside 2012-2023 are rejected", {
  expect_error(get_finance_data(yr = "2024"), "between")
  expect_error(get_finance_data(yr = "2011"), "between")
  expect_error(get_finance_data(yr = "2019:2024"), "between")
})

test_that("malformed year input is rejected", {
  expect_error(get_finance_data(yr = "abc"))
  expect_error(get_finance_data(yr = "2021:2020"), "less than or equal")
  expect_error(get_finance_data(yr = "2020:2021:2022"))
})

test_that("invalid state codes are rejected", {
  expect_error(get_finance_data(geo = "ZZ"), "Invalid state")
  expect_error(get_finance_data(geo = "KY,ZZ"), "Invalid state")
})

test_that("invalid dataset_type is rejected", {
  expect_error(get_finance_data(dataset_type = "medium"), "skinny")
})

test_that("cpi_adj must be 'none' or a year in range", {
  expect_error(get_finance_data(cpi_adj = "2024"), "between")
  expect_error(get_finance_data(cpi_adj = "abc"), "valid year")
})

test_that("vector or NA arguments produce clear package errors", {
  expect_error(get_finance_data(yr = c("2020", "2021")), "single year")
  expect_error(get_finance_data(yr = NA), "single year")
  expect_error(get_finance_data(geo = c("KY", "OH")), "state code")
  expect_error(get_finance_data(geo = NA), "state code")
  expect_error(get_finance_data(dataset_type = c("skinny", "full")), "skinny")
  expect_error(get_finance_data(cpi_adj = NA), "baseline year")
})

test_that("'all' mixed into a state list is rejected as an invalid code", {
  expect_error(get_finance_data(geo = "all,KY"), "Invalid state")
})
