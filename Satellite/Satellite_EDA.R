library(tidyverse)

nightlights <- read_csv("Satellite/nighttime_lights_points.csv")

glimpse(nightlights)

nightlights %>%
  count(institution_type)

nightlights %>%
  group_by(institution_type) %>%
  summarize(
    n = n(),
    mean_light = mean(avg_rad, na.rm = TRUE),
    median_light = median(avg_rad, na.rm = TRUE)
  )

ggplot(nightlights, aes(x = institution_type, y = avg_rad)) +
  geom_boxplot() +
  labs(
    title = "Nighttime Light Intensity by Institution Type",
    x = "Institution Type",
    y = "Average Radiance"
  ) +
  theme_minimal()