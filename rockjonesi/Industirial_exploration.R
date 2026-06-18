

library(tidygeocoder)
library(tidyverse)
library(leaflet)

PowerPlants_Raw <- read.csv("data/Industrial Institutions/PowerPlants_Raw.csv")
fortune500 <- read.csv("data/Industrial Institutions/Fortune500HQ_Raw.csv") 

#there are power plants located in Ruerto Rico, I am filtering lat/long for only the 50 states
PowerPlants_Raw <- PowerPlants_Raw %>% 
  filter(Plant.Latitude >= 18.9 & Plant.Latitude <= 71.4,
         Plant.Longitude >= -178.4 & Plant.Longitude <= -66.9)

#companies were originally labeled like 34. name. I am cleaning it up to only be company name in a new col
fortune500 <- fortune500 %>% 
  mutate(Company = str_replace_all(Subject, "^\\s*[0-9.]+\\s*|,.*$", "")) %>% 
  filter(Latitude >= 18.9 & Latitude <= 71.4,
         Longitude >= -178.4 & Longitude <= -66.9)

# power plants
ggplot() +
  geom_point(
    data = PowerPlants_Raw, 
    aes(x = Plant.Longitude, y = Plant.Latitude), 
    color = "blue", 
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

#visualizing both PowerPlants_Raw and fortune 500 companies on 1 map
ggplot() +
  geom_point(
    data = PowerPlants_Raw, 
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
leaflet(data = PowerPlants_Raw) %>%
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
  


## fortune 500 data
addLocation <- fortune500 %>%
  reverse_geocode(
    lat = Latitude, 
    long = Longitude, 
    method = "osm", 
    full_results = TRUE
  )

fortune500_Clean <- addLocation %>% select(Company, city, state, county, Latitude, Longitude)





## PowerPlants_Raw
PowerPlants_Clean <- PowerPlants_Raw %>% select(Electric.Power.Plant.Name, 
                                      Operating.Utility.Name, 
                                      Plant.City.Location, 
                                      Plant.State.Location, 
                                      Primary.Energy.Source,
                                      Plant.Longitude,
                                      Plant.Latitude)


write.csv(PowerPlants_Clean, "PowerPlants_Clean.csv", row.names = FALSE)
write.csv(fortune500_Clean, "Fortune500HQ_Clean.csv", row.names = FALSE)





