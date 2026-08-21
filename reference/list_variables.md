# List available variables in the education finance dataset

This function provides information about the variables available in the
education finance dataset, including their names, types, and brief
descriptions.

## Usage

``` r
list_variables(dataset_type = "skinny", category = "all")
```

## Arguments

- dataset_type:

  A string specifying whether to list variables for "skinny" (default)
  or "full" dataset.

- category:

  Optional. Filter variables by category: "id", "time", "geographic",
  "demographic", "revenue", "expenditure", "economic", "governance",
  "debt", "cwift", or "all" (default).

## Value

A tibble with one row per variable and the columns `name`, `type`,
`category`, `source`, `f33_item`, `first_yr_avail`, and `description`.
`f33_item` gives the F-33 survey item(s) a variable is drawn from (e.g.,
"F12", "TCAPOUT / V33"); it is `NA` for variables from non-F-33 sources
and for edfinr-adjusted measures (such as the adjusted revenue
variables), whose construction is described in the "Data Sources and
Methodology" vignette.

## Examples

``` r
# list all available variables in skinny dataset
vars <- list_variables()
head(vars)
#> # A tibble: 6 × 7
#>   name         type      category    source  f33_item first_yr_avail description
#>   <chr>        <chr>     <chr>       <chr>   <chr>    <chr>          <chr>      
#> 1 ncesid       character id          NCES F… LEAID    2012           NCES distr…
#> 2 year         integer   time        NCES F… YRDATA   2012           School yea…
#> 3 state        character geographic  NCES F… STATE    2012           State abbr…
#> 4 dist_name    character id          NCES F… NAME     2012           District n…
#> 5 enroll       numeric   demographic NCES F… V33      2012           Total dist…
#> 6 rev_total_pp numeric   revenue     NCES F… NA       2012           Total adju…

# list all variables in full dataset
full_vars <- list_variables(dataset_type = "full")
nrow(full_vars)
#> [1] 124

# list only expenditure variables in full dataset
exp_vars <- list_variables(dataset_type = "full", category = "expenditure")
head(exp_vars)
#> # A tibble: 6 × 7
#>   name             type    category   source f33_item first_yr_avail description
#>   <chr>            <chr>   <chr>      <chr>  <chr>    <chr>          <chr>      
#> 1 exp_cur_pp       numeric expenditu… NCES … TCURELS… 2012           Current ex…
#> 2 exp_cap_total_pp numeric expenditu… NCES … TCAPOUT… 2012           Total capi…
#> 3 rev_exp_pp_diff  numeric expenditu… NCES … NA       2012           Revenue mi…
#> 4 exp_cur_st_loc   numeric expenditu… NCES … CE1      2016           Current ex…
#> 5 exp_cur_fed      numeric expenditu… NCES … CE2      2016           Current ex…
#> 6 exp_cur_resa     numeric expenditu… NCES … CE3      2018           Current ex…
```
