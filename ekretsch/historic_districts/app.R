# Packages
library(shiny)
library(bslib)

library(leaflet)
library(tigris)

library(tidyverse)

# Getting data n such -----
historic_districts <- read_csv("../../data/Historic Districts/historic_districts_clean4.csv")
areas <- read_csv("../../data/Historic Districts/us_areas_cleaned.csv")

by_state <- historic_districts %>% 
  group_by(state) %>% 
  summarise(total_acreage = sum(acreage_of_property, na.rm=TRUE),
            total_num_districts = n(),
            across(25:last_col(), \(x) sum(x, na.rm = TRUE))) # NEED TO ADD THE COUNTS FOR EACH CATEGORY

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
  # Reactive function!!!
  
  # Getting the user input from clicking
  selected_state <- reactiveVal(NULL)
  
  # Get the state clicked
  observeEvent(input$map_shape_click, {
    selected_state(input$map_shape_click$id) # value of NAME for clicked state
  })
  
  # Output histogram
  output$categories_dist <- renderPlot({
    #selected_state()
    
    temp_tibble <- tibble(
      cat = names(by_state[,25:ncol(by_state)]),
      count = by_state[selected_state(), 25:ncol(by_state)]
    )
    ggplot(data = temp_tibble, aes(x = cat, y = count)) +
      geom_col()
  })
  

}

# Run the app -----
shinyApp(ui = ui, server = server)





# Old faithful

# Define UI for application that draws a histogram
# ui <- fluidPage(
#   
#   # Application title
#   titlePanel("Old Faithful Geyser Data"),
#   
#   # Sidebar with a slider input for number of bins 
#   sidebarLayout(
#     sidebarPanel(
#       sliderInput("bins",
#                   "Number of bins:",
#                   min = 1,
#                   max = 50,
#                   value = 30)
#     ),
#     
#     # Show a plot of the generated distribution
#     mainPanel(
#       plotOutput("distPlot")
#     )
#   )
# )
# 
# # Define server logic required to draw a histogram
# server <- function(input, output) {
#   
#   output$distPlot <- renderPlot({
#     # generate bins based on input$bins from ui.R
#     x    <- faithful[, 2]
#     bins <- seq(min(x), max(x), length.out = input$bins + 1)
#     
#     # draw the histogram with the specified number of bins
#     hist(x, breaks = bins, col = 'darkgray', border = 'white',
#          xlab = 'Waiting time to next eruption (in mins)',
#          main = 'Histogram of waiting times')
#   })
# }
# 
