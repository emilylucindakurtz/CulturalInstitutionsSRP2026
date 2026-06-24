library(tidyverse)

# Read satellite data --------------------------------------------------

nightlights <- read_csv("Satellite/nighttime_lights_points.csv")

NO2_fortune500 <- read_csv("Satellite/no2_fortune500.csv")
NO2_powerplant <- read_csv("Satellite/no2_power_plants_all_june2023.csv")
NO2_sportsvenues <- read_csv("Satellite/no2_sports_venues.csv")


# Check nighttime lights data -----------------------------------------

glimpse(nightlights)

nightlights %>%
  count(institution_type)

nightlights_summary <- nightlights %>%
  group_by(institution_type) %>%
  summarize(
    n = n(),
    mean_light = mean(avg_rad, na.rm = TRUE),
    median_light = median(avg_rad, na.rm = TRUE)
  )

nightlights_summary


# Visualize nighttime lights by institution type -----------------------


ggplot(nightlights, aes(x = institution_type, y = avg_rad)) +
  geom_boxplot() +
  labs(
    title = "Nighttime Light Intensity by Institution Type",
    x = "Institution Type",
    y = "Average Radiance"
  ) +
  theme_minimal()


# Combine NO2 datasets -------------------------------------------------

no2_all <- bind_rows(
  NO2_fortune500,
  NO2_powerplant,
  NO2_sportsvenues
)

glimpse(no2_all)

no2_all %>%
  count(institution_type)


# Clean and merge nighttime lights with NO2 ----------------------------


no2_clean <- no2_all %>%
  select(name, institution_type, no2)

nightlights_clean <- nightlights %>%
  select(name, institution_type, avg_rad)

satellite_indicators <- nightlights_clean %>%
  left_join(
    no2_clean,
    by = c("name", "institution_type")
  )

glimpse(satellite_indicators)


# Summary statistics ---------------------------------------------------

satellite_summary <- satellite_indicators %>%
  group_by(institution_type) %>%
  summarize(
    n = n(),
    mean_light = mean(avg_rad, na.rm = TRUE),
    median_light = median(avg_rad, na.rm = TRUE),
    mean_no2 = mean(no2, na.rm = TRUE),
    median_no2 = median(no2, na.rm = TRUE)
  )

satellite_summary


satellite_indicators %>%
  group_by(institution_type) %>%
  summarize(
    q25 = quantile(no2, 0.25, na.rm = TRUE),
    median = median(no2, na.rm = TRUE),
    q75 = quantile(no2, 0.75, na.rm = TRUE)
  )


#Visualize NO2 by institution type ------------------------------------

ggplot(satellite_indicators, aes(x = institution_type, y = no2)) +
  geom_boxplot() +
  labs(
    title = "NO2 Concentration by Institution Type",
    x = "Institution Type",
    y = "NO2"
  ) +
  theme_minimal()


# Compare average nighttime lights and average NO2 ---------------------

ggplot(
  satellite_summary,
  aes(
    x = mean_light,
    y = mean_no2,
    label = institution_type
  )
) +
  geom_point(size = 5) +
  geom_text(nudge_y = 0.000005) +
  labs(
    title = "Average Nighttime Lights vs Average NO2",
    x = "Mean Nighttime Light Intensity",
    y = "Mean NO2"
  ) +
  theme_minimal()


# Violin plot: NO2 distribution ----------------------------------------
ggplot(
  satellite_indicators,
  aes(
    x = institution_type,
    y = no2,
    fill = institution_type
  )
) +
  geom_violin(alpha = 0.6) +
  geom_boxplot(
    width = 0.1,
    outlier.shape = NA
  ) +
  labs(
    title = "Distribution of NO2 by Institution Type",
    x = "Institution Type",
    y = "NO2"
  ) +
  theme_minimal() +
  theme(legend.position = "none")


# Violin plot: nighttime light distribution ---------------------------

ggplot(
  satellite_indicators,
  aes(
    x = institution_type,
    y = avg_rad,
    fill = institution_type
  )
) +
  geom_violin(alpha = 0.6) +
  geom_boxplot(
    width = 0.1,
    outlier.shape = NA
  ) +
  labs(
    title = "Distribution of Nighttime Light Intensity by Institution Type",
    x = "Institution Type",
    y = "Average Radiance"
  ) +
  theme_minimal() +
  theme(legend.position = "none")

satellite_indicators %>%
  group_by(institution_type) %>%
  summarize(
    median_light = median(avg_rad),
    median_no2 = median(no2)
  )


# Save cleaned satellite data -----------------------------------------
write_csv(
  satellite_indicators,
  "Satellite/satellite_indicators_nightlights_no2.csv"
)

write_csv(
  satellite_summary,
  "Satellite/satellite_summary_nightlights_no2.csv"
)