# Data Sources and Methodology

## Overview

This vignette provides detailed information about the data sources and
processing methods used to prepare the data used by the `edfinr`
package. Understanding these details will help you interpret the data
appropriately and inform analytical decisions.

Full data processing methods and scripts are available on GitHub via
[bellwetherorg/edfinr_data_cleaning](https://github.com/bellwetherorg/edfinr_data_cleaning).

## Data Sources

This package provides access to education finance data from:

- [NCES CCD F-33 Data](https://nces.ed.gov/ccd/files.asp).
- NCES CCD Directory Data via the [Urban Institute’s `educationdata`
  package](https://educationdata.urban.org/documentation/#r).
- [Census Bureau SAIPE
  Estimates](https://www.census.gov/programs-surveys/saipe.html)
- American Community Survey 5-Year Estimates via [`tidycensus`
  package](https://walker-data.com/tidycensus/).
- U.S. Bureau of Labor Statistics [Consumer Price Index for All Urban
  Consumers (CPI-U)](https://data.bls.gov/toppicks?survey=cu).
- NCES EDGE [Comparable Wage Index for Teachers
  (CWIFT)](https://nces.ed.gov/programs/edge/Economic/TeacherWage).

## Data Processing Methods

- Methodology based on process used by
  [`edbuildr`](https://github.com/EdBuild/edbuildr), which is detailed
  on a [methodology page](http://data.edbuild.org/) and in their
  [workshop documentation](http://viz.edbuild.org/workshops/edbuildr/).
- The [EdFund Data Dictionary](https://data-dictionary.ed-fund.org/)
  informs our handling of F-33 data.
- Revenue adjustments for payments to other school systems follows the
  approach used by Kristen Blagg, Emily Gutierrez, and Fanny Terrones in
  [Funding Flows: Which Students Receive a Greater Share of School
  Funding?](https://apps.urban.org/features/school-funding-trends/files/202204_K12_funding_technical_appendix.pdf)
- Inflation adjustments use an average of second half CPI-U of one year
  and first half CPI-U of the following year to align with the academic
  calendar.

## Data Processing Detail

### NCES F-33 Survey Data

Data source: NCES Common Core of Data text files of F-33 data from
2011-12 through 2022-23.

A note on year conventions used throughout the package: `year` is the
fiscal year in which the school year ends, so `year == 2023` is FY2023,
covering SY2022-23. F-33 reports on state-defined fiscal years, which in
most states run July through June. The enrollment denominator for all
per-pupil measures is F-33 item V33, the district’s fall membership
count (`enroll`).

The crosswalk below maps every F-33-derived column in the full dataset
to the F-33 survey item(s) it is drawn from. It is generated from the
package’s data dictionary, so it cannot drift from what
[`list_variables()`](https://bellwetherorg.github.io/edfinr/reference/list_variables.md)
reports; single codes are 1:1 mappings and formula strings describe
simple combinations.

``` r

list_variables("full") |>
  filter(source == "NCES F-33 Survey", !is.na(f33_item)) |>
  select(name, f33_item, description) |>
  knitr::kable()
```

| name | f33_item | description |
|:---|:---|:---|
| ncesid | LEAID | NCES district ID |
| year | YRDATA | School year (end year, e.g., 2023 = 2022-2023) |
| state | STATE | State abbreviation |
| dist_name | NAME | District name |
| enroll | V33 | Total district enrollment (V33) |
| rev_total_unadj | TOTALREV | Total raw revenue (TOTALREV) |
| rev_local_unadj | TLOCREV | Local raw revenue (TLOCREV) |
| rev_state_unadj | TSTREV | State raw revenue (TSTREV) |
| rev_fed_unadj | TFEDREV | Federal raw revenue (TFEDREV) |
| rev_state_unadj_pp | TSTREV / V33 | State raw (unadjusted) revenue per-pupil |
| rev_local_unadj_pp | TLOCREV / V33 | Local raw (unadjusted) revenue per-pupil |
| rev_state_cap_debt | C11 | State revenue for capital outlay and debt service (C11); the amount netted out of rev_state, zero-filled (not NA) for non-reporting districts |
| exp_cur_pp | TCURELSC / V33 | Current expenditure per-pupil (TCURELSC divided by V33) |
| exp_cap_total_pp | TCAPOUT / V33 | Total capital outlay per-pupil (TCAPOUT / enroll) |
| exp_cur_st_loc | CE1 | Current expenditure from state/local sources (ESSA item CE1; NA where the state did not report the fund-type split) |
| exp_cur_fed | CE2 | Current expenditure from federal sources (ESSA item CE2; NA where the state did not report the fund-type split) |
| exp_cur_resa | CE3 | Current expenditure by RESA on behalf of LEAs (ESSA item CE3; NA where the state did not report the fund-type split) |
| exp_cur_total | TCURELSC | Total current expenditure for elementary/secondary education (TCURELSC); the CE1/CE2/CE3 fund-type split does not sum exactly to this total |
| exp_cap_total | TCAPOUT | Total capital outlay (TCAPOUT) |
| exp_emp_salary | Z32 | Total employee salaries (Z32) |
| exp_emp_bene | Z34 | Total employee benefits (Z34) |
| exp_textbooks | V93 | Textbooks (V93) |
| exp_utilities | V95 | Utilities and energy services (V95) |
| exp_tech_supp | V02 | Technology-related supplies and purchased services (V02) |
| exp_tech_equip | K14 | Technology-related equipment (K14) |
| exp_pay_private_sch | V91 | Payments to private schools (V91) |
| exp_pay_charter_sch | V92 | Payments to charter schools (V92) |
| exp_pay_other_lea | Q11 | Payments to other LEAs (Q11) |
| exp_other_sys_pay | V91 + V92 + Q11 | Payments to other systems (V91 + V92 + Q11) |
| osp_pct | (V91 + V92 + Q11) / TOTALREV | Share of unadjusted total revenue paid to other systems (see data-quality notes) |
| exp_instr_total | E13 | Instruction - Total (E13) |
| exp_instr_sal | Z33 | Instruction - Salaries (Z33) |
| exp_instr_bene | V10 | Instruction - Benefits (V10) |
| exp_supp_stu_total | E17 | Support services, students - Total (E17) |
| exp_supp_stu_sal | V11 | Support services, students - Salaries (V11) |
| exp_supp_stu_bene | V12 | Support services, students - Benefits (V12) |
| exp_supp_instr_total | E07 | Support services, instructional staff - Total (E07) |
| exp_supp_instr_sal | V13 | Support services, instructional staff - Salaries (V13) |
| exp_supp_instr_bene | V14 | Support services, instructional staff - Benefits (V14) |
| exp_supp_gen_admin_total | E08 | Support services, general administration - Total (E08) |
| exp_supp_gen_admin_sal | V15 | Support services, general administration - Salaries (V15) |
| exp_supp_gen_admin_bene | V16 | Support services, general administration - Benefits (V16) |
| exp_supp_sch_admin_total | E09 | Support services, school administration - Total (E09) |
| exp_supp_sch_admin_sal | V17 | Support services, school administration - Salaries (V17) |
| exp_supp_sch_admin_bene | V18 | Support services, school administration - Benefits (V18) |
| exp_supp_ops_total | V40 | Support services, operation and maintenance of plant - Total (V40) |
| exp_supp_ops_sal | V21 | Support services, operation and maintenance of plant - Salaries (V21) |
| exp_supp_ops_bene | V22 | Support services, operation and maintenance of plant - Benefits (V22) |
| exp_supp_trans_total | V45 | Support services, student transportation - Total (V45) |
| exp_supp_trans_sal | V23 | Support services, student transportation - Salaries (V23) |
| exp_supp_trans_bene | V24 | Support services, student transportation - Benefits (V24) |
| exp_central_serv_total | V90 | Business/central/other support services - Total (V90) |
| exp_central_serv_sal | V37 | Business/central/other support services - Salaries (V37) |
| exp_central_serv_bene | V38 | Business/central/other support services - Benefits (V38) |
| exp_noninstr_food_total | E11 | Food services - Total (E11) |
| exp_noninstr_food_sal | V29 | Food services - Salaries (V29) |
| exp_noninstr_food_bene | V30 | Food services - Benefits (V30) |
| exp_noninstr_ent_ops_total | V60 | Enterprise operations - Total (V60) |
| exp_noninstr_ent_ops_bene | V32 | Enterprise operations - Benefits (V32) |
| exp_noninstr_other | V65 | Other non-instructional services (V65) |
| exp_covid_total | AE1 | COVID-19 Federal Assistance Funds - Total expenditures (AE1); NA where districts did not report the COVID items (all of NY in every year; roughly a third to half of CA districts from FY21) |
| exp_covid_instr | AE2 | COVID-19 Federal Assistance Funds - Instructional expenditures (AE2) |
| exp_covid_supp | AE3 | COVID-19 Federal Assistance Funds - Support services expenditures (AE3) |
| exp_covid_cap_out | AE4 | COVID-19 Federal Assistance Funds - Capital outlay expenditures (AE4) |
| exp_covid_tech_supp | AE5 | COVID-19 Federal Assistance Funds - Technology-related supplies and purchased services expenditures (AE5) |
| exp_covid_tech_equip | AE6 | COVID-19 Federal Assistance Funds - Technology-related equipment expenditures (AE6) |
| exp_covid_supp_plant | AE7 | COVID-19 Federal Assistance Funds - Support services operation and maintenance of plant expenditures (AE7) |
| exp_covid_food | AE8 | COVID-19 Federal Assistance Funds - Food services operations (AE8) |
| exp_cap_construction | F12 | Construction (F12) |
| exp_cap_land | G15 | Land and existing structures (G15) |
| exp_cap_equip_instr | K09 | Instructional equipment (K09) |
| exp_cap_equip_other | K10 | Other equipment (K10) |
| exp_cap_equip_nonspec | K11 | Nonspecified equipment (K11) |
| exp_debt_interest | I86 | Interest on school-system debt (I86) |
| debt_lt_begin | \_19H | Long-term debt outstanding, start of FY (\_19H) |
| debt_lt_issued | \_21F | Long-term debt issued during FY (\_21F) |
| debt_lt_retired | \_31F | Long-term debt retired during FY (\_31F) |
| debt_lt_end | \_41F | Long-term debt outstanding, end of FY (\_41F) |
| debt_st_begin | \_61V | Short-term debt outstanding, start of FY (\_61V) |
| debt_st_end | \_66V | Short-term debt outstanding, end of FY (\_66V) |
| fund_bal_debt_svc | W01 | Debt service fund cash and investments, FYE (W01); NA where flagged unreported |
| fund_bal_bond | W31 | Bond fund cash and investments, FYE (W31); NA where flagged unreported |
| fund_bal_other | W61 | Other funds cash and investments, FYE (W61); NA where flagged unreported |

In addition to the items above, the cleaning scripts read F-33 variables
U11, C24, L12, M12, and D11 to construct the revenue adjustments
described under “Revenue Adjustments” below. C11 (state revenue for
capital outlay and debt service) both feeds those adjustments and ships
directly as `rev_state_cap_debt`, so it appears in the crosswalk.
Variables with an `NA` `f33_item` in
[`list_variables()`](https://bellwetherorg.github.io/edfinr/reference/list_variables.md)
are either drawn from non-F-33 sources or are edfinr-adjusted measures
whose construction is documented in that section.

Adjustments applied during cleaning:

- Rename variables.
- Convert district names to title case.
- Ensure enrollment is a numeric variable.
- Replace `-1` and `-2` codes with `NA` values.

### CCD Directory Data

Data source: NCES CCD Directory data obtained via the
[educationdata](https://educationdata.urban.org/documentation/#r)
package.

Raw variables selected:

- Core district identifiers and location: state, ncesid, county,
  dist_name, state_leaid.
- Institutional details: lea_type, lea_type_id, urbanicity,
  congressional_dist.
- Two related CCD-derived classifications, `cbsa` (core based
  statistical area) and `schlev` (LEA school level), arrive on the F-33
  files rather than through the directory pull.

Adjustments:

- Rename variables to more intuitive names.
- Directory attributes come from the directory vintage for the same
  school year as the fiscal year they describe. (Releases before 0.2.0
  joined the following school year’s vintage; see “Changes from 0.1.x”
  below.)

### SAIPE Poverty Estimates

Data source: Census Bureau SAIPE Estimates.

Raw variables selected:

- Basic geographic and demographic fields: State Postal Code, State FIPS
  Code, District ID, Name
- Population estimates: Estimated Total Population, Estimated Population
  ages 5-17, and the estimated number of relevant children ages 5 to 17
  living in poverty

Adjustments:

- Convert population fields to numeric
- Construct a combined NCES district identifier by concatenating state
  FIPS and District ID

### ACS 5-Year Estimates

Data source: American Community Survey 5-Year Estimates accessed via the
[`tidycensus`](https://walker-data.com/tidycensus/) package.

Raw variables selected:

- Economic indicators: Median household income (B19013_001), mean
  household income (aggregate household income divided by households),
  median property value (B25077_001), and the Gini index of income
  inequality (B19083_001).
- Household and labor characteristics: owner-occupied share of occupied
  housing (B25003), share of households receiving SNAP (B22003), and the
  unemployment rate among the civilian labor force (B23025).
- Educational attainment: Total population 25 years or older
  (B15003_001) and subsets of that population holding bachelor’s degrees
  (B15003_022), master’s degrees (B15003_023), professional degrees
  (B15003_024), and doctoral degrees (B15003_025).
- Data are pulled for different geographic breakdowns (unified,
  elementary, and secondary school districts).

Each fiscal year is joined to the ACS 5-year release ending in the same
calendar year: FY2023 carries the 2019-2023 5-year estimates, FY2012 the
2008-2012 estimates. The 5-year window smooths across years, and its
endpoint (December) extends a few months past the June close of the
fiscal year.

Adjustments:

- Reshape data from long to wide format.
- Rename “GEOID” to a standard `ncesid` and ensure proper formatting of
  district identifiers.
- Convert estimates to numeric as needed.

### CPI

Data source: U.S. Bureau of Labor Statistics, specifically the Consumer
Price Index for All Urban Consumers (CPI-U).

Raw variables selected:

- CPI time series data (specific variable names as provided in the raw
  file).

Adjustments:

- Calculate an averaged CPI value using the second half of one year and
  the first half of the following year to align with the academic
  calendar, with the 2011-12 school year as the baseline year.
- Clean and reformat CPI data for consistency across processing scripts.

### CWIFT (Comparable Wage Index for Teachers)

Data source: NCES EDGE [Comparable Wage Index for Teachers
(CWIFT)](https://nces.ed.gov/programs/edge/Economic/TeacherWage),
LEA-level releases.

Raw variables selected:

- District identifier (`LEAID`), the CWIFT estimate (`LEA_CWIFTEST`),
  and its standard error (`LEA_CWIFTSE`).

Adjustments and coverage:

- Each `CWIFT<yyyy>` release maps to edfinr fiscal year `yyyy`.
- FY2012-FY2014 have no CWIFT release and are returned as `NA`.
- FY2020 (no NCES release, owing to withheld ACS 2020 estimates) is
  interpolated as the mean of the FY2019 and FY2021 values for LEAs
  present in both years; the interpolated standard error is an
  approximation, not an NCES-published value.
- FY2023 is carried forward from FY2022 (no CWIFT2023 release as of the
  2026-07-20 check).
- `cwift_imputed` flags interpolated or carried-forward values and
  `cwift_impute_method` records how each value was produced.

## Joining Data

- The joining process is implemented in the
  `08_edfinr_join_and_exclude.R` script (CWIFT is prepared in
  `07_cwift_clean.R` and joined there).
- Data from the F-33 survey, CCD Directory, ACS (unified, elementary,
  and secondary), SAIPE, and CWIFT sources are merged using left joins
  on shared district identifiers (ncesid) and fiscal year.
- The procedure ensures that each district record is enriched with
  revenue, expenditure, demographic, and economic data.

## Revenue Adjustments

Additional transformations are applied after the join:

- State revenue for capital outlay and debt service (C11) is subtracted
  from state revenues. The subtracted amount ships as
  `rev_state_cap_debt` in both datasets (zero-filled, not `NA`, for
  non-reporting districts, because it feeds the adjustment arithmetic).
  The unadjusted state revenue is preserved in `rev_state_unadj` /
  `rev_state_unadj_pp`, and `c11_spike_flag` marks district-years where
  this adjustment produces an anomalous spike.
- Property sales (U11) are subtracted from local revenues.
- For Texas local education agencies (LEAs) in school year 2012-13 and
  earlier, payments to state governments (L12) are subtracted from local
  revenues.
- Payments to other school systems (V91, V92, and Q11) are
  proportionally subtracted from local, state, and federal revenues.

## Exclusions

- Districts with enrollment of zero or below are removed.
- Districts with total revenue of zero or below are removed.
- Districts with an invalid LEA type (i.e. where lea_type_id is not one
  of 1, 2, 3, or 7) are excluded. Since 0.2.0 this screen tolerates
  single-vintage miscodes: a district-year is excluded only if the
  following directory vintage agrees the district is not a regular
  district, supervisory union, or charter. Massachusetts regional
  districts, which CCD coded as service agencies (lea_type_id 4) in the
  SY2011-12 through SY2015-16 directory vintages, are retained for
  FY2012-FY2015 via an explicit vetted list (FY2016 is recovered by the
  single-vintage tolerance). Their `lea_type_id` reports what the source
  vintage said, so filtering Massachusetts years 2012-2016 on
  `lea_type_id` will drop real regional districts.
- Districts with invalid LEA/school level type (i.e. where schlev is not
  one of “01”, “02”, or “03”, except for specified CA exceptions) are
  excluded.
- Districts where total revenue per-pupil is greater than \$70,000 in
  school year 2011-12 dollars are excluded.
- Districts where total revenue per pupil is less than \$500 in school
  year 2011-12 dollars are excluded.
- Connecticut LEAs consisting of semi-private high schools are removed
  (NCES IDs “0905371”, “0905372”, and “0905373”).

## Changes from 0.1.x

Users comparing results against edfinr 0.1.x should be aware of these
methodology-relevant changes in 0.2.0:

- **`exp_cur_total` is sourced from TCURELSC.** In 0.1.x the total was
  the sum of the ESSA fund-type items (CE1 + CE2 + CE3), which several
  states skip entirely (all of Illinois and Minnesota through FY23; New
  York – including New York City – New Jersey, Massachusetts, Oregon,
  and others in earlier years) and which did not exist before FY16.
  Sourcing the total directly from the F-33 TCURELSC item makes
  `exp_cur_total`, `exp_cur_pp`, and `rev_exp_pp_diff` available for
  nearly all districts in every year 2012-2023. Where states did report
  the fund-type items, values shift slightly: the ESSA items exclude
  payments to private, charter, and other school systems, so the CE-sum
  differs from TCURELSC by more than 2% for roughly 40% of reporting
  districts. The fund-type split remains available as `exp_cur_st_loc`,
  `exp_cur_fed`, and `exp_cur_resa` (`NA` where unreported); those
  components should not be expected to sum exactly to `exp_cur_total`.
  Missing values still propagate to `NA` rather than being treated as
  zero.
- **CCD directory attributes match the labeled fiscal year.** 0.1.x
  joined directory data one school year forward, so fiscal year Y rows
  carried attributes (`dist_name`, `county`, `state_leaid`, `cong_dist`,
  `urbanicity` and its raw variants, `lea_type`, `lea_type_id`) from SY
  Y to Y+1 instead of SY Y-1 to Y. These now come from the same school
  year’s directory vintage, so values differ from 0.1.x wherever an
  attribute changed between adjacent years. The fix also restores the
  final operating year of districts that closed, which previously had no
  directory match and were silently dropped.
- **Massachusetts regional districts restored for FY2012-FY2015.** CCD
  miscoded every MA regional school district as a service agency for
  five consecutive directory vintages, so earlier releases had no data
  for these districts before FY2016. This release restores them via a
  vetted list of 60 NCES LEA IDs, roughly 107,000-110,000 students per
  year. Their `lea_type_id` still carries the miscoded value 4 through
  FY2016; see “Exclusions” above before filtering on it. MA regional
  vocational-technical districts remain excluded in every year (F-33
  codes their school level outside the panel’s
  elementary/secondary/unified scope).
- **Flagged zero-filled values are `NA`.** F-33 zero-fills some
  unreported items instead of using its `-1` missing code, marking them
  with an `FL_* = "M"` data-item flag. The cleaning pipeline now
  converts those flagged zero-fills to `NA` for the COVID
  (`exp_covid_*`), capital-detail, debt, fund-balance, CE fund-type, and
  expenditure-detail columns. Most visibly, COVID relief spending is
  `NA` rather than \$0 for all New York districts in every year and for
  roughly a third to half of California districts from FY2021 onward.
  Genuine reported zeros are unchanged. The revenue-adjustment inputs
  are deliberately excluded so adjusted revenue coverage is unchanged;
  `osp_pct` and the `exp_pay_*` columns retain zero-filled values where
  states did not report.
- **`year` is returned as an integer** rather than a character column.
- **Hosted data format.** The hosted datasets are gzip-compressed
  Parquet files read with `nanoparquet` (previously `.rds`), and each
  year is hosted as a separate file so only the requested years are
  downloaded. This is transparent to callers.

## Data Notes and Cautions

Users should note the following when working with the `edfinr` datasets.
For worked examples of the diagnostic flags and comparability issues
summarized here, see the “Data Quality and Comparability” article on the
package website.

- Some variables were originally coded with `-1` to indicate missing
  values; these have been replaced with `NA` during processing. An `NA`
  value means the item was not reported, not that it is zero.
- A wave of California charter schools became separate LEAs beginning in
  school year 2018-19, which sharply increases the number of California
  districts in the panel from 2019 onward. See the “Data Quality and
  Comparability” article for the full explanation and its implications
  for longitudinal analysis.
- The joined dataset represents a synthesis of data from multiple
  sources; discrepancies in source data formats may lead to minor
  variations.
- Inflation and adjustment factors (e.g., CPI adjustments) are based on
  averages and may not perfectly reflect local cost variations.
- Capital outlay is reported separately from current spending and is
  excluded from `exp_cur_total`. It is lumpy from year to year, so
  multi-year averages are recommended for cross-district comparison (see
  the “Capital and Facilities” article). Debt and fund-balance stocks
  (`debt_*`, `fund_bal_*`) are point-in-time balance-sheet levels and
  are never CPI-adjusted.
- CWIFT is a relative labor-cost index, not a price deflator, and has
  gaps that are imputed for some years (see the “CWIFT” article).
- **Caution is advised when comparing data across fiscal years due to
  potential differences in data collection and processing methods.**
