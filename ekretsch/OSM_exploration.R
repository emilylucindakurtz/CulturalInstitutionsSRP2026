# Starting to map OSM data!

# Used claude to help me with this

# Method 1: osmdata
# --> overpass API
# this has 10,118 entries? not sure if this includes non-us entries, but 
# either way, way more points are mapped in the US than with the other method

# Packages
library(osmdata)
library(tidyverse)

# Murals
murals <- opq(bbox = c(-125, 24, -66, 50), timeout = 120) %>% 
  add_osm_feature(key = "artwork_type", value = "mural") %>% 
  osmdata_sf() %>% 
  (function(x) bind_rows(x$osm_points, x$osm_polygons))()

write.csv(murals, "murals.csv")

ggplot(murals) +
  geom_sf(size = 0.5, alpha = 0.6, color = "steelblue") +
  coord_sf(xlim = c(-125, -66), ylim = c(24, 50)) +  # ensure it just maps continental US since I was having issues earlier
  theme_minimal() +
  labs(title = "Murals in the US (OpenStreetMap) osmdata result")

# Method 2: osmextract
# osmextract method -- I prefer this one
# For whatever reason this one only has 201 entries...

library(osmextract)
library(dplyr)

# Downloads the full US PBF (~10GB) — big but one-time
us <- oe_get(
  "United States of America", # downloads the .pbf file from Geofabrik. only has to be downloaded the first time this is run.
  layer = "points", # read only the points layer of the .pbf file, rather than other ones like the lines and polygons
  query = "SELECT * FROM points WHERE other_tags LIKE '%mural%'" # SQL query -- only loads the rows where other_tags has "mural" somewhere -- this is much much much faster than loading it all into R and then filtering (which could crash R)
)

ggplot(us) +
  geom_sf(size = 0.5, alpha = 0.6, color = "steelblue") +
  theme_minimal() +
  labs(title = "Murals in the US (OpenStreetMap) osmextract result")


# method 2 extended
# this below resulted in 600

murals_points <- oe_get(
  "United States of America",
  layer = "points",
  query = "SELECT * FROM points WHERE other_tags LIKE '%artwork_type\"=>\"mural%'"
)

murals_lines <- oe_get(
  "United States of America",
  layer = "lines",
  query = "SELECT * FROM lines WHERE other_tags LIKE '%artwork_type\"=>\"mural%'"
)

murals_polygons <- oe_get(
  "United States of America",
  layer = "multipolygons",
  query = "SELECT * FROM multipolygons WHERE other_tags LIKE '%artwork_type\"=>\"mural%'"
)

# Convert lines and polygons to centroids so geometry types match
murals_lines <- st_centroid(murals_lines)
murals_polygons <- st_centroid(murals_polygons)

murals <- bind_rows(murals_points, murals_lines, murals_polygons)

# Mapping newspapers (trying and failing)

# This is unfortunately definitely not the dataset we would want since this includes newspaper recycling, newspaper vending machines, etc.... :(
us_newspapers <- oe_get(
  "United States of America", # downloads the .pbf file from Geofabrik. only has to be downloaded the first time this is run.
  layer = "points", # read only the points layer of the .pbf file, rather than other ones like the lines and polygons
  query = "SELECT * FROM points WHERE other_tags LIKE '%newspaper%'" # SQL query -- only loads the rows where other_tags has "mural" somewhere -- this is much much much faster than loading it all into R and then filtering (which could crash R)
)

ggplot(us_newspapers) +
  geom_sf(size = 0.5, alpha = 0.6, color = "steelblue") +
  theme_minimal() +
  labs(title = "Newspapers in OSM")


# Claude info:
# The main OSM tags for news outlets are:
#  - office=newspaper — newspaper offices
#  - office=news_agency — wire services like AP, Reuters
#  - amenity=studio with studio=television or studio=radio — TV/radio stations

# Worth noting that OSM coverage of news outlets is spottier than murals — a lot of outlets just aren't tagged, so the data will be incomplete compared to something like a commercial business directory.

