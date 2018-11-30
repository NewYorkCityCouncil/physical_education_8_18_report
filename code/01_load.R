# Load district level data
by_district_raw <- read_excel("data/original_data/20180828 PE Report suppressed.xlsx", 
                          sheet = "PE Instruction District-Level", 
                          skip = 4,
                          na = c("", "s")) %>% 
  clean_names() 

# Load school level data
by_school_raw <- read_excel("data/original_data/20180828 PE Report suppressed.xlsx",
                            sheet = "PE Instruction School-Level",
                            skip = 4,
                            na = c("", "s")) %>% 
  clean_names()

# Load facilities data
facilities_raw <- read_excel("data/original_data/20180828 PE Report suppressed.xlsx",
                         sheet = "PE Space",
                         skip = 4) %>% 
  clean_names()

# Load teachers data
teachers_raw <- read_excel("data/original_data/20180828 PE Report suppressed.xlsx",
                           sheet = "Licensed PE Teachers",
                           skip = 7) %>% 
  clean_names()

# Load district demographic data
csd_dems <- read_csv("https://data.cityofnewyork.us/resource/dndd-j759.csv")
