library(tidyverse)
library(rvest)
library(tidyr)

base_url <- "https://whichmuseum.com/place/united-states-2682"

total_museums <- 12046
museums_per_page <- 36
total_pages <- ceiling(total_museums / museums_per_page)

page_urls <- tibble(
  page = 1:total_pages,
  url = if_else(
    page == 1,
    base_url,
    paste0(base_url, "?page=", page)
  )
)

get_museum_links <- function(page_url) {
  page <- read_html(page_url)
  
  links <- page %>%
    html_elements("a")
  
  tibble(
    museum_name_card = html_text2(links),
    href = html_attr(links, "href")
  ) %>%
    filter(str_detect(href, "^/museum/")) %>%
    distinct(href, .keep_all = TRUE) %>%
    mutate(
      museum_url = paste0("https://whichmuseum.com", href),
      source_page = page_url
    )
}

safe_get_museum_links <- safely(get_museum_links)

links_raw_nested <- page_urls %>%
  mutate(
    result = map(url, function(x) {
      message("scraping: ", x)
      Sys.sleep(1)
      safe_get_museum_links(x)
    }),
    data = map(result, "result"),
    error = map(result, "error")
  )

failed_pages <- links_raw_nested %>%
  filter(!map_lgl(error, is.null)) %>%
  select(page, url, error)

links_raw <- links_raw_nested %>%
  filter(map_lgl(error, is.null)) %>%
  select(page, data) %>%
  unnest(data)

whichmuseum_us_unique_links <- links_raw %>%
  distinct(museum_url, .keep_all = TRUE)

dir.create("data", showWarnings = FALSE)

write_csv(
  links_raw,
  "data/whichmuseum_us_listings_raw.csv"
)

write_csv(
  whichmuseum_us_unique_links,
  "data/whichmuseum_us_unique_links.csv"
)

write_csv(
  failed_pages,
  "data/whichmuseum_failed_pages.csv"
)

message("raw listings saved: ", nrow(links_raw))
message("unique museum URLs saved: ", nrow(whichmuseum_us_unique_links))
message("failed pages: ", nrow(failed_pages))
