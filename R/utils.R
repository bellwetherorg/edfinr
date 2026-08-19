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
#' @return A tibble with one row per variable and the columns `name`, `type`,
#'         `category`, `source`, `f33_item`, `first_yr_avail`, and `description`.
#'         `f33_item` gives the F-33 survey item(s) a variable is drawn from
#'         (e.g., "F12", "TCAPOUT / V33"); it is `NA` for variables from
#'         non-F-33 sources and for edfinr-adjusted measures (such as the
#'         adjusted revenue variables), whose construction is described in the
#'         "Data Sources and Methodology" vignette.
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
  # `f33_item` records the F-33 survey item(s) behind each F-33-sourced
  # variable (single codes for 1:1 mappings, formula strings for simple
  # combinations). It is NA for non-F-33 sources and for edfinr-adjusted
  # measures; the data-sources vignette builds its crosswalk table from this
  # column, so keep it in sync with the descriptions.
  all_variables <- tibble::tribble(
    ~name, ~type, ~category, ~source, ~f33_item, ~first_yr_avail, ~description, ~dataset,
    # --- identifiers, time, revenue (skinny) ---
    "ncesid", "character", "id", "NCES F-33 Survey", "LEAID", "2012", "NCES district ID", "skinny",
    "year", "integer", "time", "NCES F-33 Survey", "YRDATA", "2012", "School year (end year, e.g., 2023 = 2022-2023)", "skinny",
    "state", "character", "geographic", "NCES F-33 Survey", "STATE", "2012", "State abbreviation", "skinny",
    "dist_name", "character", "id", "NCES F-33 Survey", "NAME", "2012", "District name", "skinny",
    "enroll", "numeric", "demographic", "NCES F-33 Survey", "V33", "2012", "Total district enrollment (V33)", "skinny",
    "rev_total_pp", "numeric", "revenue", "NCES F-33 Survey", NA, "2012", "Total adjusted revenue per-pupil (all sources)", "skinny",
    "rev_local_pp", "numeric", "revenue", "NCES F-33 Survey", NA, "2012", "Local adjusted revenue per-pupil", "skinny",
    "rev_state_pp", "numeric", "revenue", "NCES F-33 Survey", NA, "2012", "State adjusted revenue per-pupil", "skinny",
    "rev_fed_pp", "numeric", "revenue", "NCES F-33 Survey", NA, "2012", "Federal adjusted revenue per-pupil", "skinny",
    "rev_total", "numeric", "revenue", "NCES F-33 Survey", NA, "2012", "Total adjusted revenue (all sources)", "skinny",
    "rev_local", "numeric", "revenue", "NCES F-33 Survey", NA, "2012", "Total adjusted local revenue", "skinny",
    "rev_state", "numeric", "revenue", "NCES F-33 Survey", NA, "2012", "Total adjusted state revenue", "skinny",
    "rev_fed", "numeric", "revenue", "NCES F-33 Survey", NA, "2012", "Total adjusted federal revenue", "skinny",
    "rev_total_unadj", "numeric", "revenue", "NCES F-33 Survey", "TOTALREV", "2012", "Total raw revenue (TOTALREV)", "skinny",
    "rev_local_unadj", "numeric", "revenue", "NCES F-33 Survey", "TLOCREV", "2012", "Local raw revenue (TLOCREV)", "skinny",
    "rev_state_unadj", "numeric", "revenue", "NCES F-33 Survey", "TSTREV", "2012", "State raw revenue (TSTREV)", "skinny",
    "rev_fed_unadj", "numeric", "revenue", "NCES F-33 Survey", "TFEDREV", "2012", "Federal raw revenue (TFEDREV)", "skinny",
    "rev_state_unadj_pp", "numeric", "revenue", "NCES F-33 Survey", "TSTREV / V33", "2012", "State raw (unadjusted) revenue per-pupil", "skinny",
    "rev_local_unadj_pp", "numeric", "revenue", "NCES F-33 Survey", "TLOCREV / V33", "2012", "Local raw (unadjusted) revenue per-pupil", "skinny",
    "rev_state_cap_debt", "numeric", "revenue", "NCES F-33 Survey", "C11", "2012", "State revenue for capital outlay and debt service (C11); the amount netted out of rev_state, zero-filled (not NA) for non-reporting districts", "skinny",
    # --- expenditure summary (skinny) ---
    "exp_cur_pp", "numeric", "expenditure", "NCES F-33 Survey", "TCURELSC / V33", "2012", "Current expenditure per-pupil (TCURELSC divided by V33)", "skinny",
    "exp_cap_total_pp", "numeric", "expenditure", "NCES F-33 Survey", "TCAPOUT / V33", "2012", "Total capital outlay per-pupil (TCAPOUT / enroll)", "skinny",
    "rev_exp_pp_diff", "numeric", "expenditure", "NCES F-33 Survey", NA, "2012", "Revenue minus expenditure per-pupil", "skinny",
    "exp_cur_st_loc", "numeric", "expenditure", "NCES F-33 Survey", "CE1", "2016", "Current expenditure from state/local sources (ESSA item CE1; NA where the state did not report the fund-type split)", "skinny",
    "exp_cur_fed", "numeric", "expenditure", "NCES F-33 Survey", "CE2", "2016", "Current expenditure from federal sources (ESSA item CE2; NA where the state did not report the fund-type split)", "skinny",
    "exp_cur_resa", "numeric", "expenditure", "NCES F-33 Survey", "CE3", "2018", "Current expenditure by RESA on behalf of LEAs (ESSA item CE3; NA where the state did not report the fund-type split)", "skinny",
    "exp_cur_total", "numeric", "expenditure", "NCES F-33 Survey", "TCURELSC", "2012", "Total current expenditure for elementary/secondary education (TCURELSC); the CE1/CE2/CE3 fund-type split does not sum exactly to this total", "skinny",
    "exp_cap_total", "numeric", "expenditure", "NCES F-33 Survey", "TCAPOUT", "2012", "Total capital outlay (TCAPOUT)", "skinny",
    # --- economic + demographic (skinny) ---
    "cpi_sy12", "numeric", "economic", "BLS CPI-U", NA, "2012", "Consumer Price Index (base year 2011-2012, calculated with HALF2 of first year and HALF 1 of second year in school year span)", "skinny",
    "mhi", "numeric", "economic", "5-Year ACS Survey", NA, "2012", "Median household income (B19013_001)", "skinny",
    "mean_hhi", "numeric", "economic", "5-Year ACS Survey", NA, "2012", "Mean household income (aggregate household income / households)", "skinny",
    "mpv", "numeric", "economic", "5-Year ACS Survey", NA, "2012", "Median property value (B25077_001)", "skinny",
    "adult_pop", "numeric", "demographic", "5-Year ACS Survey", NA, "2012", "Adult population (B15003_001)", "skinny",
    "ba_plus_pop", "numeric", "demographic", "5-Year ACS Survey", NA, "2012", "Adults with bachelor's degree or higher (B15003_022 + B15003_023 + B15003_024 + B15003_025)", "skinny",
    "ba_plus_pct", "numeric", "demographic", "5-Year ACS Survey", NA, "2012", "Percent of adults with bachelor's degree or higher", "skinny",
    "gini", "numeric", "demographic", "5-Year ACS Survey", NA, "2012", "Gini index of income inequality (B19083_001)", "skinny",
    "owner_pct", "numeric", "demographic", "5-Year ACS Survey", NA, "2012", "Owner-occupied share of occupied housing (B25003_002 / B25003_001)", "skinny",
    "snap_pct", "numeric", "demographic", "5-Year ACS Survey", NA, "2012", "Share of households receiving SNAP (B22003_002 / B22003_001)", "skinny",
    "unemp_rate", "numeric", "demographic", "5-Year ACS Survey", NA, "2012", "Unemployment rate (B23025_005 / B23025_003)", "skinny",
    "total_pop", "numeric", "demographic", "Census Bureau SAIPE", NA, "2012", "Total population", "skinny",
    "student_pop", "numeric", "demographic", "Census Bureau SAIPE", NA, "2012", "Student-aged population (5-17)", "skinny",
    "stpov_pop", "numeric", "demographic", "Census Bureau SAIPE", NA, "2012", "Student-aged population in poverty", "skinny",
    "stpov_pct", "numeric", "demographic", "Census Bureau SAIPE", NA, "2012", "Percent of students in poverty", "skinny",
    # --- geographic + governance (skinny) ---
    "cong_dist", "integer", "geographic", "NCES CCD Directory", NA, "2012", "Congressional district (numeric state code with two-digit district code, e.g., 2101 = KY-01)", "skinny",
    "state_leaid", "character", "id", "NCES CCD Directory", NA, "2012", "State-assigned LEA ID", "skinny",
    "county", "character", "geographic", "NCES CCD Directory", NA, "2012", "County name", "skinny",
    "cbsa", "character", "geographic", "NCES CCD Directory", NA, "2012", "Core Based Statistical Area", "skinny",
    "urbanicity_raw", "integer", "geographic", "NCES CCD Directory", NA, "2012", "Raw NCES urban-centric locale code (numeric)", "skinny",
    "urbanicity_raw_cat", "factor", "geographic", "NCES CCD Directory", NA, "2012", "Raw NCES 12-category urban-centric locale", "skinny",
    "urbanicity", "factor", "geographic", "NCES CCD Directory", NA, "2012", "Urbanicity (NCES categories condensed into City, Suburb, Town, Rural)", "skinny",
    "land_area_sq_mi", "numeric", "geographic", "Census Bureau Gazetteer", NA, "2012", "District land area in square miles (Gazetteer ALAND_SQMI; land only); NA for LEAs without a Census boundary (charters, ESAs, state-operated agencies)", "skinny",
    "s_per_sq_mi", "numeric", "geographic", "Census Bureau Gazetteer", NA, "2012", "Students per square mile (enroll / land_area_sq_mi); NA, never Inf, where land area is zero or unavailable", "skinny",
    "schlev", "character", "governance", "NCES CCD Directory", NA, "2012", "LEA or school level", "skinny",
    "lea_type", "factor", "governance", "NCES CCD Directory", NA, "2012", "LEA type description", "skinny",
    "lea_type_id", "integer", "governance", "NCES CCD Directory", NA, "2012", "LEA type numeric code", "skinny",
    # --- expenditure detail (full) ---
    "exp_emp_salary", "numeric", "expenditure", "NCES F-33 Survey", "Z32", "2012", "Total employee salaries (Z32)", "full",
    "exp_emp_bene", "numeric", "expenditure", "NCES F-33 Survey", "Z34", "2012", "Total employee benefits (Z34)", "full",
    "exp_textbooks", "numeric", "expenditure", "NCES F-33 Survey", "V93", "2012", "Textbooks (V93)", "full",
    "exp_utilities", "numeric", "expenditure", "NCES F-33 Survey", "V95", "2015", "Utilities and energy services (V95)", "full",
    "exp_tech_supp", "numeric", "expenditure", "NCES F-33 Survey", "V02", "2015", "Technology-related supplies and purchased services (V02)", "full",
    "exp_tech_equip", "numeric", "expenditure", "NCES F-33 Survey", "K14", "2015", "Technology-related equipment (K14)", "full",
    "exp_pay_private_sch", "numeric", "expenditure", "NCES F-33 Survey", "V91", "2012", "Payments to private schools (V91)", "full",
    "exp_pay_charter_sch", "numeric", "expenditure", "NCES F-33 Survey", "V92", "2012", "Payments to charter schools (V92)", "full",
    "exp_pay_other_lea", "numeric", "expenditure", "NCES F-33 Survey", "Q11", "2012", "Payments to other LEAs (Q11)", "full",
    "exp_other_sys_pay", "numeric", "expenditure", "NCES F-33 Survey", "V91 + V92 + Q11", "2012", "Payments to other systems (V91 + V92 + Q11)", "full",
    "osp_pct", "numeric", "revenue", "NCES F-33 Survey", "(V91 + V92 + Q11) / TOTALREV", "2012", "Share of unadjusted total revenue paid to other systems (see data-quality notes)", "skinny",
    "exp_instr_total", "numeric", "expenditure", "NCES F-33 Survey", "E13", "2012", "Instruction - Total (E13)", "full",
    "exp_instr_sal", "numeric", "expenditure", "NCES F-33 Survey", "Z33", "2012", "Instruction - Salaries (Z33)", "full",
    "exp_instr_bene", "numeric", "expenditure", "NCES F-33 Survey", "V10", "2012", "Instruction - Benefits (V10)", "full",
    "exp_supp_stu_total", "numeric", "expenditure", "NCES F-33 Survey", "E17", "2012", "Support services, students - Total (E17)", "full",
    "exp_supp_stu_sal", "numeric", "expenditure", "NCES F-33 Survey", "V11", "2012", "Support services, students - Salaries (V11)", "full",
    "exp_supp_stu_bene", "numeric", "expenditure", "NCES F-33 Survey", "V12", "2012", "Support services, students - Benefits (V12)", "full",
    "exp_supp_instr_total", "numeric", "expenditure", "NCES F-33 Survey", "E07", "2012", "Support services, instructional staff - Total (E07)", "full",
    "exp_supp_instr_sal", "numeric", "expenditure", "NCES F-33 Survey", "V13", "2012", "Support services, instructional staff - Salaries (V13)", "full",
    "exp_supp_instr_bene", "numeric", "expenditure", "NCES F-33 Survey", "V14", "2012", "Support services, instructional staff - Benefits (V14)", "full",
    "exp_supp_gen_admin_total", "numeric", "expenditure", "NCES F-33 Survey", "E08", "2012", "Support services, general administration - Total (E08)", "full",
    "exp_supp_gen_admin_sal", "numeric", "expenditure", "NCES F-33 Survey", "V15", "2012", "Support services, general administration - Salaries (V15)", "full",
    "exp_supp_gen_admin_bene", "numeric", "expenditure", "NCES F-33 Survey", "V16", "2012", "Support services, general administration - Benefits (V16)", "full",
    "exp_supp_sch_admin_total", "numeric", "expenditure", "NCES F-33 Survey", "E09", "2012", "Support services, school administration - Total (E09)", "full",
    "exp_supp_sch_admin_sal", "numeric", "expenditure", "NCES F-33 Survey", "V17", "2012", "Support services, school administration - Salaries (V17)", "full",
    "exp_supp_sch_admin_bene", "numeric", "expenditure", "NCES F-33 Survey", "V18", "2012", "Support services, school administration - Benefits (V18)", "full",
    "exp_supp_ops_total", "numeric", "expenditure", "NCES F-33 Survey", "V40", "2012", "Support services, operation and maintenance of plant - Total (V40)", "full",
    "exp_supp_ops_sal", "numeric", "expenditure", "NCES F-33 Survey", "V21", "2012", "Support services, operation and maintenance of plant - Salaries (V21)", "full",
    "exp_supp_ops_bene", "numeric", "expenditure", "NCES F-33 Survey", "V22", "2012", "Support services, operation and maintenance of plant - Benefits (V22)", "full",
    "exp_supp_trans_total", "numeric", "expenditure", "NCES F-33 Survey", "V45", "2012", "Support services, student transportation - Total (V45)", "full",
    "exp_supp_trans_sal", "numeric", "expenditure", "NCES F-33 Survey", "V23", "2012", "Support services, student transportation - Salaries (V23)", "full",
    "exp_supp_trans_bene", "numeric", "expenditure", "NCES F-33 Survey", "V24", "2012", "Support services, student transportation - Benefits (V24)", "full",
    "exp_central_serv_total", "numeric", "expenditure", "NCES F-33 Survey", "V90", "2012", "Business/central/other support services - Total (V90)", "full",
    "exp_central_serv_sal", "numeric", "expenditure", "NCES F-33 Survey", "V37", "2012", "Business/central/other support services - Salaries (V37)", "full",
    "exp_central_serv_bene", "numeric", "expenditure", "NCES F-33 Survey", "V38", "2012", "Business/central/other support services - Benefits (V38)", "full",
    "exp_noninstr_food_total", "numeric", "expenditure", "NCES F-33 Survey", "E11", "2012", "Food services - Total (E11)", "full",
    "exp_noninstr_food_sal", "numeric", "expenditure", "NCES F-33 Survey", "V29", "2012", "Food services - Salaries (V29)", "full",
    "exp_noninstr_food_bene", "numeric", "expenditure", "NCES F-33 Survey", "V30", "2012", "Food services - Benefits (V30)", "full",
    "exp_noninstr_ent_ops_total", "numeric", "expenditure", "NCES F-33 Survey", "V60", "2012", "Enterprise operations - Total (V60)", "full",
    "exp_noninstr_ent_ops_bene", "numeric", "expenditure", "NCES F-33 Survey", "V32", "2012", "Enterprise operations - Benefits (V32)", "full",
    "exp_noninstr_other", "numeric", "expenditure", "NCES F-33 Survey", "V65", "2012", "Other non-instructional services (V65)", "full",
    "exp_covid_total", "numeric", "expenditure", "NCES F-33 Survey", "AE1", "2020", "COVID-19 Federal Assistance Funds - Total expenditures (AE1); NA where districts did not report the COVID items (all of NY in every year; roughly a third to half of CA districts from FY21)", "full",
    "exp_covid_instr", "numeric", "expenditure", "NCES F-33 Survey", "AE2", "2020", "COVID-19 Federal Assistance Funds - Instructional expenditures (AE2)", "full",
    "exp_covid_supp", "numeric", "expenditure", "NCES F-33 Survey", "AE3", "2020", "COVID-19 Federal Assistance Funds - Support services expenditures (AE3)", "full",
    "exp_covid_cap_out", "numeric", "expenditure", "NCES F-33 Survey", "AE4", "2020", "COVID-19 Federal Assistance Funds - Capital outlay expenditures (AE4)", "full",
    "exp_covid_tech_supp", "numeric", "expenditure", "NCES F-33 Survey", "AE5", "2020", "COVID-19 Federal Assistance Funds - Technology-related supplies and purchased services expenditures (AE5)", "full",
    "exp_covid_tech_equip", "numeric", "expenditure", "NCES F-33 Survey", "AE6", "2020", "COVID-19 Federal Assistance Funds - Technology-related equipment expenditures (AE6)", "full",
    "exp_covid_supp_plant", "numeric", "expenditure", "NCES F-33 Survey", "AE7", "2021", "COVID-19 Federal Assistance Funds - Support services operation and maintenance of plant expenditures (AE7)", "full",
    "exp_covid_food", "numeric", "expenditure", "NCES F-33 Survey", "AE8", "2021", "COVID-19 Federal Assistance Funds - Food services operations (AE8)", "full",
    # --- capital outlay detail (full) ---
    "exp_cap_construction", "numeric", "expenditure", "NCES F-33 Survey", "F12", "2012", "Construction (F12)", "full",
    "exp_cap_land", "numeric", "expenditure", "NCES F-33 Survey", "G15", "2012", "Land and existing structures (G15)", "full",
    "exp_cap_equip_instr", "numeric", "expenditure", "NCES F-33 Survey", "K09", "2012", "Instructional equipment (K09)", "full",
    "exp_cap_equip_other", "numeric", "expenditure", "NCES F-33 Survey", "K10", "2012", "Other equipment (K10)", "full",
    "exp_cap_equip_nonspec", "numeric", "expenditure", "NCES F-33 Survey", "K11", "2012", "Nonspecified equipment (K11)", "full",
    "exp_debt_interest", "numeric", "expenditure", "NCES F-33 Survey", "I86", "2012", "Interest on school-system debt (I86)", "full",
    # --- debt stocks and fund balances (full; nominal under cpi_adj) ---
    "debt_lt_begin", "numeric", "debt", "NCES F-33 Survey", "_19H", "2012", "Long-term debt outstanding, start of FY (_19H)", "full",
    "debt_lt_issued", "numeric", "debt", "NCES F-33 Survey", "_21F", "2012", "Long-term debt issued during FY (_21F)", "full",
    "debt_lt_retired", "numeric", "debt", "NCES F-33 Survey", "_31F", "2012", "Long-term debt retired during FY (_31F)", "full",
    "debt_lt_end", "numeric", "debt", "NCES F-33 Survey", "_41F", "2012", "Long-term debt outstanding, end of FY (_41F)", "full",
    "debt_st_begin", "numeric", "debt", "NCES F-33 Survey", "_61V", "2012", "Short-term debt outstanding, start of FY (_61V)", "full",
    "debt_st_end", "numeric", "debt", "NCES F-33 Survey", "_66V", "2012", "Short-term debt outstanding, end of FY (_66V)", "full",
    "fund_bal_debt_svc", "numeric", "debt", "NCES F-33 Survey", "W01", "2012", "Debt service fund cash and investments, FYE (W01); NA where flagged unreported", "full",
    "fund_bal_bond", "numeric", "debt", "NCES F-33 Survey", "W31", "2012", "Bond fund cash and investments, FYE (W31); NA where flagged unreported", "full",
    "fund_bal_other", "numeric", "debt", "NCES F-33 Survey", "W61", "2012", "Other funds cash and investments, FYE (W61); NA where flagged unreported", "full",
    # --- CWIFT (cwift_est/cwift_imputed in skinny; cwift_se/cwift_impute_method full) ---
    "cwift_est", "numeric", "cwift", "NCES EDGE (CWIFT)", NA, "2015", "Comparable Wage Index for Teachers estimate (LEA_CWIFTEST)", "skinny",
    "cwift_se", "numeric", "cwift", "NCES EDGE (CWIFT)", NA, "2015", "Standard error of the CWIFT estimate (approximate for interpolated years)", "full",
    "cwift_imputed", "logical", "cwift", "NCES EDGE (CWIFT)", NA, "2015", "TRUE if the CWIFT value is imputed (interpolated or carried forward)", "skinny",
    "cwift_impute_method", "character", "cwift", "NCES EDGE (CWIFT)", NA, "2015", "CWIFT imputation method: observed / interpolated_2019_2021 / carried_forward_2022", "full",
    # --- state-revenue adjustment anomaly flag (skinny) ---
    "c11_spike_flag", "logical", "revenue", "NCES F-33 Survey", NA, "2012", "TRUE where the C11 state-revenue adjustment produces an anomalous spike", "skinny"
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

  # filter by category if requested, rejecting unknown categories so a typo
  # (e.g. "expenditures") errors instead of silently returning zero rows
  if (category != "all") {
    valid_categories <- unique(all_variables$category)
    if (!category %in% valid_categories) {
      cli::cli_abort(c(
        "Unknown category {.val {category}}.",
        "i" = "category must be \"all\" or one of: {.val {valid_categories}}."
      ))
    }
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
