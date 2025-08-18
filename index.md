# edfinr <img src=logo.png width = "250px" align = "right">

  [![R-CMD-check](https://github.com/bellwetherorg/edfinr/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/bellwetherorg/edfinr/actions/workflows/R-CMD-check.yaml)


__edfinr__ is a [Bellwether](https://bellwether.org/) R package for downloading and analyzing education finance data. It includes cleaned data from the U.S. Census Bureau’s Annual Survey of School System Finances along with data from other surveys administered by the National Center for Education Statistics (NCES) and U.S Census Bureau.

You can install the development version of __edfinr__ from GitHub with:
```r
pak::pkg_install("bellwetherorg/edfinr") 
```

To learn more about how to use __edfinr__ to analyze school system revenues and expenditures, please refer to the following articles:

- [Basic use](articles/basic-usage.html)
- [CPI adjustments](articles/cpi-adjustments.html)
- [Data sources and methodology](articles/data-sources-methods.html)

## Data Notes and Cautions

Users should note the following when working with the __edfinr__ datasets:

- Some variables were originally coded with `-1` to indicate missing values; these have been replaced with `NA` during processing.
- During data processing, we identified a sharp rise in the number of California districts appearing only from 2019 onward in the data. This reflects the fact that many charter schools became separate local education agencies (LEAs) in those years. Beginning in school year 2018–19, a wave of California charter schools switched to independent CALPADS/CBEDS reporting and thus were assigned their own NCES LEA IDs for the first time. Once in the NCES LEA universe, those new charter‐LEAs automatically show up in the F-33 finance survey (with blanks or flags if they report no finance data), and Census SAIPE and ACS school‐district products (which mirror NCES LEA boundaries).
- The joined dataset represents a synthesis of data from multiple sources; discrepancies in source data formats may lead to minor variations.
- Inflation and adjustment factors (e.g., CPI adjustments) are based on averages and may not perfectly reflect local cost variations.
- **Caution is advised when comparing data across fiscal years due to potential differences in data collection and processing methods.**

## Authors

- **Alex Spurrier** ([alex.spurrier@bellwether.org](mailto:alex.spurrier@bellwether.org))  - lead developer and package maintainer
- **Krista Kaput** - core development and feature implementation
- **Michael Chrzan** - data processing functions and testing
