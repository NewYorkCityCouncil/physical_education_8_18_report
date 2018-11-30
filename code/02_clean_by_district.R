# Rename columns and clean grade_level
by_district <- by_district_raw %>% 
  select(-category, category = category_1,
         num_required = number_of_students_who_are_receiving_the_required_amount_of_physical_education_instruction,
         perc_required = percent,
         num_less = number_of_students_who_are_receiving_less_than_the_required_amount_of_physical_education_instruction,
         perc_less = percent_1,
         num_iep_adaptive = number_of_students_who_have_an_iep_that_recommends_adaptive_physical_education,
         perc_iep_adaptive = percent_2) %>% 
  mutate(
    grade_level = as.numeric(case_when(
      grade_level == "0K" ~ "0",
      TRUE ~ grade_level
    ))
  )

# Find number of students *without* IEP
temp_iep <- by_district %>% 
  filter(category %in% c("All Students", "IEP")) %>% 
  select(-starts_with("average"), -starts_with("perc"), -ends_with("adaptive")) 

by_district_non_iep <- temp_iep %>% 
  unite(both, num_required, num_less) %>% 
  spread(category, both) %>% 
  separate(`All Students`, c("all_required", "all_less"), convert = TRUE) %>% 
  separate(IEP, c("IEP_required", "IEP_less"), convert = TRUE) %>% 
  mutate(IEP_FALSE.required = all_required - IEP_required,
         IEP_FALSE.less = all_less - IEP_less) %>% 
  select(district, grade_level, IEP_FALSE.less, IEP_FALSE.required) %>% 
  gather(category, value, IEP_FALSE.less, IEP_FALSE.required) %>% 
  separate(category, c("category", "measure"), sep = "\\.") %>% 
  spread(measure, value) %>% 
  rename(num_less = less, num_required = required) %>% 
  mutate(perc_less = num_less/(num_less + num_required),
         perc_required = num_required/(num_less + num_required)) %>% 
  bind_rows(by_district)


# Find number of *non-ELL* students
temp_ell <- by_district %>% 
  filter(category %in% c("All Students", "ELL")) %>% 
  select(-starts_with("average"), -starts_with("perc"), -ends_with("adaptive")) 

by_district_non_ell <- temp_ell %>% 
  unite(both, num_required, num_less) %>% 
  spread(category, both) %>% 
  separate(`All Students`, c("all_required", "all_less"), convert = TRUE) %>% 
  separate(ELL, c("ELL_required", "ELL_less"), convert = TRUE) %>% 
  mutate(ELL_FALSE.required = all_required - ELL_required,
         ELL_FALSE.less = all_less - ELL_less) %>% 
  select(district, grade_level, ELL_FALSE.less, ELL_FALSE.required) %>% 
  gather(category, value, ELL_FALSE.less, ELL_FALSE.required) %>% 
  separate(category, c("category", "measure"), sep = "\\.") %>% 
  spread(measure, value) %>% 
  rename(num_less = less, num_required = required) %>% 
  mutate(perc_less = num_less/(num_less + num_required),
         perc_required = num_required/(num_less + num_required)) %>% 
  bind_rows(by_district_non_iep)

# Create long data frame
by_district_long <- by_district_non_ell %>% 
  gather("measure", "value", -(district:category)) %>% 
  mutate(category = case_when(
    category %in% c("Asian", "Black", "Hispanic", "Other", "White") ~ paste0("race_", category),
    category %in% c("Female", "Male") ~ paste0("sex_", category),
    category == "IEP" ~ "IEP_TRUE",
    category == "ELL" ~ "ELL_TRUE",
    category == "All Students" ~ "Total_TRUE",
    TRUE ~ category
  )) %>% 
  separate(category, c("dem", "dem_value"), sep = "_") %>% arrange(district, grade_level) %>% 
  drop_na(value)
  

