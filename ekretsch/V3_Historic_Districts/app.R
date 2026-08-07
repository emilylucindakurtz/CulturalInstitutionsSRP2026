# V3 HISTORIC DISTRICTS SHINY APP

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

hd_by_state <- historic_districts %>% 
  group_by(state) %>% 
  summarise(total_acreage = sum(acreage_of_property, na.rm=TRUE),
            total_num_districts = n(),
            across(25:last_col(), ~ sum(.x, na.rm = TRUE)))
# changed this ^

hd_categories_counts_by_state <- hd_by_state %>%
  select(state, 4:ncol(hd_by_state)) %>%
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
unemployment_usda <- read_csv("../../data/EK_general/Unemployment2023.csv")
unemployment_usda_wider <- unemployment_usda %>% 
  clean_names() %>% 
  mutate(
    #separate("\d{4}")
    year = str_sub(attribute, -4, str_length(attribute)),
    attribute = str_sub(attribute, 1, -6) %>% 
      str_to_lower() #%>% 
    #str_replace_all("_", " ")
  )
# now actually pivoting wider
unemployment_usda_wider <- unemployment_usda_wider %>% 
  pivot_wider(
    names_from = attribute,
    values_from = value
  )

unemployment_usda_2023 <- unemployment_usda_wider %>% 
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

unemployment_usda_2023_joinable <- unemployment_usda_2023 %>% 
  mutate(NAMELSAD = str_remove(area_name, ",.*"), #before comma
         STUSPS = str_trim(str_replace(area_name, "^.*,",""))) %>% #after comma
  mutate(STUSPS = str_replace(STUSPS, "District of Columbia", "DC"), # fixing DC
         NAME = str_squish(str_remove_all(NAMELSAD, county_equivs)))


# could also potentially do this by dealling with the FIPS code but that would mean mutating the shapefile

# Joining USDA unemployment data to the counties data! (would do the same her prob if adding other data)
unemployment_usda_23_mapping <- counties_sf %>% 
  left_join(unemployment_usda_2023_joinable,  by = c("NAME", "STUSPS"))

# Joining historic districts and the unemployment rate for graphing later -------------------------------------
historic_districts <- historic_districts  %>% 
  mutate(state_abbreviation = state.abb[match(state, state.name)])

# joining the unemployment rate to historic districts via the county
historic_districts <- historic_districts %>% 
  left_join(unemployment_usda_2023_joinable %>% 
              filter(fips_code %% 1000 != 0) %>% 
              select("NAME", "state", "unemployment_rate", "fips_code"),  
            by = c("county" = "NAME", 
                   "state_abbreviation" = "state"))


# Color palette stuff -------------------------------------------------------

# Color palette
pal_unemployment_usda_23 <- colorQuantile(
  #palette = "YlOrRd",
  palette = "Spectral",
  domain = unemployment_usda_23_mapping$unemployment_rate,
  n=9,
  na.color = "grey",
  reverse = TRUE
)

# Prepping for fixing the legend (this and the labformat thing below were helped)
pal_breaks_unemployment_usda_23 <- quantile(unemployment_usda_23_mapping$unemployment_rate, probs = seq(0, 1, length.out = 10), na.rm = TRUE)
 
# Sort of "manually" logging the color palette and its values/labels so we can apply it to bar chart as well.
n_quants <- length(pal_breaks_unemployment_usda_23)

# Making a tibble to refer to the quantiles -----------------------------------
# This is where I will later track the counts for each category
pal_quantiles_unemployment_usda_23 <- tibble(
  bottom_val = numeric(n_quants),
  top_val = numeric(n_quants),
  label = character(n_quants),
  color = character(n_quants),
  counts = numeric(n_quants)
)

pal_quantiles_unemployment_usda_23[n_quants,] <- NA

for(i in 1:(n_quants-1)){
  pal_quantiles_unemployment_usda_23[i, "bottom_val"] <- pal_breaks_unemployment_usda_23[i]
  pal_quantiles_unemployment_usda_23[i, "top_val"] <- pal_breaks_unemployment_usda_23[i+1]
  pal_quantiles_unemployment_usda_23[i,"label"] <- paste0(pal_breaks_unemployment_usda_23[i], "% - ", pal_breaks_unemployment_usda_23[i+1], "%")
}

pal_quantiles_unemployment_usda_23 <- pal_quantiles_unemployment_usda_23 %>%
  mutate(color = pal_unemployment_usda_23(bottom_val))

pal_quantiles_unemployment_usda_23 <- as.data.frame(pal_quantiles_unemployment_usda_23)

# Standardized data ---------------

# Join data to shapefile #I THINK THIS IS THE ISSUE! JOINING many to many CBLLLLLLLLLLLLLLLLLL ------------------------
hd_state_areas <- states_sf %>% 
  left_join(hd_by_state, by = c("NAME" = "state")) %>% 
  left_join(areas, by = c("NAME" = "state_or_territory")) %>% 
  mutate(total_acreage_hd = total_acreage) %>% 
  select(-total_acreage)

# Standardizing (historic district acreage by total state land acreage)
hd_state_areas <- hd_state_areas %>% 
  mutate(standardized_hd_acreage = total_acreage_hd/land_area_acres*100) 

# Color palette (UNSURE IF THIS SHOULD GO HERE OR LaTER) --- def need to fix the name of this palette
pal_hd_state_areas <- colorNumeric(
  palette = "viridis", 
  domain = hd_state_areas$standardized_hd_acreage,
  na.color = "transparent"
)

# Define UI -----

ui <- page_navbar(
#    theme = shinytheme("flatly"),
  theme = bs_theme(bootswatch = "lux"), # morph also good
  #data-bs-theme="dark",
  title = "Historic Districts",
  fillable = TRUE, # Acts as page_fillable() for all tabs
    
  # Page 1 Layout
  nav_panel(
    title = "Explorer",
      h2("Find and explore historic districts"),
      p("Explanation of the page loading..."),
    
    card(
      sidebarLayout(
        position = "left",
        sidebarPanel(
          selectInput(
            inputId = "state_choice",
            label = "Choose state:",
            choices = c("All", sort(unique(hd_state_areas$NAME)))
          ),
          pickerInput(
            inputId = "categories_choice",
            label = "Choose categories:",
            choices = sort(hd_categories_counts_by_state$category_nice),
            multiple = TRUE,
            options = pickerOptions(
              actionsBox = TRUE, # adds select all/deselect all buttons
              liveSearch = TRUE, # allowing user to search
              size = 10 # max visible items before scrolling
            )
          ),
          
          radioButtons(
            inputId = "layer2_choice",
            label = "Choose a layer for further analysis:",
            choices = list(
              "None" = NA,
              "Unemployment" = "unemployment",
              "Area (TBD -- CBL)" = "area"
            )
          ),
          tags$hr(style = "border-top: 1px solid black;"), #adds a line separator thing
          
          textOutput("categories_dist_label_p1"), 
          plotlyOutput("categories_dist_p1") 
          #plotlyOutput("layer2_dist_p1") 
        ),
        mainPanel(
          card(
            leafletOutput("explorer_map", height=600)
          ),
          card(
            textOutput("layer2_dist_label_p1"),
            plotlyOutput("layer2_dist_p1") 
          )
          #card(
          #  DT::DTOutput("hd_table_p1")
          #)
          
        )
      ),
      card(
        DT::DTOutput("hd_table_p1")
      )
    )
  ),
  
  # Page 2 Layout (COMING BACK TO THIS LATER!) -------------------------------------------------------
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
  
  # ----- Page 1 NEW ---------------------------------------------------------------------------------------------------------
  
  # Trigger the zoom, state outline, and dist plot change any time the user changes the STATE dropdown selection
  observeEvent(input$state_choice, {
    
    # 1) Change zoom
    if(input$state_choice == "All"){
      leafletProxy("explorer_map") %>% 
        setView(lng = -95.7129, lat = 37.0902, zoom = 4)
    } else{
      selected_polygon <- states_sf %>% filter(NAME == input$state_choice)
      bbox <- st_bbox(selected_polygon)
      
      leafletProxy("explorer_map") %>%
        fitBounds(lng1 = bbox[["xmin"]], lat1 = bbox[["ymin"]], 
                  lng2 = bbox[["xmax"]], lat2 = bbox[["ymax"]])
    } # add another thing for alaska potentially -- or just note it due to aleutian
    
    # 2) Change state outline
    leafletProxy("explorer_map") %>% 
      clearGroup("state_outline_group")
    
    if(input$state_choice != "All"){ 
      filtered_states_sf <- states_sf %>% 
        filter(NAME == input$state_choice) # FIX THIS!!!!!!!!!! FIX FIX FIX
      
      # ^ NEED TO DEAL WITH THIS
      leafletProxy("explorer_map") %>% 
        addPolylines(data = filtered_states_sf, 
                     group = "state_outline_group",
                     options = pathOptions(pane = "state_outline_pane"),
                     color = "black", 
                     opacity = 1, 
                     weight = 2)
    }
    
    # 3) Change the categories dist plot (text has already been done)
    # ADD
    
  })
  
  # Trigger the function for hd mapping any time the user changes the STATE or CATEGORY(s) dropdown selection
  observeEvent(list(input$state_choice, input$categories_choice), {
    # 1) First clear the old ones
    leafletProxy("explorer_map") %>% 
      clearGroup("hd_group")
    
    # 2) Mark up the new ones
    if(nrow(filtered_hd()) > 0){
      leafletProxy("explorer_map") %>% 
        addCircleMarkers(
          data = filtered_hd(),
          group = "hd_group",
          options = pathOptions(pane = "hd_pane"),
          ~longitude, 
          ~latitude, 
          popup = ~property_name, 
          radius = 5, 
          color = "black", 
          fillOpacity = .5, 
          weight = 1
        )
    }
  })
  
  # Change layer 2 and layer 2 dist when the RADIO BUTTON input changes OR if STATE changes!
  observeEvent(list(input$layer2_choice, input$state_choice), { 
    
    # 1) Changing layer 2 mapping
    # 1a) Cleaning up
    leafletProxy("explorer_map") %>% 
      clearGroup("layer2_group") %>% 
      clearControls() # for legend
    
    # 1b) Re-mapping
    if(input$layer2_choice == "unemployment"){
      leafletProxy("explorer_map") %>% 
        addPolygons(
          data = filtered_county_geoms(),
          group = "layer2_group",
          options = pathOptions(pane = "layer2_pane"),
          fillColor = ~pal_unemployment_usda_23(unemployment_rate),
          fillOpacity = 1,
          color = "white",
          weight = 1,
          smoothFactor = .5,
          #label = ~area_name
          label = paste0(filtered_county_geoms()$area_name, ": ", filtered_county_geoms()$unemployment_rate, "%") #hovering
        ) %>% 
        addLegend(
          pal = pal_unemployment_usda_23,
          value = unemployment_usda_23_mapping$unemployment_rate,
          position = "bottomright",
          title = "Unemployment rate (%)",
          labFormat = function(type, cuts, p){
            n <- length(pal_breaks_unemployment_usda_23) - 1
            paste0(round(pal_breaks_unemployment_usda_23[1:n], 1), "% - ", round(pal_breaks_unemployment_usda_23[2:(n+1)], 1), "%")
          }
        )
    }
    
    # 2) Changing layer 2 distribution
    
    # ADD!
  })
  
  # Reactive blocks ---------------------------------------------------
  
  selected_state_p1 <- reactive ({
    if(input$state_choice != "All"){
      input$state_choice
    } else {
      "the USA"
    }
    # NOT SURE IF THIS ISACCTUALLY NEEDED.... Maybe?
  }) 
  
  # Historic districts
  # Recomputes automatically whenever categories_choice or state_choice changes!
  filtered_hd <- reactive ({
    # Get a character vector of the underlying column names of categories
    cols_to_check <- hd_categories_counts_by_state %>% 
      filter(category_nice %in% input$categories_choice) %>% 
      pull(category_og)
    
    # Filtering data based on CATEGORIES
    temp_df <- historic_districts %>%
      filter(if_any(all_of(cols_to_check), ~ .x == 1)) # a district shows up if it matches any selected category
    
    # FIltering data based on STATE
    if(input$state_choice != "All"){
      temp_df <- temp_df %>% 
        filter(state == input$state_choice)
    }
    
    temp_df
  })
  
                                      # Figure out if this needs to be changed if dif layer2!!
  # County geometries
  # Recomputes whenever state_choice changes
  filtered_county_geoms <- reactive({
    filtered_county_geoms <- unemployment_usda_23_mapping
    
    if(input$state_choice != "All"){ 
      filtered_county_geoms <- filtered_county_geoms %>% 
        filter(STATE_NAME == input$state_choice)
    }
    
    filtered_county_geoms
  })
  
  # Outputs ---------------------
  output$explorer_map <- renderLeaflet({
    # Just initializing the map
    leaflet() %>% 
      addProviderTiles("OpenStreetMap.HOT") %>% 
      setView(lng = -95.7129, lat = 37.0902, zoom = 4) %>% 
      addMapPane("layer2_pane", zIndex = 410) %>% 
      addMapPane("hd_pane", zIndex = 420) %>% 
      addMapPane("state_outline_pane", zIndex = 430)
    
  })
  
  output$hd_table_p1 <- DT::renderDT({
    req(filtered_hd()) # Make sure that there is actually something to put
    if(nrow(filtered_hd()) > 0){  # This makes sure that if there are no rows then the table doesn;t show up -- CHECK BACK LATER CBL ! maybe ask her?
      data_to_show <- filtered_hd() %>% 
        select(ref_number,	property_name,	state,	county,	city,	street_number,	area_of_significance)
      DT::datatable(
        data_to_show,
        options = list(
          scrollX = TRUE,   # Enforces a horizontal scrollbar instead of stretching the page
          autoWidth = FALSE # Lets the browser scale column widths dynamically
        )
      )
    }
    
  })
  
  output$categories_dist_label_p1 <- renderText({ # FIXED
    paste0("Top 5 historic district categories in ", selected_state_p1())
  })
  
  output$layer2_dist_label_p1 <- renderText({ # FIXED - But MAYBE CHANGE LABEL???
    # ADD IF 
    paste0("Distribution of historic district counts by their corresponding county's unemployment rate in ", selected_state_p1())
  })
  
  
  # COME BACK TO DISTS! CBL especially unemployment one... 
  output$categories_dist_p1 <- renderPlotly({
    if(selected_state_p1() == "the USA"){
      temp_state <- "USA"
    } else {
      temp_state <- selected_state_p1()
    }
    
    temp_df <- hd_categories_counts_by_state %>% 
      rename(counts = all_of(temp_state)) %>%  # Get just the column of the state that was clicked.
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
  
  # output$layer2_dist_label_p1 <- renderText({ # FIXED - But MAYBE CHANGE LABEL???
  #   paste0("Distribution of historic district counts by their corresponding county's unemployment rate in ", selected_state_p1())
  # })
  
  # New TEST 
  output$layer2_dist_p1 <- renderPlotly({
    if(selected_state_p1() == "the USA"){
      temp_df <- historic_districts
    } else {
      temp_df <- historic_districts %>% 
        filter(state == selected_state_p1())
    }
    
    temp_df <- temp_df %>% 
      mutate(unemployment_color = pal_unemployment_usda_23(unemployment_rate))
    
    p <- temp_df %>% 
      ggplot(aes(x = unemployment_rate, fill = unemployment_color)) +
      geom_histogram(binwidth = .3) +
      #xlim(0, 18) +
      scale_fill_identity() +
      labs(x = "County unemployment rate",
           y = "Number of historic districts")
    #scale_fill_identity()
    
    ggplotly(p)
  })
  
  #-------------------------------------------------------------------------------------------------------------------------
  

  # ----- Page 2: Analysis ----- Page 2: Analysis ----- Page 2: Analysis ----- Page 2: Analysis ----- Page 2: Analysis -----
  
  output$unemployment_map <- renderLeaflet({
    leaflet() %>% 
      addProviderTiles("CartoDB.Positron") %>% 
      setView(lng = -95.7129, lat = 37.0902, zoom = 4) %>% 
      
      addPolygons(
        data = unemployment_usda_23_mapping,
        fillColor = ~pal_unemployment_usda_23(unemployment_rate),
        fillOpacity = 1,
        color = "white",
        weight = 1,
        smoothFactor = .5
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
        data = st_centroid(hd_state_areas),
        radius = hd_state_areas$standardized_hd_acreage * 10,
        # ^ before had sqrt() thing
        stroke = FALSE, # TRY TO FIX COLOR< THE zoom thing, and other stuff...
        fillOpacity = .7
      ) %>% 
      addLegend(
        pal = pal_unemployment_usda_23,
        value = unemployment_usda_23_mapping$unemployment_rate,
        position = "bottomright",
        title = "Unemployment rate (%)",
        labFormat = function(type, cuts, p){
          n <- length(pal_breaks_unemployment_usda_23) - 1
          paste0(round(pal_breaks_unemployment_usda_23[1:n], 1), "% - ", round(pal_breaks_unemployment_usda_23[2:(n+1)], 1), "%")
        }
      )
  })
  
  
  
  #--- explorer_map standardizedhistoric district acreage by state
  
  output$map <- renderLeaflet({
    leaflet(hd_state_areas) %>% 
      addProviderTiles("CartoDB.Positron") %>% 
      
      setView(lng = -95.7129, lat = 37.0902, zoom = 4) %>% 
      
      addPolygons(
        layerId = ~NAME, # so it takes the NAME column from hd_state_areas
        fillColor = ~pal_hd_state_areas(standardized_hd_acreage),
        fillOpacity = .75,
        color = "white", # border color
        weight = 1,
        smoothFactor = 0.5 # slightly crisper borders -- default is 1 (higher values > more simplification > jaggier borders but shorter rendering)
        # add the highlight/hover and tooltip things
      ) %>% 
      
      addLegend(
        pal = pal_hd_state_areas,
        value = hd_state_areas$standardized_hd_acreage, # same as values   = ~total_num_districts
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
    bbox_data <- hd_state_areas[hd_state_areas$NAME == selected_state(), "geometry"]
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
    
    temp_df <- hd_categories_counts_by_state %>% 
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




