

library(tidyverse)
library(purrr)
library(maps)
library(usdata)
library(stringr)

PL13 <- read.csv("data/Libraries/Puout13a.csv")
PL14 <- read.csv("data/Libraries/PLS_FY2014_Outlet_puout14a.csv")
PL15 <- read.csv("data/Libraries/PLS_FY2015_Outlet_puout15a.csv")
PL16 <- read.csv("data/Libraries/PLS_FY2016_Outlet_puout16a.csv")
PL17 <- read.csv("data/Libraries/PLS_FY17_Outlet_pud17i.csv")
PL18 <- read.csv("data/Libraries/pls_fy18_outlet_pud18i.csv")
PL19 <- read.csv("data/Libraries/PLS_FY19_Outlet_pud19i.csv")
PL20 <- read.csv("data/Libraries/PLS_FY20_Outlet_pud20i.csv")
PL21 <- read.csv("data/Libraries/pls_fy21_outlet_pud21i.csv")
PL22 <- read.csv("data/Libraries/pls_fy22_outlet_pud22i.csv")
PL23 <- read.csv("data/Libraries/pls_fy23_outlet_pud23i.csv")

PL13 <- PL13 %>% mutate(LOCALE = as.integer(LOCALE))
PL14 <- PL14 %>% mutate(LOCALE = as.integer(LOCALE)) # there are "." as some of the locale cols
PL15 <- PL15 %>% mutate(LOCALE = as.integer(LOCALE)) # there are "." as some of the locale cols
PL16 <- PL16 %>% mutate(LOCALE = as.integer(LOCALE))
PL20 <- PL20 %>% mutate(LOCALE = as.integer(LOCALE))
PL22 <- PL22 %>% mutate(LOCALE = as.integer(LOCALE))

LibrariesList <- list(
  "2013" = PL13, "2014" = PL14, "2015" = PL15, "2016" = PL16, "2017" = PL17, 
  "2018" = PL18, "2019" = PL19, "2020" = PL20, "2021" = PL21, "2022" = PL22, "2023" = PL23
)

LibrariesList <- purrr::map(LibrariesList, function(x){
  x %>% select(STABR, FSCSKEY, LIBID, ADDRESS, CITY, ZIP, CNTY, LONGITUD, LATITUDE, SQ_FEET, CNTYPOP, LOCALE)
})


all_years <- bind_rows(LibrariesList, .id = "year") %>% 
  mutate(year = as.integer(year))
 

timetracker <- all_years %>% group_by(FSCSKEY) %>% summarize(open = min(year),
                                                             close = max(year),
                                                             totalyears = close - open)
closedoropened <- timetracker %>% filter(totalyears < 10)

library_changed <- all_years %>% inner_join(closedoropened, by = "FSCSKEY") %>% 
  select(-year) %>% distinct(FSCSKEY, .keep_all = TRUE) %>% filter(!FSCSKEY == "AK0018")
#FSCKEY AK0018 has lat/long of 0.000, 0.0000, will at least temporarily remove it from the data



ggplot(library_changed, aes(x = LONGITUD, y = LATITUDE, color = ifelse(close < 2023, "Closed", "Opened"))) +
  geom_point() +
  scale_color_manual(
    name = "Status",
    values = c("Closed" = "red", "Opened" = "blue"),
    labels = c("Closed", "Opened")) +
  theme_minimal()



library_changed %>% count(close < 2023)
#236 public libraries closed in the past 10 years. Only 160 new public libraries have arisen, as of 2023.


#getting the county shapefiles
county_sf <- counties(cb = TRUE, class = "sf") %>% 
  mutate(County = tolower(NAME),
         State = tolower(STATE_NAME))

#standardizing variables for join
library_map <- all_years %>% slice(-6203) %>% 
  mutate(County = str_to_lower(CNTY),
         State = str_to_lower(abbr2state(STABR)))



#aggregating to deal with many-to-many join errors
unique_county_locale <- library_map %>%
  group_by(State, County) %>%
  summarize(
    LOCALE = mean(LOCALE, na.rm = TRUE), 
    .groups = "drop"
  )

##join housing prices to county shapefile information
county_library <- county_sf %>%
  full_join(unique_county_locale %>% select(County, State, LOCALE), 
            by = c("State","County")) 

pal <- colorNumeric(
  palette = "YlOrRd", 
  domain = county_library$LOCALE
)

leaflet() %>%
  addTiles() %>%
  addPolygons(
    data = county_library,
    fillColor = ~pal(LOCALE),
    fillOpacity = 0.6,
    color = "black",
    weight = 1,
    smoothFactor = 0.5,
    popup = ~paste0(
      str_to_title(County), " County", "<br/>",
      "Metro/Urban Ranking:", LOCALE
    )
  ) %>%
  addMarkers(
    data = library_map,
    lng = ~LONGITUD, 
    lat = ~LATITUDE,
    popup = ~paste0(
      FSCSKEY, "<br/>",
      CITY, ", ", str_to_title(State), "<br/>",
      LOCALE
    ),
    label = ~CITY
  )




