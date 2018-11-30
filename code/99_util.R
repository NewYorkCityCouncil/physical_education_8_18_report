make_dem_map <- function(demo, pal) {
  
  district_percs <- by_district_long %>% 
    filter(dem == demo, measure %in% c("num_less", "num_required")) %>% 
    spread(measure, value) %>% 
    group_by(district, dem_value) %>% 
    summarize(num_less = sum(num_less),
              num_required = sum(num_required)) %>% 
    mutate(perc = num_less/(num_less + num_required)) %>% 
    select(district, dem_value, perc)
  
  
  dat <- by_district_long %>% 
    filter(dem == demo, measure == "perc_less") %>%
    as.data.frame() %>%
    group_by(district, dem_value) %>% 
    nest() %>% 
    left_join(district_percs, by = c("district", "dem_value")) %>% 
    mutate(plots = pmap(list(data, district, perc), ~ggplot(..1, aes(grade_level, value)) + 
                          geom_col(width = .9, fill = "#2C4D8D") + 
                          scale_y_continuous(labels = scales::percent, limits = c(0,1)) +
                          scale_x_continuous(breaks = 0:12, limits = c(-.5, 12.5), labels = c("K", 1:12)) +
                          labs(title = paste("District", ..2),
                               subtitle = paste0(round(..3*100), "%", " of students without enough P.E."),
                               x = "Grade",
                               y = "% of students without enough P.E.",
                               caption = "No data") + 
                          theme_bw() + 
                          theme(axis.text.x = element_text(color = ifelse(0:12 %in% ..1$grade_level, "black", "red")),
                                plot.caption = element_text(color = "red")))) %>% 
    left_join(districts, by = c("district" = "SchoolDist")) %>% 
    st_sf() %>% 
    st_transform(crs = "+proj=longlat +datum=WGS84")
  
# pal <- colorNumeric("RdYlBu", 
  #                     domain = range(dat$mean),
  #                     reverse = TRUE)
  
  if(all(dat$dem_value %in% c("TRUE", "FALSE"))) {
    dat <- dat %>% 
      mutate(dem_value = case_when(
        dem_value == "TRUE" ~ demo,
        dem_value == "FALSE" ~ paste("Non", demo, sep = "-")
      ))
  }
  
  map <- dat %>%
    leaflet() %>% 
    addProviderTiles("CartoDB.Positron") %>% 
    addPolygons(fillColor = ~pal(perc), fillOpacity = .8, stroke = FALSE, group = ~dem_value,
                popup = ~popupGraph(plots, width = 300, height = 300)) %>% 
    # addLayersControl(baseGroups = ~unique(dem_value), position = "topright", options = layersControlOptions(collapsed = FALSE)) %>% 
    addLegend(position = "bottomleft", pal = pal, values = ~perc, 
              labFormat = labelFormat(suffix = "%", 
                                      transform = function(x) x*100),
              title = "Average percentage<br>of students") %>% 
    identity()
  
  if (length(unique(dat$dem_value)) > 1){
    map <- map %>%
      addLayersControl(baseGroups = ~unique(dem_value), position = "topright", options = layersControlOptions(collapsed = FALSE))
  }
  
  # htmlwidgets::saveWidget(map, file = "~/physical_education/results/district_map.html")
  map
}
