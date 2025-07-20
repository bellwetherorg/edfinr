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
#'                 or "all" (default).
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
  
  # define all variables
  all_variables <- tibble::tibble(
    name = c(
      # variables in skinny dataset
      "ncesid", "year", "state", "dist_name", "enroll",
      "rev_total_pp", "rev_local_pp", "rev_state_pp", "rev_fed_pp",
      "rev_total", "rev_local", "rev_state", "rev_fed",
      "rev_total_unadj", "rev_local_unadj", "rev_state_unadj", "rev_fed_unadj",
      "exp_cur_pp", "rev_exp_pp_diff", "exp_cur_st_loc", "exp_cur_fed",
      "exp_cur_resa", "exp_cur_total", "cpi_sy12",
      "mhi", "mpv", "adult_pop", "ba_plus_pop", "ba_plus_pct",
      "total_pop", "student_pop", "stpov_pop", "stpov_pct",
      "cong_dist", "state_leaid", "county", "cbsa", "urbanicity",
      "schlev", "lea_type", "lea_type_id",
      
      # full dataset variables
      "exp_emp_salary", "exp_emp_bene",
      "exp_textbooks", "exp_utilities",
      "exp_tech_supp", "exp_tech_equip",
      "exp_pay_private_sch", "exp_pay_charter_sch",
      "exp_pay_other_lea", "exp_other_sys_pay",
      "exp_instr_total", "exp_instr_sal", "exp_instr_bene",
      "exp_supp_stu_total", "exp_supp_stu_sal", "exp_supp_stu_bene",
      "exp_supp_instr_total", "exp_supp_instr_sal", "exp_supp_instr_bene",
      "exp_supp_gen_admin_total", "exp_supp_gen_admin_sal", "exp_supp_gen_admin_bene",
      "exp_supp_sch_admin_total", "exp_supp_sch_admin_sal", "exp_supp_sch_admin_bene",
      "exp_supp_ops_total", "exp_supp_ops_sal", "exp_supp_ops_bene",
      "exp_supp_trans_total", "exp_supp_trans_sal", "exp_supp_trans_bene",
      "exp_central_serv_total", "exp_central_serv_sal", "exp_central_serv_bene",
      "exp_noninstr_food_total", "exp_noninstr_food_sal", "exp_noninstr_food_bene",
      "exp_noninstr_ent_ops_total", "exp_noninstr_ent_ops_bene", "exp_noninstr_other",
      "exp_covid_total", "exp_covid_instr", "exp_covid_supp", "exp_covid_cap_out",
      "exp_covid_tech_supp", "exp_covid_tech_equip", "exp_covid_supp_plant", "exp_covid_food"
    ),
    
    type = c(
      # skinny dataset types
      "character", "integer", "character", "character", "numeric",  # ncesid, year, state, dist_name, enroll
      "numeric", "numeric", "numeric", "numeric",  # rev_total_pp, rev_local_pp, rev_state_pp, rev_fed_pp
      "numeric", "numeric", "numeric", "numeric",  # rev_total, rev_local, rev_state, rev_fed
      "numeric", "numeric", "numeric", "numeric",  # rev_total_unadj, rev_local_unadj, rev_state_unadj, rev_fed_unadj
      "numeric", "numeric", "numeric", "numeric",  # exp_cur_pp, rev_exp_pp_diff, exp_cur_st_loc, exp_cur_fed
      "numeric", "numeric", "numeric",  # exp_cur_resa, exp_cur_total, cpi_sy12
      "numeric", "numeric", "numeric", "numeric", "numeric",  # mhi, mpv, adult_pop, ba_plus_pop, ba_plus_pct
      "numeric", "numeric", "numeric", "numeric",  # total_pop, student_pop, stpov_pop, stpov_pct
      "character", "character", "character", "character", "character",  # cong_dist, state_leaid, county, cbsa, urbanicity
      "character", "character", "integer",  # schlev, lea_type, lea_type_id
      # full dataset variables - all numeric
      rep("numeric", 48)
    ),
    
    category = c(
      # skinny dataset categories (in order)
      "id", "time", "geographic", "id", "demographic",  # ncesid, year, state, dist_name, enroll
      "revenue", "revenue", "revenue", "revenue",  # rev_total_pp, rev_local_pp, rev_state_pp, rev_fed_pp
      "revenue", "revenue", "revenue", "revenue",  # rev_total, rev_local, rev_state, rev_fed
      "revenue", "revenue", "revenue", "revenue",  # rev_total_unadj, rev_local_unadj, rev_state_unadj, rev_fed_unadj
      "expenditure", "expenditure", "expenditure", "expenditure",  # exp_cur_pp, rev_exp_pp_diff, exp_cur_st_loc, exp_cur_fed
      "expenditure", "expenditure", "economic",  # exp_cur_resa, exp_cur_total, cpi_sy12
      "economic", "economic", "demographic", "demographic", "demographic",  # mhi, mpv, adult_pop, ba_plus_pop, ba_plus_pct
      "demographic", "demographic", "demographic", "demographic",  # total_pop, student_pop, stpov_pop, stpov_pct
      "geographic", "id", "geographic", "geographic", "geographic",  # cong_dist, state_leaid, county, cbsa, urbanicity
      "governance", "governance", "governance",  # schlev, lea_type, lea_type_id
      # Full dataset - all expenditure
      rep("expenditure", 48)
    ),

    source = c(
      # skinny dataset sources
      rep("NCES F-33 Survey", 23),
      "BLS CPI-U",
      rep("5-Year ACS Survey", 5),
      rep("Census Bureau SAIPE", 4),
      rep("NCES CCD Directory", 8),
      # full dataset - all F-33
      rep("NCES F-33 Survey", 48)


    ),

    first_yr_avail = c(
      rep("2012", 17),
      rep("2016", 4),
      "2018",
      "2016",
      rep("2012", 18),
      rep("2012", 3),
      rep("2015", 3),
      rep("2012", 34),
      rep("2020", 6),
      rep("2021", 2)


    ),
    
    description = c(
      # skinny dataset descriptions (in order)
      "NCES district ID", "School year (end year, e.g., 2022 = 2021-2022)", "State abbreviation", 
      "District name", "Total district enrollment (V33)",
      "Total adjusted revenue per-pupil (all sources)", "Local adjusted revenue per-pupil",
      "State adjusted revenue per-pupil", "Federal adjusted revenue per-pupil",
      "Total adjusted revenue (all sources)", "Total adjusted local revenue",
      "Total adjusted state revenue", "Total adjusted federal revenue",
      "Total raw revenue (TOTALREV)", "Local raw revenue (TLOCREV)",
      "State raw revenue (TSTEREV)", "Federal raw revenue (TFEDREV)",
      "Current expenditure per-pupil (CE1 + CE2 (+ CE3 when available) divided by V33)", 
      "Revenue minus expenditure per-pupil",
      "Current expenditure from state/local sources (CE1)", "Current expenditure from federal sources (CE2)",
      "Current expenditure by RESA on behalf of LEAs (CE3)", "Total current expenditure (CE1 + CE2 (+ CE3 when available))",
      "Consumer Price Index (base year 2011-2012, calculated with HALF2 of first year and HALF 1 of second year in school year span)",
      "Median household income (B19013_001)", "Median property value (B25077_001)",
      "Adult population (B15003_001)", "Adults with bachelor's degree or higher (B15003_022 + B15003_023 + B15003_024 + B15003_025)", 
      "Percent of adults with bachelor's degree or higher",
      "Total population", "Student-aged population (5-17)",
      "Student-aged population in poverty", "Percent of students in poverty",
      "Congressional district (Formatted as numeric state code with two-digit district code e.g., '2101' = KY-01)", 
      "State-assigned LEA ID", "County name", 
      "Core Based Statistical Area", "Urbanicity (NCES categories condensed into City, Suburb, Town, Rural)",
      "LEA or school level", "LEA type description", "LEA type numeric code",
      
      # full dataset descriptions
      "Total employee salaries (Z32)", "Total employee benefits (Z34)",
      "Textbooks (V93)", "Utilities and energy services (V95)",
      "Technology-related supplies and purchased services (V02)", 
      "Technology-related equipment (K14)",
      "Payments to private schools (V91)", "Payments to charter schools (V92)", 
      "Payments to other LEAs (Q11)", "Payments to other systems (V91 + V92 + Q11)",
      "Instruction - Total (E13)", 
      "Instruction - Salaries (Z33)", 
      "Instruction - Benefits (V10)",
      "Support services, students - Total (E17)", 
      "Support services, students - Salaries (V11)", 
      "Support services, students - Benefits, (V12)",
      "Support services, instructional staff - Total (E07)",
      "Support services, instructional staff - Salaries (V13)", 
      "Support services, instructional staff - Benefits (V14)",
      "Support services, general administration - Total (E08)", 
      "Support services, general administration - Salaries (V15)", 
      "Support services, general administration - Benefits (V16)",
      "Support services, school administration - Total (E09)", 
      "Support services, school administration - Salaries (V17)", 
      "Support services, school administration - Benefits (V18)",
      "Support services, operation and maintenance of plant - Total (V40)", 
      "Support services, operation and maintenance of plant - Salaries (V21)", 
      "Support services, operation and maintenance of plant - Benefits (V22)",
      "Support services, student transportation - Total (V45)", 
      "Support services, student transportation - Salaries (V23)", 
      "Support services, student transportation - Benefits (V24)",
      "Business/central/other support services - Total (V90)", 
      "Business/central/other support services - Salaries (V37)", 
      "Business/central/other support services - Benefits (V38)",
      "Food services - Total (E11)", 
      "Food services - Salaries (V29)", 
      "Food services - Benefits (V30)",
      "Enterprise operations - Total (V60)", 
      "Enterprise operations - Benefits (V32)", 
      "Other non-instructional services (V65)",
      "COVID-19 Federal Assistance Funds - Total expenditures (AE1)", 
      "COVID-19 Federal Assistance Funds - Instructional expenditures (AE2)", 
      "COVID-19 Federal Assistance Funds - Support services expenditures (AE3)", 
      "COVID-19 Federal Assistance Funds - Capital outlay expenditures (AE4)",
      "COVID-19 Federal Assistance Funds - Technology-related supplies and purchased services expenditures (AE5)", 
      "COVID-19 Federal Assistance Funds - Technology-related equipment expenditures (AE6)", 
      "COVID-19 Federal Assistance Funds - Support services operation and maintenance of plant expenditures (AE7)", 
      "COVID-19 Federal Assistance Funds - Food services operations (AE8)"
    ),
    
    dataset = c(
      # variables in skinny dataset
      rep("skinny", 41),
      # variables only in full dataset
      rep("full", 48)
    )
  )
  
  # filter by dataset type
  if (dataset_type == "skinny") {
    variables <- dplyr::filter(all_variables, .data$dataset == "skinny")
  } else {
    # Full dataset includes all variables
    variables <- all_variables
  }
  
  # remove the dataset column before returning
  variables <- dplyr::select(variables, -.data$dataset)
  
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