

library(tidygeocoder)
library(tidyverse)
library(leaflet)
library(pdftools)
library(tidytext)
library(scales)
library(tigris) 
library(sf)

PowerPlants_Raw <- read.csv("data/Industrial Institutions/PowerPlants_Raw.csv")
fortune500 <- read.csv("data/Industrial Institutions/Fortune500HQ_Raw.csv") 

#there are power plants located in Ruerto Rico, I am filtering lat/long for only the 50 states
PowerPlants_Raw <- PowerPlants_Raw %>% 
  filter(Plant.Latitude >= 18.9 & Plant.Latitude <= 71.4,
         Plant.Longitude >= -178.4 & Plant.Longitude <= -66.9)

#companies were originally labeled like "34. name". I am cleaning it up to only be company name in a new col
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

fortune500_Clean <- addLocation  %>% mutate(City = city, State = state, County = county, County = str_remove(County, "\\s+County")) %>% 
  select(Company, City, State, County, Latitude, Longitude) %>% mutate(County = case_when(County == "Saint Louis" ~ "St. Louis",
                                                                                          TRUE ~ County))

## PowerPlants_Raw
PowerPlants_Clean <- PowerPlants_Raw %>% mutate(City = Plant.City.Location, State = Plant.State.Location, Longitude = Plant.Longitude, Latitude = Plant.Latitude) %>%  select(Electric.Power.Plant.Name, 
                                      Operating.Utility.Name, 
                                      City,
                                      State,
                                      Primary.Energy.Source,
                                      Longitude,
                                      Latitude) 


write.csv(PowerPlants_Clean, "PowerPlants_Clean.csv", row.names = FALSE)
write.csv(fortune500_Clean, "Fortune500HQ_Clean.csv", row.names = FALSE)

raw_text <- pdf_text("data/Industrial Institutions/2025Q4HousingPrices.pdf")

pdf_prices <- data.frame(
  raw_content = raw_text
) %>%
  separate_rows(raw_content, sep = "\r?\n") %>%
  mutate(raw_content = str_trim(raw_content)) %>% slice(-c(1:3)) %>% 
  mutate(
    State = str_trim(str_extract(raw_content, "(?<=,\\s)[^$]+")),
    County = str_extract(raw_content, "^.*(?=\\s+County,)"),
    Median.Home.Price = parse_number(str_extract(raw_content, "\\$\\s*[0-9,]+"))
  ) %>% 
  mutate(
    County = str_remove(County, paste0("^", State, "\\s+"))) %>% select(-raw_content) %>% drop_na()

Fortune500_Housing <- fortune500_Clean %>% 
  left_join(pdf_prices, by = c("County", "State"))





#getting the county shapefiles
county_sf <- counties(cb = TRUE, class = "sf") %>% 
  mutate(County = tolower(NAME),
         State = tolower(STATE_NAME))

#standardizing variables for join
housing_map <- Fortune500_Housing %>% 
  mutate(County = tolower(County),
         State = tolower(State))

#aggregating to deal with many-to-many join errors
unique_county_prices <- housing_map %>%
  group_by(State, County) %>%
  summarize(
    Median.Home.Price = mean(Median.Home.Price, na.rm = TRUE), 
    .groups = "drop"
  )

##join housing prices to county shapefile information
county_prices <- county_sf %>%
  inner_join(unique_county_prices %>% select(County, State, Median.Home.Price), 
             by = c("State","County")) 

pal <- colorNumeric(
  palette = "YlOrRd", 
  domain = county_prices$Median.Home.Price
)

leaflet() %>%
  addTiles() %>%
  addPolygons(
    data = county_prices,
    fillColor = ~pal(Median.Home.Price),
    fillOpacity = 0.6,
    color = "black",
    weight = 1,
    smoothFactor = 0.5,
  ) %>%
  addMarkers(
    data = housing_map,
    lng = ~Longitude, 
    lat = ~Latitude,
    popup = ~paste0(
      Company, "<br/>",
      City, ", ", str_to_title(State), "<br/>",
      dollar(Median.Home.Price)
    ),
    label = ~Company
  ) %>%
  addLegend(
    data = county_prices,
    position = "bottomright",
    pal = pal,
    values = ~Median.Home.Price,
    title = "2025 Median Home Price",
    labFormat = labelFormat(prefix = "$"),
    opacity = 0.8
  )



powerplant_types <- PowerPlants_Clean %>% group_by(State) %>% count(Primary.Energy.Source)
  

ggplot(PowerPlants_Clean, aes(x = State, fill = Primary.Energy.Source)) +
  geom_bar(color = "black") +
  facet_wrap(~ Primary.Energy.Source, scales = "free_y") +
  scale_fill_brewer(palette =  "Set3") +
  theme(axis.text.x = element_text(angle = 90)) +
  labs(y = "Count")


ggplot(Clean_Data, aes(x = State, fill = Primary.Energy.Source)) +
  geom_bar(position = "fill", color = "black") +
  scale_fill_brewer(palette =  "Set3") +
  theme(axis.text.x = element_text(angle = 90)) +
  labs(y = "Proportion")

write.csv(Fortune500_Housing, "Fortune500HQ_Housing", row.names = FALSE)

