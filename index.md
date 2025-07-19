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
