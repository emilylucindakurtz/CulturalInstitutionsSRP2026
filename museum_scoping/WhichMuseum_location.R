library(tidyverse)
library(rvest)

links <- read_csv("data/whichmuseum_us_links.csv")

scraping_location <- function(url){
  page <- read_html(url)
  
  page_text <- page%>%
    html_text2()
  
  all_links <- page%>%
    html_elements("a")
  
  links_tbl <- tibble(
    link_text = html_text2(all_links), 
    href = html_attr(all_links, "href")
  )
  
  map_link <- links_tbl%>%
    filter(str_detect(str_to_lower(link_text),"view on map|map"))%>%
    pull(href)%>%
    first()
  
  website_link <- links_tbl %>%
    filter(str_detect(str_to_lower(link_text),"website"))%>%
    pull(href)%>%
    first()
   
  category_pattern <- "History & Anthropology|Science & Technology|Nature & Natural History|Art & Design|Specialized & Alternative"
  
  category <- str_extract(page_text, category_pattern)
  
  tibble(
    category = category,
    map_link = map_link,
    website_link = website_link,
    page_text = page_text
  )
}

text_location <- links %>%
  slice(1:20)%>%
  mutate(
    data = map(museum_url, function(x){
      message("scraping: ",x)
      Sys.sleep(1)
      scraping_location(x)
    })
  )%>%
  unnest(data)

write_csv(
  text_location, 
  "data/whichmuseum_test_links.csv"
)

text_location %>%
  select(museum_url, category, map_link, website_link)
