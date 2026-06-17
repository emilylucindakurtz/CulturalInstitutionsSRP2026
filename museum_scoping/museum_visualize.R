library(tidyverse)
library(leaflet)

museum_data <- read_csv("data/whichmuseum_details_12000_geo.csv")

museum_map_data <- museum_data %>%
  filter(!is.na(latitude), !is.na(longitude), !is.na(category))

pal <- colorFactor(
  palette = "Set1",
  domain = museum_map_data$category
)

leaflet(museum_map_data) %>%
  addTiles() %>%
  addCircleMarkers(
    data = museum_map_data,
    lng = ~longitude,
    lat = ~latitude,
    radius = 3,
    color = ~pal(category),
    stroke = FALSE,
    fillOpacity = 0.5,
    group = ~category,
    popup = ~paste0(
      "<b>", museum_name, "</b><br>",
      category, "<br>",
      full_address
    )
  ) %>%
  addLayersControl(
    overlayGroups = sort(unique(museum_map_data$category)),
    options = layersControlOptions(collapsed = FALSE)
  ) %>%
  addLegend(
    "bottomright",
    pal = pal,
    values = ~category,
    title = "Museum Category"
  )