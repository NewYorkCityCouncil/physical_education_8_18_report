# Load, combine, and clean facilities and school level data
school_sq_ft <- facilities_raw %>% 
  group_by(ats_code) %>% 
  summarize(total_area = sum(sq_ft), location_name = unique(location_name), 
            shared = max(shared_with_other_schools == "Y"), multi = max(space_used_for_any_other_purpose_beside_pe == "Y"))

test <- facilities_raw %>% 
  group_by(ats_code) %>% 
  summarize(total_area = sum(sq_ft))


school_area_time <- school_sq_ft %>% 
  right_join(by_school_raw %>% 
               filter(category_1 == "All Students") %>% 
               select(ats_code = dbn, school_name, grade_level, average_minutes, average_frequency), by = "ats_code")

# Is 6th grade more like 5th grade or 7th grade?
# lm(average_minutes ~ factor(grade_level), data = school_area_time) %>% summary()

school_area_time_clean <- school_area_time %>% 
  ungroup() %>% 
  mutate(
    grade_level = as.numeric(case_when(
      grade_level == "0K" ~ "0",
      TRUE ~ grade_level
    )),
    time_diff = case_when(
      grade_level <= 5 ~ average_minutes - 120, # k-5/6 reqs 120 mins
      grade_level <= 8 ~ average_minutes - 90, # 6/7-8 reqs 90
      TRUE ~ average_minutes - 180 # 9-12 reqs 180
    ),
    group = case_when(grade_level <= 5 ~ "elementary",
                      grade_level <= 8 ~ "middle",
                      TRUE ~ "high"),
    grade_level = factor(grade_level)) 
