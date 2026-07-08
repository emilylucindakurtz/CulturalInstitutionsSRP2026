library(tidyverse)

app_data <- read_csv("data/Museum/museum_app_data.csv")
visit_info <- read_csv("data/Museum/museum_visit_information_full.csv")

museum_app_data_enriched <- app_data %>%
  left_join(
    visit_info %>%
      select(
        museum_name,
        website_link,
        scraped_visit_link,
        scraped_ticket_link,
        hours_text,
        admission_text,
        accessibility_text
      ),
    by = c("museum_name", "website_link")
  ) %>%
  mutate(
    final_visit_link = coalesce(scraped_visit_link, visit_link),
    final_ticket_link = coalesce(scraped_ticket_link, ticket_link)
  )

write_csv(
  museum_app_data_enriched,
  "data/Museum/museum_app_data_enriched.csv"
)