

library(tidyverse)
library(pdftools)
library(tidytext)

#importing pdf of "the List" with the goal of extracting venue capacity
raw_text <- pdf_text("data/Sports Venues/stadiums.pdf")

#each line of text in the pdf corresponds to a single venue
#cleaning each line into individual rows in a df
pdf_venue <- data.frame(
  raw_content = raw_text
) %>%
  separate_rows(raw_content, sep = "\r?\n") %>%
  mutate(raw_content = str_trim(raw_content)) %>% 
filter(str_detect(raw_content, ".*-.*\\(.*\\)"))

#extracting venue name and it's corresponding capacity
#each line contains the venue name after the last hyphen, and capacity in following parentheses
name_capacity <- pdf_venue %>%
  extract(
    col = raw_content,
    into = c("Name", "capacity"),
    regex = ".*-\\s*(.*?)\\s*\\(([^)]+)\\)")



venues <- read.csv("data/Sports Venues/Sportsvenues.csv") %>% select(1,3,4)

#there are issues with duplicates: many venue have the same name, but can be uniquely
#identified if paired with capacity or long/lat info. However, there are no unique
#identifiers shared between the two data sets. This means we must break the join process into 
#multiple steps:

# identify and pull the duplicate venue names
duplicate_names <- venues %>% 
  count(Name) %>% 
  filter(n > 1) %>% 
  pull(Name)

#find all unique venue information from the location and capacities datasets
unique_loc <- venues %>% filter(!Name %in% duplicate_names) %>% mutate(Name = fct_collapse(Name, 
                             "Georgia State Convocation Center" = 
                               c("Georgia State Convocation Center",
                                 "GSU Convocation Center"),
                             "Memorial Athletic and Convocation Center" = 
                               c("Memorial Athletic and Convocation Center",
                                 "Memorial Athletic & Convocation Center"),
                             "Williams Athletics and Assembly Center" = 
                               c("Williams Athletics and Assembly Center",
                                 "Williams Athletics & Assembly Center"),
                             "William R. Johnson Coliseum" =
                               c("William R Johnson Coliseum",
                                 "William R. Johnson Coliseum"),
                             "UWM Panther Arena" = 
                               c("UW-Milwaukee Panther Arena",
                                 "UWM Panther Arena"),
                             "Valley Children’s Stadium" = 
                               c("Valley Children’s Stadium",
                                 "Valley Children's Stadium"),
                             "UC Stadium at Laidley Field" = 
                               c("UC Stadium at Laidley Field",
                                 "UC Football Stadium"),
                             "Tony’s Pizza Event Center" =
                               c("Tony’s Pizza Event Center",
                                 "Tony's Pizza Events Center"),
                             "The Dome at America’s Center" =
                               c("The Dome at America’s Center",
                                 "The Dome at America's Center"),
                             "Strahan Arena" = 
                               c("Strahan Coliseum",
                                 "Strahan Arena"),
                             "Sports Illustrated Stadium" =
                               c("Sports Illustrated Stadium",
                                 "Sports Illustrated"),
                             "Solider Field" =
                               c("Solider Field",
                                 "Soldier Field"),
                             "SJB Pavilion at Ole Miss" =
                               c("SJB Pavilion at Ole Miss",
                                 "SJB Pavilion"),
                             "SeatGeek Stadium" = 
                               c("SeatGeek Stadium",
                                 "SeatGeak Stadium"),
                             "Sargent’s Stadium at the Point" =
                               c("Sargent’s Stadium at the Point",
                                 "Sargent's Stadium at the Point"),
                             "S.B. Ballard Stadium" = 
                               c("S.B. Ballard Stadium",
                                 "S.B Ballard Stadium"),
                             "Rose Bowl Stadium" = 
                               c("Rose Bowl Stadium",
                                 "Rose Bowl"),
                             "Rock Creek Tennis Center" =
                               c("Rock Creek Tennis Center",
                                 "Rock Creek Park Tennis Center"),
                             "Robert and Janet Vackar Stadium" = 
                               c("Robert and Janet Vackar Stadium",
                                 "Robert & Janet Vackar Stadium"),
                             "Recreation Athletic Facility" =
                               c("Recreation Athletic Facility",
                                 "Recreation/Athletic Facility"),
                             "Raising Cane’s River Center" = 
                               c("Raising Cane’s River Center",
                                 "Raising Cane's River Center"),
                             "PNG Field" = c("PNG Field", 
                                             "PNC Arena"),
                             "Pechanga Arena" = 
                               c("Pechanga Arena",
                                 "Pechanga Arena San Diego"),
                             "OU Credit Union O’rena" = 
                               c("OU Credit Union O’rena",
                                 "OU Credit Union O'rena"),
                             "O’Kelly-Riddick Stadium" =
                               c("Riddick Stadium", 
                                 "O’Kelly-Riddick Stadium"),
                             "O’Brate Stadium" =
                               c("O’Brate Stadium", 
                                 "O'Brate Stadium"),
                             "NOW Arena" = 
                               c("NOW Arena",
                                 "Now Arena"),
                             "Norfolk Scope Arena" =
                               c("Norfolk Scope Arena",
                                 "Norfolk Scope"),
                             "Nassau Veterans Memorial Coliseum" =
                               c("Nassau Veterans Memorial Coliseum",
                                 "Nassau Coliseum"),
                             "T-Mobile Park" = 
                               c("T-Mobile Park", 
                                 "Mobile Park"),
                             "T-Mobile Center" = 
                               c("T-Mobile Center", 
                                 "Mobile Center"),
                             "T-Mobile Arena" = 
                               c("T-Mobile Arena", 
                                 "Mobile Arena"),
                             "Mississippi Veterans Memorial Stadium" =
                               c("Mississippi Veterans Memorial Stadium",
                                 "Mississippi Vet. Memorial Stadium"),
                             "McGuirk Stadium" =
                               c("McGuirk Stadium", 
                                 "McGuirk Alumni Stadium")
  ))
unique_cap <- name_capacity %>% filter(!Name %in% duplicate_names) %>% 
  mutate(Name = fct_collapse(Name, 
                             "Georgia State Convocation Center" = 
                               c("Georgia State Convocation Center",
                                 "GSU Convocation Center"),
                             "Memorial Athletic and Convocation Center" = 
                               c("Memorial Athletic and Convocation Center",
                                 "Memorial Athletic & Convocation Center"),
                             "Williams Athletics and Assembly Center" = 
                               c("Williams Athletics and Assembly Center",
                                 "Williams Athletics & Assembly Center"),
                             "William R. Johnson Coliseum" =
                               c("William R Johnson Coliseum",
                                 "William R. Johnson Coliseum"),
                             "UWM Panther Arena" = 
                               c("UW-Milwaukee Panther Arena",
                                 "UWM Panther Arena"),
                             "Valley Children’s Stadium" = 
                               c("Valley Children’s Stadium",
                                 "Valley Children's Stadium"),
                             "UC Stadium at Laidley Field" = 
                               c("UC Stadium at Laidley Field",
                                 "UC Football Stadium"),
                             "Tony’s Pizza Event Center" =
                               c("Tony’s Pizza Event Center",
                                 "Tony's Pizza Events Center"),
                             "The Dome at America’s Center" =
                               c("The Dome at America’s Center",
                                 "The Dome at America's Center"),
                             "Strahan Arena" = 
                               c("Strahan Coliseum",
                                 "Strahan Arena"),
                             "Sports Illustrated Stadium" =
                               c("Sports Illustrated Stadium",
                                 "Sports Illustrated"),
                             "Solider Field" =
                               c("Solider Field",
                                 "Soldier Field"),
                             "SJB Pavilion at Ole Miss" =
                               c("SJB Pavilion at Ole Miss",
                                 "SJB Pavilion"),
                             "SeatGeek Stadium" = 
                               c("SeatGeek Stadium",
                                 "SeatGeak Stadium"),
                             "Sargent’s Stadium at the Point" =
                               c("Sargent’s Stadium at the Point",
                                 "Sargent's Stadium at the Point"),
                             "S.B. Ballard Stadium" = 
                               c("S.B. Ballard Stadium",
                                 "S.B Ballard Stadium"),
                             "Rose Bowl Stadium" = 
                               c("Rose Bowl Stadium",
                                 "Rose Bowl"),
                             "Rock Creek Tennis Center" =
                               c("Rock Creek Tennis Center",
                                 "Rock Creek Park Tennis Center"),
                             "Robert and Janet Vackar Stadium" = 
                               c("Robert and Janet Vackar Stadium",
                                 "Robert & Janet Vackar Stadium"),
                             "Recreation Athletic Facility" =
                               c("Recreation Athletic Facility",
                                 "Recreation/Athletic Facility"),
                             "Raising Cane’s River Center" = 
                               c("Raising Cane’s River Center",
                                 "Raising Cane's River Center"),
                             "PNG Field" = c("PNG Field", 
                                             "PNC Arena"),
                             "Pechanga Arena" = 
                               c("Pechanga Arena",
                                 "Pechanga Arena San Diego"),
                             "OU Credit Union O’rena" = 
                               c("OU Credit Union O’rena",
                                 "OU Credit Union O'rena"),
                             "O’Kelly-Riddick Stadium" =
                               c("Riddick Stadium", 
                                 "O’Kelly-Riddick Stadium"),
                             "O’Brate Stadium" =
                               c("O’Brate Stadium", 
                                 "O'Brate Stadium"),
                             "NOW Arena" = 
                               c("NOW Arena",
                                 "Now Arena"),
                             "Norfolk Scope Arena" =
                               c("Norfolk Scope Arena",
                                 "Norfolk Scope"),
                             "Nassau Veterans Memorial Coliseum" =
                               c("Nassau Veterans Memorial Coliseum",
                                 "Nassau Coliseum"),
                             "T-Mobile Park" = 
                               c("T-Mobile Park", 
                                 "Mobile Park"),
                             "T-Mobile Center" = 
                               c("T-Mobile Center", 
                                 "Mobile Center"),
                             "T-Mobile Arena" = 
                               c("T-Mobile Arena", 
                                 "Mobile Arena"),
                             "Mississippi Veterans Memorial Stadium" =
                               c("Mississippi Veterans Memorial Stadium",
                                 "Mississippi Vet. Memorial Stadium"),
                             "McGuirk Stadium" =
                               c("McGuirk Stadium", 
                                 "McGuirk Alumni Stadium")
  ))

#merge unique venues for full capacity and location information
clean_merged_subset <- unique_loc %>% 
  full_join(unique_cap, by = "Name")

#collect all the duplicate venues
venues_dup_subset <- venues %>% filter(Name %in% duplicate_names)
pdf_dup_subset  <- name_capacity %>% filter(Name %in% duplicate_names)

#add them to one large dataset to clean
full_venue <- bind_rows(
  clean_merged_subset, 
  venues_dup_subset, 
  pdf_dup_subset
)

#to investigate what duplicates need to be manually fixed
na_venue <- full_venue %>% 
  filter(if_any(everything(), is.na))

#through cross-referencing original data sources, I manually added respective capacity data to duplicate venues.
fixed_venue <- full_venue %>%
  mutate(capacity = case_when(
    Name == "Convocation Center" & format(round(Latitude, 2), nsmall = 2) == "33.57" ~ "3,600",
    Name == "Convocation Center" & format(round(Latitude, 2), nsmall = 2) == "39.32" ~ "13,080",
    Name == "Convocation Center" & format(round(Latitude, 2), nsmall = 2) == "29.58" ~ "4,080",
    Name == "Convocation Center" & format(round(Latitude, 2), nsmall = 2) == "37.02" ~ "7,200",
    Name == "Wildcat Stadium" & format(round(Latitude, 2), nsmall = 2) == "32.53" ~ "10,000",
    Name == "Wildcat Stadium" & format(round(Latitude, 2), nsmall = 2) == "43.14" ~ "11,015",
    Name == "Wildcat Stadium" & format(round(Latitude, 2), nsmall = 2) == "32.47" ~ "12,000",
    Name == "War Memorial Stadium" & format(round(Latitude, 2), nsmall = 2) == "37.01" ~ "3,750",
    Name == "War Memorial Stadium" & format(round(Latitude, 2), nsmall = 2) == "36.08" ~ "7,500",
    Name == "War Memorial Stadium" & format(round(Latitude, 2), nsmall = 2) == "41.31" ~ "29,181",
    Name == "War Memorial Stadium" & format(round(Latitude, 2), nsmall = 2) == "34.75" ~ "54,120",
    Name == "Veterans Memorial Stadium" & format(round(Latitude, 2), nsmall = 2) == "41.97" ~ "5,300",
    Name == "Veterans Memorial Stadium" & format(round(Latitude, 2), nsmall = 2) == "31.80" ~ "30,000",
    Name == "Veterans Memorial Coliseum" & format(round(Latitude, 2), nsmall = 2) == "43.05" ~ "7,890",
    Name == "Veterans Memorial Coliseum" & format(round(Latitude, 2), nsmall = 2) == "45.53" ~ "9,122",
    Name == "University Stadium" & format(round(Latitude, 2), nsmall = 2) == "33.58" ~ "10,000",
    Name == "University Stadium" & format(round(Latitude, 2), nsmall = 2) == "35.07" ~ "37,440",
    Name == "Truist Stadium" & format(round(Latitude, 2), nsmall = 2) == "36.09" ~ "5,500",
    Name == "Truist Stadium" & format(round(Latitude, 2), nsmall = 2) == "36.08" ~ "21,500",
    Name == "Toyota Field" & format(round(Latitude, 2), nsmall = 2) == "34.68" ~ "5,500",
    Name == "Toyota Field" & format(round(Latitude, 2), nsmall = 2) == "29.54" ~ "8,400",
    Name == "Toyota Center" & format(round(Latitude, 2), nsmall = 2) == "29.75" ~ "18,023",
    Name == "Toyota Center" & format(round(Latitude, 2), nsmall = 2) == "46.22" ~ "5,785",
    Name == "Titan Stadium" & format(round(Latitude, 2), nsmall = 2) == "33.89" ~ "10,000",
    Name == "Titan Stadium" & format(round(Latitude, 2), nsmall = 2) == "44.02" ~ "9,800",
    Name == "The Coliseum" & format(round(Latitude, 2), nsmall = 2) == "33.58" ~ "7,000",
    Name == "The Coliseum" & format(round(Latitude, 2), nsmall = 2) == "32.71" ~ "3,890",
    Name == "Moody Coliseum" & format(round(Latitude, 2), nsmall = 2) == "32.47" ~ "3,600",
    Name == "Moody Coliseum" & format(round(Latitude, 2), nsmall = 2) == "32.84" ~ "7,000",
    Name == "Memorial Stadium" & format(round(Latitude, 2), nsmall = 2) == "39.18" ~ "52,626",
    Name == "Memorial Stadium" & format(round(Latitude, 2), nsmall = 2) == "40.10" ~ "60,670", 
    Name == "Memorial Stadium" & format(round(Latitude, 2), nsmall = 2) == "34.68" ~ "81,500", 
    Name == "Memorial Stadium" & format(round(Latitude, 2), nsmall = 2) == "38.94" ~ "62,621", 
    Name == "Memorial Stadium" & format(round(Latitude, 2), nsmall = 2) == "33.25" ~ "12,764",
    Name == "Memorial Stadium" & format(round(Latitude, 2), nsmall = 2) == "40.82" ~ "90,000", 
    Name == "Memorial Stadium" & format(round(Latitude, 2), nsmall = 2) == "39.47" ~ "12,764", 
    Name == "Memorial Stadium" & format(round(Latitude, 2), nsmall = 2) == "33.85" ~ "11,526", 
    Name == "Memorial Stadium" & format(round(Latitude, 2), nsmall = 2) == "32.21" ~ "14,500",
    TRUE ~ capacity
  )) %>% filter(!(is.na(Latitude))) %>% 
  filter(
    (Latitude >= 24.4 & Latitude <= 49.4 & Longitude >= -125.0 & Longitude <= -66.9) | # Lower 48
      (Latitude >= 51.0 & Latitude <= 71.4 & Longitude >= -179.2 & Longitude <= -129.9) | # Alaska
      (Latitude >= 18.9 & Latitude <= 22.3 & Longitude >= -160.5 & Longitude <= -154.7)   # Hawaii
  ) %>% 
                  mutate(capacity = as.numeric(gsub(",", "", capacity)))

ggplot() +
  geom_point(
    data = fixed_venue, 
    aes(x = Longitude, y = Latitude, size = capacity, color = if_else(capacity > 20000, "blue", "red")), 
    alpha = 0.3
  ) +
  scale_color_identity() +
  scale_size_continuous(range = c(1, 5)) +
  labs(x = "Longitude",
       y = "Latitude",
       size = "Capacity") +
  theme_minimal()


write.csv(fixed_venue, "Sportsvenues_Clean.csv", row.names = FALSE)
