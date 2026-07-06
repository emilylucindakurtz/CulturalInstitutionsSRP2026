#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

library(shiny)
library(tidyverse)
library(sf)
library(tigris)
library(leaflet)
library(htmltools)
library(scales)

options(tigris_use_cache = TRUE)

# Load and clean IPUMS data
IPUMS_data <- read_csv("data/nhgis0002_ds272_20245_county.csv")

rename_nhgis_codes <- function(data) {
  data %>%
    rename(
      total_population = AUO6E001,
      race_total = AUO7E001,
      white = AUO7E002,
      black = AUO7E003,
      american_indian_alaska_native = AUO7E004,
      asian = AUO7E005,
      native_hawaiian_pacific_islander = AUO7E006,
      other_race = AUO7E007,
      two_or_more_races = AUO7E008,
      education_total_25plus = AUQ8E001,
      bachelors_degree = AUQ8E022,
      masters_degree = AUQ8E023,
      professional_degree = AUQ8E024,
      doctorate_degree = AUQ8E025,
      median_household_income = AURUE001
    )
}

IPUMS_data <- rename_nhgis_codes(IPUMS_data) %>%
  mutate(
    ## Any true income value is >= 0 and negatives are recoded NA
    median_household_income = ifelse(median_household_income < 0, NA_real_, median_household_income),
    GEOID = str_pad(as.character(TL_GEO_ID), 5, pad = "0"),
    pct_white = 100 * white / race_total,
    pct_black = 100 * black / race_total,
    pct_aian = 100 * american_indian_alaska_native / race_total,
    pct_asian = 100 * asian / race_total,
    pct_nhpi = 100 * native_hawaiian_pacific_islander / race_total,
    pct_two_or_more = 100 * two_or_more_races / race_total,
    pct_bachelors_plus = 100 * (bachelors_degree + masters_degree +professional_degree + doctorate_degree) / education_total_25plus)

# Variable choices exposed to the user (label = column name)
ipums_var_choices <- c(
  "Total Population" = "total_population",
  "Median Household Income ($)" = "median_household_income",
  "White alone (%)" = "pct_white",
  "Black or African American alone (%)" = "pct_black",
  "Asian alone (%)" = "pct_asian",
  "American Indian / Alaska Native alone (%)" = "pct_aian",
  "Native Hawaiian / Pacific Islander alone (%)" = "pct_nhpi",
  "Two or More Races (%)" = "pct_two_or_more",
  "Bachelor's Degree or Higher, 25+ (%)" = "pct_bachelors_plus"
)


# Add county boundaries and joining data
counties_sf_raw <- counties(cb = TRUE, resolution = "20m", year = 2024)

counties_sf <- counties_sf_raw %>%
  left_join(IPUMS_data, by = "GEOID") %>%
  filter(!is.na(total_population)) %>%
  filter(!STATEFP %in% c("60", "66", "69", "72", "78")) %>%     # drop AS, GU, MP, PR, VI coordinates
  st_transform(crs = 4326)

# Load and clean each institution dataset
### Standardized to common columns: name, latitude, longitude, type, popup

## Colleges --
colleges <- read_csv("data/joined_colleges.csv") %>%
  filter(!is.na(Latitude), !is.na(Longitude)) %>%
  transmute(
    name = College,
    latitude = Latitude,
    longitude = Longitude,
    type = college_type, # "LAC" / "HBCU"
    popup = sprintf("<strong>%s</strong><br/>%s, %s<br/>Type: %s",
                    College, City, State, college_type)
  )

college_type_choices <- sort(unique(colleges$type))

## Automotive/EV facilities --
auto_facilities <- read_csv("data/auto_ev_map.csv") %>%
  filter(!is.na(latitude), !is.na(longitude)) %>%
  transmute(
    name = facility_name,
    latitude, longitude,
    type = ifelse(EV_facility, "EV Facility", "Traditional/Other Facility"),
    popup = sprintf("<strong>%s</strong><br/>%s<br/>%s, %s<br/>%s",
                    facility_name, company, city, state, products_or_focus)
  )

auto_type_choices <- sort(unique(auto_facilities$type))

## Theaters (NRHP/LHAT) --
theaters <- read_csv("data/NRHP_LHAT_only_theaters.csv") %>%
  filter(!is.na(latitude), !is.na(longitude)) %>%
  transmute(
    name = `Property Name`,
    latitude, longitude,
    type = ifelse(LHAT_member, "LHAT Member Theater", "NRHP-Listed Only"),
    popup = sprintf("<strong>%s</strong><br/>%s, %s<br/>Listed: %s<br/>Type: %s",
                    `Property Name`, City, state, `Listed Date`,
                    ifelse(LHAT_member, "LHAT Member Theater", "NRHP-Listed Only"))
  )

theater_type_choices <- sort(unique(theaters$type))

## Opera companies --

### US state abbreviations (+DC) valid for county map
us_states <- c(state.abb, "DC")

### light cleanup of the messy `state` field - see caveats above
opera_raw <- read_csv("data/opera_america_members.csv")

clean_state <- function(x) {
  x <- str_trim(x)
  x <- recode(x,
              "California"  = "CA", "Massachusetts" = "MA", "New Jersey" = "NJ",
              "New York"    = "NY", "Ohio" = "OH", "FLORIDA" = "FL",
              "nj" = "NJ", "New york " = "NY", .default = x
  )
  x <- str_remove(x, "`")  # fixes "MD`"
  x
}

opera <- opera_raw %>%
  mutate(state = clean_state(state)) %>%
  filter(
    state %in% us_states,  # drop Canadian provinces & international
    !is.na(latitude), !is.na(longitude),
    !type %in% c("", "TEST"),
    !is.na(type)
  ) %>%
  transmute(
    name = name,
    latitude, longitude,
    type = type,
    popup = sprintf("<strong>%s</strong><br/>%s, %s<br/>Type: %s",
                    name, city, state, type)
  )

opera_type_choices <- sort(unique(opera$type))

# Spatial joineach point's county-level IPUMS values for boxplots
join_institution_to_county <- function(points_df, counties_sf) {
  ipums_cols <- unname(ipums_var_choices)
  county_lookup <- counties_sf %>% select(GEOID, all_of(ipums_cols))
  
  pts_sf <- points_df %>%
    mutate(.row_id = row_number()) %>%
    st_as_sf(coords = c("longitude", "latitude"), crs = 4326, remove = FALSE)
  
  primary <- st_join(pts_sf, county_lookup, join = st_within) %>%
    st_drop_geometry()
  
  unmatched_ids <- primary$.row_id[is.na(primary$GEOID)]
  
  if (length(unmatched_ids) > 0) {
    fallback <- pts_sf %>%
      filter(.row_id %in% unmatched_ids) %>%
      st_join(county_lookup, join = st_nearest_feature) %>%
      st_drop_geometry() %>%
      select(.row_id, GEOID, all_of(ipums_cols))
    
    primary <- rows_update(primary, fallback, by = ".row_id")
  }
  
  primary %>% select(-.row_id)
}

# Use Okabe-Ito colorblind-safe palette for consistency across levels

type_color_ramp <- c("#8B008B", "#009E73", "#0072B2", "#CC79A7", "#56B4E9",
                     "#D55E00", "#F0E442", "#999999", "#E69F00")

get_type_pal <- function(type_values) {
  lev <- sort(unique(type_values))
  cols <- type_color_ramp[seq_along(lev)]
  colorFactor(palette = cols, domain = factor(type_values, levels = lev))
}

# Map UI page for each institution
mapPageUI <- function(id, type_choices, institution_label) {
  ns <- NS(id)
  
  sidebarLayout(
    sidebarPanel(
      width = 3,
      selectInput(
        ns("ipums_var"),
        "Shade counties by:",
        choices = ipums_var_choices,
        selected = "total_population"
      ),
      checkboxGroupInput(
        ns("type_filter"),
        paste0("Show ", institution_label, " type(s):"),
        choices = type_choices,
        selected = type_choices
      ),
      hr(),
      helpText("County shading = 2020-2024 ACS 5-year estimates (IPUMS NHGIS).",
               "Points = institution locations."),
      helpText("Color bins are based on data quantiles, thus bin widths shown in the legend may look uneven."),
      if (institution_label == "opera company") {
        helpText(em("Note: non-US Opera America members (Canada, other countries) ",
                    "are excluded since they can't be matched to a US county. "))
      }
    ),
    mainPanel(
      width = 9,
      leafletOutput(ns("map"), height = "750px")
    )
  )
}

mapPageServer <- function(id, points_data) {
  moduleServer(id, function(input, output, session) {
    
    filtered_points <- reactive({
      req(input$type_filter)
      points_data %>% filter(type %in% input$type_filter)
    })
    
    output$map <- renderLeaflet({
      leaflet() %>%
        addProviderTiles(providers$CartoDB.Positron) %>%
        setView(lng = -98.5, lat = 39.8, zoom = 4) %>%
        # Dedicated pane for institution points
        addMapPane("pointsPane", zIndex = 450)
    })
    
    # Render all maps
    outputOptions(output, "map", suspendWhenHidden = FALSE)
    
    observe({
      var <- input$ipums_var
      var_label <- names(ipums_var_choices)[ipums_var_choices == var]
      values <- counties_sf[[var]]
      
      # Build bins with same number of counties for improved display of variation
      n_bins <- 7
      breaks <- quantile(values, probs = seq(0, 1, length.out = n_bins + 1),
                         na.rm = TRUE)
      breaks <- unique(breaks)       # collapse duplicate edges
      county_pal <- colorBin("YlOrRd", domain = values, bins = breaks,
                             na.color = "#f0f0f0")
      
      county_labels <- sprintf(
        "<strong>%s</strong><br/>%s: %s",
        counties_sf$NAME_E,
        var_label,
        ifelse(is.na(values), "N/A",
               formatC(round(values, 1), format = "f", digits = 1, big.mark = ","))
      ) %>% lapply(HTML)
      
      pts <- filtered_points()
      type_pal <- get_type_pal(points_data$type)
      
      leafletProxy(session$ns("map"), data = NULL, session = session) %>%
        clearShapes() %>%
        clearMarkers() %>%
        clearControls() %>%
        addPolygons(
          data = counties_sf,
          fillColor = ~county_pal(values),
          weight = 0.5, opacity = 1, color = "white", fillOpacity = 0.7,
          label = county_labels,
          labelOptions = labelOptions(textsize = "13px"),
          highlightOptions = highlightOptions(weight = 2, color = "#666",
                                              fillOpacity = 0.9, bringToFront = TRUE)
        ) %>%
        addLegend(
          pal = county_pal, values = values, opacity = 0.7,
          title = var_label, position = "bottomright",
          labFormat = labelFormat(big.mark = ",")
        ) %>%
        addCircleMarkers(
          data = pts,
          lng = ~longitude, lat = ~latitude,
          radius = 5, weight = 1, stroke = TRUE, fillOpacity = 0.9,
          color = ~type_pal(type),
          label = lapply(pts$popup, HTML),
          labelOptions = labelOptions(textsize = "12px"),
          options = pathOptions(pane = "pointsPane")
        ) %>%
        addLegend(
          pal = type_pal, values = points_data$type,
          title = "Institution Type", position = "bottomleft"
        )
    })
  })
}


# Define UI for application that draws a histogram
ui <- navbarPage(
  title = "Mapping Cultural Institutions",
  tabPanel("Colleges", mapPageUI("colleges", college_type_choices, "college")),
  tabPanel("Automotive & EV Facilities", mapPageUI("auto", auto_type_choices, "facility")),
  tabPanel("Historic Theaters", mapPageUI("theaters", theater_type_choices, "theater")),
  tabPanel("Opera Companies", mapPageUI("opera", opera_type_choices, "opera company"))
)

# Define server logic required to draw a histogram
server <- function(input, output, session) {
  mapPageServer("colleges", colleges)
  mapPageServer("auto", auto_facilities)
  mapPageServer("theaters", theaters)
  mapPageServer("opera", opera)
}
# Run the application 
shinyApp(ui, server)
