# load data and packages
library(sf)
files <- list.files("code", pattern = "[0-9]{2}_.*\\.R$", full.names = TRUE)
sapply(files, source)

# Get number of days k-5 get gym
elem_days <- school_area_time_clean %>% 
  filter(grade_level %in% c(0, 1, 2, 3, 4, 5)) %>% 
  mutate(grade_level = ifelse(grade_level == 0, "K", as.character(grade_level))) %>% 
  mutate(days_less = 5 - average_frequency,
         caption = paste0("<strong>", location_name, ": </strong><br>",
                          round(average_frequency, 1), " Days of P.E. per week"))

# Pull school locations from open data API
school_locations <- st_read("https://data.cityofnewyork.us/resource/r2nx-nhxe.geojson?$limit=9999999") %>% 
  st_cast("POINT") %>% 
  mutate(ats_system_code = str_trim(as.character(ats_system_code)))

# color palette
pal <- colorNumeric("RdYlBu", domain = elem_days$average_frequency)

# Join elem_days to school_locations and create map file
map <- elem_days %>% 
  inner_join(school_locations , by = c("ats_code" = "ats_system_code")) %>% 
  st_as_sf() %>% 
  st_transform(crs = "+proj=longlat +datum=WGS84") %>% 
  leaflet() %>% 
  addProviderTiles("CartoDB.Positron") %>% 
  addCircleMarkers(color = ~pal(average_frequency), group = ~grade_level, popup = ~caption, radius = 1.5) %>% 
  addLegend(position = "bottomleft", pal = pal, values = ~average_frequency,
            title = "Days of PE<br>per week") %>% 
  addLayersControl(baseGroups = list("K", "1", "2", "3", "4", "5"),
                   options = layersControlOptions(collapsed = FALSE))
htmlwidgets::saveWidget(map, file = "pe_days.html")
file.rename("pe_days.html", "results/standalone_maps/pe_days.html")

# Find schools offering no PE
elem_days %>%
  group_by(ats_code) %>% 
  mutate(tmp = sum(average_frequency)) %>% 
  filter(tmp == 0) %>% 
  pull(location_name) %>% 
  unique()
# Look at them all
schools <- c( "Central Park East I", "The Michael J. Petrides School", "P.S. 035"  )  
elem_days %>%
  filter(location_name %in% schools) %>% 
  View()

# Find schools offering PE 5 days a week for all grades  
elem_days %>%
  group_by(ats_code) %>% 
  mutate(tmp = sum(average_frequency)) %>% 
  filter(tmp == n()*5) %>% 
  pull(location_name) %>% 
  unique()
