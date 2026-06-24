library(shiny)
library(tidyverse)
library(leaflet)
library(DT)
library(geosphere)
library(jsonlite)


museum_data <- read_csv("../data/Museum/whichmuseum_details_12000_geo.csv") %>%
  filter(!is.na(latitude), !is.na(longitude)) %>%
  mutate(
    website_link = if_else(is.na(website_link), "", website_link),
    museum_url = if_else(is.na(museum_url), "", museum_url),
    category = if_else(is.na(category), "Unknown", category),
    state = case_when(
      str_detect(state, "^FL") ~ "Florida",
      str_detect(state, "^NJ") ~ "New Jersey",
      str_detect(state, "^NY") ~ "New York",
      TRUE ~ state
    ),
    basic_intro = paste0(
      museum_name,
      " is a ",
      category,
      " museum located in ",
      state,
      ", United States."
    ),
    theme = case_when(
      str_detect(str_to_lower(museum_name), "children|kids|child") ~ "Children",
      str_detect(str_to_lower(museum_name), "zoo|aquarium|wildlife|botanical|nature") ~ "Nature",
      str_detect(str_to_lower(museum_name), "air|space|aviation|flight|railroad|railway|transport|car|auto") ~ "Transportation",
      str_detect(str_to_lower(museum_name), "military|war|naval|army|veteran") ~ "Military",
      str_detect(str_to_lower(category), "history") ~ "History",
      str_detect(str_to_lower(category), "art") ~ "Art",
      str_detect(str_to_lower(category), "science|technology") ~ "Science",
      TRUE ~ "Other"
    )
  ) %>%
  filter(state %in% state.name | state == "Washington DC")

state_choices <- c("All", sort(unique(museum_data$state)))
category_choices <- c("All", sort(unique(museum_data$category)))
theme_choices <- c("All", sort(unique(museum_data$theme)))


ui <- fluidPage(
  titlePanel("Museum Explorer"),
  
  sidebarLayout(
    sidebarPanel(
      textInput(
        "keyword",
        "Search by keyword",
        placeholder = "Try art, history, science, children..."
      ),
      
      selectInput(
        "category",
        "Category",
        choices = category_choices,
        selected = "All"
      ),
      
      selectInput(
        "theme",
        "Theme",
        choices = theme_choices,
        selected = "All"
      ),
      
      selectInput(
        "state",
        "State",
        choices = state_choices,
        selected = "All"
      ),
      
      checkboxInput(
        "has_website",
        "Only show museums with website",
        value = FALSE
      ),
      
      hr(),
      
      h4("Find museums near ZIP code"),
      
      textInput(
        "zip",
        "ZIP code",
        placeholder = "Example: 55454"
      ),
      
      numericInput(
        "radius",
        "Radius in miles",
        value = 25,
        min = 1,
        max = 200
      ),
      
      actionButton(
        "clear_zip",
        "Clear ZIP search"
      ),
      
      br(),
      br(),
      
      actionButton(
        "apply_filters",
        "Apply Filters",
        class = "btn-primary"
      ),
      
      hr(),
      
      h4("Selected Museum"),
      uiOutput("museum_profile")
    ),
    
    mainPanel(
      h3(textOutput("result_count")),
      leafletOutput("museum_map", height = 600),
      br(),
      DTOutput("museum_table")
    )
  )
)



server <- function(input, output, session) {
  
  selected_museum <- reactiveVal(NULL)
  
  zip_location <- reactive({
    if (input$zip == "") {
      return(NULL)
    }
    
    query <- paste(input$zip, "United States")
    
    url <- paste0(
      "https://nominatim.openstreetmap.org/search?q=",
      URLencode(query),
      "&format=json&limit=1"
    )
    
    result <- tryCatch(
      jsonlite::fromJSON(url),
      error = function(e) NULL
    )
    
    if (is.null(result) || nrow(result) == 0) {
      return(NULL)
    }
    
    tibble(
      latitude = as.numeric(result$lat[1]),
      longitude = as.numeric(result$lon[1])
    )
  })
  
  observeEvent(input$clear_zip, {
    updateTextInput(session, "zip", value = "")
  })
  
  filtered_museums <- eventReactive(input$apply_filters, {
    data <- museum_data
    
    if (input$category != "All") {
      data <- data %>%
        filter(category == input$category)
    }
    
    if (input$theme != "All") {
      data <- data %>%
        filter(theme == input$theme)
    }
    
    if (input$state != "All") {
      data <- data %>%
        filter(state == input$state)
    }
    
    if (input$has_website) {
      data <- data %>%
        filter(website_link != "")
    }
    
    if (input$keyword != "") {
      keyword <- str_to_lower(input$keyword)
      
      data <- data %>%
        filter(
          str_detect(str_to_lower(museum_name), keyword) |
            str_detect(str_to_lower(category), keyword) |
            str_detect(str_to_lower(theme), keyword) |
            str_detect(str_to_lower(full_address), keyword)
        )
    }
    
    zip_loc <- zip_location()
    
    if (!is.null(zip_loc)) {
      data <- data %>%
        mutate(
          distance_miles = distHaversine(
            matrix(c(longitude, latitude), ncol = 2),
            matrix(c(zip_loc$longitude, zip_loc$latitude), ncol = 2)
          ) / 1609.34
        ) %>%
        filter(distance_miles <= input$radius) %>%
        arrange(distance_miles)
    }
    
    selected_museum(NULL)
    
    data
  }, ignoreNULL = FALSE)
  
  output$result_count <- renderText({
    paste(nrow(filtered_museums()), "museums found")
  })
  
  output$museum_map <- renderLeaflet({
    data <- filtered_museums()
    
    leaflet(data) %>%
      addTiles() %>%
      addCircleMarkers(
        lng = ~longitude,
        lat = ~latitude,
        radius = 4,
        stroke = FALSE,
        fillOpacity = 0.7,
        popup = ~paste0(
          "<b>", museum_name, "</b><br>",
          category, "<br>",
          theme, "<br>",
          full_address, "<br>",
          ifelse(
            website_link != "",
            paste0("<a href='", website_link, "' target='_blank'>Website</a>"),
            "No website available"
          )
        ),
        layerId = ~museum_url
      )
  })
  
  output$museum_table <- renderDT({
    data <- filtered_museums()
    
    table_data <- data %>%
      select(
        museum_name,
        category,
        theme,
        state,
        full_address,
        website_link,
        museum_url,
        any_of("distance_miles")
      )
    
    datatable(
      table_data,
      options = list(pageLength = 10),
      rownames = FALSE
    )
  })
  
  observeEvent(input$museum_map_marker_click, {
    click <- input$museum_map_marker_click
    
    selected <- filtered_museums() %>%
      filter(museum_url == click$id) %>%
      slice(1)
    
    selected_museum(selected)
  })
  
  output$museum_profile <- renderUI({
    museum <- selected_museum()
    
    if (is.null(museum) || nrow(museum) == 0) {
      return(p("Click a museum on the map to see details."))
    }
    
    tagList(
      h3(paste0("🏛 ", museum$museum_name)),
      p(strong("Category: "), museum$category),
      p(strong("Theme: "), museum$theme),
      p(strong("State: "), museum$state),
      p(strong("📍 Address: "), museum$full_address),
      p(strong("About: "), museum$basic_intro),
      
      if ("distance_miles" %in% names(museum)) {
        p(strong("Distance: "), round(museum$distance_miles, 1), " miles")
      },
      
      if (museum$website_link != "") {
        tags$p(
          tags$a(
            href = museum$website_link,
            target = "_blank",
            "🌐 Visit official website"
          )
        )
      },
      
      if (museum$museum_url != "") {
        tags$p(
          tags$a(
            href = museum$museum_url,
            target = "_blank",
            "🔎 View WhichMuseum page"
          )
        )
      }
    )
  })
}

shinyApp(ui, server)