# V2 HISTORIC DISTRICTS SHINY APP

# Packages
library(shiny)
library(bslib)
library(thematic)
library(shinythemes)
library(shinyWidgets)
library(plotly)

library(leaflet)
library(tigris)
library(sf)

library(tidyverse)
library(tidytext)

library(janitor)
library(readr)

# ----- Getting data n such ------

# Main historic district data!! --
historic_districts <- read_csv("../../data/Historic Districts/historic_districts_clean4.csv")
areas <- read_csv("../../data/Historic Districts/us_areas_cleaned.csv")

by_state <- historic_districts %>% 
  group_by(state) %>% 
  summarise(total_acreage = sum(acreage_of_property, na.rm=TRUE),
            total_num_districts = n(),
            across(25:last_col(), \(x) sum(x, na.rm = TRUE)))

categories_counts <- by_state %>%
  select(state, 4:ncol(by_state)) %>%
  column_to_rownames(var = "state") %>%   # Promotes state from a regular column to R row name
  t() %>% # Transposes (rows become columns, columns become rows) (returns a matrix)
  as.data.frame() %>%
  rownames_to_column(var = "category") %>%
  mutate(USA = rowSums(across(where(is.numeric)), na.rm = TRUE), # total across all US
         category_og = category,
         category = gsub("_", " ", str_remove(category, "aos_")),
         category_nice = str_to_title(category)) # for the user stuff so that we can get the OG

# ----------------------------

# Get state geometries
states_sf <- tigris::states(cb = TRUE, resolution = "20m") %>% 
  st_transform(crs = 4326)

# Get counties shape files
counties_sf <- tigris::counties(cb = TRUE) %>% 
  st_transform(crs = 4326)

# ----------------------------

# Unemployment rates ---------
# USDA
unemployment_data_usda <- read_csv("../../data/EK_general/Unemployment2023.csv")
unemployment_wider <- unemployment_data_usda %>% 
  clean_names() %>% 
  mutate(
    #separate("\d{4}")
    year = str_sub(attribute, -4, str_length(attribute)),
    attribute = str_sub(attribute, 1, -6) %>% 
      str_to_lower() #%>% 
    #str_replace_all("_", " ")
  )
# now actually pivoting wider
unemployment_wider <- unemployment_wider %>% 
  pivot_wider(
    names_from = attribute,
    values_from = value
  )
unemployment_filtered <- unemployment_wider %>% 
  filter(year == "2023")


# Getting it in a way that we can join it to the shapefile easily

county_equivs <- paste("County", 
                       "Planning Region", 
                       "Borough", 
                       "Census Area", 
                       "/municipality", 
                       "Municipality", 
                       "/city", 
                       "Parish", 
                       sep = "|")

unemployment_joinable <- unemployment_filtered %>% 
  mutate(NAMELSAD = str_remove(area_name, ",.*"), #before comma
         STUSPS = str_trim(str_replace(area_name, "^.*,",""))) %>% #after comma
  mutate(STUSPS = str_replace(STUSPS, "District of Columbia", "DC"), # fixing DC
         NAME = str_squish(str_remove_all(NAMELSAD, county_equivs)))


# could also potentially do this by dealling with the FIPS code but that would mean mutating the shapefile

# Joining USDA unemployment data to the counties data! (would do the same her prob if adding other data)
mapping_data_usda <- counties_sf %>% 
  left_join(unemployment_joinable,  by = c("NAME", "STUSPS"))

# Joining historic districts and the unemployment rate for graphing later -------------------------------------
historic_districts <- historic_districts  %>% 
  mutate(state_abbreviation = state.abb[match(state, state.name)])

# joining the unemployment rate to historic districts via the county
historic_districts <- historic_districts %>% 
  left_join(unemployment_joinable %>% 
              filter(fips_code %% 1000 != 0) %>% 
              select("NAME", "state", "unemployment_rate", "fips_code"),  
            by = c("county" = "NAME", 
                   "state_abbreviation" = "state"))


# Color pallete stuff -------------------------------------------------------

# Color pallete
pal_usda <- colorQuantile(
  #palette = "YlOrRd",
  palette = "Spectral",
  domain = mapping_data_usda$unemployment_rate,
  n=9,
  na.color = "grey",
  reverse = TRUE
)

# Prepping for fixing the legend (this and the labformat thing below were helped)
pal_usda_breaks <- quantile(mapping_data_usda$unemployment_rate, probs = seq(0, 1, length.out = 10), na.rm = TRUE)
 
# Sort of "manually" logging the color pallete and its values/labels so we can apply it to bar chart as well.
n_quants <- length(pal_usda_breaks)

# Making a tibble to refer to the quantiles -----------------------------------
# This is where I will later track the counts for each category
pal_usda_quantiles <- tibble(
  bottom_val = numeric(n_quants),
  top_val = numeric(n_quants),
  label = character(n_quants),
  color = character(n_quants),
  counts = numeric(n_quants)
)

pal_usda_quantiles[n_quants,] <- NA

for(i in 1:(n_quants-1)){
  pal_usda_quantiles[i, "bottom_val"] <- pal_usda_breaks[i]
  pal_usda_quantiles[i, "top_val"] <- pal_usda_breaks[i+1]
  pal_usda_quantiles[i,"label"] <- paste0(pal_usda_breaks[i], "% - ", pal_usda_breaks[i+1], "%")
}

pal_usda_quantiles <- pal_usda_quantiles %>%
  mutate(color = pal_usda(bottom_val))

pal_usda_quantiles <- as.data.frame(pal_usda_quantiles)

# Standardized data ---------------

# Join data to shapefile #I THINK THIS IS THE ISSUE! JOINING many to many
choropleth_area_data <- states_sf %>% 
  left_join(by_state, by = c("NAME" = "state")) %>% 
  left_join(areas, by = c("NAME" = "state_or_territory")) %>% 
  mutate(total_acreage_hd = total_acreage) %>% 
  select(-total_acreage)

# Standardizing (historic district acreage by total state land acreage)
choropleth_area_data <- choropleth_area_data %>% 
  mutate(standardized_hd_acreage = total_acreage_hd/land_area_acres*100) 

# Color palette (UNSURE IF THIS SHOULD GO HERE OR LaTER) --- def need to fix the name of this palette
my_palette <- colorNumeric(
  palette = "viridis", 
  domain = choropleth_area_data$standardized_hd_acreage,
  na.color = "transparent"
)

# Define UI -----

ui <- page_navbar(
#    theme = shinytheme("flatly"),
  theme = bs_theme(bootswatch = "lux"), # morph also goo
  #data-bs-theme="dark",
  title = "Historic Districts",
  fillable = TRUE, # Acts as page_fillable() for all tabs
    
  # Page 1 Layout
  nav_panel(
    title = "Finder",
      h2("Find historic districts"),
      p("Explanation of the page loading..."),
    
    card(
      sidebarLayout(
        position = "left",
        sidebarPanel(
          selectInput(
            inputId = "state_choice",
            label = "Choose state:",
            choices = c("All", sort(unique(choropleth_area_data$NAME)))
          ),
          pickerInput(
            inputId = "categories_choice",
            label = "Choose categories:",
            choices = sort(categories_counts$category_nice),
            multiple = TRUE,
            options = pickerOptions(
              actionsBox = TRUE, # adds select all/deselect all buttons
              liveSearch = TRUE, # allowing user to search
              size = 10 # max visible items before scrolling
            )
          ),
          textOutput("categories_dist_label_p1"),
          plotlyOutput("categories_dist_p1"),
          
        ),
        mainPanel(
          card(
            leafletOutput("map2", height=600)
          ),
          card(
            plotlyOutput("extra_layer_dist") # RENAME!
          ),
          card(
            DT::DTOutput("table2")
          )
          
        )
      )
    )
  ),
  
  # Page 2 Layout
    nav_panel(
      title = "Analysis",
      
      # CSS for scrolling below is from gemini... 
      tags$head(
        tags$style(HTML("
      /* Force the bslib card grid/container to allow natural height */
      .bslib-card, .card {
        height: auto !important;
        min-height: max-content !important;
        max-height: none !important;
      }
      /* Remove internal scrollbars from the card body */
      .card-body, .bslib-card-body {
        overflow: visible !important;
        height: auto !important;
        max-height: none !important;
        flex: none !important; /* Prevents flexbox from collapsing the body */
      }"))),
      
      card(
        card(
            mainPanel(
              h2("Title"),
              p("*Note legend situation... [will add later]"),
              card(
                leafletOutput("unemployment_map")
              )
            )
          
        ),
        
        card(
          h4("Analysis: "),
          p("This plot shows xyz")
          )
      ),
      
      # ---
      card(
        card(
        sidebarLayout(
          position = "right",
          sidebarPanel(
            card(
              textOutput("dist_state"),
              plotlyOutput("categories_dist")
            )
          ),
          mainPanel(
            h2("Standardized historic district acreage by state"),
            p("Percent of each state's land area that is filled by historic districts"),
            card(
              leafletOutput("map")
            )
          )
        )
      ),
      
      card(
        h4("Analysis: "),
        p("This plot shows the percent of each state's area that is taken up by historic districts (historic district acreage of each state divided by that state's total area)."),
        p("The choropleth map reveals there is an overwhelming concentration of historic districts on the East Coast, in particular Virginia."),
        p("Further, it is interesting to compare the distributions of most popular categories for historic districts between states. [add alaska thing]")
      )
      )
    )
    
  )

# ------------------------------------------------------------------------------

# ----- Define server logic -----
server <- function(input, output) {
  #bs_themer()
  thematic_shiny(font = "auto")
  
  # ----- Page 1 ----- Page 1 ----- Page 1 ----- Page 1 ----- Page 1 ----- Page 1 ----- Page 1 ----- Page 1 ----- Page 1 -----
  
  # Reactive value to hold the currently filtered dataset (shared by map and table)
  districts_filtered <- reactiveVal(NULL)
  
  # Reactive value to hold the current state
  selected_state_p1 <- reactiveVal(NULL) # SHOULD PROB TAKE OUT LATER!!
  
  # FUNCTION for reaction to changing filters ---------------------------------------------------------------------------
  
  update_districts <- function() {
    # Get a character vector of the underlying column names
    cols_to_check <- categories_counts %>% 
      filter(category_nice %in% input$categories_choice) %>% 
      pull(category_og)
    
    # Clear previous markers and shapes and legends to avoid duplicates
    leafletProxy("map2") %>% 
      clearMarkers() %>% 
      clearShapes() %>% 
      clearControls() # for legend
    
    # Make reactive val null if they select US instead of a specific state -- maybe change later
    # Also add shape for the state
    if(input$state_choice != "All"){
      selected_state_p1(input$state_choice)
      
      filtered_states_sf <- states_sf %>% 
        filter(NAME == input$state_choice)
      
      leafletProxy("map2") %>% 
        addPolylines(data = filtered_states_sf, color = "black", opacity = 1, weight = 2)
      
    } else{
      selected_state_p1(NULL)
    }
    
    # Filtering data based on state and types of districts
    filtered_data <- historic_districts %>%
      filter(if_any(all_of(cols_to_check), ~ .x == 1)) # a district shows up if it matches any selected category
    
    if(input$state_choice != "All"){
      filtered_data <- filtered_data %>% 
        filter(state == input$state_choice)
      
      filtered_county_geoms <- mapping_data_usda %>% 
        filter(STATE_NAME == input$state_choice) # maybe cbl and change to selected_state_p1()????
    } else {
      filtered_county_geoms <- mapping_data_usda #CBLLL
    }
    
    
    # Adding the unemployment rate -- NEED TO if else etc
    leafletProxy("map2") %>% 
      addPolygons(
        data = filtered_county_geoms,
        fillColor = ~pal_usda(unemployment_rate),
        fillOpacity = 1,
        color = "white",
        weight = 1,
        smoothFactor = .5,
      ) %>% 
      addLegend(
        pal = pal_usda,
        value = mapping_data_usda$unemployment_rate,
        position = "bottomright",
        title = "Unemployment rate (%)",
        labFormat = function(type, cuts, p){
          n <- length(pal_usda_breaks) - 1
          paste0(round(pal_usda_breaks[1:n], 1), "% - ", round(pal_usda_breaks[2:(n+1)], 1), "%")
        }
      )
      
    # Adding the full outline of the state on top (since it got covered by other things)
    if(input$state_choice != "All"){
      leafletProxy("map2") %>% 
        addPolylines(data = filtered_states_sf, color = "black", opacity = 1, weight = 2)
    }
    
    # Updating the map and the table if there are historic districts to see based on filters!
    # (if/else for the table)
    if(length(cols_to_check) > 0) {
      # Add markers if there are datapoints to plot
      if (nrow(filtered_data) > 0) { 
        leafletProxy("map2", data = filtered_data) %>% 
          addCircleMarkers(
            ~longitude, 
            ~latitude, 
            popup = ~property_name, 
            radius = 5, 
            color = "black", 
            fillOpacity = .5, 
            weight = 1
            )
      }
      
      #updating table
      districts_filtered(filtered_data)
      
    } else {
      districts_filtered(NULL) # if nothing is selected then clear the table
    }
  }
  
  output$table2 <- DT::renderDT({
    req(districts_filtered()) # Make sure that there is actually something to put
    data_to_show <- districts_filtered() %>% 
      select(ref_number,	property_name,	state,	county,	city,	street_number,	area_of_significance)
    
    DT::datatable(
      data_to_show,
      options = list(
        scrollX = TRUE,   # Enforces a horizontal scrollbar instead of stretching the page
        autoWidth = FALSE # Lets the browser scale column widths dynamically
      )
    )
    
  })
  
  output$categories_dist_p1 <- renderPlotly({
    if(is.null(selected_state_p1())){
      selected_state_p1("USA")
    }
    
    temp_df <- categories_counts %>% 
      rename(counts = all_of(selected_state_p1())) %>%  # Get just the column of the state that was clicked.
      select(category, counts) %>% 
      filter(counts >0) %>% 
      mutate(percent = counts/sum(counts),
             percent_label = paste0(round(percent*100, digits = 0), "%")) # for label!!
    
    p <- temp_df %>% 
      mutate(tooltip_text = paste(
        paste0("Category: ", category),
        paste0("Counts: ", counts),
        sep = "\n"
      )) %>% 
      
      slice_max(order_by = counts, n = 5) %>% 
      
      ggplot(aes(y = reorder(category, counts), x = counts, text = tooltip_text)) +
        geom_col() +
        scale_y_discrete(labels = scales::label_wrap(10)) +
        theme_minimal() + #CBL -- 
        theme(
          axis.text = element_text(size = 8),
          axis.title.y = element_text(margin = margin(r = 50))
        ) +
        labs(
          y = NULL,
          x = "Count"
        ) +
        geom_text(aes(label = percent_label),
                  position = position_stack(vjust = 0.5), # centers it in the bar
                  color = "white")
      
      
      #geom_text(aes(label = value), vjust = -0.5) 
    
    
    ggplotly(p, tooltip = "text")
  })
  
  
  # New TEST
  output$extra_layer_dist <- renderPlotly({
    if(selected_state_p1() == "USA"){
      temp_df <- historic_districts
    } else {
      temp_df <- historic_districts %>% 
        filter(state == selected_state_p1())
    }
    
    temp_df <- temp_df %>% 
      mutate(unemployment_color = pal_usda(unemployment_rate))
    
    p <- temp_df %>% 
      ggplot(aes(x = unemployment_rate, fill = unemployment_color)) +
      geom_histogram(binwidth = .3) +
      #xlim(0, 18) +
      scale_fill_identity()
      
      #labs(y = "Unemployment rate") +
      #scale_fill_identity()
    
    ggplotly(p)
  })
  
  # OLD VERSION 
  # output$extra_layer_dist <- renderPlotly({
  #   # need to figure out the checking etc
  #   if(selected_state_p1() == "USA"){
  #     temp_df <- historic_districts
  #   } else {
  #     temp_df <- historic_districts %>% 
  #       filter(state == selected_state_p1())
  #   }
  #   
  #   # adding the counts
  #   pal_usda_quantiles <- pal_usda_quantiles %>% 
  #     rowwise() %>%  # so that r evaluates one range at a time
  #     mutate(
  #       counts = sum(temp_df$unemployment_rate >= bottom_val & 
  #                      temp_df$unemployment_rate < (top_val),
  #                    na.rm = TRUE)
  #     ) %>% 
  #     ungroup() # removing the rowwise grouping
  #   
  #   # Since the last quantile is inclusive of its max need to make slight adjustment
  #   pal_usda_quantiles[(n_quants-1), "counts"] <- sum(
  #     temp_df$unemployment_rate >= pal_usda_quantiles$bottom_val[(n_quants-1)] &
  #       temp_df$unemployment_rate <= pal_usda_quantiles$top_val[(n_quants-1)], na.rm = TRUE)
  #   
  #   pal_usda_quantiles[n_quants, "counts"] <- sum(is.na(temp_df$unemployment_rate))
  #   
  #   p <- pal_usda_quantiles %>% 
  #     ggplot(aes(y = reorder(label, bottom_val), x = counts, fill = color)) +
  #     geom_col() +
  #     labs(y = "Unemployment rate") +
  #     scale_fill_identity()
  #   
  #   ggplotly(p)
  # })
  
  output$map2 <- renderLeaflet({
    leaflet() %>% 
      addProviderTiles("OpenStreetMap.HOT") %>% 
      setView(lng = -95.7129, lat = 37.0902, zoom = 4)
    
  })
  
  # Trigger an event every time the user changes the dropdown selection
  observeEvent(input$state_choice, {
    if(input$state_choice == "All"){
      leafletProxy("map2") %>% 
        setView(lng = -95.7129, lat = 37.0902, zoom = 4)
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
    
  }, ignoreNULL = FALSE) # this ensures that if there is nothing selected it still runs the function YAY!
  
  
  
  
  
  #-------------------------------------------------------------------------------------------------------------------------
  

  # ----- Page 2: Analysis ----- Page 2: Analysis ----- Page 2: Analysis ----- Page 2: Analysis ----- Page 2: Analysis -----
  
  output$unemployment_map <- renderLeaflet({
    leaflet() %>% 
      addProviderTiles("CartoDB.Positron") %>% 
      setView(lng = -95.7129, lat = 37.0902, zoom = 4) %>% 
      
      addPolygons(
        data = mapping_data_usda,
        fillColor = ~pal_usda(unemployment_rate),
        fillOpacity = 1,
        color = "white",
        weight = 1,
        smoothFactor = .5,
      ) %>% 
      addPolygons(
        data = states_sf,
        fill = FALSE,
        color = 'black',
        weight = 1.5,
        opacity = 1,
        smoothFactor = .5
      ) %>% 
      addCircleMarkers(
        data = st_centroid(choropleth_area_data),
        radius = choropleth_area_data$standardized_hd_acreage * 10,
        # ^ before had sqrt() thing
        stroke = FALSE, # TRY TO FIX COLOR< THE zoom thing, and other stuff...
        fillOpacity = .7
      ) %>% 
      addLegend(
        pal = pal_usda,
        value = mapping_data_usda$unemployment_rate,
        position = "bottomright",
        title = "Unemployment rate (%)",
        labFormat = function(type, cuts, p){
          n <- length(pal_usda_breaks) - 1
          paste0(round(pal_usda_breaks[1:n], 1), "% - ", round(pal_usda_breaks[2:(n+1)], 1), "%")
        }
      )
  })
  
  
  # output$unemployment_map <- renderLeaflet({
  #   leaflet() %>% 
  #     addProviderTiles("CartoDB.Positron") %>% 
  #     setView(lng = -95.7129, lat = 37.0902, zoom = 4) %>% 
  #     
  #     addPolygons(
  #       data = mapping_data_usda,
  #       fillColor = ~pal_usda(unemployment_rate),
  #       fillOpacity = 1,
  #       color = "white",
  #       weight = 1,
  #       smoothFactor = .5,
  #     ) %>% 
  #     addPolygons(
  #       data = states_sf,
  #       fill = FALSE,
  #       color = 'black',
  #       weight = 1.5,
  #       opacity = 1,
  #       smoothFactor = .5
  #     ) %>% 
  #     addLegend(
  #       pal = pal_usda,
  #       value = mapping_data_usda$unemployment_rate,
  #       position = "bottomright",
  #       title = "Unemployment rate (%)",
  #       labFormat = function(type, cuts, p){
  #         n <- length(pal_usda_breaks) - 1
  #         paste0(round(pal_usda_breaks[1:n], 1), "% - ", round(pal_usda_breaks[2:(n+1)], 1), "%")
  #       }
  #     )
  # })
  
  #--- map2 standardizedhistoric district acreage by state
  
  output$map <- renderLeaflet({
    leaflet(choropleth_area_data) %>% 
      addProviderTiles("CartoDB.Positron") %>% 
      
      setView(lng = -95.7129, lat = 37.0902, zoom = 4) %>% 
      
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
        title = paste("Key (%)")
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
  
  output$dist_state <- renderText({
    if(is.null(selected_state())){
      "Click on a state to see its top 5 historic district categories"
    } else{
      paste0("Top 5 historic district categories in ", selected_state())
    }
  })
  
  output$categories_dist <- renderPlotly({
    req(selected_state())     # Prevent error on startup when no state is clicked yet
    
    state_name <- selected_state()
    
    temp_df <- categories_counts %>% 
      rename(counts = all_of(selected_state())) %>%  # Get just the column of the state that was clicked.
      select(category, counts) %>% 
      filter(counts >0)
    
    p <- temp_df %>% 
      mutate(tooltip_text = paste(
        paste0("Category: ", category),
        paste0("Counts: ", counts),
        sep = "\n"
      )) %>% 
      slice_max(order_by = counts, n = 5) %>% 
      ggplot(aes(y = reorder(category, counts), x = counts, text = tooltip_text)) +
      geom_col() +
      scale_y_discrete(labels = scales::label_wrap(10)) +
      theme_minimal() + #CBL -- 
      theme(
        axis.text = element_text(size = 8),
        axis.title.y = element_text(margin = margin(r = 50))
        #axis.text.x = element_text(angle = 30, hjust = 0.5, vjust = 0.5)
      ) +
      labs(
        #title = paste0(selected_state(), " top 5 categories of historic districts"),
        y = NULL,
        x = "Count"
      )
    
    ggplotly(p, tooltip = "text")
  })
  
  
}

# ----- Run the app -----
shinyApp(ui = ui, server = server)




