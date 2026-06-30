library(tidyverse)
library(rvest)
library(httr)


museum_data <- read_csv("data/Museum/whichmuseum_details_12000_geo.csv")


museum_app_data <- museum_data %>%
  filter(!is.na(latitude), !is.na(longitude)) %>%
  mutate(
    website_link = if_else(is.na(website_link), "", website_link),
    museum_url = if_else(is.na(museum_url), "", museum_url),
    category = if_else(is.na(category), "Unknown", category),
    state = case_when(
      str_detect(state, "^FL") ~ "Florida",
      str_detect(state, "^NJ") ~ "New Jersey",
      str_detect(state, "^NY") ~ "New York",
      TRUE ~ state
    )
  ) %>%
  filter(state %in% state.name | state == "Washington DC") %>%
  mutate(
    has_website = website_link != "",
    
    basic_intro = paste0(
      museum_name,
      " is a ",
      category,
      " museum located in ",
      state,
      ", United States."
    ),
    
    text_for_tags = str_to_lower(
      paste(museum_name, category, full_address)
    ),
    
    theme = case_when(
      str_detect(text_for_tags, "children|kids|child|youth|family") ~ "Children / Family",
      str_detect(text_for_tags, "zoo|aquarium|wildlife|botanical|garden|nature|natural history") ~ "Nature",
      str_detect(text_for_tags, "air|space|aviation|flight|railroad|railway|transport|car|auto|maritime|ship") ~ "Transportation",
      str_detect(text_for_tags, "military|war|naval|army|veteran|battlefield") ~ "Military",
      str_detect(text_for_tags, "science|technology|planetarium") ~ "Science",
      str_detect(text_for_tags, "art|design|gallery") ~ "Art",
      str_detect(text_for_tags, "history|historic|heritage|anthropology") ~ "History",
      TRUE ~ "Other"
    ),
    
    family_friendly = str_detect(text_for_tags, "children|kids|child|youth|family"),
    outdoor_related = str_detect(text_for_tags, "park|garden|zoo|aquarium|wildlife|nature|botanical"),
    science_related = str_detect(text_for_tags, "science|technology|space|planetarium"),
    art_related = str_detect(text_for_tags, "art|design|gallery"),
    history_related = str_detect(text_for_tags, "history|historic|heritage|anthropology"),
    transportation_related = str_detect(text_for_tags, "air|space|aviation|flight|railroad|railway|transport|car|auto|maritime|ship"),
    military_related = str_detect(text_for_tags, "military|war|naval|army|veteran|battlefield")
  ) %>%
  select(-text_for_tags)



get_visitor_links <- function(url) {
  if (is.na(url) || url == "") {
    return(tibble(ticket_link = NA_character_, visit_link = NA_character_))
  }
  
  page <- tryCatch(
    read_html(url),
    error = function(e) NULL
  )
  
  if (is.null(page)) {
    return(tibble(ticket_link = NA_character_, visit_link = NA_character_))
  }
  
  links <- page %>%
    html_elements("a")
  
  links_tbl <- tibble(
    link_text = html_text2(links),
    href = html_attr(links, "href")
  ) %>%
    filter(!is.na(href)) %>%
    mutate(
      link_text_lower = str_to_lower(link_text),
      href_lower = str_to_lower(href)
    )
  
  ticket_link <- links_tbl %>%
    filter(
      str_detect(link_text_lower, "ticket|admission|admissions|buy|reserve|reservation|book") |
        str_detect(href_lower, "ticket|admission|admissions|buy|reserve|reservation|book")
    ) %>%
    pull(href) %>%
    first()
  
  visit_link <- links_tbl %>%
    filter(
      str_detect(link_text_lower, "visit|plan your visit|hours|directions") |
        str_detect(href_lower, "visit|hours|directions")
    ) %>%
    pull(href) %>%
    first()
  
  tibble(
    ticket_link = ticket_link,
    visit_link = visit_link
  )
}


visitor_links_test <- museum_app_data %>%
  slice(1:20) %>%
  mutate(
    visitor_data = map(website_link, function(x) {
      message("scraping: ", x)
      Sys.sleep(1)
      get_visitor_links(x)
    })
  ) %>%
  unnest(visitor_data)

View(visitor_links_test)


safe_get_visitor_links <- safely(get_visitor_links)

visitor_links_full <- museum_app_data %>%
  mutate(
    result = map(website_link, function(x) {
      message("scraping: ", x)
      Sys.sleep(1)
      safe_get_visitor_links(x)
    }),
    visitor_data = map(result, "result"),
    error = map(result, "error")
  )

failed_visitor_links <- visitor_links_full %>%
  filter(!map_lgl(error, is.null)) %>%
  select(museum_name, website_link, error)

visitor_links_clean <- visitor_links_full %>%
  mutate(
    visitor_data = map(visitor_data, function(x) {
      if (is.null(x)) {
        tibble(ticket_link = NA_character_, visit_link = NA_character_)
      } else {
        x
      }
    })
  ) %>%
  select(-result, -error) %>%
  unnest(visitor_data) %>%
  mutate(
    has_ticket_link = !is.na(ticket_link),
    has_visit_link = !is.na(visit_link)
  )


dir.create("data/Museum", showWarnings = FALSE)

write_csv(
  visitor_links_clean,
  "data/Museum/museum_app_data.csv"
)

write_csv(
  failed_visitor_links,
  "data/Museum/museum_visitor_link_failures.csv"
)

message("Saved app data: ", nrow(visitor_links_clean), " rows.")
message("Failed visitor link scrapes: ", nrow(failed_visitor_links))