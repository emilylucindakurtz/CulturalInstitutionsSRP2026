

library(tidygeocoder)
library(tidyverse)
library(leaflet)
library(pdftools)
library(tidytext)
library(scales)
library(tigris) 
library(rvest)
library(sf)
library(readxl)
library(geosphere)
library(leaflet.extras)

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
PowerPlants_Clean <- PowerPlants_Raw %>% mutate(City = Plant.City.Location, State = Plant.State.Location, Longitude = Plant.Longitude, Latitude = Plant.Latitude) %>%  
  select(Electric.Power.Plant.Name, 
         Operating.Utility.Name, 
         City,
         State,
         Primary.Energy.Source,
         Maximum.Summer.Capacity..Megawatts.,
         Longitude,
         Latitude) 


#write.csv(PowerPlants_Clean, "PowerPlants_Clean.csv", row.names = FALSE)
#write.csv(fortune500_Clean, "Fortune500HQ_Clean.csv", row.names = FALSE)


#Does not contain housing data for LA, AK, or CT
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
  left_join(pdf_prices, by = c("County", "State")) %>% mutate(Q4.2025.Median.Home.Price = Median.Home.Price) %>% select(-Median.Home.Price)

Fortune500_All_Housing <- fortune500_Clean %>% 
  full_join(pdf_prices, by = c("County", "State")) 


county_HPI <- read_excel("data/Industrial Institutions/hpi_at_county.xlsx", skip = 5) %>% filter(Year > 1999)


data_centers <- read_csv("data/Industrial Institutions/data_centers_tracker_Raw.csv") %>% 
  select(facility_name, address, city, state, zip, county, lat, long, status, operator_name, mw, sizerank, community_pushback)


#getting the county shapefiles
county_sf <- counties(cb = TRUE, class = "sf") %>% 
  mutate(County = tolower(NAME),
         State = tolower(STATE_NAME))

#standardizing variables for join
housing_map <- Fortune500_All_Housing %>% 
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
  full_join(unique_county_prices %>% select(County, State, Median.Home.Price), 
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
    popup = ~paste0(
      str_to_title(County), " County", "<br/>",
      "Median Home Price: ", dollar(Median.Home.Price)
      )
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
    data = (county_prices %>% drop_na()),
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


ggplot(PowerPlants_Clean, aes(x = State, fill = Primary.Energy.Source)) +
  geom_bar(position = "fill", color = "black") +
  scale_fill_brewer(palette =  "Set3") +
  theme(axis.text.x = element_text(angle = 90)) +
  labs(y = "Proportion")

#write.csv(Fortune500_Housing, "Fortune500HQ_Housing.csv", row.names = FALSE)
#write.csv(county_HPI, "county_HPI.csv", row.names = FALSE)
#write.csv(Fortune500_All_Housing, "Fortune500_Housing_All_Counties.csv", row.names = FALSE)




data_centers <- data_centers %>% mutate(
  mw_clean = parse_number(gsub("-.*", "", mw)), 
  mw_clean = ifelse(is.na(mw_clean), 0, mw_clean)) %>% 
  filter(!is.na(lat) & !is.na(long)) %>% 
  st_as_sf(coords = c("long", "lat"), crs = 4326)



powerplant_produc <- PowerPlants_Clean %>% rename(mw_capacity = Maximum.Summer.Capacity..Megawatts.) %>% 
  mutate(mw_capacity = ifelse(is.na(mw_capacity), 0, mw_capacity)) %>% 
  filter(!is.na(Latitude) & !is.na(Longitude))
US <- st_transform(US, crs = 4326)

maplibre(
  style = "https://basemaps.cartocdn.com/gl/positron-gl-style/style.json"
) %>% add_fill_layer(id = "country", 
                     source = US,
                     fill_color = "navy",
                     fill_opacity = 0.2) %>% 
  add_circle_layer(
    id = "circles",
    source = powerplant_produc,
    circle_radius = 2,
    circle_color = "red",
    circle_stroke_width = .1,
    circle_stroke_color = "black",
    cluster_options = cluster_options()
    )



heatmap_colors <- c("blue", "cyan", "limegreen", "yellow", "red")

leaflet(powerplant_produc) %>%
  addProviderTiles(providers$CartoDB.Positron) %>% 
  addCircleMarkers(
    data = powerplant_produc,
    lat = ~Latitude,
    lng = ~Longitude,
    label = ~paste0("mw capacity: ", mw_capacity),
    radius = 3,
    weight = .03,
    fillOpacity = 0,
    fillColor = "black"
  ) %>% 
  addHeatmap(
    lng = ~Longitude, 
    lat = ~Latitude, 
    intensity = ~mw_capacity, # heating by the plant's mw capacity
    blur = 10, 
    radius = 13
    ) %>% 
  addCircleMarkers(
    data = data_centers,
    lat = ~lat,
    lng = ~long,
    label = ~paste0("mw consumption: ", ifelse(mw_clean == 0, "unknown", mw_clean)),
    radius = ~rescale(mw_clean, c(3,8)),
    weight = 0,
    fillOpacity = 1,
    fillColor = "black"
  ) %>% 
  addLegend(
    position = "bottomright",
    colors = rev(heatmap_colors), 
    labels = rev(c("Low", "", "Medium", "", "High")),
    title = "Production Capacity (MW)",
    opacity = 0.7
  )



radius_meters <- 50 * 1609.34

distance_matrix <- distm(
  x = data_centers[, c("long", "lat")], 
  y = powerplant_produc[, c("Longitude", "Latitude")], 
  fun = distGeo
)

data_centers$local_mw_capacity <- apply(distance_matrix, 1, function(row_distances) {
  plants_in_range <- row_distances <= radius_meters
  sum(powerplant_produc$mw_capacity[plants_in_range], na.rm = TRUE)
})


data_centers <- data_centers %>%
  mutate(
    pct_consumed = ifelse(local_mw_capacity > 0, 
                          (mw_clean / local_mw_capacity) * 100, 
                          NA) 
  )


my_bins <- c(0, 10, 50, 100, 500) 

pal <- colorBin(
  palette = "YlOrRd",
  domain = data_centers$pct_consumed,
  bins = my_bins,
  na.color = "gray"
)

# Build the map
leaflet(data_centers) %>%
  addProviderTiles(providers$CartoDB.DarkMatter) %>%
  addCircles(
    lng = ~long, 
    lat = ~lat,
    radius = radius_meters,
    stroke = FALSE,    
    fillOpacity = 0,   
    

    highlightOptions = highlightOptions(
      stroke = TRUE, 
      color = "yellow", 
      weight = 2,
      fillOpacity = 0.1,
      bringToFront = FALSE
    )
  ) %>%
  addCircleMarkers(
    data = powerplant_produc,
    lat = ~Latitude,
    lng = ~Longitude,
    label = ~paste0("mw capacity: ", mw_capacity),
    radius = 2,
    weight = 1,
    stroke = TRUE,
    color = "white",
    fillOpacity = .5,
    fillColor = "blue"
  ) %>% 
  addCircleMarkers(
    lng = ~long, 
    lat = ~lat,
    radius = 6,
    weight = 1,
    color = "#ffffff",
    fillColor = ~pal(pct_consumed),
    fillOpacity = 0.9,
    label = ~paste0("Consumes ", ifelse(pct_consumed == 0, "unknown", round(pct_consumed, 1)), "% of local power")
  ) %>%
  addLegend(
    position = "bottomright",
    pal = pal,
    values = ~pct_consumed,
    title = "% of Local Power Consumed",
    opacity = 1
  ) 
















