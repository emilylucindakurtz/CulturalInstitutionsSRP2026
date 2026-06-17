library(tidyverse)
library(rvest)
library(tidyr)
library(tidygeocoder)

listings <- read_csv("data/whichmuseum_us_listings_raw.csv")

unique_links <- listings %>%
  distinct(museum_url, .keep_all = TRUE)

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
  
  if (length(country_index) > 0 && !is.na(country_index) && country_index > 4) {
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
    full_address = str_squish(paste(city, state, "United States", sep = ", ")),
    website_link = website_link
  )
}
safe_scrape_museum_details <- safely(scrape_museum_details)

details_nested <- unique_links %>%
  mutate(
    result = map(museum_url, function(x) {
      message("scraping: ", x)
      Sys.sleep(0.5)
      safe_scrape_museum_details(x)
    }),
    data = map(result, "result"),
    error = map(result, "error")
  )

failed_museums <- details_nested %>%
  filter(!map_lgl(error, is.null)) %>%
  select(museum_url, error)

museum_details_unique <- details_nested %>%
  filter(map_lgl(error, is.null)) %>%
  select(data) %>%
  unnest(data)

museum_details_unique_geo <- museum_details_unique %>%
  filter(!is.na(full_address), full_address != "") %>%
  geocode(
    address = full_address,
    method = "osm",
    lat = latitude,
    long = longitude
  )

museum_details_12000_geo <- listings %>%
  left_join(
    museum_details_unique_geo,
    by = "museum_url"
  )

dir.create("data", showWarnings = FALSE)

write_csv(
  museum_details_unique_geo,
  "data/whichmuseum_details_unique_geo.csv"
)

write_csv(
  museum_details_12000_geo,
  "data/whichmuseum_details_12000_geo.csv"
)

write_csv(
  failed_museums,
  "data/whichmuseum_failed_museums.csv"
)

message("unique details with coordinates saved: ", nrow(museum_details_unique_geo))
message("12000 listings with coordinates saved: ", nrow(museum_details_12000_geo))
message("failed museums: ", nrow(failed_museums))

View(museum_details_12000_geo)