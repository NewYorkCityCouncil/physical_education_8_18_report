# Physical Education in NYC Public Schools
Nick Solomon

2018-11-13

***

This project analyzes data contained in the August 2018 DOE physical education report. The main issues of concern are how demographic informationa and facilities availability effects the amount of physical education students recieve.

## Dependencies

The following R code will install necessary software dependencies.

```r
packages <- c(
  "tidyverse",
  "sf",
  "leaflet",
  "readxl",
  "janitor",
  "mapview",
  "scales"
)

install.packages(packages)
```

Datasets required are:

- [DOE Phys Ed report](https://infohub.nyced.org/reports-and-policies/government/intergovernmental-affairs/physical-education-reporting)
- [CSD shapefiles](https://data.cityofnewyork.us/Education/School-Districts/r8nu-ymqj)

All code expects datasets to be in `data/original_data` folder.