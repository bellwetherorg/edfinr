# `edfinr`

An R package for downloading and analyzing education finance data from multiple sources.

## Installation

You can install the development version of `edfinr` from GitHub with:

```r
devtools::install_github("bellwetherorg/edfinr") 
```

## Usage

### Getting Finance Data

The `get_finance_data()` function allows you to download education finance data with options for year ranges, geographic scope, and dataset type (skinny or full).

```r
library(edfinr)

# get data for all states for 2022 (uses skinny dataset by default)
df <- get_finance_data(yr = "2022", geo = "all")

# get data for Kentucky for 2020-2022
ky_data <- get_finance_data(yr = "2020:2022", geo = "KY")

# get data for multiple states for all available years
regional_data <- get_finance_data(yr = "all", geo = "IN,KY,OH,TN")

# get full dataset with detailed expenditure variables
# the full dataset includes 48 additional expenditure variables
full_data <- get_finance_data(yr = "2022", geo = "KY", dataset_type = "full")

# compare dataset sizes
skinny_data <- get_finance_data(yr = "2022", geo = "KY", dataset_type = "skinny")
ncol(skinny_data)  # 41 variables
ncol(full_data)    # 89 variables
```

### Exploring Available Variables

The `list_variables()` function helps you understand what data is available in each dataset type.

```r
# view all variables in the skinny dataset (default)
vars_skinny <- list_variables()
nrow(vars_skinny)  # 41 variables

# view all variables in the full dataset
vars_full <- list_variables(dataset_type = "full")
nrow(vars_full)    # 89 variables

# filter variables by category
revenue_vars <- list_variables(category = "revenue")
expenditure_vars <- list_variables(dataset_type = "full", category = "expenditure")

# see what categories are available
unique(list_variables(dataset_type = "full")$category)
# [1] "id" "time" "geographic" "demographic" "revenue" "expenditure" "economic" "governance"

# view variable details
list_variables() |>
  filter(category == "revenue") |>
  select(name, description)

# get list of valid state codes
states <- get_states()
```

### Working with the Data

```r
library(tidyverse)

# basic analysis with skinny dataset
get_finance_data(yr = "2022", geo = "KY") |>
  select(dist_name, enroll, rev_total_pp, exp_cur_pp) |>
  arrange(desc(rev_total_pp)) |>
  head(10)

# analysis with full dataset - examining detailed expenditures
get_finance_data(yr = "2022", geo = "KY", dataset_type = "full") |>
  select(ncesid, state, dist_name, enroll, exp_covid_total) |>
  filter(!is.na(exp_covid_total)) |>
  mutate(exp_covid_total_pp = exp_covid_total / enroll) |>
  arrange(desc(exp_covid_total_pp))

```

## Data Sources

This package provides access to education finance data from:

- [NCES CCD F-33 Data](https://nces.ed.gov/ccd/files.asp)
- NCES CCD Directory Data via the [Urban Institute's `educationdata` package](https://educationdata.urban.org/documentation/#r)
- [Census Bureau SAIPE Estimates](https://www.census.gov/programs-surveys/saipe.html)
- American Community Survey 5-Year Estimates via [`tidycensus` package](https://walker-data.com/tidycensus/)
- U.S Bureau of Labor Statistics [Consumer Price Index for All Urban Consumers (CPI-U)](https://data.bls.gov/toppicks?survey=cu)

## Data Processing Methods

- Methodology based on process used by [`edbuildr`](https://github.com/EdBuild/edbuildr), which is detailed on a [methodology page](http://data.edbuild.org/) and in their [workshop documentation](http://viz.edbuild.org/workshops/edbuildr/).
- The [EdFund Data Dictionary](https://data-dictionary.ed-fund.org/?_gl=1*199anoz*_ga*MTg3MDM3NDg2LjE3MzkzNzAzOTE.*_ga_TGH6XK399M*MTc0NDIyMzY3Ni43LjEuMTc0NDIyMzY4MC4wLjAuMA..) informs our handling of F-33 data.
- Revenue adjustments for payments to other school systems follows the approach used by Kristen Blagg, Emily Gutierrez, and Fanny Terrones in [Funding Flows: Which Students Receive a Greater Share of School Funding?](https://apps.urban.org/features/school-funding-trends/files/202204_K12_funding_technical_appendix.pdf).
- Inflation adjustments use an average of second half CPI-U of one year and first half CPI-U of the following year to align with the academic calendar.

## Data Processing Detail

### NCES F-33 Survey Data

Data source: NCES Common Core of Data text files of F-33 data from 2011-12 through 2021-22.

Raw variables selected:

- Basic information: state, leaid, name, yrdata, V33
- Revenue data: totalrev, tlocrev, tstrev, tfedrev
- Expenditure data: c11, u11, v91, v92, c24, l12, m12, d11, q11
- Current expenditure data: ce1, ce2, and ce3
- Detailed expenditure data: z32, z34, v93, v95, v02, k14, e13, z33, v10, e17, v11, v12, e07, v13, v14, e08, v15, v16, e09, v17, v18, v40, v21, v22, v45, v23, v24, v90, v37, v38, e11, v29, v30, v60, v32, v65, ae1, ae2, ae3, ae4, ae5, ae6, ae7, ae8

Adjustments:

- Rename variables
- Convert district names to title case
- Ensure enrollment is a numeric variable
- Replace `-1` and `-2` codes with `NA` values

### CCD Directory Data

Data source: NCES CCD Directory data obtained via the
[educationdata](https://educationdata.urban.org/documentation/#r)
package.

Raw variables selected:

- Core district identifiers and location: state, ncesid, county, dist_name, state_leaid
- Institutional details: lea_type, lea_type_id, urbanicity, congressional_dist

Adjustments:

- Rename variables to more intuitive names

### SAIPE Poverty Estimates

Data source: Census Bureau SAIPE Estimates

Raw variables selected:

- Basic geographic and demographic fields: State Postal Code, State FIPS Code, District ID, Name
- Population estimates: Estimated Total Population, Estimated Population 5-17, and the estimated number of relevant children 5 to 17 years old in poverty

Adjustments:

- Convert population fields to numeric
- Construct a combined NCES district identifier by concatenating state FIPS and District ID

### ACS 5-Year Estimates

Data source: American Community Survey 5-Year Estimates accessed via the
[`tidycensus`](https://walker-data.com/tidycensus/) package

Raw variables selected:

- Economic indicators: Median household income (B19013_001) and median property value (B25077_001)
- Educational attainment: Total population 25 years or older (B15003_001) and subsets of that population holding bachelor's degrees (B15003_022), master's degrees (B15003_023), professional degrees (B15003_024), and doctoral degrees (B15003_025).
- Data are pulled for different geographic breakdowns (unified, elementary, and secondary school districts)

Adjustments:

- Reshape data from long to wide format
- Rename “GEOID” to a standard `ncesid` and ensure proper formatting of district identifiers
- Convert estimates to numeric as needed

### CPI

Data source: U.S. Bureau of Labor Statistics, specifically the Consumer Price Index for All Urban Consumers (CPI-U)

Raw variables selected:

- CPI time series data (specific variable names as provided in the raw file)

Adjustments:

- Calculate an averaged CPI value using the second half of one year and the first half of the following year to align with the academic calendar, with the 2011-12 school year as the baseline year
- Clean and reformat CPI data for consistency across processing scripts

## Joining Data

- The joining process is implemented in the `07_edfinr_join_and_exclude.R` script.
- Data from the F-33 survey, CCD Directory, ACS (unified, elementary, and secondary), and SAIPE sources are merged using left joins on shared district identifiers (ncesid) and fiscal year.
- The procedure ensures that each district record is enriched with revenue, expenditure, demographic, and economic data.

## Revenue Adjustments

Additional transformations are applied after the join:
- Capital expenditures and debt service (C11) are subtrated from state revenues
- Property sales (U11) are subtracted from local revenues
- For Texas LEAs in 2012-13 and earlier, payments to state governments (L12) are subtracted from local revenues
- Payments to other school systems (V91, V92, and Q11) are proportionally subracted from local, state, and federal revenues

## Exclusions

- Districts with enrollment less than 0 are removed.
- Districts with total revenue less than 0 are removed.
- Districts with an invalid LEA type (i.e. where lea_type_id is not one of 1, 2, 3, or 7) are excluded.
- Districts with invalid LEA/school level type (i.e. where schlev is not one of "01", "02", or "03", except for specified CA exceptions) are excluded.
- Districts where total revenue per-pupil is greater than $70,000 in 2011-12 dollars are excluded.
- Districts where total revenue per pupil is less than $500 in 2011-12 dollars are excluded.
- Connecticut LEAs consisting of semi-private high schools are removed (NCES IDs "0905371", "0905372", and "0905373").

## Data Notes and Cautions

Users should note the following when working with the `edfinr` datasets:

- Some variables were originally coded with `-1` to indicate missing values; these have been replaced with `NA` during processing.
- During data processing, we identified a sharp rise in the number of California districts appearing only from 2019 onward in the data. This reflects the fact that many charter schools became separate LEAs in those years. Beginning in 2018–19, a wave of California charter schools switched to independent CALPADS/CBEDS reporting and thus were assigned their own NCES LEA IDs for the first time. Once in the NCES LEA universe, those new charter‐LEAs automatically show up in the F-33 finance survey (with blanks or flags if they report no finance data), and Census’s SAIPE and ACS school‐district products (which mirror NCES LEA boundaries).
- The joined dataset represents a synthesis of data from multiple sources; discrepancies in source data formats may lead to minor variations.
- Inflation and adjustment factors (e.g., CPI adjustments) are based on averages and may not perfectly reflect local cost variations.
- **Caution is advised when comparing data across fiscal years due to potential differences in data collection and processing methods.**

## Authors

- **Alex Spurrier** ([alex.spurrier@bellwether.org](mailto:alex.spurrier@bellwether.org))  - Lead developer and package maintainer
- **Krista Kaput** - Core development and feature implementation
- **Michael Chrzan** - Data processing functions and testing

## License

MIT License
