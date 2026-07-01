

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
library(usa)



Powerplants <- read.csv("PowerPlants_Clean.csv")
Headquarters <- read.csv("Fortune500HQ_Housing.csv")
HPI <- read.csv("county_HPI.csv")





#Power Plant Data Merge
state_counts <- Powerplants %>% 
  group_by(State) %>% 
  summarise(State.Powerplant.Count = n())

state_sf <- states(cb = TRUE, class = "sf") %>% 
  mutate(State = str_to_title(NAME)) %>% 
  filter(State %in% Powerplants$State) %>% 
  left_join(state_counts, by = "State")

#F500HQ Data Merge
HPI <- HPI %>% mutate(County = str_to_lower(County),
                      State = str_to_lower(state_convert(State, to = "name")))

county_sf <- counties(cb = TRUE, class = "sf") %>% 
  mutate(County = tolower(NAME),
         State = tolower(STATE_NAME))

housing_map <- Headquarters %>% 
  mutate(County = tolower(County),
         State = tolower(State))

unique_county_prices <- housing_map %>%
  group_by(State, County) %>%
  summarize(
    Median.Home.Price = mean(Median.Home.Price, na.rm = TRUE), 
    .groups = "drop"
  ) 
county_prices <- county_sf %>%
  full_join(unique_county_prices, 
            by = c("State","County")) 

HQHPICNTY <- county_prices %>% full_join(HPI, by = c("State","County"))

max <- HQHPICNTY %>% select(Year) %>% drop_na() %>% mutate(Year = as.numeric(Year)) %>% pull(Year) %>% max()
min <- HQHPICNTY %>% select(Year) %>% drop_na() %>% mutate(Year = as.numeric(Year)) %>% pull(Year) %>% min()

HPI_2000 <- HPI %>% filter(Year == 2000) %>% group_by(State) %>% summarize(avg_hpi = mean(HPI))
HPI_2025 <- HPI %>% filter(Year == 2016) %>% group_by(State) %>% summarize(avg_hpi = mean(HPI))

HPI_State_Change <- HPI %>% 
  mutate(total_hpi_change = ((HPI_2000$HPI) - (HPI_2025$HPI))/100)


#----user interface------

ui <- navbarPage(
  title = "Exploring Industrial Institutions in the United States",
tabPanel(
  title = "Home"
),
navbarMenu(
  title = "Electric Power Plants",
##-------map---------
  tabPanel(
    title = "Map Power Plants by State",
    
    fluidRow(
      column(
        width = 4,
        card(
          card_header(h4("Explore by State")),
          card_body(
            plotOutput("SidebarChart", height = 400)
          )
        )
      ),
      column(
        width = 8,
        card(
          card_body(
            leafletOutput("Map", height = 600)
          )
        )
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
    )
  ),
navbarMenu(
  title = "Fortune 500 Headquarters",
  
  tabPanel(
    title = "HPI Change Overtime in the Presence of Megacorporations",
    
    sidebarLayout(
      
      sidebarPanel(
        uiOutput("slider")
      ),
    
    mainPanel(
      leafletOutput("Housing", height = 500)
        )
      )
    )
  )
)


#-------sever-------

server <- function(input, output) {
  
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
  clicked_state <- reactiveVal(NULL)
  
  energy_source_pal <- colorFactor(
    palette = "Set3", 
    domain = Powerplants$Primary.Energy.Source
  )
  
  powerplant_count_pal <- colorNumeric(
    palette = "cividis",
    domain = state_sf$State.Powerplant.Count
  )
  
  all_sources <- sort(unique(Powerplants$Primary.Energy.Source))
  leaflet_colors <- setNames(energy_source_pal(all_sources), all_sources)
  
  
  output$Map <- renderLeaflet({
    leaflet(state_sf) %>% 
      addProviderTiles(providers$CartoDB.Positron) %>% 
      setView(lng = -98.58, lat = 39.82, zoom = 4) %>%
      addPolygons(
        layerId = ~State,
        fillColor = ~powerplant_count_pal(State.Powerplant.Count),
        fillOpacity = 0.3,
        color = "black",
        weight = 1,
        label = ~State.Powerplant.Count
      ) %>% 
      
      addLegend(
        pal = powerplant_count_pal,
        value = state_sf$State.Powerplant.Count, 
        position = "bottomright",
        title = "State Electric Power Plant Counts"
      )
  })
    
  observeEvent(input$Map_shape_click, {
    clicked_state(input$Map_shape_click$id)
    
    state_fill_opacities <- ifelse(state_sf$State == clicked_state(), 0, 0.3)
    
    bbox_data <- state_sf[state_sf$State == clicked_state(), "geometry"]
    bbox <- st_bbox(bbox_data)

    powerplant_subset <- Powerplants[Powerplants$State == clicked_state(), ]
    

    leafletProxy("Map") %>% 
      clearMarkers() %>% 
      clearControls() %>% 
      addPolygons(
        data = state_sf,
        layerId = ~State,
        fillColor = ~powerplant_count_pal(State.Powerplant.Count),
        fillOpacity = state_fill_opacities, 
        color = "black",
        weight = 1
      ) %>%
      fitBounds(
        lng1 = bbox[["xmin"]], lat1 = bbox[["ymin"]],
        lng2 = bbox[["xmax"]], lat2 = bbox[["ymax"]]
      ) %>% 
      addCircleMarkers(
        data = powerplant_subset,
        lat = ~Latitude,
        lng = ~Longitude,
        radius = 4,
        fillColor = ~energy_source_pal(Primary.Energy.Source),
        fillOpacity = 1,
        popup = ~Electric.Power.Plant.Name,
        stroke = FALSE,
        group = ~Primary.Energy.Source,
        label = ~str_to_title(Primary.Energy.Source)
      ) %>% 
      addLegend(
        data = powerplant_subset,
        position = "bottomleft",
        pal = energy_source_pal,
        values = ~Primary.Energy.Source,
        title = "Primary Energy Source",
        opacity = 0.8
      )
  })
  
output$SidebarChart <- renderPlot({
  req(clicked_state())
  
  state_subset <- Powerplants %>% filter(State == clicked_state())
  
  ggplot(state_subset, aes(x = fct_infreq(str_to_title(Primary.Energy.Source)), fill = Primary.Energy.Source)) +
    geom_bar(color = "black") +
    scale_fill_manual(values = leaflet_colors) +
    theme(axis.text.x = element_text(angle = -90)) +
    labs(y = "Count",
         x = "Powerplant Primary Energy Source",
         title = paste("Energy Source Distribution for", clicked_state()))
  
  })

pal <- colorNumeric(
  palette = "PiYG", 
  domain = HQHPICNTY$Annual.Change....
)


output$Housing <- renderLeaflet({
    leaflet(state_sf) %>% 
      addProviderTiles(providers$CartoDB.Positron) %>% 
      setView(lng = -98.58, lat = 39.82, zoom = 4) %>%
      addPolygons(
        group = "base_states",
        fillColor = "white",
        fillOpacity = 0.3,
        color = "black",
        weight = 1
      ) %>% 
    addMarkers(
      data = housing_map,
      lng = ~Longitude, 
      lat = ~Latitude,
      layerId = ~Company,
      label = ~Company
    ) 
})

zoomed_state <- reactiveVal(NULL)

observeEvent(input$Housing_marker_click, {

  company <- input$Housing_marker_click
  req(company$id)
  
  clicked_company <- housing_map %>% filter(Company == company$id)
  state_focus <- clicked_company$State[1]
  
  zoomed_state(state_focus)
  
  bbox_data <- state_sf[state_sf$State == str_to_title(state_focus), ]
  bbox <- st_bbox(bbox_data)
  
  current_year <- if (!is.null(input$Year)) input$Year else 2000
  year_state_subset <- HQHPICNTY %>% filter(Year == current_year, State == str_to_title(state_focus))
  
  leafletProxy("Housing") %>% 
    fitBounds(
      lng1 = bbox[["xmin"]], lat1 = bbox[["ymin"]],
      lng2 = bbox[["xmax"]], lat2 = bbox[["ymax"]]
    ) 
})

selected_data <- reactive({
  req(zoomed_state())
  current_year <- if (!is.null(input$Year)) input$Year else 2000
  
  HQHPICNTY %>% 
    filter(Year == current_year, State == zoomed_state()) %>% 
    filter(!st_is_empty(geometry))
})

observe({
  req(zoomed_state())
  req(input$Year)

  df <- selected_data()
  
  leafletProxy("Housing") %>% 
    clearGroup("counties") %>% 
    addPolygons(
      data = df,
      group = "counties",
      layerId = ~County,
      fillColor = ~pal(Annual.Change....),
      fillOpacity = 0.8,
      label = ~as.character(HPI),
      color = "black",
      weight = 1
    )
})

output$slider <- renderUI({
  req(zoomed_state())
  
  sliderInput("Year", 
              "Slide to Change the Year", 
              min = 2000, 
              max = 2025, 
              2000, 
              animate = animationOptions(interval = 1500, loop = TRUE)
  )
})
###side map under this one, plotting just overall HPI % change since 2000. Should supplement with a bar graph with state counts of # of F500 companies, to see 
##if there is a trend between amount of these comapnies and HPI % change
  
}


shinyApp(ui, server)

