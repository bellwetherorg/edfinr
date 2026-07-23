#' Get Education Finance Data
#'
#' This function downloads tidy education finance data using data from the
#' NCES F-33 Survey, Census Bureau Small Area Income Poverty Estimates (SAIPE),
#' and community data from the ACS 5-Year Estimates.
#'
#' @importFrom rlang .data
#'
#' @param yr A string specifying the year(s) to retrieve. Can be a single year ("2023"),
#'           a range ("2020:2023"), or "all" for all available years. Defaults to "2023".
#'           Only the requested year(s) are downloaded -- each year is a separate
#'           hosted file of roughly 3-6 MB, so a single-year request transfers far
#'           less than the full panel. `yr = "all"` fetches the entire history from
#'           one combined file. When `cpi_adj` names a year outside the request, that
#'           year's file is also downloaded to source the baseline, then dropped from
#'           the returned data.
#' @param geo A string specifying the geographic scope. Can be "all" for all states (default),
#'            a single state code ("KY"), or a comma-separated list of state codes ("IN,KY,OH,TN").
#' @param dataset_type A string specifying whether to download the "skinny" (default) or "full" dataset.
#'                     The skinny version excludes detailed expenditure data for faster downloads.
#' @param cpi_adj A string specifying the CPI adjustment baseline year. Can be "none" (default)
#'                 for no adjustment, or a year between 2012-2023 to use as the baseline year.
#'                 When a year is specified (e.g., "2023"), revenue, expenditure, and economic
#'                 variables are adjusted to that school year's dollars using CPI averaged over
#'                 the months of the school year (e.g., "2023" uses the 2022-23 school year CPI).
#'                 Capital outlay and debt-interest flows are adjusted; debt and fund-balance
#'                 stocks (debt_*, fund_bal_*) and the CWIFT index are returned nominal.
#'                 When cpi_adj is set to a value other than "none", a new column "cpi_adj_index"
#'                 will be added to the output showing the adjustment index used for each row.
#' @param refresh A logical value indicating whether to force a refresh of the cached data. Default is FALSE.
#' @param quiet A logical value indicating whether to suppress download progress messages.
#'              Default is FALSE. Note: Cache is stored in R's temporary directory and will be cleared when 
#'              the R session ends.
#' @return A tibble containing the requested education finance data.
#' @export
#'
#' @examples
#' # Check valid parameters without downloading
#' get_states()  # Valid state codes
#' 
#' \donttest{
#' # These examples require internet access and may take time to download
#' 
#' # get data for Kentucky for 2022
#' ky_data <- get_finance_data(yr = "2022", geo = "KY")
#'
#' # get data for multiple years
#' ky_multi <- get_finance_data(yr = "2020:2022", geo = "KY")
#'
#' # get full dataset with detailed expenditure data
#' ky_full <- get_finance_data(yr = "2022", geo = "KY", dataset_type = "full")
#'   
#' # get data adjusted to 2022 dollars
#' ky_adjusted <- get_finance_data(yr = "2020:2022", geo = "KY", cpi_adj = "2022")
#' 
#' #' # get data for multiple states for all available years
#' regional_data <- get_finance_data(yr = "all", geo = "IN,KY,OH,TN")
#' }
get_finance_data <- function(yr = "2023", geo = "all", dataset_type = "skinny", cpi_adj = "none", refresh = FALSE, quiet = FALSE) {
  # define valid years
  valid_years <- 2012:2023

  # define valid state codes (all US states + DC)
  valid_states <- c(
    "AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "FL", "GA",
    "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA", "ME", "MD",
    "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH", "NJ",
    "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "RI", "SC",
    "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI", "WY", "DC"
  )

  # validate year parameter
  if (yr != "all") {
    if (grepl(":", yr)) {
      # validate year range
      yr_range <- strsplit(yr, ":")[[1]]
      if (length(yr_range) != 2) {
        cli::cli_abort("Year range must be in format 'start:end', e.g., '2020:2022'.")
      }

      start_yr <- suppressWarnings(as.numeric(yr_range[1]))
      end_yr <- suppressWarnings(as.numeric(yr_range[2]))

      if (is.na(start_yr) || is.na(end_yr)) {
        cli::cli_abort("Year range must contain valid numeric years.")
      }

      if (!start_yr %in% valid_years || !end_yr %in% valid_years) {
        cli::cli_abort("Years must be between {min(valid_years)} and {max(valid_years)}.")
      }

      if (start_yr > end_yr) {
        cli::cli_abort("Start year must be less than or equal to end year.")
      }
    } else {
      # validate single year
      single_yr <- suppressWarnings(as.numeric(yr))
      if (is.na(single_yr)) {
        cli::cli_abort("Year must be a valid number, a range (e.g., '2020:2022'), or 'all'.")
      }

      if (!single_yr %in% valid_years) {
        cli::cli_abort("Year must be between {min(valid_years)} and {max(valid_years)}.")
      }
    }
  }

  # validate geography parameter
  if (geo != "all") {
    states <- toupper(strsplit(geo, ",")[[1]])

    # check if all provided states are valid
    invalid_states <- states[!states %in% valid_states]
    if (length(invalid_states) > 0) {
      cli::cli_abort("Invalid state code(s): {paste(invalid_states, collapse = ', ')}.
                     State codes must be valid two-letter US state codes.")
    }
  }

  # validate dataset_type parameter
  if (!dataset_type %in% c("skinny", "full")) {
    cli::cli_abort("dataset_type must be either 'skinny' or 'full'.")
  }
  
  # validate cpi_adj parameter
  if (cpi_adj != "none") {
    cpi_year <- suppressWarnings(as.numeric(cpi_adj))
    if (is.na(cpi_year)) {
      cli::cli_abort("cpi_adj must be 'none' or a valid year between {min(valid_years)} and {max(valid_years)}.")
    }
    if (!cpi_year %in% valid_years) {
      cli::cli_abort("cpi_adj year must be between {min(valid_years)} and {max(valid_years)}.")
    }
  }

  # base url for the hosted parquet files
  base <- "https://edfinr-tidy-data.s3.us-east-2.amazonaws.com/"

  # build the set of files to fetch. yr = "all" pulls the full history from one
  # combined file; any other request pulls only the per-year slice files it
  # needs -- plus the cpi_adj baseline year's slice, which the year filter below
  # later drops -- so a single-year request downloads ~4 MB instead of ~50 MB.
  if (yr == "all") {
    urls <- paste0(base, "edfinr_data_fy12_fy23_", dataset_type, ".parquet")
  } else {
    if (grepl(":", yr)) {
      yr_range <- strsplit(yr, ":")[[1]]
      requested_years <- as.numeric(yr_range[1]):as.numeric(yr_range[2])
    } else {
      requested_years <- as.numeric(yr)
    }
    # include the cpi_adj baseline year so its cpi value is present even when it
    # falls outside the requested range (the year filter later drops it)
    fetch_years <- sort(unique(c(
      requested_years,
      if (cpi_adj != "none") as.numeric(cpi_adj)
    )))
    urls <- paste0(base, "edfinr_data_fy", fetch_years, "_", dataset_type, ".parquet")
  }

  # report progress once for the whole set (not once per file); the set is
  # "stale" if any of its files must be (re)downloaded
  any_stale <- refresh ||
    any(!vapply(urls, function(u) is_cache_current(basename(u)), logical(1)))

  if (any_stale) {
    if (!quiet) {
      cli::cli_alert_info("Downloading education finance data...")
    }
  } else if (!quiet) {
    cli::cli_alert_info("Using cached data. Use refresh = TRUE to download fresh data.")
  }

  # download (with retries) and read each file, then stack into one tibble.
  # the slices share an identical schema -- column order, types, and factor
  # levels -- so bind_rows preserves all of them without drift.
  data <- dplyr::bind_rows(
    lapply(urls, fetch_parquet, refresh = refresh, quiet = quiet)
  )

  if (any_stale && !quiet) {
    cli::cli_alert_success("Download complete.")
  }

  # convert to tibble
  if (!inherits(data, "tbl_df")) {
    data <- tibble::as_tibble(data)
  }

  # year is stored as character in the parquet; return it as integer
  data <- dplyr::mutate(data, year = as.integer(.data$year))

  # if cpi adjustment is requested, capture the baseline cpi from the full data
  # before any year/geo filtering, so the baseline year need not fall within the
  # requested year range
  baseline_cpi <- NULL
  if (cpi_adj != "none") {
    cpi_year <- as.numeric(cpi_adj)
    # cpi is national, so any row for the baseline year gives the same value
    baseline_data <- dplyr::filter(data, .data$year == cpi_year)
    if (nrow(baseline_data) == 0) {
      cli::cli_abort("No data available for the specified baseline year {cpi_year}.")
    }
    baseline_cpi <- baseline_data$cpi_sy12[1]
  }

  # process year parameter
  if (yr != "all") {
    if (grepl(":", yr)) {
      # handle year range (e.g., "2020:2022")
      yr_range <- strsplit(yr, ":")[[1]]
      start_yr <- as.numeric(yr_range[1])
      end_yr <- as.numeric(yr_range[2])
      years <- start_yr:end_yr
      data <- dplyr::filter(data, .data$year %in% years)
    } else {
      # handle single year
      data <- dplyr::filter(data, .data$year == as.numeric(yr))
    }
  }

  # process geography parameter
  if (geo != "all") {
    # handle comma-separated list of states
    states <- toupper(strsplit(geo, ",")[[1]])
    data <- dplyr::filter(data, .data$state %in% states)
  }
  
  # apply cpi adjustment if requested (baseline_cpi captured before filtering)
  if (cpi_adj != "none" && !is.null(baseline_cpi)) {
    
    # define columns to adjust
    # revenue columns (both raw and adjusted versions)
    revenue_cols <- c("rev_total_pp", "rev_local_pp", "rev_state_pp", "rev_fed_pp",
                     "rev_total", "rev_local", "rev_state", "rev_fed",
                     "rev_total_unadj", "rev_local_unadj", "rev_state_unadj", "rev_fed_unadj",
                     "rev_state_unadj_pp", "rev_local_unadj_pp", "rev_state_cap_debt")
    
    # expenditure columns (skinny dataset)
    expenditure_cols <- c("exp_cur_pp", "rev_exp_pp_diff", "exp_cur_st_loc",
                         "exp_cur_fed", "exp_cur_resa", "exp_cur_total",
                         "exp_cap_total", "exp_cap_total_pp")

    # economic columns (excluding cpi_sy12 itself)
    economic_cols <- c("mhi", "mpv", "mean_hhi")
    
    # additional expenditure columns for full dataset
    if (dataset_type == "full") {
      full_expenditure_cols <- c("exp_emp_salary", "exp_emp_bene", "exp_textbooks", 
        "exp_utilities", "exp_tech_supp", "exp_tech_equip", "exp_pay_private_sch", 
        "exp_pay_charter_sch", "exp_pay_other_lea", "exp_other_sys_pay", 
        "exp_instr_total", "exp_instr_sal", "exp_instr_bene", "exp_supp_stu_total", 
        "exp_supp_stu_sal", "exp_supp_stu_bene", "exp_supp_instr_total", 
        "exp_supp_instr_sal", "exp_supp_instr_bene", "exp_supp_gen_admin_total", 
        "exp_supp_gen_admin_sal", "exp_supp_gen_admin_bene", "exp_supp_sch_admin_total", 
        "exp_supp_sch_admin_sal", "exp_supp_sch_admin_bene", "exp_supp_ops_total", 
        "exp_supp_ops_sal", "exp_supp_ops_bene", "exp_supp_trans_total", 
        "exp_supp_trans_sal", "exp_supp_trans_bene", "exp_central_serv_total", 
        "exp_central_serv_sal", "exp_central_serv_bene", "exp_noninstr_food_total", 
        "exp_noninstr_food_sal", "exp_noninstr_food_bene", "exp_noninstr_ent_ops_total", 
        "exp_noninstr_ent_ops_bene", "exp_noninstr_other", "exp_covid_total", 
        "exp_covid_instr", "exp_covid_supp", "exp_covid_cap_out", "exp_covid_tech_supp", 
        "exp_covid_tech_equip", "exp_covid_supp_plant", "exp_covid_food",
        "exp_cap_construction", "exp_cap_land", "exp_cap_equip_instr",
        "exp_cap_equip_other", "exp_cap_equip_nonspec", "exp_debt_interest")
      expenditure_cols <- c(expenditure_cols, full_expenditure_cols)
    }
    
    # combine all columns to adjust
    cols_to_adjust <- c(revenue_cols, expenditure_cols, economic_cols)
    
    # apply cpi adjustment using mutate and across
    data <- data |>
      dplyr::mutate(
        # add the adjustment index column
        cpi_adj_index = baseline_cpi / .data$cpi_sy12,
        # apply adjustment to financial columns
        dplyr::across(
          dplyr::all_of(cols_to_adjust),
          ~ .x * cpi_adj_index
        )
      )
  }

  return(data)
}

