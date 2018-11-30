# Packages
library(sf)
library(leaflet)
library(mapview)
library(purrr)
library(scales)
library(tidycensus)

# Source code folder
files <- list.files("code", pattern = "[0-9]{2}_.*\\.R$", full.names = TRUE)
sapply(files, source)

# Read CSD shapefile
districts <- st_read("data/original_data/nysd_18c") %>% 
  st_simplify(preserveTopology = TRUE, 
              dTolerance = 100) %>% 
  st_cast("MULTIPOLYGON")

# Demogrpahics in the data
dems <- c("Total", "race", "sex", "IEP", "ELL")

# Shared palette for maps
pal <- colorNumeric("RdYlBu", 
                    domain = by_district_long %>% 
                      filter(measure == "perc_less") %>% 
                      pull(value) %>% 
                      range(),
                    reverse = TRUE)

# Make and save maps
walk(dems, ~htmlwidgets::saveWidget(make_dem_map(.x, pal), file = paste0(.x, "_map.html")))

# Move maps to separate folder
if(!dir.exists("results/standalone_maps/")) dir.create("results/standalone_maps/")

walk(dems, ~file.rename(paste0(.x, "_map.html"), paste0("results/standalone_maps/", .x, "_map.html")))



