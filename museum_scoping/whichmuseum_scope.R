library(tidyverse)
library(rvest)
library(tidyr)

base_url <-("https://whichmuseum.com/place/united-states-2682")

total_museums <- 12046
museums_per_page <- 36
total_pages <- ceiling(total_museums/museums_per_page)

page_url<-tibble(
  page = 1:total_pages,
  url = if_else(
    page==1,
    base_url,
    paste0(base_url,"?page=", page)
  )
)

get_museum_links<-function(page_url){
  page<- read_html(base_url)
  
  links<- page%>%
    html_elements("a")
  
  tibble(
    museum_name_card = html_text2(links),
    href = html_attr(links, "href")
  )%>%
    filter(str_detect(href, "^/museum/"))%>%
    distinct(href, .keepall = TRUE)%>%
    mutate(
      museum_url = paste0("https://whichmuseum.com",href),
      source_page = page_url
    )
}

whichmuseum_us_links <- page_url %>% 
  mutate(
    data = map(url, function(x){
      message("scraping:", x)
      Sys.sleep(1)
      get_museum_links(x)
    })
  )%>%
  unnest(data)%>%
  distinct(museum_url,.keep_all = TRUE)

dir.create("data", showWarnings = FALSE)

write_csv(
  whichmuseum_us_links, 
  "data/whichmuseum_us_links.csv"
)
message("saved", nrow(whichmuseum_us_links), "museum links.")
