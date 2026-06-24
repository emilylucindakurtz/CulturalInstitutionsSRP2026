library(tidyverse)
library(leaflet)

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

names(satellite_locations)

satellite_locations %>%
  count(institution_type)

dir.create("data/Satellite", showWarnings = FALSE)

write_csv(
  satellite_locations,
  "data/Satellite/satellite_locations.csv"
)

leaflet(satellite_locations) %>%
  addTiles() %>%
  addCircleMarkers(
    lng = ~longitude,
    lat = ~latitude,
    group = ~institution_type,
    radius = 3,
    fillOpacity = 0.6,
    stroke = FALSE,
    popup = ~paste0(name, "<br>", institution_type)
  ) %>%
  addLayersControl(
    overlayGroups = unique(satellite_locations$institution_type),
    options = layersControlOptions(collapsed = FALSE)
  )