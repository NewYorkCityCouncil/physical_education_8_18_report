
# Find district percentages
district_percs <- by_district_long %>% 
  filter(measure %in% c("num_less", "num_required")) %>% 
  spread(measure, value) %>% 
  group_by(district, dem_value, dem) %>% 
  summarize(num_less = sum(num_less),
            num_required = sum(num_required)) %>% 
  mutate(perc = num_less/(num_less + num_required)) %>% 
  select(district, dem_value, perc, dem)


tmp <- by_district_long %>% 
  filter(measure == "perc_less") %>%
  as.data.frame() %>%
  group_by(district, dem_value, dem) %>% 
  nest() %>% 
  left_join(district_percs, by = c("district", "dem", "dem_value")) %>% 
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
  select(-data, - plots)

# Find top n-th school in each dem 
ranks <- function(x) {
  tmp %>% 
  ungroup() %>% 
  group_by(dem, dem_value) %>% 
  arrange(desc(perc)) %>% 
    mutate(n = x) %>% 
  slice(x)
}

ranks_df <- map_df(1:3, ranks)

ranks_df %>% 
  ungroup() %>% 
  arrange(dem, dem_value, n) %>% 
  select(rank = n, dem, dem_value, district, perc) %>% 
  knitr::kable()

# Find bottom n-th schools in each dem
ranks2 <- function(x) {
  tmp %>% 
    ungroup() %>% 
    group_by(dem, dem_value) %>% 
    arrange(perc) %>% 
    mutate(n = x) %>% 
    slice(x)
}

ranks_df2 <- map_df(1:3, ranks2)
ranks_df2 %>% ungroup() %>% 
  arrange(dem, dem_value, n) %>% 
  select(rank = n, dem, dem_value, district, perc) %>% 
  knitr::kable()

