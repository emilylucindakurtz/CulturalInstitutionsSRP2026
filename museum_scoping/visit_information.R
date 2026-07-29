library(tidyverse)
library(rvest)
library(httr)


museum_app_data <- read_csv("data/Museum/museum_app_data.csv") %>%
  mutate(
    website_link = if_else(is.na(website_link), "", website_link)
  )


make_absolute_url <- function(href, base_url) {
  if (is.na(href) || href == "") {
    return(NA_character_)
  }
  
  if (str_detect(href, "^https?://")) {
    return(href)
  }
  
  if (str_starts(href, "/")) {
    domain <- str_extract(base_url, "^https?://[^/]+")
    return(paste0(domain, href))
  }
  
  return(paste0(str_remove(base_url, "/$"), "/", href))
}



get_visit_info <- function(url) {
  empty_result <- tibble(
    scraped_visit_link = NA_character_,
    scraped_ticket_link = NA_character_,
    hours_text = NA_character_,
    admission_text = NA_character_,
    accessibility_text = NA_character_
  )
  
  if (is.na(url) || url == "") {
    return(empty_result)
  }
  
  page <- tryCatch(
    read_html(url),
    error = function(e) NULL
  )
  
  if (is.null(page)) {
    return(empty_result)
  }
  
  page_text <- html_text2(page)
  
  links <- page %>%
    html_elements("a")
  
  links_tbl <- tibble(
    link_text = html_text2(links),
    href = html_attr(links, "href")
  ) %>%
    filter(!is.na(href)) %>%
    mutate(
      link_text_lower = str_to_lower(link_text),
      href_lower = str_to_lower(href),
      full_href = map_chr(href, make_absolute_url, base_url = url)
    )
  
  scraped_visit_link <- links_tbl %>%
    filter(
      str_detect(link_text_lower, "visit|plan your visit|hours|directions") |
        str_detect(href_lower, "visit|hours|directions")
    ) %>%
    pull(full_href) %>%
    first()
  
  scraped_ticket_link <- links_tbl %>%
    filter(
      str_detect(link_text_lower, "ticket|admission|admissions|buy|reserve|reservation|book") |
        str_detect(href_lower, "ticket|admission|admissions|buy|reserve|reservation|book")
    ) %>%
    pull(full_href) %>%
    first()
  
  lines <- page_text %>%
    str_split("\n") %>%
    pluck(1) %>%
    str_squish()
  
  lines <- lines[lines != ""]
  
  hours_text <- lines %>%
    str_subset(regex("hours|open|closed|monday|tuesday|wednesday|thursday|friday|saturday|sunday", ignore_case = TRUE)) %>%
    head(5) %>%
    paste(collapse = " | ")
  
  admission_text <- lines %>%
    str_subset(regex("admission|ticket|tickets|free|members|adult|child|children|student|senior", ignore_case = TRUE)) %>%
    head(5) %>%
    paste(collapse = " | ")
  
  accessibility_text <- lines %>%
    str_subset(regex("accessibility|accessible|wheelchair|ada|service animal|disability", ignore_case = TRUE)) %>%
    head(5) %>%
    paste(collapse = " | ")
  
  tibble(
    scraped_visit_link = scraped_visit_link,
    scraped_ticket_link = scraped_ticket_link,
    hours_text = if_else(hours_text == "", NA_character_, hours_text),
    admission_text = if_else(admission_text == "", NA_character_, admission_text),
    accessibility_text = if_else(accessibility_text == "", NA_character_, accessibility_text)
  )
}

visit_info_test <- museum_app_data %>%
  filter(website_link != "") %>%
  slice(1:100) %>%
  mutate(
    visit_info = map(website_link, function(x) {
      message("scraping: ", x)
      Sys.sleep(1)
      get_visit_info(x)
    })
  ) %>%
  unnest(visit_info)

View(visit_info_test)

write_csv(
  visit_info_test,
  "data/Museum/museum_visit_information_test_100.csv"
)

safe_get_visit_info <- safely(get_visit_info)

visit_info_full <- museum_app_data %>%
  filter(website_link != "") %>%
  mutate(
    result = map(website_link, function(x) {
      message("scraping: ", x)
      Sys.sleep(1)
      safe_get_visit_info(x)
    }),
    visit_info = map(result, "result"),
    error = map(result, "error")
  )

failed_visit_info <- visit_info_full %>%
  filter(!map_lgl(error, is.null)) %>%
  select(museum_name, website_link, error)

visit_info_clean <- visit_info_full %>%
  mutate(
    visit_info = map(visit_info, function(x) {
      if (is.null(x)) {
        tibble(
          scraped_visit_link = NA_character_,
          scraped_ticket_link = NA_character_,
          hours_text = NA_character_,
          admission_text = NA_character_,
          accessibility_text = NA_character_
        )
      } else {
        x
      }
    })
  ) %>%
  select(-result, -error) %>%
  unnest(visit_info)

write_csv(
  visit_info_clean,
  "data/Museum/museum_visit_information_full.csv"
)

write_csv(
  failed_visit_info,
  "data/Museum/museum_visit_information_failures.csv"
)

message("Saved full visit info: ", nrow(visit_info_clean))
message("Failed scrapes: ", nrow(failed_visit_info))