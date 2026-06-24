# Packages
library(shiny)
library(bslib)

library(leaflet)
library(tigris)
library(sf)

library(tidyverse)

library(janitor)

# Getting data n such -----
historic_districts <- read_csv("../../data/Historic Districts/historic_districts_clean4.csv")
areas <- read_csv("../../data/Historic Districts/us_areas_cleaned.csv")

by_state <- historic_districts %>% 
  group_by(state) %>% 
  summarise(total_acreage = sum(acreage_of_property, na.rm=TRUE),
            total_num_districts = n(),
            across(25:last_col(), \(x) sum(x, na.rm = TRUE))) # NEED TO ADD THE COUNTS FOR EACH CATEGORY

categories_counts <- by_state %>% 
  select(state, 4:ncol(by_state)) %>% 
  column_to_rownames(var = "state") %>%   
  # ^ Promotes state from a regular column to R row name
  t() %>% # Transposes (rows become columns, columns become rows) (returns a matrix)
  as.data.frame() %>% 
  rownames_to_column(var = "category") %>% 
  mutate(category = gsub("_", " ", str_remove(category, "aos_")))

# Get state geometries
states_sf <- tigris::states(cb = TRUE, resolution = "20m")

# Join data to shapefile
map_data <- states_sf %>% 
  left_join(by_state, by = c("NAME" = "state")) %>% 
  left_join(areas, by = c("NAME" = "state_or_territory")) %>% 
  mutate(total_acreage_hd = total_acreage) %>% 
  select(-total_acreage)

# Standardizing (historic district acreage by total state land acreage)
map_data <- map_data %>% 
  mutate(standardized_hd_acreage = total_acreage_hd/land_area_acres) 

# Color palette (UNSURE IF THIS SHOULD GO HERE OR LaTER)
my_palette <- colorNumeric(
  palette = "viridis", 
  domain = map_data$standardized_hd_acreage,
  na.color = "transparent"
)

# Define UI -----
ui <- page_fluid(
  titlePanel("Historic Districts"),
  
  sidebarLayout(
    position = "right",
    
    sidebarPanel(
      plotOutput("categories_dist")
    ),
    
    mainPanel(
      title = "Historic Districts",
      leafletOutput("map")
    )
  )
  
)

# Define server logic -----
server <- function(input, output) {
  
  output$categories_dist <- renderPlot({
    ggplot()
  })
    
  output$map <- renderLeaflet({
    leaflet(map_data) %>% 
      addProviderTiles("CartoDB.Positron") %>% 
      
      setView(lng = -85, lat = 39.50, zoom = 4) %>% 
      
      addPolygons(
        layerId = ~NAME, # so it takes the NAME column from map_data
        fillColor = ~my_palette(standardized_hd_acreage),
        fillOpacity = .75,
        color = "white", # border color
        weight = 1,
        smoothFactor = 0.5, # slightly crisper borders -- default is 1 (higher values > more simplification > jaggier borders but shorter rendering)
        # add the highlight/hover and tooltip things
      ) %>% 
      
      addLegend(
        pal = my_palette,
        value = map_data$standardized_hd_acreage, # same as values   = ~total_num_districts
        position = "bottomright",
        title = "Hist. Dist. area/state land area"
      )
  })
  
  # MAP CLICKING STUFF -----
  
  # Getting the user input from clicking
  selected_state <- reactiveVal(NULL) # Reactive function!!!
  
  # Get the state clicked
  observeEvent(input$map_shape_click, {
    
    selected_state(input$map_shape_click$id) # value of NAME for clicked state
    
    # Get the bounding box for that state so we can zoom
    bbox_data <- map_data[map_data$NAME == selected_state(), "geometry"]
    bbox <- st_bbox(bbox_data)
    # ^ st_bbox() is a function in the R sf (Simple Features) package used to calculate or return the bounding box of a spatial object. It returns a named numeric vector containing the minimum and maximum coordinates (\(xmin, ymin, xmax, ymax\)) that define the rectangular extent of a spatial dataset
    
    leafletProxy("map") %>% 
      fitBounds(
        lng1 = bbox[["xmin"]], lat1 = bbox[["ymin"]],
        lng2 = bbox[["xmax"]], lat2 = bbox[["ymax"]]
      )
  })
  
  # Output histogram
  output$categories_dist <- renderPlot({
    #selected_state()
    temp_df <- categories_counts %>% 
      rename(counts = selected_state()) %>% 
      select(category, counts) %>% 
      filter(counts >0)
      
    ggplot(data = temp_df, aes(y = reorder(category, counts), x = counts)) +
      geom_col() +
      labs(
        title =selected_state(),
        y = "Category",
        x = "Counts"
      )
  })
  

}

# Run the app -----
shinyApp(ui = ui, server = server)