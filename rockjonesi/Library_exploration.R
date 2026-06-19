

library(tidyverse)
library(purrr)


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








