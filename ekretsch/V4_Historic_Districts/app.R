# V4 HISTORIC DISTRICTS SHINY APP

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

county_equivs <- paste("County", 
                       "Planning Region",
                       "Borough",
                       "Census Area",
                       "/municipality",
                       "Municipality",
                       "/city",
                       "Parish",
                       sep = "|")


# Unemployment rates ---------
# BLS LAUS -----
unemployment_bls <- read_csv("../../data/EK_general/annual_bls_laus_1990_2025.csv")

unemployment_bls_2025_joinable <- unemployment_bls %>% 
  mutate(STUSPS = str_replace(STUSPS, "District of Columbia", "DC"), # fixing DC
         NAME = str_squish(str_remove_all(NAMELSAD, county_equivs))) %>%  
  filter(year == 2025)

unemployment_bls_2025 <- counties_sf %>% 
  left_join(unemployment_bls_2025_joinable, by = c("NAMELSAD", "STUSPS")) # removed , "NAME"

# Joining historic districts and the unemployment rate for graphing later -------------------------------------
historic_districts <- historic_districts  %>% 
  mutate(state_abbreviation = state.abb[match(state, state.name)])

# joining the unemployment rate to historic districts via the county
historic_districts <- historic_districts %>% 
  left_join(unemployment_bls_2025_joinable %>% 
              #filter(area_type_code == "F") %>% 
              select("NAME", "STUSPS", "unemployment_percent", "year"),  
            by = c("county" = "NAME", 
                   "state_abbreviation" = "STUSPS"))

# Color palette stuff -------------------------------------------------------

# Color palette BLS
pal_unemployment_bls_25 <- colorQuantile(
  #palette = "YlGnBu",           #also tried piyg and ylor and didn't love either #  spectral good
  palette = "Spectral",
  domain = unemployment_bls_2025$unemployment_percent,
  n = 10,
  na.color = "grey",
  reverse = TRUE
) 
  
# Fixing BLS palette legend
pal_breaks_unemployment_bls <- quantile(unemployment_bls_2025$unemployment_percent, probs = seq(0, 1, length.out = 11), na.rm = TRUE)

# Sort of "manually" logging the color pallete and its values/labels so we can apply it to bar chart as well.
n_quants <- length(pal_breaks_unemployment_bls)

# Making a tibble to refer to the quantiles
pal_bls_quantiles <- tibble(
  bottom_val = numeric(n_quants),
  top_val = numeric(n_quants),
  label = character(n_quants),
  color = character(n_quants),
  counts = numeric(n_quants)
)

pal_bls_quantiles[n_quants,] <- NA


for(i in 1:(n_quants-1)){
  pal_bls_quantiles[i, "bottom_val"] <- pal_breaks_unemployment_bls[i]
  pal_bls_quantiles[i, "top_val"] <- pal_breaks_unemployment_bls[i+1]
  pal_bls_quantiles[i,"label"] <- paste0(pal_breaks_unemployment_bls[i], "% - ", pal_breaks_unemployment_bls[i+1], "%")
}

pal_bls_quantiles <- pal_bls_quantiles %>%
  mutate(color = pal_unemployment_bls_25(bottom_val))

pal_bls_quantiles <- as.data.frame(pal_bls_quantiles)



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
  title = "Historic Districts Across the US",
  fluid = TRUE,
  fillable = TRUE, # Acts as page_fillable() for all tabs
  
  # Home Page
  nav_panel(
    title = "Home",
    h2("📍 Welcome to", em("Historic Districts Across the US")),

    p("This is part of Emily Kurtz’s 2026 Summer Project,", 
      strong("Mapping Cultural Institutions in the United States."),
      br(),
      br(),
      em("Historic Districts Across the US "),
      "offers an interactive map and analysis of the historic districts listed on the National Park Service’s ", 
      a("National Register of Historic Places.", href = "https://www.nps.gov/subjects/nationalregister/index.htm"),
      br(),
      br(),
      "The two ",
      span("main goals of this project", style = "background-color: #cee8ed;"),
      " were to",
      br(),
      "1) strengthen my skills in data collection, cleaning, analysis, and visualization with R, and",
      br(),
      "2) investigate geographic, economic, and/or demographic patterns of historic districts.",
      br(),
      br(),
      span("I ultimately focused on", style = "background-color: #cee8ed;"),
      br(),
      "a) overall geographic distribution of historic districts across the US,",
      br(),
      "b) the categories (types) of historic districts, and",
      br(),
      "c) unemployment rate data.",
      br()
    ),
    tags$hr(style = "border-top: 1px solid black;"),
    p(
      "🔎 To find and explore historic districts and data visualizations, navigate to the “Explore” tab.",
      br(),
      "💡 To read my analysis of these patterns and distributions, click on the “Analysis” tab.",
      br(),
      "📋 To access the data used on this (sub) project, check out the “Data” tab.",
      br(),
      br(),
      br(),
      em(strong("Thank you for visiting, and happy exploring! ﹏𓊝﹏"))
    )
  ),  
  # Page 1 Layout
  nav_panel(
    title = "Explorer",
      h2("Find and explore historic districts"),

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
              "Unemployment rate (2025)" = "unemployment",
              "Percent of state area filled by historic districts" = "standardized_hd_area"
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
      h2("Analysis"),
      
      #CSS for scrolling below is from gemini...
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
        sidebarLayout(
          position = "right",
          sidebarPanel(
            width = 2,
            tags$figure(
            tags$img(src = "nps.png", style = "width: 100%; height: auto; display: block;"),
            tags$figcaption("The National Park Service provides the NRHP.")
            )
          ),
          mainPanel(
            width = 10,
            h2("Introduction", style = "background-color: #cee8ed"),
            br(),
            br(),
            p("When I began looking into cultural institutions to investigate for this project, I stumbled upon the ",
              a("National Register of Historic Places (NRHP)", href = "https://www.nps.gov/subjects/nationalregister/index.htm"),
              "while hoping to find a list of ethnic enclaves (such as Chinatown or Little Ethiopia).
            Although the NRHP is not a list of ethnic enclaves, I was astonished and intrigued by the extensive list of historic districts that I found.
              I had no idea just how much history is embedded in everyday places that I frequent, as well as the rest of the US. 
              Thus, I decided to continue down the path of historic districts.")
          ))),
        card(
          h2("Areas", style = "background-color: #cee8ed"),
          sidebarLayout(
            position = "left",
            sidebarPanel(
             #width = 2,
              tags$figure(
              tags$img(src = "overwhelming_districts.png", style = "width: 100%; height: auto; display: block;"),
              tags$figcaption("Overwhelming historic districts map.")
              )
            ),
            mainPanel(
              #width = 10,
              #h2("Areas"),
              p("Once I had completed the time-consuming task of geocoding all of the locations of the historic districts in the US, I decided to start 
                my investigation with what seemed like the most sensible use of my newly found longitude and latitude data – a geographic analysis. 
                However, the many points on my Leaflet map were far too overwhelming to make use of at face value. 
                I wanted to see what states had more historical significance via historic districts. 
                I tried out different variations on choropleth maps (one showed the number of historic districts by state, 
                another showed the area of historic districts by state…)."),
                #br(),
                p("I ended up noticing that the vast difference in ",
              a("state areas", href="https://www.census.gov/geographies/reference-files/2010/geo/state-area.html"),
              " (California = 163,695 sq mi, Massachusetts = 10,554 sq mi) resulted in misleading choropleth state maps, 
              so I decided to standardize the areas. I took the aggregated area of historic districts in each state and divided that 
              by the state’s total area, giving me the “Percent of state area filled by historic districts” layer. "
            )
          )
        )
      ),
      card(
        fluidRow(
          # Column 1: Takes up 4 out of 12 slots (1/3 of the page)
          column(width = 5, p("Misleading map -- number of historic districts by state."), img(src = "num_hd.png", style = "width: 100%; height: auto; display: block;")),
          column(width = 2, class = "text-center", p(strong("versus"))),
          column(width = 5, p("Standardized map -- percent of state consumed by historic districts."), img(src = "areas.png", style = "width: 100%; height: auto; display: block;"))
        )
      ),
      card(
        p("The standardized map emphasizes the high concentration of historic districts in Virginia. 
          Connecticut, Massachusetts, Rhode Island, Maryland, New Jersey, and Delaware also have a high percentage of their area filled by historic districts. 
          This makes sense as they were all part of the first 13 colonies, and thus have had more time to create US history. "),

        p("It is interesting to me that Georgia, South Carolina, North Carolina, Pennsylvania, and New York have far less of their land filled by historic districts. 
        Although I did not have time to do so, I would be interested in a deeper analysis of the battlefields and/or locations of battles across the US 
        to see if there is a pattern between that data and the historic district data.") # add link/highlight here!!
      ),
      card(
        fluidRow(
          column(width = 5,
                 p("I was also intrigued by the fact that Colorado has a relatively high area density of historic districts compared to the rest of the mountain west and midwest US. 
              I am unsure of why this may be, but three of the top 5 historic district categories in Colorado – commerce, exploration settlement, and industry, in conjunction 
              with some brief Colorado history (Pike’s Peak Gold Rush) led me to believe that the state’s natural resources and westward expansion may play a role. 
              Further investigation needed here as well!") #add link/highlight here!!
                 ),
          column(width = 4,
                 tags$figure(
                   tags$img(src = "colorado.png",  style = "width: 100%; height: auto; display: block;"),
                   tags$caption("CO has a relatively high percentage of its area filled by historic districts.")
                 )),
          column(width = 3,
                 tags$figure(
                   tags$img(src = "colorado_categories.png",  style = "width: 100%; height: auto; display: block;")#,
                   #tags$caption("CO's top 5 historic district categories.")
                 ))
        )
      ),
      
      # --------------------------
      card(
        h2("Categories", style = "background-color: #cee8ed"),
  
        fluidRow(
          column(width = 3,
                 tags$figure(
                   tags$img(src = "us_categories.png", style = "width: 100%; height: auto; display: block;"),
                   tags$figcaption("Most common categories in the US.")
                 )),
          column(width = 4,
                 p("As briefly mentioned in the section above, I also chose to investigate the breakdown of the most common categories of historic districts. 
            For clarification, the NRHP offers a variable detailing all of the categories that each historic district falls into, such as 
            Archaeology, Art, Commerce, Economics, etc. This was a slight area of frustration for me because I couldn't easily map each historic district 
            to one singular category (as most historic districts fall into many categories). 
            However, I made a reactive bar plot showing the top 5 most common categories in the state selected (or US, if the US is selected).
            This helped me notice that architecture is the most common category across the US, which makes sense – houses, buildings, schools…")),
          column(width = 2,
                 p("But one state in particular caught my eye: Alaska. 
              In Alaska, architecture is second to industry, exploration settlement, and commerce, which are tied for first. 
              This leads me to believe that Alaska is not only geographically disconnected from the rest of the US, 
              but also could have historic disconnections. This is another area for further analysis.")), # FURTHER analysis
          column(width = 3,
                 tags$figure(
                   tags$img(src = "alaska_categories.png", style = "width: 100%; height: auto; display: block;"),
                   tags$figcaption("Most common categories in AK -- architecture is NOT #1.")
                 ))
          
        )
      ),
      
      card(
        h2("Unemployment", style = "background-color: #cee8ed"),
        sidebarLayout(
          position = "left",
          sidebarPanel(
            width = 5,
            tags$figure(
              tags$img(src = "us_vs_hd.png", style = "width: 100%; height: auto; display: block;"),
              tags$figcaption("US county mean unemployment rate (black) versus US historic district mean unemployment rate (red)")
            )
          ),
          mainPanel(
            width = 7,
            p("Lastly, I chose to investigate unemployment through the lens of historic districts. 
          I noticed that many of the historic districts seemed to be tightly clustered around cities/more urban areas. 
          I was curious if there were any economic patterns to the locations of historic districts (could they be associated with better economic outcomes?),
          so I decided to add a layer for unemployment by county."),
            p(
              "With the map overlayed with unemployment by county, I saw that the clustered historic districts appeared to be in the counties with lower unemployment rates.
              Thus, I thought it would be interesting to create a histogram showing the distribution of the unemployment rates by county weighted by the number of historic districts that are in each county. 
              This is simply the mean of the following: each county's unemployment rate multiplied by how many historic districts are located in that county.
              The image on the left shows the weighted county mean as the red line, ~4.094%, and the unweighted county mean as the black line, ~4.233%.
              Due to time constraints I was unable to perform a proper hypothesis test for difference of means, but the slight difference indicates that this could be an interesting area for further research."
            )
          )
        )
        
      ),
      card(
        h2("Next steps", style = "background-color: #cee8ed"),
        p("As referenced in my brief analyses above, there are many unanswered questions, as well as new questions, that this project as led me to. 
          A few areas that I propose for further research include the following:"),
        tags$ul(
          tags$li("Why does Colorado have such a high historic district density compared to the rest of the surrounding states?"),
          tags$li("Why, exactly, is Alaska’s historic district category distribution so different from the rest of the US? Are there other states that are outliers? Are there better ways to categorize the historic districts in order to help with analysis/mapping?"),
          tags$li("Is the mean of historic-district-weighted county unemployment rates truly different from that of the unweighted county unemployment rates? Is this consistent across years?"),
          tags$li("Referencing the question above, is there a way to map the addition/removal of historic districts and whether there are associating patterns in unemployment rate changes?"),
          tags$li("Some of my research on this project included investigating library data. How does the distribution of libraries across the US compare to that of historic districts? Are there connections between the two?"),
          tags$li("Going back to my original search that led me to the NRHP – I’m still interested in ethnic enclaves, and their mapping across the US. How do they change when there are demographic and economic changes in areas?"),
          tags$li("One of my many struggles while doing this project was false geocoding of the historic district locations. There are simply too many for me to check manually, so is there a way for me to either fix the geocoding (such as a better package), and/or a way for the user to contribute feedback to correct issues with the page?"),
        )
        )
    )
  ),
  nav_panel(
    title = "Data",
    h2("Data"),
    card(
      h3("Historic Districts",  style = "background-color: #cee8ed"),
      tags$ul(
        tags$li("File name: historic_districts_clean4.csv"),
        tags$li("The original source was the National Register of Historic Places (NRHP) Historic Landmarks, from the National Park Service."),
        tags$li("The link to the data that I downloaded can be found here: https://www.nps.gov/subjects/nationalregister/data-downloads.htm "),
        tags$li("To download, scroll down to Spreadsheet of NRHP Listed properties (listings up to 5/22/2026) and download the .xlsx file. I then converted that to a csv and performed my cleaning and wrangling."),
        tags$li("Since the original dataset did not include the longitude and latitude of the historic districts, I had to geocoded the addresses."),
        tags$li("I used the ‘arcgis’ method from the ‘arcgisgeocode’ package as the method for the ‘geocode()’ function from ‘tidygeocoder’ package."),
        tags$li("I used this method rather than other ones such as ‘census’ or ‘osm’ because the addresses were messy/incomplete and ‘arcgis’ was the only method (that I had access) that could deal with these addresses.")
      )
    ),
    card(
      h3("State Areas",  style = "background-color: #cee8ed"),
      tags$ul(
      tags$li("File name: us_areas_cleaned.csv"),
      tags$li("To standardize the historic district areas by state, I had to first get the areas of each of the US states."),
      tags$li("I used the Census State Geographies via https://www.census.gov/geographies/reference-files/2010/geo/state-area.html"),
      tags$li("Although this data is from 2010, I decided it was the most complete and reliable as it is from the Census and includes the 5 US territories (which I wanted to include in my map)."),
      tags$li("I scraped this census page. I first checked that this was allowed by running 'paths_allowed()' on the census link, which came back ‘True’."),
      tags$li("The code used to scrape and clean is in historic_districts_exploration_1.1.qmd")
      )
    ),
    card(
      
      h3("Unemployment Rate", style = "background-color: #cee8ed"),
      tags$ul(
      tags$li("File name: annual_bls_laus_1990_2025.csv"),
      tags$li("I utilized the local-area unemployment statistics (LAUS) from the Bureau of Labor Statistics via the package ‘BLSloadR’."),
      tags$li("I filtered for only annual data (M13) and unemployment rate, and included all years from 1990-2025, though I only ended up using the 2025 data.")
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
          fillColor = ~pal_unemployment_bls_25(unemployment_percent),
          fillOpacity = 1,
          color = "white",
          weight = 1,
          smoothFactor = .5,
          #label = ~area_name
          label = paste0(filtered_county_geoms()$NAMELSAD, ": ", filtered_county_geoms()$unemployment_percent, "%") #hovering
        ) %>% 
        addLegend(
          pal = pal_unemployment_bls_25,
          value = unemployment_bls_2025$unemployment_percent,
          position = "bottomright",
          title = "Unemployment rate (%)",
          labFormat = function(type, cuts, p){
            n <- length(pal_breaks_unemployment_bls) - 1
            paste0(round(pal_breaks_unemployment_bls[1:n], 1), "% - ", round(pal_breaks_unemployment_bls[2:(n+1)], 1), "%")
          }
        )
    } else if(input$layer2_choice == "standardized_hd_area"){
      leafletProxy("explorer_map") %>% 
        addPolygons(
          data = hd_state_areas,
          group = "layer2_group",
          options = pathOptions(pane = "layer2_pane"),
          layerId = ~NAME, # so it takes the NAME column from hd_state_areas -- this is for the clicking thing that was og on page 2. potentially remove later.
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
      
    }
    
    # 2) Changing layer 2 distribution -- already below tho... figure out
    
    # ADD!
  })
  
  # Reactive blocks ---------------------------------------------------
  
  selected_state_p1 <- reactive ({
    if(input$state_choice != "All"){
      input$state_choice
    } else {
      "the US"
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
    filtered_county_geoms <- unemployment_bls_2025
    
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
  
  
  # COME BACK TO DISTS! CBL especially unemployment one... CBLLLLLLLŁLŁ
  output$categories_dist_p1 <- renderPlotly({
    if(selected_state_p1() == "the US"){
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

  output$layer2_dist_p1 <- renderPlotly({
    if(selected_state_p1() == "the US"){
      temp_df <- historic_districts
    } else {
      temp_df <- historic_districts %>% 
        filter(state == selected_state_p1())
    }
    
    temp_df <- temp_df %>% 
      mutate(unemployment_color = pal_unemployment_bls_25(unemployment_percent))
    
    p <- temp_df %>% 
      ggplot(aes(x = unemployment_percent, fill = unemployment_color)) +
      geom_histogram(binwidth = .3) +
      #geom_vline(xintercept = mean(historic_districts$unemployment_percent, na.rm = TRUE), color = "red", linetype = "dashed", linewidth = .3) +
      #geom_vline(xintercept = mean(unemployment_bls_2025$unemployment_percent, na.rm = TRUE), color = "black", linetype = "dashed", linewidth = .3) +
      
      #xlim(0, 18) +
      scale_fill_identity() +
      labs(x = "County unemployment rate",
           y = "Number of historic districts")
    #scale_fill_identity()
    
    ggplotly(p)
  })
  
  #-------------------------------------------------------------------------------------------------------------------------
  

  # ----- Page 2: Analysis ----- Page 2: Analysis ----- Page 2: Analysis ----- Page 2: Analysis ----- Page 2: Analysis -----
  
  
  
}

# ----- Run the app -----
shinyApp(ui = ui, server = server)




