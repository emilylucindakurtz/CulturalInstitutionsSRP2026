library(shiny)
library(tidyverse)
library(DT)
library(bslib)

satellite_data <- read_csv(
  #"./outputs/Satellite/satellite_all_indicators.csv",
  "satellite_all_indicators.csv",
  show_col_types = FALSE
) %>%
  mutate(
    institution_type = as.character(institution_type),
    avg_rad = as.numeric(avg_rad),
    no2 = as.numeric(no2),
    impervious_surface = as.numeric(impervious_surface)
  ) %>%
  filter(
    !is.na(institution_type),
    !is.na(avg_rad),
    !is.na(no2),
    !is.na(impervious_surface)
  )
satellite_long <- satellite_data %>%
  pivot_longer(
    cols = c(avg_rad, no2, impervious_surface),
    names_to = "indicator_code",
    values_to = "value"
  ) %>%
  mutate(
    indicator = recode(
      indicator_code,
      avg_rad = "Nighttime Lights",
      no2 = "NO₂",
      impervious_surface = "Impervious Surface"
    )
  )

institution_choices <- sort(unique(satellite_data$institution_type))

indicator_choices <- c(
  "Nighttime Lights" = "avg_rad",
  "NO₂" = "no2",
  "Impervious Surface" = "impervious_surface"
)

ui <- page_sidebar(
  title = "Satellite Indicators Dashboard",
  
  sidebar = sidebar(
    checkboxGroupInput(
      inputId = "institution_filter",
      label = "Institution Type",
      choices = institution_choices,
      selected = institution_choices
    ),
    
    selectInput(
      inputId = "indicator",
      label = "Satellite Indicator",
      choices = indicator_choices,
      selected = "avg_rad"
    ),
    
    selectInput(
      inputId = "x_indicator",
      label = "Scatterplot X-axis",
      choices = indicator_choices,
      selected = "impervious_surface"
    ),
    
    selectInput(
      inputId = "y_indicator",
      label = "Scatterplot Y-axis",
      choices = indicator_choices,
      selected = "avg_rad"
    ),
    
    actionButton(
      inputId = "apply_filters",
      label = "Apply Filters",
      class = "btn-primary"
    ),
    
    br(),
    br(),
    
    actionButton(
      inputId = "reset_filters",
      label = "Reset Filters"
    ),
    
    hr(),
    
    downloadButton(
      outputId = "download_filtered",
      label = "Download Filtered Data"
    )
  ),
  
  layout_columns(
    value_box(
      title = "Locations",
      value = textOutput("location_count")
    ),
    
    value_box(
      title = "Mean",
      value = textOutput("mean_value")
    ),
    
    value_box(
      title = "Median",
      value = textOutput("median_value")
    ),
    
    value_box(
      title = "Standard Deviation",
      value = textOutput("sd_value")
    ),
    col_widths = c(3, 3, 3, 3)
  ),
  
  navset_card_tab(
    nav_panel(
      "Distribution",
      plotOutput("distribution_plot", height = 500)
    ),
    
    nav_panel(
      "Scatterplot",
      plotOutput("scatter_plot", height = 500)
    ),
    
    nav_panel(
      "Correlation",
      plotOutput("correlation_plot", height = 500)
    ),
    
    nav_panel(
      "Summary Table",
      DTOutput("summary_table")
    ),
    
    nav_panel(
      "Point-Level Data",
      DTOutput("data_table")
    )
  )
)

server <- function(input, output, session) {
  
  observeEvent(input$reset_filters, {
    updateCheckboxGroupInput(
      session,
      "institution_filter",
      selected = institution_choices
    )
    
    updateSelectInput(
      session,
      "indicator",
      selected = "avg_rad"
    )
    
    updateSelectInput(
      session,
      "x_indicator",
      selected = "impervious_surface"
    )
    
    updateSelectInput(
      session,
      "y_indicator",
      selected = "avg_rad"
    )
  })
  
  filtered_data <- eventReactive(
    input$apply_filters,
    {
      req(input$institution_filter)
      
      satellite_data %>%
        filter(institution_type %in% input$institution_filter)
    },
    ignoreNULL = FALSE
  )
  
  selected_indicator_label <- reactive({
    names(indicator_choices)[
      indicator_choices == input$indicator
    ]
  })
  
  x_indicator_label <- reactive({
    names(indicator_choices)[
      indicator_choices == input$x_indicator
    ]
  })
  
  y_indicator_label <- reactive({
    names(indicator_choices)[
      indicator_choices == input$y_indicator
    ]
  })
  
  selected_values <- reactive({
    filtered_data()[[input$indicator]]
  })
  
  output$location_count <- renderText({
    format(nrow(filtered_data()), big.mark = ",")
  })
  
  output$mean_value <- renderText({
    values <- selected_values()
    
    if (input$indicator == "no2") {
      format(
        mean(values, na.rm = TRUE),
        scientific = TRUE,
        digits = 3
      )
    } else {
      round(mean(values, na.rm = TRUE), 2)
    }
  })
  
  output$median_value <- renderText({
    values <- selected_values()
    
    if (input$indicator == "no2") {
      format(
        median(values, na.rm = TRUE),
        scientific = TRUE,
        digits = 3
      )
    } else {
      round(median(values, na.rm = TRUE), 2)
    }
  })
  
  output$sd_value <- renderText({
    values <- selected_values()
    
    if (input$indicator == "no2") {
      format(
        sd(values, na.rm = TRUE),
        scientific = TRUE,
        digits = 3
      )
    } else {
      round(sd(values, na.rm = TRUE), 2)
    }
  })
  
  output$distribution_plot <- renderPlot({
    data <- filtered_data()
    
    ggplot(
      data,
      aes(
        x = institution_type,
        y = .data[[input$indicator]],
        fill = institution_type
      )
    ) +
      geom_violin(
        alpha = 0.55,
        trim = FALSE
      ) +
      geom_boxplot(
        width = 0.12,
        outlier.shape = NA
      ) +
      labs(
        title = paste(
          "Distribution of",
          selected_indicator_label(),
          "by Institution Type"
        ),
        x = "Institution Type",
        y = selected_indicator_label()
      ) +
      theme_minimal(base_size = 14) +
      theme(
        legend.position = "none",
        plot.title = element_text(face = "bold")
      )
  })
  
  output$scatter_plot <- renderPlot({
    data <- filtered_data()
    
    validate(
      need(
        input$x_indicator != input$y_indicator,
        "Choose two different indicators."
      )
    )
    
    ggplot(
      data,
      aes(
        x = .data[[input$x_indicator]],
        y = .data[[input$y_indicator]],
        color = institution_type
      )
    ) +
      geom_point(
        alpha = 0.35,
        size = 1.4
      ) +
      geom_smooth(
        method = "lm",
        se = FALSE,
        color = "black"
      ) +
      labs(
        title = paste(
          y_indicator_label(),
          "vs",
          x_indicator_label()
        ),
        x = x_indicator_label(),
        y = y_indicator_label(),
        color = "Institution Type"
      ) +
      theme_minimal(base_size = 14) +
      theme(
        plot.title = element_text(face = "bold")
      )
  })
  
  output$correlation_plot <- renderPlot({
    data <- filtered_data() %>%
      select(
        avg_rad,
        no2,
        impervious_surface
      )
    
    corr_matrix <- cor(
      data,
      use = "complete.obs"
    )
    
    corr_long <- corr_matrix %>%
      as.data.frame() %>%
      rownames_to_column("indicator_1") %>%
      pivot_longer(
        cols = -indicator_1,
        names_to = "indicator_2",
        values_to = "correlation"
      ) %>%
      mutate(
        indicator_1 = recode(
          indicator_1,
          avg_rad = "Nighttime Lights",
          no2 = "NO₂",
          impervious_surface = "Impervious Surface"
        ),
        indicator_2 = recode(
          indicator_2,
          avg_rad = "Nighttime Lights",
          no2 = "NO₂",
          impervious_surface = "Impervious Surface"
        )
      )
    
    ggplot(
      corr_long,
      aes(
        x = indicator_1,
        y = indicator_2,
        fill = correlation
      )
    ) +
      geom_tile() +
      geom_text(
        aes(label = round(correlation, 2)),
        size = 6
      ) +
      scale_fill_gradient2(
        limits = c(-1, 1),
        midpoint = 0
      ) +
      labs(
        title = "Correlation Among Satellite Indicators",
        x = NULL,
        y = NULL,
        fill = "Correlation"
      ) +
      theme_minimal(base_size = 14) +
      theme(
        plot.title = element_text(face = "bold"),
        axis.text.x = element_text(
          angle = 30,
          hjust = 1
        )
      )
  })
  
  output$summary_table <- renderDT({
    summary_data <- filtered_data() %>%
      group_by(institution_type) %>%
      summarize(
        n = n(),
        
        mean_nighttime_lights = mean(
          avg_rad,
          na.rm = TRUE
        ),
        
        median_nighttime_lights = median(
          avg_rad,
          na.rm = TRUE
        ),
        
        mean_no2 = mean(
          no2,
          na.rm = TRUE
        ),
        
        median_no2 = median(
          no2,
          na.rm = TRUE
        ),
        
        mean_impervious_surface = mean(
          impervious_surface,
          na.rm = TRUE
        ),
        
        median_impervious_surface = median(
          impervious_surface,
          na.rm = TRUE
        ),
        
        .groups = "drop"
      )
    
    datatable(
      summary_data,
      rownames = FALSE,
      options = list(
        pageLength = 10,
        scrollX = TRUE
      )
    ) %>%
      formatRound(
        columns = c(
          "mean_nighttime_lights",
          "median_nighttime_lights",
          "mean_impervious_surface",
          "median_impervious_surface"
        ),
        digits = 2
      ) %>%
      formatSignif(
        columns = c(
          "mean_no2",
          "median_no2"
        ),
        digits = 3
      )
  })
  
  output$data_table <- renderDT({
    table_data <- filtered_data() %>%
      select(
        name,
        institution_type,
        avg_rad,
        no2,
        impervious_surface
      ) %>%
      rename(
        Name = name,
        `Institution Type` = institution_type,
        `Nighttime Lights` = avg_rad,
        `NO₂` = no2,
        `Impervious Surface (%)` = impervious_surface
      )
    
    datatable(
      table_data,
      rownames = FALSE,
      filter = "top",
      options = list(
        pageLength = 15,
        scrollX = TRUE
      )
    ) %>%
      formatRound(
        columns = c(
          "Nighttime Lights",
          "Impervious Surface (%)"
        ),
        digits = 2
      ) %>%
      formatSignif(
        columns = "NO₂",
        digits = 3
      )
  })
  
  output$download_filtered <- downloadHandler(
    filename = function() {
      paste0(
        "filtered_satellite_data_",
        Sys.Date(),
        ".csv"
      )
    },
    
    content = function(file) {
      write_csv(
        filtered_data(),
        file
      )
    }
  )
}

shinyApp(ui, server)