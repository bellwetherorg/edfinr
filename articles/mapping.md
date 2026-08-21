# Mapping School Finance Data

## Introduction

Maps are often the most effective way to communicate school finance
patterns: funding disparities, labor-cost geography, and property-wealth
gradients all have strong spatial structure. `edfinr` does not ship
geometries, but its `ncesid` matches the GEOID used by Census Bureau
school district boundary files – the same identifier the package itself
uses to join ACS data – so joining finance data to shapes from the
[tigris](https://github.com/walkerke/tigris) package is a
straightforward process.

``` r

library(edfinr)
library(dplyr)
library(ggplot2)
library(sf)
library(tigris)

# cache downloaded shapefiles across sessions
options(tigris_use_cache = TRUE)
```

## Before you map: district geography caveats

1.  **Three overlapping layers.** Census publishes *unified*,
    *elementary*, and *secondary* school district boundaries. In states
    where elementary and secondary districts coexist (Illinois,
    California, and others), the layers overlap, and mapping only the
    unified layer silently drops districts.
    [`tigris::school_districts()`](https://rdrr.io/pkg/tigris/man/school_districts.html)
    takes a `type` argument; check your state’s structure before
    assuming `"unified"` covers it.
2.  **Boundaries change.** Use a geometry `year` close to your data
    year, since district consolidations and boundary changes accumulate.
3.  **Cartographic boundary files.** `cb = TRUE` returns generalized
    boundaries that are smaller and draw faster; use the default
    TIGER/Line files only when you need legal-boundary precision.
4.  **Not every district joins.** Some `edfinr` districts (certain
    charter LEAs, for example) have no mapped boundary, and some mapped
    areas have no finance record. Count the misses after joining rather
    than assuming completeness.
5.  **Map area tracks geography, not students.** Geographically large,
    sparsely populated rural districts dominate a statewide choropleth’s
    ink, while the districts serving the most students occupy the least.
    A map can invert the visual impression of where most students
    actually are; consider labeling or insetting major metros when that
    distinction matters.

## Joining finance data to boundaries

Ohio features unified school districts, which keeps the example simple
and avoids overlapping geometries. First, pull the finance data and the
boundaries, then join on `GEOID = ncesid`:

``` r

oh_2023 <- get_finance_data(yr = "2023", geo = "OH")

oh_shapes <- school_districts(state = "OH", year = 2023, cb = TRUE)
```

    ##   |                                                                              |                                                                      |   0%  |                                                                              |=                                                                     |   1%  |                                                                              |=                                                                     |   2%  |                                                                              |==                                                                    |   3%  |                                                                              |===                                                                   |   4%  |                                                                              |====                                                                  |   6%  |                                                                              |======                                                                |   8%  |                                                                              |======                                                                |   9%  |                                                                              |========                                                              |  11%  |                                                                              |=========                                                             |  13%  |                                                                              |===========                                                           |  15%  |                                                                              |============                                                          |  17%  |                                                                              |=================                                                     |  25%  |                                                                              |===================                                                   |  27%  |                                                                              |====================                                                  |  29%  |                                                                              |======================                                                |  31%  |                                                                              |==========================                                            |  37%  |                                                                              |=============================                                         |  41%  |                                                                              |=======================================                               |  56%  |                                                                              |=========================================                             |  58%  |                                                                              |=============================================                         |  64%  |                                                                              |================================================                      |  68%  |                                                                              |======================================================                |  77%  |                                                                              |========================================================              |  81%  |                                                                              |=============================================================         |  87%  |                                                                              |================================================================      |  91%  |                                                                              |======================================================================|  99%  |                                                                              |======================================================================| 100%

``` r

oh_map <- oh_shapes |>
  left_join(oh_2023, by = c("GEOID" = "ncesid"))

# diagnostics: how many shapes have no finance record, and vice versa?
sum(is.na(oh_map$rev_total_pp))
```

    ## [1] 4

``` r

nrow(anti_join(oh_2023, sf::st_drop_geometry(oh_shapes), by = c("ncesid" = "GEOID")))
```

    ## [1] 327

## Mapping per-pupil revenue

With an `sf` object,
[`ggplot2::geom_sf()`](https://ggplot2.tidyverse.org/reference/ggsf.html)
handles the rest. Binned scale usually communicate funding levels better
than continuous gradients (which can be skewed by outliers), because
readers can attach a dollar range to each color:

``` r

ggplot(oh_map) +
  geom_sf(aes(fill = rev_total_pp), color = "white", linewidth = 0.05) +
  scale_fill_viridis_b(
    n.breaks = 6,
    labels = scales::label_dollar()
  ) +
  labs(
    title = "Total Revenue Per-Pupil in Ohio Districts, SY2022-23",
    fill = "Revenue\nPer-Pupil"
  ) +
  theme_void()
```

![Choropleth map of Ohio school districts shaded by total revenue
per-pupil in SY2022-23 using a binned color
scale.](mapping_files/figure-html/revenue-map-1.png)

## Mapping labor costs with CWIFT

Any `edfinr` variable maps the same way. The CWIFT teacher-wage index
makes the metro/rural labor-cost geography visible (see the “CWIFT”
article for what the index does and does not measure):

``` r

ggplot(oh_map) +
  geom_sf(aes(fill = cwift_est), color = "white", linewidth = 0.05) +
  scale_fill_viridis_c(option = "magma") +
  labs(
    title = "Comparable Wage Index for Teachers in Ohio, FY2023",
    subtitle = "FY2023 values are carried forward from FY2022",
    fill = "CWIFT"
  ) +
  theme_void()
```

![Choropleth map of Ohio school districts shaded by the CWIFT teacher
wage index, with higher values concentrated around metro
areas.](mapping_files/figure-html/cwift-map-1.png)

## Going further

- **Multi-state maps**:
  [`school_districts()`](https://rdrr.io/pkg/tigris/man/school_districts.html)
  accepts a vector of states; filter `get_finance_data(geo = ...)` to
  match.
- **Coastal states**:
  [`tigris::erase_water()`](https://rdrr.io/pkg/tigris/man/erase_water.html)
  improves shoreline maps.
- **ACS overlays**: the
  [tidycensus](https://walker-data.com/tidycensus/) package retrieves
  ACS variables with geometry included (`geometry = TRUE`); its GEOIDs
  join to `ncesid` the same way, which is convenient when you need ACS
  measures beyond those bundled in `edfinr`.
- **Interactive maps**: `sf` objects work directly with `mapview` and
  `leaflet` for exploratory work.

## See also

- The “CWIFT” article for interpreting the wage index.
- The “Community and Economic Context” article for the ACS and SAIPE
  measures worth mapping.
- The “Data Quality and Comparability” article for panel-composition
  caveats that affect join completeness.
