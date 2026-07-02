# Packages
library(shiny)
library(bslib)
library(thematic)
library(shinythemes)

library(leaflet)
library(tigris)
library(sf)

library(tidyverse)

library(janitor)

# Enable automatic matching of plots to the application theme
# Use font = "auto" to automatically carry over Google Fonts or custom CSS typography
# 1. Set the underlying complete theme globally
#ggplot2::theme_set(ggplot2::theme_minimal())

# 2. Initialize thematic
#thematic_shiny(font = "auto")
# Set the default global theme to bw
theme_set(theme_bw())

# ----- Getting data n such -----
historic_districts <- read_csv("../../data/Historic Districts/historic_districts_clean4.csv")
areas <- read_csv("../../data/Historic Districts/us_areas_cleaned.csv")

by_state <- historic_districts %>% 
  group_by(state) %>% 
  summarise(total_acreage = sum(acreage_of_property, na.rm=TRUE),
            total_num_districts = n(),
            across(25:last_col(), function(x) sum(x, na.rm = TRUE))) # NEED TO ADD THE COUNTS FOR EACH CATEGORY

categories_counts <- by_state %>% 
  select(state, 4:ncol(by_state)) %>% 
  column_to_rownames(var = "state") %>%   # Promotes state from a regular column to R row name
  t() %>% # Transposes (rows become columns, columns become rows) (returns a matrix)
  as.data.frame() %>% 
  rownames_to_column(var = "category") %>% 
  mutate(category_og = category, 
         category = gsub("_", " ", str_remove(category, "aos_")),
         category_nice = str_to_title(category)) # for the user stuff so that we can get the OG

# Get state geometries
states_sf <- tigris::states(cb = TRUE, resolution = "20m") %>% 
  st_transform(crs = 4326)

# Join data to shapefile
choropleth_area_data <- states_sf %>% 
  left_join(by_state, by = c("NAME" = "state")) %>% 
  left_join(areas, by = c("NAME" = "state_or_territory")) %>% 
  mutate(total_acreage_hd = total_acreage) %>% 
  select(-total_acreage)

# Standardizing (historic district acreage by total state land acreage)
choropleth_area_data <- choropleth_area_data %>% 
  mutate(standardized_hd_acreage = total_acreage_hd/land_area_acres) 

# Color palette (UNSURE IF THIS SHOULD GO HERE OR LaTER)
my_palette <- colorNumeric(
  palette = "viridis", 
  domain = choropleth_area_data$standardized_hd_acreage,
  na.color = "transparent"
)

# Define UI -----

ui <- page_navbar(
    #theme = shinytheme("flatly"),
    title = "Historic Districts",
    
    nav_panel(
      title = "Title",
      sidebarLayout(
        position = "right",
        sidebarPanel(
          plotOutput("categories_dist")
        ),
        
        mainPanel(
          #title = "Historic Districts",
          leafletOutput("map")
        )
      )
    ),
    nav_panel(
      title = "Title2",
      sidebarLayout(
        position = "left",
        sidebarPanel(
          selectInput(
            inputId = "state_choice",
            label = "Choose state:",
            choices = c("All", sort(unique(choropleth_area_data$NAME)))
          ),
          checkboxGroupInput(
            inputId = "categories_choice",
            label = "Which categories would you like?",
            #choices = sort(categories_counts$category_og)
            choices = sort(categories_counts$category_nice)
          )
        ),
        mainPanel(
          leafletOutput("map2"),
          dataTableOutput("table2")
        )
      )
    )
  )

# ------------------------------------------------------------------------------

# ----- Define server logic -----
server <- function(input, output) {
  
  # ----- Page 2 -----
  
  # Reactive value to hold the currently filtered dataset (shared by map and table)
  districts_filtered <- reactiveVal(NULL)
  
  # Function for reaction to changing filters
  
  update_districts <- function() {
    # Get a character vector of the underlying column names
    cols_to_check <- categories_counts %>% 
      filter(category_nice %in% input$categories_choice) %>% 
      pull(category_og)
    
    # Clear previous markers to avoid duplicates
    leafletProxy("map2") %>% clearMarkers()
    
    # Filter historic districts for only those that fit the user's specifications
    if(length(cols_to_check) > 0) {
      
      filtered_data <- historic_districts %>%
        filter(if_any(all_of(cols_to_check), ~ .x == 1)) # a district shows up if it matches any selected category
      
      if(input$state_choice != "All"){
        filtered_data <- filtered_data %>% 
          filter(state == input$state_choice)
        
        filtered_states_sf <- states_sf %>% 
          filter(NAME == input$state_choice)
        
        leafletProxy("map2") %>% 
          addPolylines(data = filtered_states_sf, color = "black", opacity = 1, weight = 2)
      }
      
      # Add markers if there are datapoints to plot
      if (nrow(filtered_data) > 0) {
        leafletProxy("map2", data = filtered_data) %>% 
          addCircleMarkers(~longitude, ~latitude, popup = ~property_name, radius = 5, color = "black", fillOpacity = .5, weight = 1)
      }
      
      districts_filtered(filtered_data)
      
    } else {
      districts_filtered(NULL) # if nothing is selected then clear the table
    }
  }
  
  output$table2 <- renderDataTable({
    req(districts_filtered()) # Make sure that there is actually something to put
    districts_filtered() %>% 
      select(ref_number,	property_name,	state,	county,	city,	street_number,	area_of_significance,	external_link)
  })
  
  output$map2 <- renderLeaflet({
    leaflet() %>% 
      addProviderTiles("OpenStreetMap.HOT") %>% 
      setView(lng = -85, lat = 39.5, zoom = 4)  # set it to US to start
  })
  
  # Trigger an event every time the user changes the dropdown selection
  observeEvent(input$state_choice, {
    if(input$state_choice == "All"){
      leafletProxy("map2") %>% 
        setView(lng = -85, lat = 39.5, zoom = 4)
    } else{
      selected_polygon <- states_sf %>% filter(NAME == input$state_choice)
      bbox <- st_bbox(selected_polygon)
      
      leafletProxy("map2") %>%
        fitBounds(lng1 = bbox[["xmin"]], lat1 = bbox[["ymin"]], 
                  lng2 = bbox[["xmax"]], lat2 = bbox[["ymax"]])
    } #add another thing for alaska... not sure what's going on there
    
    update_districts()
    
  })
  
  # Trigger an event every time the user changes the checkbox selection
  observeEvent(input$categories_choice, {
    update_districts()
  })

  # ----- Page 1 -----
  
  output$map <- renderLeaflet({
    leaflet(choropleth_area_data) %>% 
      addProviderTiles("CartoDB.Positron") %>% 
      
      setView(lng = -85, lat = 39.50, zoom = 4) %>% 
      
      addPolygons(
        layerId = ~NAME, # so it takes the NAME column from choropleth_area_data
        fillColor = ~my_palette(standardized_hd_acreage),
        fillOpacity = .75,
        color = "white", # border color
        weight = 1,
        smoothFactor = 0.5 # slightly crisper borders -- default is 1 (higher values > more simplification > jaggier borders but shorter rendering)
        # add the highlight/hover and tooltip things
      ) %>% 
      
      addLegend(
        pal = my_palette,
        value = choropleth_area_data$standardized_hd_acreage, # same as values   = ~total_num_districts
        position = "bottomright",
        title = "Hist. Dist. area/state land area"
      )
  })
  
  
  # ----- MAP CLICKING STUFF -----
  
  # Getting the user input from clicking
  selected_state <- reactiveVal(NULL) # Reactive function!!!
  
  # Get the state clicked
  observeEvent(input$map_shape_click, {
    
    selected_state(input$map_shape_click$id) # value of NAME for clicked state
    
    # Get the bounding box for that state so we can zoom
    bbox_data <- choropleth_area_data[choropleth_area_data$NAME == selected_state(), "geometry"]
    bbox <- st_bbox(bbox_data)
    # ^ st_bbox() is a function in the R sf (Simple Features) package used to calculate or return the bounding box of a spatial object. It returns a named numeric vector containing the minimum and maximum coordinates (\(xmin, ymin, xmax, ymax\)) that define the rectangular extent of a spatial dataset
    
    leafletProxy("map") %>% 
      fitBounds(
        lng1 = bbox[["xmin"]], lat1 = bbox[["ymin"]],
        lng2 = bbox[["xmax"]], lat2 = bbox[["ymax"]]
      )
  })
  
  # ----- Output histogram -----
  output$categories_dist <- renderPlot({
    req(selected_state())     # Prevent error on startup when no state is clicked yet
    
    state_name <- selected_state()
    
    temp_df <- categories_counts %>% 
      rename(counts = all_of(selected_state())) %>%  # Get just the column of the state that was clicked.
      select(category, counts) %>% 
      filter(counts >0)
    
    ggplot(data = temp_df, aes(y = reorder(category, counts), x = counts)) +
      geom_col() +
      labs(
        title = selected_state(),
        y = "Category",
        x = "Counts"
      ) +
      theme_bw() #CBL -- 
  })
  
  
}

# ----- Run the app -----
shinyApp(ui = ui, server = server)




