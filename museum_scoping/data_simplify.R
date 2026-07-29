library(tidyverse)

museum_enriched <- read_csv("data/Museum/museum_app_data_enriched.csv")

museum_app_final <- museum_enriched %>%
  mutate(
    website_link = if_else(is.na(website_link), "", website_link),
    ticket_link = coalesce(final_ticket_link, ticket_link, ""),
    visit_link = coalesce(final_visit_link, visit_link, ""),
    
    hours_text = if_else(is.na(hours_text), "", hours_text),
    admission_text = if_else(is.na(admission_text), "", admission_text),
    accessibility_text = if_else(is.na(accessibility_text), "", accessibility_text),
    
    hours_summary = str_squish(str_trunc(hours_text, 250)),
    admission_summary = str_squish(str_trunc(admission_text, 250)),
    accessibility_summary = str_squish(str_trunc(accessibility_text, 250)),
    
    recommended_for = case_when(
      theme == "Children / Family" ~ "Families and children",
      theme == "Nature" ~ "Outdoor and nature lovers",
      theme == "Transportation" ~ "Transportation enthusiasts",
      theme == "Military" ~ "Military and history enthusiasts",
      theme == "Science" ~ "Science and technology enthusiasts",
      theme == "Art" ~ "Art lovers",
      theme == "History" ~ "History enthusiasts",
      TRUE ~ "General visitors"
    ),
    
    has_website = website_link != "",
    has_ticket_link = ticket_link != "",
    has_visit_link = visit_link != "",
    has_hours_info = hours_summary != "",
    has_admission_info = admission_summary != "",
    has_accessibility_info = accessibility_summary != ""
  ) %>%
  select(
    museum_name,
    category,
    theme,
    recommended_for,
    state,
    full_address,
    latitude,
    longitude,
    basic_intro,
    website_link,
    ticket_link,
    visit_link,
    hours_summary,
    admission_summary,
    accessibility_summary,
    has_website,
    has_ticket_link,
    has_visit_link,
    has_hours_info,
    has_admission_info,
    has_accessibility_info
  ) %>%
  distinct() %>%
  mutate(
    museum_id = row_number()
  )

write_csv(
  museum_app_final,
  "data/Museum/museum_app_final.csv"
)

message("Saved museum_app_final.csv")
message("Rows: ", nrow(museum_app_final))
message("Columns: ", ncol(museum_app_final))