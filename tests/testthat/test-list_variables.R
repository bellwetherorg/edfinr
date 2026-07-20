# The variable dictionary is static, so these tests need no network access.

test_that("dictionary has the expected number of rows", {
  expect_equal(nrow(list_variables("skinny")), 56)
  expect_equal(nrow(list_variables("full")), 121)
})

test_that("new debt and cwift categories are present", {
  full <- list_variables("full")
  expect_true(all(c("debt", "cwift") %in% full$category))
  expect_equal(nrow(list_variables("full", category = "debt")), 9)
  expect_equal(nrow(list_variables("full", category = "cwift")), 4)
})

test_that("capital and cwift variables are documented with expected types", {
  full <- list_variables("full")
  expect_true("exp_cap_total" %in% full$name)
  expect_equal(full$type[full$name == "exp_cap_total"], "numeric")
  expect_equal(full$type[full$name == "exp_cap_total_pp"], "numeric")
  expect_equal(full$type[full$name == "cwift_impute_method"], "character")
  expect_equal(full$type[full$name == "cwift_imputed"], "logical")
})

test_that("debt stocks and fund balances are categorized as debt", {
  debt <- list_variables("full", category = "debt")$name
  expect_true(all(c("debt_lt_end", "fund_bal_bond", "fund_bal_other") %in% debt))
})

test_that("skinny is a strict subset of full", {
  expect_true(all(list_variables("skinny")$name %in% list_variables("full")$name))
})

test_that("the internal dataset column is not exposed", {
  expect_false("dataset" %in% names(list_variables("full")))
})

test_that("invalid dataset_type is rejected", {
  expect_error(list_variables("medium"), "skinny")
})
