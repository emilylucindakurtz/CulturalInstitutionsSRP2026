

library(shiny)
library(bslib)
library(plotly)
library(tidygeocoder)
library(tidyverse)
library(leaflet.extras)
library(leaflet)
library(pdftools)
library(tidytext)
library(scales)
library(DT)
library(shinyWidgets)
library(tigris) 
library(sf)
library(htmltools)
library(htmlwidgets)
library(forcats)
library(usa)



Powerplants <- read.csv("PowerPlants_Clean.csv")
Headquarters <- read.csv("Fortune500HQ_Housing.csv")
HPI <- read.csv("county_HPI.csv")
US_Housing <- read.csv("Fortune500_Housing_All_Counties.csv")



#-------Data Cleaning---------

#Power plant merge for state SF info
state_counts <- Powerplants %>% 
  group_by(State) %>% 
  summarise(State.Powerplant.Count = n())

state_sf <- states(cb = TRUE, class = "sf") %>% 
  mutate(State = str_to_title(NAME)) %>% 
  filter(State %in% Powerplants$State) %>% 
  left_join(state_counts, by = "State")

#F500HQ Data Merge for county SF info
HPI <- HPI %>% mutate(County = str_to_lower(County),
                      State = str_to_lower(state_convert(State, to = "name")))

county_sf <- counties(cb = TRUE, class = "sf") %>% 
  mutate(County = tolower(NAME),
         State = tolower(STATE_NAME))

housing_map <- US_Housing %>% 
  mutate(County = tolower(County),
         State = tolower(State))

unique_county_prices <- housing_map %>%
  group_by(State, County) %>%
  summarize(
    Median.Home.Price = mean(Median.Home.Price, na.rm = TRUE), 
    .groups = "drop"
  ) 

county_prices <- county_sf %>%
  full_join(unique_county_prices %>% select(County, State, Median.Home.Price), 
            by = c("State","County"))

HQHPICNTY <- county_sf %>% 
  left_join(HPI, by = c("State", "County"), relationship = "many-to-many")

#calculating total hpi % change from 2000-2025
HPI_State_Change <- HPI %>%
  filter(Year %in% c(2000, 2025), !is.na(HPI)) %>%
  group_by(State, Year) %>%
  summarize(avg_hpi = mean(HPI), .groups = "drop") %>%
  pivot_wider(names_from = Year, values_from = avg_hpi, names_prefix = "avg_hpi_") %>%
  mutate(total_hpi_change = ((avg_hpi_2025 - avg_hpi_2000)/avg_hpi_2000),
         State = str_to_title(State))

HPI_sf <- state_sf %>% full_join(HPI_State_Change, by = "State") %>% drop_na()

HQ_counts <- Headquarters %>%
  group_by(State) %>%
  summarize(num_HQ = n(), .groups = "drop")

Headquarters_bar <- state_sf %>%
  left_join(HQ_counts, by = "State") %>%
  mutate(num_HQ = replace_na(num_HQ, 0)) 

#for per-capita calculations
usPOP <- read.csv("usPOP.csv") 

usPOP <- usPOP %>%
  mutate(State = str_replace_all(State, "\\.", " "), 
         Population = parse_number(Population))

#will be per 1,000,000 people
Headquarters_bar <- Headquarters_bar %>% full_join(usPOP, by = "State") 
Headquarters_bar <- Headquarters_bar %>% mutate(HQ_per_cap = (num_HQ/Population)*1000000) %>% 
  full_join(HPI_State_Change, by = c("State")) 
                                                       
#Data centers                                       
data_centers <- read.csv("data_centers.csv") %>% 
  mutate(State = str_to_title(state_convert(state, to = "name")))

powerplant_produc <- Powerplants %>% rename(mw_capacity = Maximum.Summer.Capacity..Megawatts.) %>% 
  mutate(mw_capacity = ifelse(is.na(mw_capacity), 0, mw_capacity)) %>% 
  filter(!is.na(Latitude) & !is.na(Longitude))



#UI----
ui <- page_fluid(
    navset_card_underline(
      id = "main_nav",
#Home tab----
      nav_panel(
        "Home",
        value = "Home",
        card(
          card_header(
            div(
              "Overview", 
                class = "text-center w-100")
          ),
          div(
            textOutput(
              "Introduction"
            ),
            style = "white-space: pre-wrap;",
            card(
                 actionLink(inputId = "linkB1", label = "Read More About Power Plants and Data Centers"),
                 br(),
                 actionLink(inputId = "linkB2", label = "Read More About Corporations and Housing"),
                 br(),
                 actionLink(inputId = "datasources", label = "Data Sources")
                 )
          )
        )
      ),
#Blog tab----
      nav_panel_hidden(
        value = "pp_blog",
        actionLink("back_to_home_1", "Return Home"),
        card(
          div(
            textOutput(
              "Blog1"
            ),
            style = "white-space: pre-wrap;"
          )
        )
      ),
#Blog tab----
      nav_panel_hidden(
        value = "ch_blog",
        actionLink("back_to_home_2", "Return Home"),
        card(
          div(
            textOutput(
              "Blog2"
            ),
            style = "white-space: pre-wrap;"
          )
        )
      ),
#Data tab----
    nav_panel_hidden(
      value = "data_page",
      actionLink("back_to_home_3", "Return Home"),
      card(
        div(
          textOutput(
            "DataSource"
          ),
          style = "white-space: pre-wrap;"
        )
      )
    ),
#PP tab ----
      nav_panel(
        "Power Plants",
        layout_columns(
          card(
            layout_columns(
              plotOutput("SidebarChart", height = 350),
              div(
                selectInput(
                  inputId = "energy_choice",
                  label = "Select Energy Type",
                  choices = sort(unique(str_to_title(Powerplants$Primary.Energy.Source))),
                  width = "100%"
                ),
                plotOutput("Energy", height = 350)
              ),
              col_widths = c(6,6)
            )
          ),
          card(
            card_header(
              tooltip(
                span("Map of US Electric Power Plants", icon("info-circle")),
                      "Click on a state to explore"
                )
              ),
            leafletOutput("Map", height = 700)
            ),
          col_widths = c(12, 12)
        )
      ),
#DC tab----
      nav_panel(
        "Data Centers",
        layout_columns(
          card(
            card_body(
              card_header("Data Center Clustering Relative to Regional Production Potential"),
              fillable = TRUE,
              layout_columns(
                leafletOutput("Heatmap", height = 700),
                  div(
                    pickerInput(
                      inputId = "energy_source",
                      label = tooltip(
                        span("Select Energy Type(s)", icon("info-circle")),
                        "Click to select one or more power plant primary energy sources"
                        ),
                      choices = c("All", sort(unique(str_to_title(Powerplants$Primary.Energy.Source)))),
                      selected = "All",
                      multiple = TRUE,
                      width = "100%"
                    ),
                    selectInput(
                      inputId = "State",
                      label = "Select State",
                      choices = c("United States", sort(unique(str_to_title(Powerplants$State)))),
                      selected = "United States",
                      width = "100%"
                    ),
                    div(
                      style = "max-height: 550px; overflow-y: auto;", 
                      tooltip(
                        icon("info-circle"),
                              "Table of mapped power plants. Scroll for additional location and energy information."),
                      dataTableOutput("Heatmap_Data")
                    )
                  ),
                col_widths = c(8,4)
              )
            )
          ),
          card(
            card_header(
              tooltip(
                span("US Data Center Energy Consumption Compared to Local Producers", icon("info-circle")),
                "Calculated as a proportion of energy consumed by the total megawatt production capacity of electric power plants within
                a 50 mile radius of a given data center."
                )
              ),
            layout_columns(
              leafletOutput("Data_centers", height = 500),
              col_widths = c(10)
            )
          ),
          col_widths = c(12,12)
        )
      ),
#Housing tab----
      nav_panel(
        "Corporate and Housing",
        layout_columns(
          card(
            card_header(
              tooltip(
                span("County Housing Trends in the Presence of Fortune Headquarters", 
                icon("info-circle")),
                "Click on a company marker to see state specific trends"
                )
              ),
            layout_columns(
              leafletOutput("Housing", height = 500),
              div(
                uiOutput("slider"),
                plotOutput("StateHPIChart", height = 400)
              ),
              col_widths = c(7,5)
            )
          ),
          card(
            card_header(
              tooltip(
                span("Map of HPI (%) Change From 2000-2025 ", icon("info-circle")),
                "The Housing Price Index (HPI) is a measure of percent change in a residential property's price relative to a 
                baseline HPI of 100. An HPI of 200 would indicate a property price has doubled compared to the base price."
              )
            ),
            layout_columns(
              leafletOutput("HPI", height = 400),
              plotOutput("Companycount", height = 400),
              col_widths = c(7,5)
            )
          ),
          col_widths = c(12,12)
        )
      )
    )
)


#Server----

server <- function(input, output) {
  

  output$Introduction <- renderText(
    expr = "
    In this broad exploration of cultural institutions in the United States I elected to focus my research efforts towards institutions driven by industry, to inspire questions about how local economies and living conditions could be affected. More specifically, I looked at electric power plants, data centers, and corporate company headquarters. This blog post hopes to highlight the motivations, methods, and processes behind my facet of this mapping project, as well as the potential for implications and possible extensions of it.
    
My choices of institutions stemmed originally from a curiosity about how large companies and facilities tie into local communities across the US despite often being subjectively controversial–for large scale effects on the climate, livability of an area, or on commercial markets. However, these entities remain locally essential by providing rural job markets, important technological advancements, and incentives to relocate which can shift regional economies. Rural natural gas power plants are an example of a facility that have measurable carbon effects on the environment, but also could be very important employers of multiple surrounding communities that all lack many other stable career opportunities.

From a macro perspective, climate change activists or policy makers may wish to regulate or physically overhaul the plant to mediate its carbon footprint, but consequently the dependent local communities would be further limited. How can policy makers fully understand such an impact before making such a change without experiencing the local necessity of the facility first-hand? And conversely, how might community members understand the urgency of policy makers when the plant is the supporter of themselves, and change does not seem like an option for them? This friction at the micro and macroscopics levels is an impossible challenge and is  something that is present for each one of these institutions. 

Though the timeframe of this project was shortened, I wanted to initiate explorations at a foundational level by mapping electric power plants and data centers in the US; visualizing distributions of energy production and consumption; and trying to relate county-level housing trends to the incentives of large corporations. Click through the tabs above to visually explore more on each topic. Click on the links below to read about trends that have been observed and highlighted from the visuals.
    
This project uses a compilation of data that was collected from pre-existing and accessible data sources. All power plant information was collected from the Federal Emergency Management Agency (FEMA). Housing price information was sourced from the National Association of Realtors (NAR) statistics and research division, and from the Federal Housing Finance Agency (FHFA). Information on data centers was provided by the project advisor, Emily Kurtz. Click the Data Source link below to find out more.
    "
  )
  
  observeEvent(input$linkB1, {
    nav_select(id = "main_nav", selected = "pp_blog")
  })
  observeEvent(input$back_to_home_1, { nav_select(id = "main_nav", selected = "Home") })
  
  observeEvent(input$linkB2, {
    nav_select(id = "main_nav", selected = "ch_blog")
  })
  observeEvent(input$back_to_home_2, { nav_select(id = "main_nav", selected = "Home") })
  
  observeEvent(input$datasources, {
    nav_select(id = "main_nav", selected = "data_page")
  })
  observeEvent(input$back_to_home_3, { nav_select(id = "main_nav", selected = "Home") })


    output$Blog1 <- renderText(
      expr = "Initially, it can be seen in the Primary Energy Source Distribution for the US that solar power plants are the most numerous, followed by natural gas and hydroelectric power plants. Then, by selecting these energy types in the adjacent graph it can be seen that California actually has the highest counts of power plants whose primary energy source is one of the three. This was expected, based on the initial power plant map which shades US states by count and shows California has almost 800 more power plants than the next state. However, after inspecting the intersections of power plant energy capacity and data centers locations, it was surprising to see only small clustering of data centers in California compared to some other US states. This led me to deeper examination of this geographic correlation.

	Foremost, I took a step back to observe how data centers tended to be clustered in the US and was surprised to see there was a much higher abundance of them in the eastern half of the US, most noticeably along the east coast and near the great lakes. However, two underlying trends that correspond with the eastern US are the population density and presence of high capacity natural gas power plants. Visually, these factors were the most consistent explainers of clusters of data centers in the US. Using the layer controls on the heat map in the data centers tab, it can be seen how small data centers seem to cluster around highly populous areas like Atlanta, Dallas, or D.C. and tend to be very sparsely populated in the Great Plains region of the US. This is likewise, for hyperscale data centers which seem to follow this geographic trend even more consistently but in smaller clustering: there are very few western centers of this size. Conversely, the largest data centers actually show up in Great Plains states like Utah and Wyoming, where populations are sparse and there is ample space.  This trend makes sense, as small data centers do not require as much space or resources and are purposed with smaller tasks such as reducing latency, while mega campuses are massive consumers of local resources. Additionally, the clustering around natural gas power plants could be reasoned by the reliability of consistent energy production  as they are not heavily affected by weather fluctuations like solar or wind plants, making them optimal energy sources for data centers to locate near. 

This did not fully explain why California had fewer data centers, as it has the most natural gas power plants and is the most populated state. However, further research could hope to explain more localized trends. Additionally, due to time constraints I was unable to collect comprehensive nationwide employment data that was related to power plants in the US, but future extensions of this project would hope to examine how impactful an employer a given power plant is, by the percentage of a standardized region it employed. This would be another step towards my original motivating questions.
"
    )
    
    output$Blog2 <- renderText(
      expr = "
      My goal for this piece of my research was to examine if there were trends in higher housing prices in counties where Fortune 500 company headquarters were also located. This exploration was also limited  by the timeframe, as I was not able to visualize the true impact of companies as I had initially imagined, which was visualizing direct housing prices differences in the years following when they were first named to the Fortune 500 list. Alternatively, I was able to visualize housing price index trends over the past 25 years in counties across the US to try and examine price change differences in surrounding counties to see if there were higher rates of growth in the counties in which the headquarters were located. Observing such a correlation could help motivate questions about whether these companies were directly driving changes in the housing market through employment incentives. To fully explore this layer, I had also hoped to collect employment data for each company on the Fortune 500 list to examine how much local job markets are influenced by the presence of the headquarters office. This could lead to questions about how much communities members actually rely on the headquarters for jobs versus are negatively impacted by their potential to influence county housing prices. These are questions that were also outside of the mapping scope of this project and would require more advanced research and statistical modeling. 
      
In terms of observed trends in the relevant counties with a Fortune 500 company, housing prices did tend to increase, but there is generally too much confounding information to make claims of strong correlations. The companies tend to be located in the more populous areas of the state they are in, which inherently will have a higher housing price index. I also investigated whether states with higher per-capita counts of Fortune 500 companies tended to have higher percentage changes in the statewide housing price index over 25 years, but found no noticeable relationship.
"
    )
    
    output$DataSource <- renderText(
      expr = "
      Power Plants:
      https://gis-fema.hub.arcgis.com/datasets/b063316fac7345dba4bae96eaa813b2f/about
      
      Housing:
      https://www.nar.realtor/research-and-statistics/housing-statistics/county-median-home-prices-and-monthly-mortgage-payment
      https://www.fhfa.gov/data/hpi/datasets?tab=annual-data 
      
      Fortune 500:
      https://padlet.com/gallery/a-map-of-fortune-500-headquarters-357ned1s9wig
      "
    )

  
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
        title = "Total Power Plant Count"
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
  if (is.null(clicked_state())) {
    state_subset <- Powerplants 
    title <- "Primary Energy Source Distribution for the US"
  } else {
    state_subset <- Powerplants %>% filter(State == clicked_state())
    title <- paste("Primary Energy Source Distribution for", clicked_state())
  }
  

  ggplot(state_subset, aes(x = fct_infreq(str_to_title(Primary.Energy.Source)), fill = Primary.Energy.Source)) +
    geom_bar(color = "black") +
    scale_fill_manual(values = leaflet_colors) +
    theme(axis.text.x = element_text(angle = -90)) +
    labs(y = "Count",
         x = "Powerplant Primary Energy Source",
         title = title)
  
  })



output$Energy <- renderPlot({
  
  energy_subset <- Powerplants %>% 
    filter(str_to_title(Primary.Energy.Source) == input$energy_choice)
  
  ggplot(energy_subset, aes(x = fct_infreq(State), fill = Primary.Energy.Source)) +
    geom_bar(color = "black") +
    scale_x_discrete(drop = FALSE) +
    scale_fill_manual(values = leaflet_colors) +
    theme(axis.text.x = element_text(angle = -90),
          legend.position = "none") +
    labs(y = "Count",
         x = " ",
         title = paste("Primary Energy Source:", str_to_title(input$Primary.Energy.Source)))
  
  
})


max_abs_val <- max(abs(HQHPICNTY$Annual.Change....), na.rm = TRUE)

cus <- c("darkred", "#8e0152", "#ffffff", "limegreen", "#276419")

pal <- colorNumeric(
  palette = cus,
  domain = c(-max_abs_val, max_abs_val)
)

County_pal <- colorNumeric(
  palette = "YlOrRd", 
  domain = county_prices$Median.Home.Price
)

output$Housing <- renderLeaflet({
    leaflet(state_sf) %>% 
      addProviderTiles(providers$CartoDB.Positron) %>% 
      setView(lng = -98.58, lat = 39.82, zoom = 4) %>%
      addPolygons(
        group = "base_states",
        fillColor = "white",
        fillOpacity = 0,
        color = "black",
        weight = 1
      ) %>% 
    addPolygons(
      data = county_prices,
      group = "all_counties",
      fillColor = ~County_pal(Median.Home.Price),
      fillOpacity = 0.6,
      color = "black",
      weight = 1,
      smoothFactor = 0.5,
      label = ~paste0(str_to_title(County), " County"),
      popup = ~paste0(
        str_to_title(County), " County,", "<br/>",
        "Median Home Price: ", dollar(Median.Home.Price)
      ) 
    ) %>% 
    addMarkers(
      data = housing_map,
      lng = ~Longitude, 
      lat = ~Latitude,
      layerId = ~Company,
      label = ~Company
    ) %>% 
    addLegend(
      data = (county_prices %>% drop_na()),
      position = "bottomright",
      pal = County_pal,
      values = ~Median.Home.Price,
      title = "2025 Median Home Price",
      labFormat = labelFormat(prefix = "$"),
      opacity = 0.8
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

selected_state <- reactive({
  req(zoomed_state())
  current_year <- if (!is.null(input$Year)) input$Year else 2000
  
  HQHPICNTY %>% 
    filter(Year == current_year, State == zoomed_state()) %>% 
    filter(!st_is_empty(geometry), !is.na(Annual.Change....)) 
})

observe({
  req(zoomed_state())
  req(input$Year)

  county_subset <- selected_state()
  
  
  leafletProxy("Housing") %>% 
    clearGroup("counties") %>% 
    clearGroup("all_counties") %>% 
    clearControls() %>% 
    addPolygons(
      data = county_subset,
      group = "counties",
      layerId = ~County,
      fillColor = ~pal(Annual.Change....),
      fillOpacity = 1,
      label = ~str_to_title(County),
      popup = ~paste0(str_to_title(County), " County,", "<br/>",
                      "HPI: ", as.character(HPI), "<br/>",
                      Annual.Change....,"% Change From ", (as.numeric(Year) - 1)),
      color = "black",
      weight = 1
    ) %>% 
    addLegend(
      pal = pal,
      values = county_subset$Annual.Change....,
      title = "Year-to-Year Change in HPI (%)",
      position = "bottomleft",
      opacity = 1
     ) %>% 
    addLegend(
      position = "topright",
      colors = character(0),
      labels = character(0),
      title = paste0("Year: ", if (!is.null(input$Year)) as.character(input$Year) else "2000")
    )
})

output$slider <- renderUI({
  req(zoomed_state())
  
  sliderInput("Year", 
              "Slide to Change the Year", 
              min = 2000, 
              max = 2025, 
              2000, 
              animate = animationOptions(interval = 3500, loop = TRUE)
  )
})

HPIPerPal <- colorNumeric(
  palette = "YlGn", 
  domain = HPI_sf$total_hpi_change
)
  
output$HPI <- renderLeaflet({
  leaflet(HPI_sf) %>% 
    addProviderTiles(providers$CartoDB.Positron) %>% 
    setView(lng = -98.58, lat = 39.82, zoom = 4) %>%
    addPolygons(
      layerId = ~State,
      fillColor = ~HPIPerPal(total_hpi_change),
      fillOpacity = 0.5,
      color = "black",
      weight = 1,
      label = ~percent(round(total_hpi_change, 3))
    ) %>% 
    
    addLegend(
      pal = HPIPerPal,
      values = HPI_State_Change$total_hpi_change, 
      position = "bottomright",
      title = "Total HPI Change (%)",
      labFormat = labelFormat(suffix = "%", transform = function(x) x * 100)
    )
})

leaflet_colors2 <- setNames(HPIPerPal(HPI_sf$total_hpi_change), HPI_sf$State)

output$Companycount <- renderPlot({
  
  ggplot(Headquarters_bar, aes(x = reorder(State, -total_hpi_change), y = HQ_per_cap, fill = State)) +
    geom_col(color = "black", alpha = 0.5) +
    scale_x_discrete(drop = FALSE) +
    scale_fill_manual(values = leaflet_colors2) +
    theme(axis.text.x = element_text(angle = -90),
          legend.position = "none") +
    labs(y = "Count",
         x = "State",
         title = "Fortune 500 Companies per 1 Million People by State")
    
})


output$StateHPIChart <- renderPlot({
  req(zoomed_state())
  
  state_subset <- HPI %>% filter(State == zoomed_state(), !is.na(Annual.Change....)) %>% 
    group_by(Year) %>% summarize(avg_annual_change = mean(Annual.Change....))
  
  ggplot(state_subset, aes(x = as.factor(Year), y = avg_annual_change, fill = ifelse(avg_annual_change > 0, "lightgreen", "red"))) +
    geom_col(color = "black", alpha = 0.3) +
    geom_hline(yintercept = 0)+
    scale_fill_identity() +
    theme(axis.text.x = element_text(angle = -90),
          legend.position = "none") +
    labs(x = "Year",
         y = "Anual Change (%)",
         title = paste("Annual Percent Change Averaged Across : ", str_to_title(zoomed_state())))
  
})


energy_subset <- reactive({
  if(is.null(input$energy_source) || "All" %in% input$energy_source) {
    return(powerplant_produc)
  }
  
  powerplant_produc %>% 
    mutate(Primary.Energy.Source = tolower(Primary.Energy.Source)) %>% 
    filter(Primary.Energy.Source %in% tolower(input$energy_source))
  
})

state_subset <- reactive({
  if(is.null(input$State) || input$State == "United States") {
    return(energy_subset())
  }
  
  energy_subset() %>% 
    mutate(State = str_to_title(State)) %>% 
    filter(State == input$State)
})

DC_subset <- reactive({
  if(is.null(input$State) || input$State == "United States") {
    return(data_centers)
  }
  
  data_centers %>% 
    mutate(State = str_to_title(State)) %>% 
    filter(State == input$State)
})


data_centers$dc_radius <- rescale(data_centers$mw_clean, to = c(3, 8))

output$Heatmap <- renderLeaflet({
  heatmap_colors <- c("blue", "cyan", "limegreen", "yellow", "red")
  
  leaflet(state_subset()) %>%
    addProviderTiles(providers$CartoDB.Positron) %>% 
    addCircleMarkers(
      lat = ~Latitude,
      lng = ~Longitude,
      label = ~paste0("mw capacity: ", mw_capacity),
      radius = 3,
      weight = .03,
      fillOpacity = 0,
      fillColor = "black",
      group = "plants"
    ) %>% 
    addHeatmap(
      lng = ~Longitude, 
      lat = ~Latitude, 
      intensity = ~mw_capacity, 
      blur = 10, 
      radius = 13
    ) %>% 
    #Small Data Centers (0-100 MW)
    addCircleMarkers(
      data = subset(DC_subset(), mw_clean <= 100),
      lat = ~lat,
      lng = ~long,
      label = ~paste0("mw consumption: ", ifelse(mw_clean == 0, "unknown" , mw_clean)),
      radius = ~dc_radius, 
      weight = 0, fillOpacity = 1, fillColor = "black",
      group = "Small (0-100 MW)"
    ) %>% 
    #Hyperscale Data Centers (100-1000 MW)
    addCircleMarkers(
      data = subset(DC_subset(), mw_clean > 100 & mw_clean <= 1000),
      lat = ~lat,
      lng = ~long,
      label = ~paste0("mw consumption: ", ifelse(mw_clean == 0, "unknown ", mw_clean)),
      radius = ~dc_radius, 
      weight = 0, fillOpacity = 1, fillColor = "black",
      group = "Hyperscale (100-1000 MW)"
    ) %>% 
    #Mega Campus Data Centers (>1000 MW)
    addCircleMarkers(
      data = subset(DC_subset(), mw_clean > 1000),
      lat = ~lat,
      lng = ~long,
      label = ~paste0("mw consumption: ", ifelse(mw_clean == 0, "unknown ", mw_clean)),
      radius = ~dc_radius, 
      weight = 0, fillOpacity = 1, fillColor = "black",
      group = "Mega Campus (>1000 MW)"
    ) %>% 
    
    addLegend(
      position = "bottomleft",
      colors = rev(heatmap_colors), 
      labels = rev(c("Low", "", "Medium", "", "High")),
      title = "Power Plant Capacity (MW)",
      opacity = 0.7
    ) %>%
    addLayersControl(
      overlayGroups = c(
        "Small (0-100 MW)", 
        "Hyperscale (100-1000 MW)", 
        "Mega Campus (>1000 MW)"
      ),
      options = layersControlOptions(collapsed = FALSE)
    )
})

observe({
  leafletProxy("Heatmap") %>%
    clearGroup("plants") %>%
    clearGroup("Small (0-100 MW)") %>%
    clearGroup("Hyperscale (100-1000 MW)") %>%
    clearGroup("Mega Campus (>1000 MW)") %>%
    removeWebGLHeatmap(layerId = "heat") %>%
    
    addCircleMarkers(
      data = state_subset(),
      lat = ~Latitude,
      lng = ~Longitude,
      label = ~paste0("mw capacity: ", mw_capacity, ", Source: ", str_to_title(Primary.Energy.Source)),
      radius = 3,
      weight = .03,
      fillOpacity = 0,
      fillColor = "black",
      group = "plants"
    ) %>% 
    addHeatmap(
      data = state_subset(),
      lng = ~Longitude, 
      lat = ~Latitude, 
      intensity = ~mw_capacity, 
      blur = 10, 
      radius = 13,
      layerId = "heat"
    ) %>% 
    addCircleMarkers(
      data = subset(DC_subset(), mw_clean <= 100),
      lat = ~lat,
      lng = ~long,
      label = ~paste0("mw consumption: ", ifelse(mw_clean == 0, "unknown ", mw_clean)),
      radius = ~dc_radius, 
      weight = 0, fillOpacity = 1, fillColor = "black",
      group = "Small (0-100 MW)"
    ) %>% 
    addCircleMarkers(
      data = subset(DC_subset(), mw_clean > 100 & mw_clean <= 1000),
      lat = ~lat,
      lng = ~long,
      label = ~paste0("mw consumption: ", ifelse(mw_clean == 0, "unknown ", mw_clean)),
      radius = ~dc_radius, 
      weight = 0, fillOpacity = 1, fillColor = "black",
      group = "Hyperscale (100-1000 MW)"
    ) %>% 
    addCircleMarkers(
      data = subset(DC_subset(), mw_clean > 1000),
      lat = ~lat,
      lng = ~long,
      label = ~paste0("mw consumption: ", ifelse(mw_clean == 0, "unknown ", mw_clean)),
      radius = ~dc_radius, 
      weight = 0, fillOpacity = 1, fillColor = "black",
      group = "Mega Campus (>1000 MW)"
    )
})


output$Heatmap_Data <- renderDataTable({
plants <- state_subset() %>% arrange(-mw_capacity)},
options = list(pageLength = 15)
)


output$Data_centers <- renderLeaflet({
  my_bins <- c(0, 10, 50, 100, 500, 10000) 
  
  
  pal <- colorBin(
    palette = "YlOrRd",
    domain = data_centers$pct_consumed,
    bins = my_bins,
    na.color = "gray"
  )
  
  local_range <- 50 * 1609.34
  
  # Build the map
  leaflet(data_centers) %>%
    addProviderTiles(providers$CartoDB.DarkMatter) %>%
    addCircles(
      lng = ~long, 
      lat = ~lat,
      radius = local_range,
      stroke = TRUE,              
      color = "#ffffff01",       
      weight = 1,   
      fillColor = "#ffffff01",    
      highlightOptions = highlightOptions(
        stroke = TRUE, 
        color = "red", 
        weight = 2,
        fillOpacity = 0.1,
        bringToFront = FALSE     
      )
    ) %>%
    addCircleMarkers(
      data = powerplant_produc,
      lat = ~Latitude,
      lng = ~Longitude,
      label = ~paste0("mw capacity: ", mw_capacity),
      radius = 2.5,
      weight = 1,
      stroke = TRUE,
      color = "white",
      fillOpacity = .5,
      fillColor = "blue"
    ) %>% 
    addCircleMarkers(
      lng = ~long, 
      lat = ~lat,
      radius = 6,
      weight = 1,
      color = "#ffffff",
      fillColor = ~pal(pct_consumed),
      fillOpacity = 0.9,
      label = ~paste0("Consumes ", ifelse(mw_clean == 0, "unknown ", mw_clean), " mw. Which is ", ifelse(pct_consumed == 0, "unknown ", round(pct_consumed, 1)), "% of local plant power")
    ) %>%
    addLegend(
      position = "bottomright",
      pal = pal,
      values = data_centers$pct_consumed,
      title = "% of Local Power Consumed",
      opacity = 1
    ) %>% 
    addLegend(
      position = "topright",
      colors = "transparent",
      labels = "⭕ Power Plants Within 50 Miles" 
    ) %>% 
    addLegend(
      position = "topright",
      colors = "transparent",      
      labels = "🔵 Power Plants"
    ) 
})



}

shinyApp(ui, server)

