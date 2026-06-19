library(tidyverse)

fortune500 <- read_csv("data/Industrial Institutions/Fortune500HQ.csv")
powerplants <- read_csv("data/Industrial Institutions/PowerPlants.csv")
sportsvenues <- read_csv("data/Sports Venues/Sportsvenues.csv")

names(fortune500)
names(powerplants)
names(sportsvenues)

fortune500_clean <- fortune500 %>%
  transmute(
    name = Subject,
    institution_type = "Fortune 500 HQ",
    latitude = Latitude,
    longitude = Longitude
  )

powerplants_clean <- powerplants %>%
  transmute(
    name = `Electric Power Plant Name`,
    institution_type = "Power Plant",
    latitude = `Plant Latitude`,
    longitude = `Plant Longitude`
  )

sportsvenues_clean <- sportsvenues %>%
  transmute(
    name = Name,
    institution_type = "Sports Venue",
    latitude = Latitude,
    longitude = Longitude
  )

satellite_locations <- bind_rows(
  fortune500_clean,
  powerplants_clean,
  sportsvenues_clean
) %>%
  filter(!is.na(latitude), !is.na(longitude))

satellite_locations %>%
  count(institution_type)

dir.create("data/Satellite", showWarnings = FALSE)

write_csv(
  satellite_locations,
  "data/Satellite/satellite_locations.csv"
)