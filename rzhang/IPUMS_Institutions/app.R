#
# This is a Shiny web application. Click the 'Run App' button above to start.
#

library(shiny)
library(tidyverse)
library(sf)
library(tigris)
library(leaflet)
library(htmltools)
library(scales)
library(bslib)
library(markdown)

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

# Variable choices shown to user (label = column name)
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

##  Variable choices grouped into optgroups for the dropdown UI 
ipums_var_choices_ui <- list(
  "Population & Income" = c("Total Population" = "total_population",
                            "Median Household Income ($)" = "median_household_income"),
  "Race (%)" = c("White alone" = "pct_white",
                 "Black or African American alone" = "pct_black",
                 "Asian alone" = "pct_asian",
                 "American Indian / Alaska Native alone" = "pct_aian",
                 "Native Hawaiian / Pacific Islander alone" = "pct_nhpi",
                 "Two or More Races" = "pct_two_or_more"),
  "Education (25+)" = c("Bachelor's Degree or Higher" = "pct_bachelors_plus")
)

# Add county boundaries and joining data
counties_sf_raw <- counties(cb = TRUE, resolution = "20m", year = 2024)

counties_sf <- counties_sf_raw %>%
  left_join(IPUMS_data, by = "GEOID") %>%
  filter(!is.na(total_population)) %>%
  filter(!STATEFP %in% c("60", "66", "69", "72", "78")) %>%     # drop AS, GU, MP, PR, VI coordinates
  st_transform(crs = 4326)


# Clean Institution Data
colleges <- read_csv("data/colleges_app_clean.csv")
auto_facilities <- read_csv("data/auto_facilities_app_clean.csv")
theaters <- read_csv("data/theaters_app_clean.csv")
opera <- read_csv("data/opera_app_clean.csv")

college_type_choices <- sort(unique(colleges$type))
auto_type_choices <- sort(unique(auto_facilities$type))
theater_type_choices <- sort(unique(theaters$type))
opera_type_choices <- sort(unique(opera$type))


# Spatial join each point's county-level IPUMS values for boxplots
attach_county_data <- function(points_df) {
  pts_sf <- st_as_sf(points_df, coords = c("longitude", "latitude"),
                     crs = 4326, remove = FALSE)
  
  joined <- st_join(
    pts_sf,
    counties_sf %>% select(GEOID, NAME_E, all_of(unname(ipums_var_choices))),
    join = st_within,
    left = TRUE
  )
  
  st_drop_geometry(joined)
}

colleges <- attach_county_data(colleges)
auto_facilities <- attach_county_data(auto_facilities)
theaters <- attach_county_data(theaters)
opera <- attach_county_data(opera)


# Use Okabe-Ito colorblind-safe palette for consistency across levels

type_color_ramp <- c("#D41159", "#FFD67A", "#F16EB7", "#FFB3F4", "#F57714",
                     "#730E9E", "#999999")

get_type_pal <- function(type_values) {
  lev <- sort(unique(type_values))
  cols <- type_color_ramp[seq_along(lev)]
  colorFactor(palette = cols, domain = factor(type_values, levels = lev))
}

## Match boxplot colors with the map points colors
get_type_colors <- function(type_values) {
  lev <- sort(unique(type_values))
  setNames(type_color_ramp[seq_along(lev)], lev)
}

# Map UI page for each institution
mapPageUI <- function(id, type_choices, institution_label, institution_choices) {
  ns <- NS(id)
  
  sidebarLayout(
    sidebarPanel(
      width = 3,
      
      ## Search box for mapping specific institutions
      selectizeInput(
        ns("search_institution"),
        tagList("Search for a", institution_label, ":"),
        choices = c("Type to search..." = "", institution_choices),
        options = list(placeholder = "Type to search...")
      ),
      hr(),
      
      div(
        style = "display: flex; align-items: center; gap: 6px;",
        tags$label("Shade counties by:", style = "margin-bottom: 0;"),
      ),
      selectInput(
        ns("ipums_var"),
        label = NULL,
        choices = ipums_var_choices_ui,
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
      if (institution_label == "opera company") {
        helpText(em("Non-US Opera America members (Canada, other countries) ",
                    "are excluded since they can't be matched to a US county. "))
      }
    ),
    mainPanel(
      width = 9,
      fluidRow(
        column(7, leafletOutput(ns("map"), height = "700px")),
        column(5,
               uiOutput(ns("boxplot_title")),
               plotOutput(ns("boxplot"), height = "670px"),
               div(
                 style = "display: flex; align-items: flex-start; gap: 6px;",
               )
        )
      )
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
      leaflet(options = leafletOptions(preferCanvas = TRUE)) %>%
        addProviderTiles(providers$CartoDB.Positron) %>%
        setView(lng = -98.5, lat = 39.8, zoom = 4) %>%
        # Dedicated pane for institution points
        addMapPane("pointsPane", zIndex = 450) %>%
        addMapPane("statePane", zIndex = 410) %>%
        addPolygons(
          data = states_sf,
          fill = FALSE,
          color = "#4d4d4d", weight = 1.3, opacity = 0.8,
          options = pathOptions(pane = "statePane", interactive = FALSE)
        )
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
      county_pal <- colorBin("Blues", domain = values, bins = breaks,
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
                                              fillOpacity = 0.9, bringToFront = TRUE),
          group = "counties"
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
          options = pathOptions(pane = "pointsPane"),
          group = "institutions"
        ) %>%
        addLegend(
          pal = type_pal, values = points_data$type,
          title = "Institution Type", position = "bottomleft"
        )
    })
    
    # Search box for finding the selected institution on the map
    observeEvent(input$search_institution, {
      req(input$search_institution != "")
      
      match_row <- points_data %>%
        filter(name == input$search_institution) %>%
        slice(1)
      
      req(nrow(match_row) == 1)
      
      leafletProxy(session$ns("map"), session = session) %>%
        clearGroup("search_highlight") %>%
        setView(lng = match_row$longitude, lat = match_row$latitude, zoom = 10) %>%
        addCircleMarkers(
          lng = match_row$longitude, lat = match_row$latitude,
          radius = 12, color = "#222222", weight = 3,
          fillColor = "#FFD700", fillOpacity = 0.9,
          options = pathOptions(pane = "pointsPane"),
          group = "search_highlight"
        ) %>%
        addPopups(
          lng = match_row$longitude, lat = match_row$latitude,
          popup = HTML(match_row$popup)
        )
    })
    
    ## Chart heading, rendered as HTML to show entire variable titles
    output$boxplot_title <- renderUI({
      var <- input$ipums_var
      var_label <- names(ipums_var_choices)[ipums_var_choices == var]
      tagList(
        tags$h4(paste(var_label, "by Institution Type"), style = "margin-bottom: 2px;"),
        tags$p("Value = the county each institution is located in", style = "color: #666; font-size: 0.9em; margin-top: 0;")
      )
    })
    
    # EDA boxplots: distribution of the selected IPUMS variable split by institution type
    output$boxplot <- renderPlot({
      var <- input$ipums_var
      var_label <- names(ipums_var_choices)[ipums_var_choices == var]
      
      df <- filtered_points() %>%
        filter(!is.na(.data[[var]]))
      
      req(nrow(df) > 0)
      
      type_colors <- get_type_colors(points_data$type)
      
      ## Label each x-axis category with its sample size
      counts <- table(df$type)
      x_labels <- setNames(paste0(names(counts), "\n(n=", counts, ")"),
                           names(counts))
      
      ## Log scale to prevent compression by outlier counties
      log_scale_vars <- c("total_population", "median_household_income")
      
      p <- ggplot(df, aes(x = type, y = .data[[var]], fill = type)) +
        geom_boxplot(outlier.alpha = 0.4, width = 0.6) +
        geom_jitter(width = 0.15, size = 1.5, alpha = 0.4, color = "black") +
        scale_fill_manual(values = type_colors, guide = "none") +
        scale_x_discrete(labels = x_labels) +
        coord_flip() +
        labs(x = NULL, y = var_label) +
        theme_minimal(base_size = 13) +
        theme(plot.title = element_text(face = "bold"))
      
      if (var %in% log_scale_vars) {
        p <- p +
          scale_y_log10(labels = scales::comma) +
          labs(y = paste0(var_label, " (log scale)"))
      } else {
        p <- p + scale_y_continuous(labels = scales::comma)
      }
      p
    })
    
  })
}


# UI for application
ui <- navbarPage(
  title = "Institution Location Explorer",
  id = "main_nav",   # allows path between buttons on homepage and other tabs
  selected = "Home",
  theme = bs_theme(version = 5),
  
  ## Homepage
  tabPanel("Home", fluidPage(
    div(style = "text-align: center; padding: 40px 20px 10px; max-width: 750px; margin: 0 auto;",
        h1("Institution Location Explorer"),
        p( "Explore institutions in the United States of America and how ",
           "each maps onto demographic and economic landscapes across ",
           "counties. Choose from specialized colleges, automotive & EV ", 
           "manufacturing facilities, historic theaters, and opera companies.",
           style = "font-size: 1.15em; color: #555;")
        ),
    hr(),
    h3("Institutions", style = "text-align: center; margin-top: 30px; margin-bottom: 20px;"),
    layout_columns(
      col_widths = c(3, 3, 3, 3),
      card(
        card_header(icon("graduation-cap"), " Colleges"),
        p("Liberal Arts Colleges and HBCUs across the U.S."),
        actionButton("nav_colleges", "Explore", class = "btn-outline-primary btn-sm")
      ),
      card(
        card_header(icon("car"), " Automotive & EV"),
        p("Vehicle assembly and EV manufacturing facilities."),
        actionButton("nav_auto", "Explore", class = "btn-outline-primary btn-sm")
      ),
      card(
        card_header(icon("landmark"), " Historic Theaters"),
        p("NRHP-listed and League of Historic American Theatres members."),
        actionButton("nav_theaters", "Explore", class = "btn-outline-primary btn-sm")
      ),
      card(
        card_header(icon("music"), " Opera Companies"),
        p("Opera America member companies nationwide."),
        actionButton("nav_opera", "Explore", class = "btn-outline-primary btn-sm")
      )
    ),
    div(
      style = "text-align: center; margin: 30px 0 10px;",
      actionButton("nav_blog", "Read the Blog Post \u2192", class = "btn-primary")
    )
  ),
  hr(),
  div(
    style = "max-width: 1100px; margin: 20px auto;",
    h3("Ways to navigate the app"),
    tags$ol(
      style = "font-size: 1.05em; line-height: 1.9;",
      tags$li("Select a tab above for institution type."),
      tags$li("Shade the map by any Census variable using the dropdown on the left (pick between population, income, race, or education)."),
      tags$li("Filter by type with the checkboxes (e.g. LAC vs. HBCU, EV vs. traditional auto facility)."),
      tags$li("Search for a specific institution by name to find it on the map."),
      tags$li("Compare distributions in the boxplot next to the map"),
      tags$li("Read the analysis on the Blog Post tab for a deeper look at one pattern found in the data.")
    ))
  ),
  tabPanel("Colleges", mapPageUI("colleges", college_type_choices, "college",
                                 sort(unique(colleges$name)))),
  tabPanel("Automotive & EV Facilities", mapPageUI("auto", auto_type_choices, "facility",
                                                   sort(unique(auto_facilities$name)))),
  tabPanel("Historic Theaters", mapPageUI("theaters", theater_type_choices, "theater",
                                          sort(unique(theaters$name)))),
  tabPanel("Opera Companies", mapPageUI("opera", opera_type_choices, "opera company",
                                        sort(unique(opera$name)))),
  ## Blog Post tab
  tabPanel(
    "Blog Post",
    fluidPage(
      tags$head(
        tags$style(HTML(".blog-content img {
            max-width: 100%;
            height: auto;
            display: block;
            margin: 20px auto;
            border: 1px solid #ddd;
          }
        "))
      ),
      fluidRow(
        column(
          8, offset = 2,
          div(
            class = "blog-content",
            style = "font-size: 1.05em; line-height: 1.65; padding-top: 20px;",
            ### Use markdown package to read blog_post.md into app
            includeMarkdown("blog_post.md")
          )
        )
      )
    )
  )
)


# Server
server <- function(input, output, session) {
  observeEvent(input$nav_colleges, {
    updateNavbarPage(session, "main_nav", selected = "Colleges")
  })
  observeEvent(input$nav_auto, {
    updateNavbarPage(session, "main_nav", selected = "Automotive & EV Facilities")
  })
  observeEvent(input$nav_theaters, {
    updateNavbarPage(session, "main_nav", selected = "Historic Theaters")
  })
  observeEvent(input$nav_opera, {
    updateNavbarPage(session, "main_nav", selected = "Opera Companies")
  })
  observeEvent(input$nav_blog, {
    updateNavbarPage(session, "main_nav", selected = "Blog Post")
  })
  
  mapPageServer("colleges", colleges)
  mapPageServer("auto", auto_facilities)
  mapPageServer("theaters", theaters)
  mapPageServer("opera", opera)
}
# Run the application 
shinyApp(ui, server)
