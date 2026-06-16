library(tidyverse)
library(rvest)
library(tidyr)

links <- read_csv("data/whichmuseum_us_links.csv")

scrape_museum_details <- function(url) {
  page <- read_html(url)
  page_text <- html_text2(page)
  
  category_pattern <- "History & Anthropology|Science & Technology|Nature & Natural History|Art & Design|Specialized & Alternative"
  category <- str_extract(page_text, category_pattern)
  
  lines <- page_text %>%
    str_split("\n") %>%
    pluck(1) %>%
    str_squish()
  
  lines <- lines[lines != ""]
  
  country_index <- tail(which(lines == "United States"), 1)
  
  address <- NA_character_
  city_zip <- NA_character_
  state <- NA_character_
  
  if (!is.na(country_index) && country_index >= 5) {
    address <- lines[country_index - 4]
    city_zip <- lines[country_index - 3]
    state <- lines[country_index - 1]
  }
  
  zip <- str_extract(city_zip, "\\b\\d{5}\\b")
  
  city <- city_zip %>%
    str_remove("\\b\\d{5}\\b") %>%
    str_squish()
  
  all_links <- page %>%
    html_elements("a")
  
  links_tbl <- tibble(
    link_text = html_text2(all_links),
    href = html_attr(all_links, "href")
  )
  
  website_link <- links_tbl %>%
    filter(str_detect(str_to_lower(link_text), "website")) %>%
    pull(href) %>%
    first()
  
  tibble(
    museum_url = url,
    category = category,
    museum_name = address,
    street_address = city,
    state = state,
    country = "United States",
    full_address = str_squish(paste(city, state, zip, "United States", sep = ", ")),
    website_link = website_link
  )
}

museum_details_test <- links %>%
  mutate(
    data = map(museum_url, function(x) {
      message("scraping: ", x)
      Sys.sleep(1)
      scrape_museum_details(x)
    })
  ) %>%
  select(data) %>%
  unnest(data)

dir.create("data", showWarnings = FALSE)

write_csv(
  museum_details_test,
  "data/whichmuseum_details_test.csv"
)

View(museum_details_test)

