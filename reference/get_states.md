# Get list of valid state codes

Returns the valid two-letter state codes that can be used with
get_finance_data

## Usage

``` r
get_states()
```

## Value

A character vector of state codes

## Examples

``` r
# Get all valid state codes
states <- get_states()
head(states)
#> [1] "AL" "AK" "AZ" "AR" "CA" "CO"
```
