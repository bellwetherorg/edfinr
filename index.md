# `edfinr` <img src="man/figures/logo.png" width="250px" align="right">

  [![R-CMD-check](https://github.com/bellwetherorg/edfinr/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/bellwetherorg/edfinr/actions/workflows/R-CMD-check.yaml) ![CRAN Badge](https://www.r-pkg.org/badges/version/edfinr)  ![CRAN downloads](https://cranlogs.r-pkg.org/badges/grand-total/edfinr)


__edfinr__ is a [Bellwether](https://bellwether.org/) R package for downloading and analyzing education finance data. It includes cleaned data from the U.S. Census Bureau’s Annual Survey of School System Finances along with data from other surveys administered by the National Center for Education Statistics (NCES) and U.S Census Bureau.

You can install __edfinr__ from CRAN with:
```r
install.packages("edfinr")
```

You can install the development version of __edfinr__ from GitHub with:
```r
pak::pkg_install("bellwetherorg/edfinr") 
```

To learn more about how to use __edfinr__ to analyze school system revenues and expenditures, please refer to the following articles:

- [Get started: basic usage](articles/edfinr.html)
- [CPI adjustments](articles/cpi-adjustments.html)
- [Capital and facilities](articles/capital-facilities.html)
- [CWIFT](articles/cwift.html)
- [COVID relief spending](articles/covid-relief.html)
- [Community and economic context](articles/community-context.html)
- [Mapping school finance data](articles/mapping.html)
- [Data quality and comparability](articles/data-quality.html)
- [Data sources and methodology](articles/data-sources-methods.html)

## Data Notes and Cautions

Users should note the following when working with the __edfinr__ datasets:

- Some variables were originally coded with `-1` to indicate missing values; these have been replaced with `NA` during processing. An `NA` means an item was not reported, not that it is zero.
- The number of California districts jumps from 2019 onward because a wave of charter schools became separate local education agencies (LEAs); see the [data quality and comparability](articles/data-quality.html) article for the full explanation and its implications for longitudinal analysis.
- The joined dataset represents a synthesis of data from multiple sources; discrepancies in source data formats may lead to minor variations.
- Inflation and adjustment factors (e.g., CPI adjustments) are based on averages and may not perfectly reflect local cost variations.
- **Caution is advised when comparing data across fiscal years due to potential differences in data collection and processing methods.**

## Authors

- **Alex Spurrier** ([alex.spurrier@bellwether.org](mailto:alex.spurrier@bellwether.org))  - lead developer and package maintainer
- **Krista Kaput** - core development and feature implementation
- **Michael Chrzan** - data processing functions and testing
