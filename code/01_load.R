by_district_raw <- read_excel("data/original_data/20180828 PE Report suppressed.xlsx", 
                          sheet = "PE Instruction District-Level", 
                          skip = 4,
                          na = c("", "s")) %>% 
  clean_names() 


by_school_raw <- read_excel("data/original_data/20180828 PE Report suppressed.xlsx",
                            sheet = "PE Instruction School-Level",
                            skip = 4,
                            na = c("", "s")) %>% 
  clean_names()

facilities_raw <- read_excel("data/original_data/20180828 PE Report suppressed.xlsx",
                         sheet = "PE Space",
                         skip = 4) %>% 
  clean_names()

teachers_raw <- read_excel("data/original_data/20180828 PE Report suppressed.xlsx",
                           sheet = "Licensed PE Teachers",
                           skip = 7) %>% 
  clean_names()

csd_dems <- read_csv("https://data.cityofnewyork.us/resource/dndd-j759.csv")
