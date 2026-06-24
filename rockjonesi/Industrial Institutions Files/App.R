

library(shiny)
library(bslib)
library(plotly)
library(tidygeocoder)
library(tidyverse)
library(leaflet)
library(pdftools)
library(tidytext)
library(scales)
library(tigris) 
library(sf)
library(htmlwidgets)
library(forcats)



Powerplants <- read.csv("PowerPlants_Clean.csv")

state_sf <- states(cb = TRUE, class = "sf") %>% 
  mutate(State = str_to_title(NAME)) %>% 
  filter(State %in% Powerplants$State)


#----user interface------

ui <- navbarPage(
  title = "State-Level Information of Powerplant Energy Types",
##-------Tab 1------------ 
  tabPanel(
    title = "Explore by States",
    
    sidebarLayout(
      
      sidebarPanel(
        width = 3,
        h1("Find Your State"),
        
        selectInput(
          inputId = "state_choice",
          label = "Select",
          choices = sort(unique(Powerplants$State))
        )
      ),
      
  mainPanel(
    plotOutput("Bar", height = 500),
      )
    )
  ),
##-------Tab 2------------  
  tabPanel(
    title = "Explore by Energy Sources",
    
    sidebarLayout(
      
      sidebarPanel(
        width = 3,
        h1("Choose an Energy Souce"),
        
        selectInput(
          inputId = "energy_choice",
          label = "Select",
          choices = sort(unique(str_to_title(Powerplants$Primary.Energy.Source)))
        )
      ),
      mainPanel(
        plotOutput("Energy", height = 500)
      )
    )
  ),
tabPanel(
  title = "Map Power Plants by State",
  
  sidebarLayout(
    
    sidebarPanel(
      width = 3,
      h1("Select a State to Map"),
      
      selectInput(
        inputId = "choose_state",
        label = "Select",
        choices = sort(unique((Powerplants_sf$State)))
      )
    ),
    mainPanel(
      leafletOutput("Map", height = 600)
    )
  )
),
)

#-------sever-------

server <- function(input, output) {
  
  ##------by state plot---------
  output$Bar <- renderPlot({
    
    state_subset <- Powerplants %>% filter(State == input$state_choice)
      
    ggplot(state_subset, aes(x = fct_infreq(Primary.Energy.Source), fill = Primary.Energy.Source)) +
      geom_bar(color = "black") +
      scale_fill_brewer(palette =  "Set3") +
      theme(axis.text.x = element_text(angle = -90)) +
      labs(y = "Count",
           x = "Powerplant Primary Energy Source",
           title = paste("Energy Source Distribution for", input$state_choice))
  })
  
  ##------by energy plot----------
  output$Energy <- renderPlot({
    
    energy_subset <- Powerplants %>% mutate(Primary.Energy.Source = str_to_title(Primary.Energy.Source)) %>% 
      filter(Primary.Energy.Source == input$energy_choice)
    
    ggplot(energy_subset, aes(x = fct_infreq(State), fill = Primary.Energy.Source)) +
      geom_bar(color = "black") +
      scale_x_discrete(drop = FALSE) +
      scale_fill_brewer(palette =  "Set3") +
      theme(axis.text.x = element_text(angle = -90),
            legend.position = "none") +
      labs(y = "Count",
           x = "Primary Energy Source",
           title = paste("Primary Energy Source:", str_to_title(input$Primary.Energy.Source)))
    
    
    })
  
  ##--------state power plants map---------
  output$Map <- renderLeaflet({
    powerplant_subset <- Powerplants_sf %>% filter(State == input$choose_state)
    state_subset <- state_sf %>% filter(State == input$choose_state)
    
    pal <- colorFactor(
      palette = "Set3", 
      domain = powerplant_subset$Primary.Energy.Source
    )
    
    map <- leaflet() %>% 
      addProviderTiles(providers$CartoDB.Positron) %>% 
      addPolygons(
        data = state_subset,
        fillColor = "lightblue",
        fillOpacity = 0.0,
        color = "black",
        opacity = 1,
        weight = 1,
      ) %>% 
      addCircleMarkers(
        data = powerplant_subset,
        lat = ~Latitude,
        lng = ~Longitude,
        radius = 4,
        fillColor = ~pal(Primary.Energy.Source),
        fillOpacity = 1,
        popup = ~Electric.Power.Plant.Name,
        stroke = FALSE,
        group = ~Primary.Energy.Source,
        label = ~str_to_title(Primary.Energy.Source)
      ) %>% 
      addLayersControl(
        overlayGroups = sort(unique(str_to_title(powerplant_subset$Primary.Energy.Source))),
        options = layersControlOptions(collapse = TRUE),
        position = "topleft"
      ) %>% 
      addLegend(
        data = powerplant_subset,
        position = "bottomleft",
        pal = pal,
        values = ~Primary.Energy.Source,
        title = "Primary Energy Source",
        opacity = 0.8
      )
  })
  
  
}

shinyApp(ui, server)

