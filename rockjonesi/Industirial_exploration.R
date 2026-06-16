

library(tidyverse)
library(leaflet)

powerplants <- read.csv("data/Industrial Institutions/PowerPlants.csv")
fortune500 <- read.csv("data/Industrial Institutions/Fortune500HQ.csv") 

#there are power plants located in Ruerto Rico, I am filtering lat/long for only the 50 states
powerplants <- powerplants %>% 
  filter(Plant.Latitude >= 18.9 & Plant.Latitude <= 71.4,
         Plant.Longitude >= -178.4 & Plant.Longitude <= -66.9)

#companies were originally labeled like 34. name. I am cleaning it up to only be company name in a new col
fortune500 <- fortune500 %>% 
  mutate(Company = str_replace_all(Subject, "^\\s*[0-9.]+\\s*|,.*$", "")) %>% 
  filter(Latitude >= 18.9 & Latitude <= 71.4,
         Longitude >= -178.4 & Longitude <= -66.9)

# power plants
powerplants
ggplot() +
  geom_point(
    data = powerplants, 
    aes(x = Plant.Longitude, y = Plant.Latitude), 
    color = "blue", 
    size = 0.5, 
    alpha = 0.3
  ) +
  labs(x = "Longitude",
       y = "Latitude") +
  theme_minimal()

# fortune 500 companies
ggplot() +
  geom_point(
    data = fortune500, 
    aes(x = Longitude, y = Latitude), 
    color = "#b60a1b",
    alpha = 0.6
  ) +
  labs(x = "Longitude",
       y = "Latitude") +
  theme_minimal()

#visualizing both powerplants and fortune 500 companies on 1 map
powerplants
ggplot() +
  geom_point(
    data = powerplants, 
    aes(x = Plant.Longitude, y = Plant.Latitude), 
    color = "blue", 
    size = 0.5, 
    alpha = 0.3
  ) +
  geom_point(
    data = fortune500, 
    aes(x = Longitude, y = Latitude), 
    color = "red",
    alpha = 0.6,
    size = 0.5
  ) +
  labs(x = "Longitude",
       y = "Latitude") +
  theme_minimal()

#interactive EDA that includes both data sets, blue dots are power plants, red are fortune 500 companies
leaflet(data = powerplants) %>%
  addTiles() %>%
  addCircleMarkers(
    lng = ~Plant.Longitude,
    lat = ~Plant.Latitude,
    popup = ~Primary.Energy.Source,
    clusterOptions = markerClusterOptions(),
    color = "blue"
  ) %>% 
addCircleMarkers(
  data = fortune500,
  lng = ~Longitude,
  lat = ~Latitude,
popup = ~Company,
clusterOptions = markerClusterOptions(),
color = "red")
  




