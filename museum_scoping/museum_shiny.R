library(shiny)
library(tidyverse)
library(leaflet)
library(DT)
library(geosphere)
library(jsonlite)

museum_data <- read_csv("../data/Museum/museum_app_final.csv") %>%
  filter(!is.na(latitude), !is.na(longitude)) %>%
  mutate(
    website_link = if_else(is.na(website_link), "", website_link),
    ticket_link = if_else(is.na(ticket_link), "", ticket_link),
    visit_link = if_else(is.na(visit_link), "", visit_link),
    hours_summary = if_else(is.na(hours_summary), "", hours_summary),
    admission_summary = if_else(is.na(admission_summary), "", admission_summary),
    accessibility_summary = if_else(is.na(accessibility_summary), "", accessibility_summary),
    category = if_else(is.na(category), "Unknown", category),
    theme = if_else(is.na(theme), "Other", theme),
    recommended_for = if_else(is.na(recommended_for), "General visitors", recommended_for),
    basic_intro = if_else(
      is.na(basic_intro) | basic_intro == "",
      paste0(museum_name, " is a ", category, " museum located in ", state, ", United States."),
      basic_intro
    ),
    museum_id = row_number()
  )

state_choices <- c("All", sort(unique(museum_data$state)))
category_choices <- c("All", sort(unique(museum_data$category)))
theme_choices <- c("All", sort(unique(museum_data$theme)))

ui <- fluidPage(
  titlePanel("Museum Explorer"),
  
  sidebarLayout(
    sidebarPanel(
      textInput("keyword", "Search by keyword",
                placeholder = "Try art, history, science, children..."),
      
      selectInput("category", "Category", choices = category_choices, selected = "All"),
      selectInput("theme", "Theme", choices = theme_choices, selected = "All"),
      selectInput("state", "State", choices = state_choices, selected = "All"),
      
      checkboxInput("has_website", "Only show museums with website", FALSE),
      checkboxInput("has_ticket", "Only show museums with ticket/admission link", FALSE),
      checkboxInput("has_hours", "Only show museums with hours information", FALSE),
      
      hr(),
      h4("Find museums near ZIP code"),
      textInput("zip", "ZIP code", placeholder = "Example: 55454"),
      numericInput("radius", "Radius in miles", value = 25, min = 1, max = 200),
      
      actionButton("clear_zip", "Clear ZIP search"),
      br(), br(),
      actionButton("apply_filters", "Apply Filters", class = "btn-primary")
    ),
    
    mainPanel(
      h3(textOutput("result_count")),
      leafletOutput("museum_map", height = 600),
      br(),
      
      h3("Museum Details"),
      wellPanel(uiOutput("museum_profile")),
      br(),
      
      DTOutput("museum_table")
    )
  )
)

server <- function(input, output, session) {
  
  selected_museum <- reactiveVal(NULL)
  
  zip_location <- reactive({
    if (input$zip == "") return(NULL)
    
    query <- paste(input$zip, "United States")
    url <- paste0(
      "https://nominatim.openstreetmap.org/search?q=",
      URLencode(query),
      "&format=json&limit=1"
    )
    
    result <- tryCatch(jsonlite::fromJSON(url), error = function(e) NULL)
    if (is.null(result) || nrow(result) == 0) return(NULL)
    
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
      data <- data %>% filter(category == input$category)
    }
    
    if (input$theme != "All") {
      data <- data %>% filter(theme == input$theme)
    }
    
    if (input$state != "All") {
      data <- data %>% filter(state == input$state)
    }
    
    if (input$has_website) {
      data <- data %>% filter(website_link != "")
    }
    
    if (input$has_ticket) {
      data <- data %>% filter(ticket_link != "")
    }
    
    if (input$has_hours) {
      data <- data %>% filter(hours_summary != "")
    }
    
    if (input$keyword != "") {
      keyword <- str_to_lower(input$keyword)
      
      data <- data %>%
        filter(
          str_detect(str_to_lower(museum_name), keyword) |
            str_detect(str_to_lower(category), keyword) |
            str_detect(str_to_lower(theme), keyword) |
            str_detect(str_to_lower(full_address), keyword) |
            str_detect(str_to_lower(recommended_for), keyword) |
            str_detect(str_to_lower(basic_intro), keyword)
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
    
    leaflet(data, options = leafletOptions(preferCanvas = TRUE)) %>%
      addTiles() %>%
      addMarkers(
        lng = ~longitude,
        lat = ~latitude,
        layerId = ~museum_id,
        popup = ~paste0(
          "<b>", museum_name, "</b><br>",
          category, "<br>",
          theme, "<br>",
          full_address, "<br>",
          "Click marker for details."
        ),
        clusterOptions = markerClusterOptions()
      )
  })
  
  output$museum_table <- renderDT({
    data <- filtered_museums()
    
    table_data <- data %>%
      mutate(
        ticket_status = if_else(ticket_link != "", "Ticket link found", "Check official website"),
        hours_status = if_else(hours_summary != "", "Hours info found", "Check official website")
      ) %>%
      select(
        museum_id,
        museum_name,
        category,
        theme,
        state,
        full_address,
        ticket_status,
        hours_status,
        website_link,
        any_of("distance_miles")
      )
    
    datatable(
      table_data,
      options = list(pageLength = 10, scrollX = TRUE),
      rownames = FALSE,
      selection = "single"
    )
  })
  
  observeEvent(input$museum_map_marker_click, {
    click <- input$museum_map_marker_click
    
    selected <- filtered_museums() %>%
      filter(museum_id == as.numeric(click$id)) %>%
      slice(1)
    
    selected_museum(selected)
  })
  
  observeEvent(input$museum_table_rows_selected, {
    selected_row <- input$museum_table_rows_selected
    
    if (length(selected_row) > 0) {
      selected <- filtered_museums() %>%
        slice(selected_row)
      
      selected_museum(selected)
    }
  })
  
  output$museum_profile <- renderUI({
    museum <- selected_museum()
    
    if (is.null(museum) || nrow(museum) == 0) {
      return(p("Click a museum on the map or select a row in the table to see details."))
    }
    
    google_maps_link <- paste0(
      "https://www.google.com/maps/search/?api=1&query=",
      URLencode(museum$full_address)
    )
    
    tagList(
      h2(paste0("🏛 ", museum$museum_name)),
      p(strong("Category: "), museum$category),
      p(strong("Theme: "), museum$theme),
      p(strong("Recommended for: "), museum$recommended_for),
      p(strong("State: "), museum$state),
      p(strong("📍 Address: "), museum$full_address),
      p(strong("About: "), museum$basic_intro),
      
      if ("distance_miles" %in% names(museum)) {
        p(strong("Distance: "), round(museum$distance_miles, 1), " miles")
      },
      
      if (museum$hours_summary != "") {
        p(strong("🕒 Hours info: "), museum$hours_summary)
      },
      
      if (museum$admission_summary != "") {
        p(strong("🎟 Admission info: "), museum$admission_summary)
      },
      
      if (museum$accessibility_summary != "") {
        p(strong("♿ Accessibility: "), museum$accessibility_summary)
      },
      
      hr(),
      h4("Visitor Links"),
      
      tags$p(tags$a(
        href = google_maps_link,
        target = "_blank",
        onclick = "window.open(this.href); return false;",
        "🧭 Open in Google Maps"
      )),
      
      if (museum$website_link != "") {
        tags$p(tags$a(
          href = museum$website_link,
          target = "_blank",
          onclick = "window.open(this.href); return false;",
          "🌐 Visit official website"
        ))
      },
      
      if (museum$ticket_link != "") {
        tags$p(tags$a(
          href = museum$ticket_link,
          target = "_blank",
          onclick = "window.open(this.href); return false;",
          "🎟 Buy tickets / admission"
        ))
      } else if (museum$website_link != "") {
        tags$p(tags$a(
          href = museum$website_link,
          target = "_blank",
          onclick = "window.open(this.href); return false;",
          "🎟 Check tickets on official website"
        ))
      },
      
      if (museum$visit_link != "") {
        tags$p(tags$a(
          href = museum$visit_link,
          target = "_blank",
          onclick = "window.open(this.href); return false;",
          "🕒 Plan your visit / hours"
        ))
      }
    )
  })
}

shinyApp(ui, server)