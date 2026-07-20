#' List available variables in the education finance dataset
#'
#' This function provides information about the variables available
#' in the education finance dataset, including their names, types,
#' and brief descriptions.
#'
#' @importFrom rlang .data
#'
#' @param dataset_type A string specifying whether to list variables for "skinny" (default) or "full" dataset.
#' @param category Optional. Filter variables by category: "id", "time", "geographic",
#'                 "demographic", "revenue", "expenditure", "economic", "governance",
#'                 "debt", "cwift", or "all" (default).
#' @return A tibble with variable information
#' @export
#'
#' @examples
#' # list all available variables in skinny dataset
#' vars <- list_variables()
#' head(vars)
#'
#' # list all variables in full dataset
#' full_vars <- list_variables(dataset_type = "full")
#' nrow(full_vars)
#'
#' # list only expenditure variables in full dataset
#' exp_vars <- list_variables(dataset_type = "full", category = "expenditure")
#' head(exp_vars)
list_variables <- function(dataset_type = "skinny", category = "all") {
  # validate dataset_type parameter
  if (!dataset_type %in% c("skinny", "full")) {
    cli::cli_abort("dataset_type must be either 'skinny' or 'full'.")
  }

  # define all variables (one row per variable, in full-dataset column order).
  # the `dataset` column tags membership; the skinny dataset is the subset
  # tagged "skinny". types match what get_finance_data() returns (year is
  # coerced to integer on read; urbanicity/urbanicity_raw_cat/lea_type are
  # factors as round-tripped from parquet).
  all_variables <- tibble::tribble(
    ~name, ~type, ~category, ~source, ~first_yr_avail, ~description, ~dataset,
    # --- identifiers, time, revenue (skinny) ---
    "ncesid", "character", "id", "NCES F-33 Survey", "2012", "NCES district ID", "skinny",
    "year", "integer", "time", "NCES F-33 Survey", "2012", "School year (end year, e.g., 2023 = 2022-2023)", "skinny",
    "state", "character", "geographic", "NCES F-33 Survey", "2012", "State abbreviation", "skinny",
    "dist_name", "character", "id", "NCES F-33 Survey", "2012", "District name", "skinny",
    "enroll", "numeric", "demographic", "NCES F-33 Survey", "2012", "Total district enrollment (V33)", "skinny",
    "rev_total_pp", "numeric", "revenue", "NCES F-33 Survey", "2012", "Total adjusted revenue per-pupil (all sources)", "skinny",
    "rev_local_pp", "numeric", "revenue", "NCES F-33 Survey", "2012", "Local adjusted revenue per-pupil", "skinny",
    "rev_state_pp", "numeric", "revenue", "NCES F-33 Survey", "2012", "State adjusted revenue per-pupil", "skinny",
    "rev_fed_pp", "numeric", "revenue", "NCES F-33 Survey", "2012", "Federal adjusted revenue per-pupil", "skinny",
    "rev_total", "numeric", "revenue", "NCES F-33 Survey", "2012", "Total adjusted revenue (all sources)", "skinny",
    "rev_local", "numeric", "revenue", "NCES F-33 Survey", "2012", "Total adjusted local revenue", "skinny",
    "rev_state", "numeric", "revenue", "NCES F-33 Survey", "2012", "Total adjusted state revenue", "skinny",
    "rev_fed", "numeric", "revenue", "NCES F-33 Survey", "2012", "Total adjusted federal revenue", "skinny",
    "rev_total_unadj", "numeric", "revenue", "NCES F-33 Survey", "2012", "Total raw revenue (TOTALREV)", "skinny",
    "rev_local_unadj", "numeric", "revenue", "NCES F-33 Survey", "2012", "Local raw revenue (TLOCREV)", "skinny",
    "rev_state_unadj", "numeric", "revenue", "NCES F-33 Survey", "2012", "State raw revenue (TSTEREV)", "skinny",
    "rev_fed_unadj", "numeric", "revenue", "NCES F-33 Survey", "2012", "Federal raw revenue (TFEDREV)", "skinny",
    "rev_state_unadj_pp", "numeric", "revenue", "NCES F-33 Survey", "2012", "State raw (unadjusted) revenue per-pupil", "skinny",
    "rev_local_unadj_pp", "numeric", "revenue", "NCES F-33 Survey", "2012", "Local raw (unadjusted) revenue per-pupil", "skinny",
    # --- expenditure summary (skinny) ---
    "exp_cur_pp", "numeric", "expenditure", "NCES F-33 Survey", "2016", "Current expenditure per-pupil (CE1 + CE2 (+ CE3 when available) divided by V33)", "skinny",
    "exp_cap_total_pp", "numeric", "expenditure", "NCES F-33 Survey", "2012", "Total capital outlay per-pupil (TCAPOUT / enroll)", "skinny",
    "rev_exp_pp_diff", "numeric", "expenditure", "NCES F-33 Survey", "2016", "Revenue minus expenditure per-pupil", "skinny",
    "exp_cur_st_loc", "numeric", "expenditure", "NCES F-33 Survey", "2016", "Current expenditure from state/local sources (CE1)", "skinny",
    "exp_cur_fed", "numeric", "expenditure", "NCES F-33 Survey", "2016", "Current expenditure from federal sources (CE2)", "skinny",
    "exp_cur_resa", "numeric", "expenditure", "NCES F-33 Survey", "2018", "Current expenditure by RESA on behalf of LEAs (CE3)", "skinny",
    "exp_cur_total", "numeric", "expenditure", "NCES F-33 Survey", "2016", "Total current expenditure (CE1 + CE2 (+ CE3 when available))", "skinny",
    "exp_cap_total", "numeric", "expenditure", "NCES F-33 Survey", "2012", "Total capital outlay (TCAPOUT)", "skinny",
    # --- economic + demographic (skinny) ---
    "cpi_sy12", "numeric", "economic", "BLS CPI-U", "2012", "Consumer Price Index (base year 2011-2012, calculated with HALF2 of first year and HALF 1 of second year in school year span)", "skinny",
    "mhi", "numeric", "economic", "5-Year ACS Survey", "2012", "Median household income (B19013_001)", "skinny",
    "mean_hhi", "numeric", "economic", "5-Year ACS Survey", "2012", "Mean household income (aggregate household income / households)", "skinny",
    "mpv", "numeric", "economic", "5-Year ACS Survey", "2012", "Median property value (B25077_001)", "skinny",
    "adult_pop", "numeric", "demographic", "5-Year ACS Survey", "2012", "Adult population (B15003_001)", "skinny",
    "ba_plus_pop", "numeric", "demographic", "5-Year ACS Survey", "2012", "Adults with bachelor's degree or higher (B15003_022 + B15003_023 + B15003_024 + B15003_025)", "skinny",
    "ba_plus_pct", "numeric", "demographic", "5-Year ACS Survey", "2012", "Percent of adults with bachelor's degree or higher", "skinny",
    "gini", "numeric", "demographic", "5-Year ACS Survey", "2012", "Gini index of income inequality (B19083_001)", "skinny",
    "owner_pct", "numeric", "demographic", "5-Year ACS Survey", "2012", "Owner-occupied share of occupied housing (B25003_002 / B25003_001)", "skinny",
    "snap_pct", "numeric", "demographic", "5-Year ACS Survey", "2012", "Share of households receiving SNAP (B22003_002 / B22003_001)", "skinny",
    "unemp_rate", "numeric", "demographic", "5-Year ACS Survey", "2012", "Unemployment rate (B23025_005 / B23025_003)", "skinny",
    "total_pop", "numeric", "demographic", "Census Bureau SAIPE", "2012", "Total population", "skinny",
    "student_pop", "numeric", "demographic", "Census Bureau SAIPE", "2012", "Student-aged population (5-17)", "skinny",
    "stpov_pop", "numeric", "demographic", "Census Bureau SAIPE", "2012", "Student-aged population in poverty", "skinny",
    "stpov_pct", "numeric", "demographic", "Census Bureau SAIPE", "2012", "Percent of students in poverty", "skinny",
    # --- geographic + governance (skinny) ---
    "cong_dist", "integer", "geographic", "NCES CCD Directory", "2012", "Congressional district (numeric state code with two-digit district code, e.g., 2101 = KY-01)", "skinny",
    "state_leaid", "character", "id", "NCES CCD Directory", "2012", "State-assigned LEA ID", "skinny",
    "county", "character", "geographic", "NCES CCD Directory", "2012", "County name", "skinny",
    "cbsa", "character", "geographic", "NCES CCD Directory", "2012", "Core Based Statistical Area", "skinny",
    "urbanicity_raw", "integer", "geographic", "NCES CCD Directory", "2012", "Raw NCES urban-centric locale code (numeric)", "skinny",
    "urbanicity_raw_cat", "factor", "geographic", "NCES CCD Directory", "2012", "Raw NCES 12-category urban-centric locale", "skinny",
    "urbanicity", "factor", "geographic", "NCES CCD Directory", "2012", "Urbanicity (NCES categories condensed into City, Suburb, Town, Rural)", "skinny",
    "schlev", "character", "governance", "NCES CCD Directory", "2012", "LEA or school level", "skinny",
    "lea_type", "factor", "governance", "NCES CCD Directory", "2012", "LEA type description", "skinny",
    "lea_type_id", "integer", "governance", "NCES CCD Directory", "2012", "LEA type numeric code", "skinny",
    # --- expenditure detail (full) ---
    "exp_emp_salary", "numeric", "expenditure", "NCES F-33 Survey", "2012", "Total employee salaries (Z32)", "full",
    "exp_emp_bene", "numeric", "expenditure", "NCES F-33 Survey", "2012", "Total employee benefits (Z34)", "full",
    "exp_textbooks", "numeric", "expenditure", "NCES F-33 Survey", "2012", "Textbooks (V93)", "full",
    "exp_utilities", "numeric", "expenditure", "NCES F-33 Survey", "2015", "Utilities and energy services (V95)", "full",
    "exp_tech_supp", "numeric", "expenditure", "NCES F-33 Survey", "2015", "Technology-related supplies and purchased services (V02)", "full",
    "exp_tech_equip", "numeric", "expenditure", "NCES F-33 Survey", "2015", "Technology-related equipment (K14)", "full",
    "exp_pay_private_sch", "numeric", "expenditure", "NCES F-33 Survey", "2012", "Payments to private schools (V91)", "full",
    "exp_pay_charter_sch", "numeric", "expenditure", "NCES F-33 Survey", "2012", "Payments to charter schools (V92)", "full",
    "exp_pay_other_lea", "numeric", "expenditure", "NCES F-33 Survey", "2012", "Payments to other LEAs (Q11)", "full",
    "exp_other_sys_pay", "numeric", "expenditure", "NCES F-33 Survey", "2012", "Payments to other systems (V91 + V92 + Q11)", "full",
    "osp_pct", "numeric", "revenue", "NCES F-33 Survey", "2012", "Share of unadjusted total revenue paid to other systems (see data-quality notes)", "skinny",
    "exp_instr_total", "numeric", "expenditure", "NCES F-33 Survey", "2012", "Instruction - Total (E13)", "full",
    "exp_instr_sal", "numeric", "expenditure", "NCES F-33 Survey", "2012", "Instruction - Salaries (Z33)", "full",
    "exp_instr_bene", "numeric", "expenditure", "NCES F-33 Survey", "2012", "Instruction - Benefits (V10)", "full",
    "exp_supp_stu_total", "numeric", "expenditure", "NCES F-33 Survey", "2012", "Support services, students - Total (E17)", "full",
    "exp_supp_stu_sal", "numeric", "expenditure", "NCES F-33 Survey", "2012", "Support services, students - Salaries (V11)", "full",
    "exp_supp_stu_bene", "numeric", "expenditure", "NCES F-33 Survey", "2012", "Support services, students - Benefits (V12)", "full",
    "exp_supp_instr_total", "numeric", "expenditure", "NCES F-33 Survey", "2012", "Support services, instructional staff - Total (E07)", "full",
    "exp_supp_instr_sal", "numeric", "expenditure", "NCES F-33 Survey", "2012", "Support services, instructional staff - Salaries (V13)", "full",
    "exp_supp_instr_bene", "numeric", "expenditure", "NCES F-33 Survey", "2012", "Support services, instructional staff - Benefits (V14)", "full",
    "exp_supp_gen_admin_total", "numeric", "expenditure", "NCES F-33 Survey", "2012", "Support services, general administration - Total (E08)", "full",
    "exp_supp_gen_admin_sal", "numeric", "expenditure", "NCES F-33 Survey", "2012", "Support services, general administration - Salaries (V15)", "full",
    "exp_supp_gen_admin_bene", "numeric", "expenditure", "NCES F-33 Survey", "2012", "Support services, general administration - Benefits (V16)", "full",
    "exp_supp_sch_admin_total", "numeric", "expenditure", "NCES F-33 Survey", "2012", "Support services, school administration - Total (E09)", "full",
    "exp_supp_sch_admin_sal", "numeric", "expenditure", "NCES F-33 Survey", "2012", "Support services, school administration - Salaries (V17)", "full",
    "exp_supp_sch_admin_bene", "numeric", "expenditure", "NCES F-33 Survey", "2012", "Support services, school administration - Benefits (V18)", "full",
    "exp_supp_ops_total", "numeric", "expenditure", "NCES F-33 Survey", "2012", "Support services, operation and maintenance of plant - Total (V40)", "full",
    "exp_supp_ops_sal", "numeric", "expenditure", "NCES F-33 Survey", "2012", "Support services, operation and maintenance of plant - Salaries (V21)", "full",
    "exp_supp_ops_bene", "numeric", "expenditure", "NCES F-33 Survey", "2012", "Support services, operation and maintenance of plant - Benefits (V22)", "full",
    "exp_supp_trans_total", "numeric", "expenditure", "NCES F-33 Survey", "2012", "Support services, student transportation - Total (V45)", "full",
    "exp_supp_trans_sal", "numeric", "expenditure", "NCES F-33 Survey", "2012", "Support services, student transportation - Salaries (V23)", "full",
    "exp_supp_trans_bene", "numeric", "expenditure", "NCES F-33 Survey", "2012", "Support services, student transportation - Benefits (V24)", "full",
    "exp_central_serv_total", "numeric", "expenditure", "NCES F-33 Survey", "2012", "Business/central/other support services - Total (V90)", "full",
    "exp_central_serv_sal", "numeric", "expenditure", "NCES F-33 Survey", "2012", "Business/central/other support services - Salaries (V37)", "full",
    "exp_central_serv_bene", "numeric", "expenditure", "NCES F-33 Survey", "2012", "Business/central/other support services - Benefits (V38)", "full",
    "exp_noninstr_food_total", "numeric", "expenditure", "NCES F-33 Survey", "2012", "Food services - Total (E11)", "full",
    "exp_noninstr_food_sal", "numeric", "expenditure", "NCES F-33 Survey", "2012", "Food services - Salaries (V29)", "full",
    "exp_noninstr_food_bene", "numeric", "expenditure", "NCES F-33 Survey", "2012", "Food services - Benefits (V30)", "full",
    "exp_noninstr_ent_ops_total", "numeric", "expenditure", "NCES F-33 Survey", "2012", "Enterprise operations - Total (V60)", "full",
    "exp_noninstr_ent_ops_bene", "numeric", "expenditure", "NCES F-33 Survey", "2012", "Enterprise operations - Benefits (V32)", "full",
    "exp_noninstr_other", "numeric", "expenditure", "NCES F-33 Survey", "2012", "Other non-instructional services (V65)", "full",
    "exp_covid_total", "numeric", "expenditure", "NCES F-33 Survey", "2020", "COVID-19 Federal Assistance Funds - Total expenditures (AE1)", "full",
    "exp_covid_instr", "numeric", "expenditure", "NCES F-33 Survey", "2020", "COVID-19 Federal Assistance Funds - Instructional expenditures (AE2)", "full",
    "exp_covid_supp", "numeric", "expenditure", "NCES F-33 Survey", "2020", "COVID-19 Federal Assistance Funds - Support services expenditures (AE3)", "full",
    "exp_covid_cap_out", "numeric", "expenditure", "NCES F-33 Survey", "2020", "COVID-19 Federal Assistance Funds - Capital outlay expenditures (AE4)", "full",
    "exp_covid_tech_supp", "numeric", "expenditure", "NCES F-33 Survey", "2020", "COVID-19 Federal Assistance Funds - Technology-related supplies and purchased services expenditures (AE5)", "full",
    "exp_covid_tech_equip", "numeric", "expenditure", "NCES F-33 Survey", "2020", "COVID-19 Federal Assistance Funds - Technology-related equipment expenditures (AE6)", "full",
    "exp_covid_supp_plant", "numeric", "expenditure", "NCES F-33 Survey", "2021", "COVID-19 Federal Assistance Funds - Support services operation and maintenance of plant expenditures (AE7)", "full",
    "exp_covid_food", "numeric", "expenditure", "NCES F-33 Survey", "2021", "COVID-19 Federal Assistance Funds - Food services operations (AE8)", "full",
    # --- capital outlay detail (full) ---
    "exp_cap_construction", "numeric", "expenditure", "NCES F-33 Survey", "2012", "Construction (F12)", "full",
    "exp_cap_land", "numeric", "expenditure", "NCES F-33 Survey", "2012", "Land and existing structures (G15)", "full",
    "exp_cap_equip_instr", "numeric", "expenditure", "NCES F-33 Survey", "2012", "Instructional equipment (K09)", "full",
    "exp_cap_equip_other", "numeric", "expenditure", "NCES F-33 Survey", "2012", "Other equipment (K10)", "full",
    "exp_cap_equip_nonspec", "numeric", "expenditure", "NCES F-33 Survey", "2012", "Nonspecified equipment (K11)", "full",
    "exp_debt_interest", "numeric", "expenditure", "NCES F-33 Survey", "2012", "Interest on school-system debt (I86)", "full",
    # --- debt stocks and fund balances (full; nominal under cpi_adj) ---
    "debt_lt_begin", "numeric", "debt", "NCES F-33 Survey", "2012", "Long-term debt outstanding, start of FY (_19H)", "full",
    "debt_lt_issued", "numeric", "debt", "NCES F-33 Survey", "2012", "Long-term debt issued during FY (_21F)", "full",
    "debt_lt_retired", "numeric", "debt", "NCES F-33 Survey", "2012", "Long-term debt retired during FY (_31F)", "full",
    "debt_lt_end", "numeric", "debt", "NCES F-33 Survey", "2012", "Long-term debt outstanding, end of FY (_41F)", "full",
    "debt_st_begin", "numeric", "debt", "NCES F-33 Survey", "2012", "Short-term debt outstanding, start of FY (_61V)", "full",
    "debt_st_end", "numeric", "debt", "NCES F-33 Survey", "2012", "Short-term debt outstanding, end of FY (_66V)", "full",
    "fund_bal_debt_svc", "numeric", "debt", "NCES F-33 Survey", "2012", "Debt service fund cash and investments, FYE (W01)", "full",
    "fund_bal_bond", "numeric", "debt", "NCES F-33 Survey", "2012", "Bond fund cash and investments, FYE (W31)", "full",
    "fund_bal_other", "numeric", "debt", "NCES F-33 Survey", "2012", "Other funds cash and investments, FYE (W61)", "full",
    # --- CWIFT (cwift_est/cwift_imputed in skinny; cwift_se/cwift_impute_method full) ---
    "cwift_est", "numeric", "cwift", "NCES EDGE (CWIFT)", "2015", "Comparable Wage Index for Teachers estimate (LEA_CWIFTEST)", "skinny",
    "cwift_se", "numeric", "cwift", "NCES EDGE (CWIFT)", "2015", "Standard error of the CWIFT estimate (approximate for interpolated years)", "full",
    "cwift_imputed", "logical", "cwift", "NCES EDGE (CWIFT)", "2015", "TRUE if the CWIFT value is imputed (interpolated or carried forward)", "skinny",
    "cwift_impute_method", "character", "cwift", "NCES EDGE (CWIFT)", "2015", "CWIFT imputation method: observed / interpolated_2019_2021 / carried_forward_2022", "full",
    # --- state-revenue adjustment anomaly flag (skinny) ---
    "c11_spike_flag", "logical", "revenue", "NCES F-33 Survey", "2012", "TRUE where the C11 state-revenue adjustment produces an anomalous spike", "skinny"
  )

  # filter by dataset type
  if (dataset_type == "skinny") {
    variables <- dplyr::filter(all_variables, .data$dataset == "skinny")
  } else {
    # Full dataset includes all variables
    variables <- all_variables
  }

  # remove the dataset column before returning
  variables <- dplyr::select(variables, -"dataset")

  # filter by category if requested
  if (category != "all") {
    variables <- dplyr::filter(variables, .data$category == !!category)
  }

  return(variables)
}

#' Get list of valid state codes
#'
#' Returns the valid two-letter state codes that can be used with get_finance_data
#'
#' @return A character vector of state codes
#' @export
#'
#' @examples
#' # Get all valid state codes
#' states <- get_states()
#' head(states)
get_states <- function() {
  states <- c(
    "AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "FL", "GA",
    "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA", "ME", "MD",
    "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH", "NJ",
    "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "RI", "SC",
    "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI", "WY",
    "DC"
  )

  return(states)
}
