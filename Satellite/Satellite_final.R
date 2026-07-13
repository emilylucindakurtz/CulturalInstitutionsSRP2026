library(tidyverse)
library(broom)
library(ggplot2)

nightlights <- read_csv("./Satellite/nighttime_lights_points.csv")
no2_fortune500 <- read_csv("./Satellite/no2_fortune500.csv")
no2_powerplant <- read_csv("./Satellite/no2_power_plants_all_june2023.csv")
no2_sportsvenues <- read_csv("./Satellite/no2_sports_venues.csv")
impervious <- read_csv("./Satellite/impervious_surface_points.csv")


no2_all <- bind_rows(
  no2_fortune500,
  no2_powerplant,
  no2_sportsvenues
)

no2_clean <- no2_all %>%
  select(name, institution_type, no2)

nightlights_clean <- nightlights %>%
  select(name, institution_type, avg_rad)

impervious_clean <- impervious %>%
  select(name, institution_type, impervious_surface)


satellite_all <- nightlights_clean %>%
  left_join(no2_clean, by = c("name", "institution_type")) %>%
  left_join(impervious_clean, by = c("name", "institution_type")) %>%
  filter(
    !is.na(avg_rad),
    !is.na(no2),
    !is.na(impervious_surface)
  )

#   Compare the average levels of each satellite indicator
#   across institution types.

satellite_summary <- satellite_all %>%
  group_by(institution_type) %>%
  summarize(
    n = n(),
    
    mean_light = mean(avg_rad, na.rm = TRUE),
    median_light = median(avg_rad, na.rm = TRUE),
    
    mean_no2 = mean(no2, na.rm = TRUE),
    median_no2 = median(no2, na.rm = TRUE),
    
    mean_impervious = mean(impervious_surface, na.rm = TRUE),
    median_impervious = median(impervious_surface, na.rm = TRUE)
  )

satellite_summary


#   Convert three satellite indicators into one column
#   so they can be visualized together using facet plots.
satellite_long <- satellite_all %>%
  pivot_longer(
    cols = c(avg_rad, no2, impervious_surface),
    names_to = "indicator",
    values_to = "value"
  ) %>%
  mutate(
    indicator = recode(
      indicator,
      avg_rad = "Nighttime Lights",
      no2 = "NO2",
      impervious_surface = "Impervious Surface"
    )
  )
# Figure 1
# Violin plots + boxplots
#   Compare the distribution of each satellite indicator
#   across institution types.
ggplot(
  satellite_long,
  aes(
    x = institution_type,
    y = value,
    fill = institution_type
  )
) +
  geom_violin(alpha = 0.6) +
  geom_boxplot(width = 0.12, outlier.shape = NA) +
  facet_wrap(~ indicator, scales = "free_y") +
  labs(
    title = "Satellite Indicators by Institution Type",
    x = "Institution Type",
    y = "Indicator Value"
  ) +
  theme_minimal() +
  theme(legend.position = "none")

#   Measure linear relationships among the three satellite
#   indicators.
satellite_corr <- satellite_all %>%
  select(avg_rad, no2, impervious_surface) %>%
  cor(use = "complete.obs")

satellite_corr


satellite_corr_long <- satellite_corr %>%
  as.data.frame() %>%
  rownames_to_column("indicator_1") %>%
  pivot_longer(
    cols = -indicator_1,
    names_to = "indicator_2",
    values_to = "correlation"
  )

#   Visualize the correlation matrix between all satellite
#   indicators.

ggplot(
  satellite_corr_long,
  aes(
    x = indicator_1,
    y = indicator_2,
    fill = correlation
  )
) +
  geom_tile() +
  geom_text(aes(label = round(correlation, 2))) +
  labs(
    title = "Correlation Among Satellite Indicators",
    x = NULL,
    y = NULL,
    fill = "Correlation"
  ) +
  theme_minimal()

#   Test whether institution type has a statistically
#   significant effect on each satellite indicator.
run_anova <- function(data, outcome) {
  formula <- as.formula(paste(outcome, "~ institution_type"))
  model <- aov(formula, data = data)
  
  list(
    anova = tidy(model),
    tukey = tidy(TukeyHSD(model))
  )
}

anova_light <- run_anova(satellite_all, "avg_rad")
anova_no2 <- run_anova(satellite_all, "no2")
anova_impervious <- run_anova(satellite_all, "impervious_surface")

anova_light$anova
anova_no2$anova
anova_impervious$anova

anova_light$tukey
anova_no2$tukey
anova_impervious$tukey

#   Export summary statistics, ANOVA tables, and Tukey
#   post-hoc comparisons for inclusion in the final report.

dir.create("outputs", showWarnings = FALSE)
dir.create("outputs/Satellite", showWarnings = FALSE)

write_csv(
  satellite_all,
  "outputs/Satellite/satellite_all_indicators.csv"
)

write_csv(
  satellite_summary,
  "outputs/Satellite/satellite_summary_all_indicators.csv"
)

write_csv(
  anova_light$anova,
  "outputs/Satellite/anova_nighttime_lights.csv"
)

write_csv(
  anova_no2$anova,
  "outputs/Satellite/anova_no2.csv"
)

write_csv(
  anova_impervious$anova,
  "outputs/Satellite/anova_impervious.csv"
)

write_csv(
  anova_light$tukey,
  "outputs/Satellite/tukey_nighttime_lights.csv"
)

write_csv(
  anova_no2$tukey,
  "outputs/Satellite/tukey_no2.csv"
)

write_csv(
  anova_impervious$tukey,
  "outputs/Satellite/tukey_impervious.csv"
)
#   Provide a publication-style visualization showing
#   median, quartiles, and potential outliers for each
#   satellite indicator.
# Boxplots for all satellite indicators
ggplot(
  satellite_long,
  aes(
    x = institution_type,
    y = value,
    fill = institution_type
  )
) +
  geom_boxplot(
    width = 0.6,
    outlier.alpha = 0.25
  ) +
  facet_wrap(
    ~indicator,
    scales = "free_y",
    nrow = 1
  ) +
  labs(
    title = "Satellite Indicators by Institution Type",
    x = "",
    y = ""
  ) +
  theme_minimal(base_size = 14) +
  theme(
    legend.position = "none",
    plot.title = element_text(face = "bold"),
    strip.text = element_text(face = "bold")
  )
# Density distributions
#   Compare the overall distributions of each satellite
#   indicator across institution types.
ggplot(
  satellite_long,
  aes(
    x = value,
    fill = institution_type
  )
) +
  geom_density(alpha = 0.4) +
  facet_wrap(
    ~indicator,
    scales = "free",
    ncol = 1
  ) +
  labs(
    title = "Distribution of Satellite Indicators",
    x = "",
    y = "Density"
  ) +
  theme_minimal(base_size = 14)

# Night Lights vs Impervious Surface
#   Examine the relationship between urban development
#   intensity and nighttime human activity.
ggplot(
  satellite_all,
  aes(
    x = impervious_surface,
    y = avg_rad,
    color = institution_type
  )
) +
  geom_point(alpha = 0.6) +
  geom_smooth(
    method = "lm",
    se = FALSE,
    color = "black"
  ) +
  labs(
    title = "Nighttime Lights vs Impervious Surface",
    x = "Impervious Surface (%)",
    y = "Nighttime Lights"
  ) +
  theme_minimal(base_size = 14)

# Night Lights vs No2
#   Explore whether more active urban areas tend to have
#   higher atmospheric NO₂ concentrations.
ggplot(
  satellite_all,
  aes(
    x = avg_rad,
    y = no2,
    color = institution_type
  )
) +
  geom_point(alpha = 0.6) +
  geom_smooth(
    method = "lm",
    se = FALSE,
    color = "black"
  ) +
  labs(
    title = "Nighttime Lights vs NO₂",
    x = "Nighttime Lights",
    y = "NO₂"
  ) +
  theme_minimal(base_size = 14)


# Impervious Surface vs No2
#   Investigate whether more urbanized environments exhibit
#   higher NO₂ concentrations.
ggplot(
  satellite_all,
  aes(
    x = impervious_surface,
    y = no2,
    color = institution_type
  )
) +
  geom_point(alpha = 0.6) +
  geom_smooth(
    method = "lm",
    se = FALSE,
    color = "black"
  ) +
  labs(
    title = "Impervious Surface vs NO₂",
    x = "Impervious Surface (%)",
    y = "NO₂"
  ) +
  theme_minimal(base_size = 14)
#   Summarize statistical significance for each satellite
#   indicator.
anova_results <- bind_rows(
  
  anova_light$anova %>%
    filter(term == "institution_type") %>%
    transmute(
      Indicator = "Nighttime Lights",
      DF = df,
      `F Statistic` = round(statistic, 2),
      `P Value` = signif(p.value, 3),
      Significant = ifelse(p.value < 0.001,
                           "***",
                           ifelse(p.value < 0.01,
                                  "**",
                                  ifelse(p.value < 0.05,
                                         "*",
                                         "No")))
    ),
  
  anova_no2$anova %>%
    filter(term == "institution_type") %>%
    transmute(
      Indicator = "NO₂",
      DF = df,
      `F Statistic` = round(statistic, 2),
      `P Value` = signif(p.value, 3),
      Significant = ifelse(p.value < 0.001,
                           "***",
                           ifelse(p.value < 0.01,
                                  "**",
                                  ifelse(p.value < 0.05,
                                         "*",
                                         "No")))
    ),
  
  anova_impervious$anova %>%
    filter(term == "institution_type") %>%
    transmute(
      Indicator = "Impervious Surface",
      DF = df,
      `F Statistic` = round(statistic, 2),
      `P Value` = signif(p.value, 3),
      Significant = ifelse(p.value < 0.001,
                           "***",
                           ifelse(p.value < 0.01,
                                  "**",
                                  ifelse(p.value < 0.05,
                                         "*",
                                         "No")))
    )
  
)

anova_results

write_csv(
  anova_results,
  "outputs/Satellite/Table2_ANOVA_Results.csv"
)