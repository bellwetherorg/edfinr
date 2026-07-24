# The variable dictionary is static, so these tests need no network access.

test_that("dictionary has the expected number of rows", {
  expect_equal(nrow(list_variables("skinny")), 57)
  expect_equal(nrow(list_variables("full")), 122)
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

test_that("f33_item maps F-33 variables and is NA elsewhere", {
  full <- list_variables("full")
  expect_true("f33_item" %in% names(full))
  # 1:1 mappings
  expect_equal(full$f33_item[full$name == "exp_cap_construction"], "F12")
  expect_equal(full$f33_item[full$name == "debt_lt_begin"], "_19H")
  expect_equal(full$f33_item[full$name == "rev_state_unadj"], "TSTREV")
  # formula-style mappings
  expect_equal(full$f33_item[full$name == "exp_cap_total_pp"], "TCAPOUT / V33")
  # NA for non-F-33 sources and edfinr-adjusted measures
  expect_true(is.na(full$f33_item[full$name == "cwift_est"]))
  expect_true(is.na(full$f33_item[full$name == "mhi"]))
  expect_true(is.na(full$f33_item[full$name == "rev_total"]))
  # every non-NA f33_item belongs to an F-33-sourced variable
  expect_true(all(full$source[!is.na(full$f33_item)] == "NCES F-33 Survey"))
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

test_that("unknown category is rejected instead of returning zero rows", {
  expect_error(list_variables("full", category = "expenditures"), "Unknown category")
  # valid categories still filter
  expect_gt(nrow(list_variables("full", category = "expenditure")), 0)
})
