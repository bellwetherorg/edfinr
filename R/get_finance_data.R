#' Get Education Finance Data
#'
#' This function downloads tidy education finance data using data from the
#' NCES F-33 Survey, Census Bureau Small Area Income Poverty Estimates (SAIPE),
#' and community data from the ACS 5-Year Estimates.
#'
#' #' @importFrom rlang .data
#'
#' @param yr A string specifying the year(s) to retrieve. Can be a single year ("2022"),
#'           a range ("2020:2022"), or "all" for all available years.
#' @param geo A string specifying the geographic scope. Can be "all" for all states,
#'           a single state code ("KY"), or a comma-separated list of state codes ("IN,KY,OH,TN").
#'                Default is FALSE, which uses cached data if available.
#' @param dataset_type A string specifying whether to download the "skinny" (default) or "full" dataset.
#'                     The skinny version excludes detailed expenditure data for faster downloads.
#' @param cpi_adj A string specifying the CPI adjustment baseline year. Can be "none" (default) 
#'                 for no adjustment, or a year between 2012-2022 to use as the baseline year.
#'                 When a year is specified (e.g., "2022"), revenue, expenditure, and economic 
#'                 variables are adjusted to that school year's dollars using CPI averaged over 
#'                 the months of the school year (e.g., "2022" uses the 2021-22 school year CPI).
#'                 When cpi_adj is set to a value other than "none", a new column "cpi_adj_index" 
#'                 will be added to the output showing the adjustment index used for each row.
#' @param refresh A logical value indicating whether to force a refresh of the cached data.
#' @param quiet A logical value indicating whether to suppress download progress messages.
#'              Default is FALSE.
#' @return A tibble containing the requested education finance data.
#' @export
#'
#' @examples
#' \dontrun{
#' # get data for all states for 2022
#' df <- get_finance_data(yr = "2022", geo = "all")
#'
#' # get data for Kentucky for 2020-2022
#' ky_data <- get_finance_data(yr = "2020:2022", geo = "KY")
#'
#' # get data for multiple states for all available years
#' regional_data <- get_finance_data(yr = "all", geo = "IN,KY,OH,TN")
#'
#' # get full dataset with detailed expenditure data
#' full_data <- get_finance_data(yr = "2022", geo = "KY", dataset_type = "full")
#'
#' # use with pipe
#' library(dplyr)
#' get_finance_data(yr = "2022", geo = "KY") |>
#'   select(district_name, rev_total, exp_curr_total) |>
#'   arrange(desc(rev_total))
#'   
#' # get data adjusted to 2015 dollars
#' adjusted_data <- get_finance_data(yr = "2020:2022", geo = "KY", cpi_adj = "2015")
#' }
get_finance_data <- function(yr = "2022", geo = "all", dataset_type = "skinny", cpi_adj = "none", refresh = FALSE, quiet = FALSE) {
  # define valid years (assuming 2012-2022 based on filename)
  valid_years <- 2012:2022

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
    states <- strsplit(geo, ",")[[1]]

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
      cli::cli_abort("cpi_adj must be 'none' or a valid year between 2012 and 2022.")
    }
    if (!cpi_year %in% 2012:2022) {
      cli::cli_abort("cpi_adj year must be between 2012 and 2022.")
    }
  }

  # url for the .rds file
  url_full <- "https://edfinr-tidy-data.s3.us-east-2.amazonaws.com/edfinr_data_fy12_fy22_full.rds"
  url_skinny <- "https://edfinr-tidy-data.s3.us-east-2.amazonaws.com/edfinr_data_fy12_fy22_skinny.rds"

  # select URL based on dataset_type
  url <- if (dataset_type == "full") url_full else url_skinny

  # cache handling - different cache files for different dataset types
  cache_name <- paste0("edfinr_data_fy12_fy22_", dataset_type, ".rds")
  cache_file_path <- cache_file(cache_name)

  # check if we need to download the data
  download_required <- refresh || !is_cache_current(cache_name)

  if (download_required) {
    if (!quiet) {
      cli::cli_alert_info("Downloading education finance data...")
    }

    # download the file to cache
    utils::download.file(url, cache_file_path, mode = "wb", quiet = quiet)

    if (!quiet) {
      cli::cli_alert_success("Download complete.")
    }
  } else if (!quiet) {
    cli::cli_alert_info("Using cached data. Use refresh = TRUE to download fresh data.")
  }

  # read the .rds file from cache
  data <- readRDS(cache_file_path)

  # convert to tibble
  if (!inherits(data, "tbl_df")) {
    data <- tibble::as_tibble(data)
  }

  # if cpi adjustment is requested, we need to get the baseline cpi before filtering
  baseline_cpi <- NULL
  if (cpi_adj != "none") {
    cpi_year <- as.numeric(cpi_adj)
    
    # get the cpi value for the baseline year
    baseline_data <- dplyr::filter(data, .data$year == cpi_year)
    
    if (nrow(baseline_data) == 0) {
      cli::cli_abort("No data available for the specified baseline year {cpi_year}.")
    }
    # use the first cpi value as they should all be the same for a given year
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
    states <- strsplit(geo, ",")[[1]]
    data <- dplyr::filter(data, .data$state %in% states)
  }
  
  # apply cpi adjustment if requested
  if (cpi_adj != "none" && !is.null(baseline_cpi)) {
    
    # define columns to adjust
    # revenue columns (both raw and adjusted versions)
    revenue_cols <- c("rev_total_pp", "rev_local_pp", "rev_state_pp", "rev_fed_pp",
                     "rev_total", "rev_local", "rev_state", "rev_fed",
                     "rev_total_unadj", "rev_local_unadj", "rev_state_unadj", "rev_fed_unadj")
    
    # expenditure columns (skinny dataset)
    expenditure_cols <- c("exp_cur_pp", "rev_exp_pp_diff", "exp_cur_st_loc", 
                         "exp_cur_fed", "exp_cur_resa", "exp_cur_total")
    
    # economic columns (excluding cpi_sy12 itself)
    economic_cols <- c("mhi", "mpv")
    
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
        "exp_supp_opps_sal", "exp_supp_opps_bene", "exp_supp_trans_total", 
        "exp_supp_trans_sal", "exp_supp_trans_bene", "exp_central_serv_total", 
        "exp_central_serv_sal", "exp_central_serv_bene", "exp_noninstr_food_total", 
        "exp_noninstr_food_sal", "exp_noninstr_food_bene", "exp_noninstr_ent_ops_total", 
        "exp_noninstr_ent_ops_bene", "exp_noninstr_other", "exp_covid_total", 
        "exp_covid_instr", "exp_covid_supp", "exp_covid_cap_out", "exp_covid_tech_supp", 
        "exp_covid_tech_equip", "exp_covid_supp_plant", "exp_covid_food")
      expenditure_cols <- c(expenditure_cols, full_expenditure_cols)
    }
    
    # combine all columns to adjust
    cols_to_adjust <- c(revenue_cols, expenditure_cols, economic_cols)
    
    # filter to only include columns that exist in the data
    cols_to_adjust <- cols_to_adjust[cols_to_adjust %in% names(data)]
    
    # apply cpi adjustment using mutate and across
    data <- data |>
      dplyr::mutate(
        # add the adjustment index column
        cpi_adj_index = .data$cpi_sy12 / baseline_cpi,
        # apply adjustment to financial columns
        dplyr::across(
          dplyr::all_of(cols_to_adjust),
          ~ .x * .data$cpi_sy12 / baseline_cpi
        )
      )
  }

  return(data)
}

