# Get Education Finance Data

This function downloads tidy education finance data using data from the
NCES F-33 Survey, Census Bureau Small Area Income Poverty Estimates
(SAIPE), and community data from the ACS 5-Year Estimates.

## Usage

``` r
get_finance_data(
  yr = "2023",
  geo = "all",
  dataset_type = "skinny",
  cpi_adj = "none",
  refresh = FALSE,
  quiet = FALSE
)
```

## Arguments

- yr:

  A string specifying the year(s) to retrieve. Can be a single year
  ("2023"), a range ("2020:2023"), or "all" for all available years.
  Defaults to "2023". Only the requested year(s) are downloaded – each
  year is a separate hosted file of roughly 3-6 MB, so a single-year
  request transfers far less than the full panel. \`yr = "all"\` fetches
  the entire history from one combined file. When \`cpi_adj\` names a
  year outside the request, that year's file is also downloaded to
  source the baseline, then dropped from the returned data.

- geo:

  A string specifying the geographic scope. Can be "all" for all states
  (default), a single state code ("KY"), or a comma-separated list of
  state codes ("IN,KY,OH,TN").

- dataset_type:

  A string specifying whether to download the "skinny" (default) or
  "full" dataset. The skinny version excludes detailed expenditure data
  for faster downloads.

- cpi_adj:

  A string specifying the CPI adjustment baseline year. Can be "none"
  (default) for no adjustment, or a year between 2012-2023 to use as the
  baseline year. When a year is specified (e.g., "2023"), revenue,
  expenditure, and economic variables are adjusted to that school year's
  dollars using CPI averaged over the months of the school year (e.g.,
  "2023" uses the 2022-23 school year CPI). Capital outlay and
  debt-interest flows are adjusted; debt and fund-balance stocks
  (debt\_\*, fund_bal\_\*) and the CWIFT index are returned nominal.
  When cpi_adj is set to a value other than "none", a new column
  "cpi_adj_index" will be added to the output showing the adjustment
  index used for each row.

- refresh:

  A logical value indicating whether to force a refresh of the cached
  data. Default is FALSE.

- quiet:

  A logical value indicating whether to suppress download progress
  messages. Default is FALSE.

## Value

A tibble containing the requested education finance data.

## Details

Downloaded files are cached for the duration of the R session in a
subdirectory of \[tempdir()\], so repeated calls in one session do not
re-download; the cache is cleared when the session ends. Use \`refresh =
TRUE\` to force a fresh download. During downloads the package
temporarily raises R's download timeout to at least 600 seconds (the
\`yr = "all"\` combined files are 38-54 MB); a higher user-set
\`options(timeout = )\` is respected.

## Examples

``` r
# Check valid parameters without downloading
get_states()  # Valid state codes
#>  [1] "AL" "AK" "AZ" "AR" "CA" "CO" "CT" "DE" "FL" "GA" "HI" "ID" "IL" "IN" "IA"
#> [16] "KS" "KY" "LA" "ME" "MD" "MA" "MI" "MN" "MS" "MO" "MT" "NE" "NV" "NH" "NJ"
#> [31] "NM" "NY" "NC" "ND" "OH" "OK" "OR" "PA" "RI" "SC" "SD" "TN" "TX" "UT" "VT"
#> [46] "VA" "WA" "WV" "WI" "WY" "DC"

# \donttest{
# These examples require internet access and may take time to download

# get data for Kentucky for 2023
ky_data <- get_finance_data(yr = "2023", geo = "KY")
#> ℹ Downloading education finance data...
#> ✔ Download complete.

# get data for multiple years
ky_multi <- get_finance_data(yr = "2021:2023", geo = "KY")
#> ℹ Downloading education finance data...
#> ✔ Download complete.

# get full dataset with detailed expenditure data
ky_full <- get_finance_data(yr = "2023", geo = "KY", dataset_type = "full")
#> ℹ Downloading education finance data...
#> ✔ Download complete.

# get data adjusted to 2023 dollars
ky_adjusted <- get_finance_data(yr = "2021:2023", geo = "KY", cpi_adj = "2023")
#> ℹ Using cached data. Use refresh = TRUE to download fresh data.

# get data for multiple states for several years
regional_data <- get_finance_data(yr = "2021:2023", geo = "IN,KY,OH,TN")
#> ℹ Using cached data. Use refresh = TRUE to download fresh data.
# }
```
