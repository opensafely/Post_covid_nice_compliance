# Script to generate descriptive stats from long covid 

library(tidyverse)
library(lubridate)
library(ggalluvial)

# Start with time gap between acute and long covid diagnosis
cohort <- read_csv(file = "output/input_all.csv",
                   col_types = cols(patient_id = col_number(),
                                    age = col_number(),
                                    region = col_factor(),
                                    sex = col_factor(),
                                    imd = col_factor(),
                                    ethnicity = col_factor(),
                                    .default = col_date())
                   )

cohort <- cohort %>% 
   mutate("diff_acute_to_og" = diag_ongoing_covid - diag_acute_covid,
          "diff_acute_to_pc" = diag_post_covid - diag_acute_covid)

#summarise time differences
time_acute_to_lc <- cohort %>% 
  summarise(mean(diff_acute_to_og, na.rm = TRUE),
            mean(diff_acute_to_pc, na.rm = TRUE))

#freq_table
freq_sex <- cohort %>%
  mutate("has_diag_acute_covid" = case_when(!is.na(diag_acute_covid) ~ 1, TRUE ~ 0),
                             "has_diag_og_covid" = case_when(!is.na(diag_ongoing_covid) ~ 1, TRUE ~ 0),
                             "has_diag_pc_covid" = case_when(!is.na(diag_post_covid) ~ 1, TRUE ~ 0)) %>% 
  group_by(sex) %>% 
  summarise(acute_covid = sum(has_diag_acute_covid),
            ongoing_covid = sum(has_diag_og_covid),
            post_covid = sum(has_diag_pc_covid)) %>% 
  rename("Demographic" = sex) %>% 
  mutate("Grouping" = "Sex")

freq_region <- cohort %>%
  mutate("has_diag_acute_covid" = case_when(!is.na(diag_acute_covid) ~ 1, TRUE ~ 0),
         "has_diag_og_covid" = case_when(!is.na(diag_ongoing_covid) ~ 1, TRUE ~ 0),
         "has_diag_pc_covid" = case_when(!is.na(diag_post_covid) ~ 1, TRUE ~ 0)) %>% 
  group_by(region) %>% 
  summarise(acute_covid = sum(has_diag_acute_covid),
            ongoing_covid = sum(has_diag_og_covid),
            post_covid = sum(has_diag_pc_covid)) %>% 
  rename("Demographic" = region) %>% 
  mutate("Grouping" = "region")


freq_imd <- cohort %>%
  mutate("has_diag_acute_covid" = case_when(!is.na(diag_acute_covid) ~ 1, TRUE ~ 0),
         "has_diag_og_covid" = case_when(!is.na(diag_ongoing_covid) ~ 1, TRUE ~ 0),
         "has_diag_pc_covid" = case_when(!is.na(diag_post_covid) ~ 1, TRUE ~ 0)) %>% 
  group_by(imd) %>% 
  summarise(acute_covid = sum(has_diag_acute_covid),
            ongoing_covid = sum(has_diag_og_covid),
            post_covid = sum(has_diag_pc_covid)) %>% 
  rename("Demographic" = imd) %>% 
  mutate("Grouping" = "IMD")

freq_ethnicity <- cohort %>%
  mutate("has_diag_acute_covid" = case_when(!is.na(diag_acute_covid) ~ 1, TRUE ~ 0),
         "has_diag_og_covid" = case_when(!is.na(diag_ongoing_covid) ~ 1, TRUE ~ 0),
         "has_diag_pc_covid" = case_when(!is.na(diag_post_covid) ~ 1, TRUE ~ 0)) %>% 
  group_by(ethnicity) %>% 
  summarise(acute_covid = sum(has_diag_acute_covid),
            ongoing_covid = sum(has_diag_og_covid),
            post_covid = sum(has_diag_pc_covid)) %>% 
  rename("Demographic" = ethnicity) %>% 
  mutate("Grouping" = "ethnicity")

freq_age_band <- cohort %>%
  mutate("has_diag_acute_covid" = case_when(!is.na(diag_acute_covid) ~ 1, TRUE ~ 0),
         "has_diag_og_covid" = case_when(!is.na(diag_ongoing_covid) ~ 1, TRUE ~ 0),
         "has_diag_pc_covid" = case_when(!is.na(diag_post_covid) ~ 1, TRUE ~ 0)) %>% 
  group_by(age_band = cut(age, breaks = 10)) %>% 
  summarise(acute_covid = sum(has_diag_acute_covid),
            ongoing_covid = sum(has_diag_og_covid),
            post_covid = sum(has_diag_pc_covid)) %>% 
  rename("Demographic" = age_band) %>% 
  mutate("Grouping" = "Age Band")

freq_table <- bind_rows(freq_age_band, freq_ethnicity, freq_imd, freq_region, freq_sex)

#alluvial datasets
alluvial_ac_ogpc <- cohort %>% 
  mutate("has_diag_acute_covid" = case_when(!is.na(diag_acute_covid) ~ "Acute Covid", TRUE ~ "No Acute Covid"),
         "has_diag_og_covid" = case_when(!is.na(diag_ongoing_covid) ~ "Ongoing Covid", TRUE ~ "No Ongoing Covid"),
         "has_diag_pc_covid" = case_when(!is.na(diag_post_covid) ~ "Post Covid", TRUE ~ "No Post Covid")) %>% 
  group_by(sex, 
           has_diag_acute_covid,
           has_diag_og_covid,
           has_diag_pc_covid) %>% 
  summarise(freq = n()) %>% 
  filter(freq > 6)

#Acute to ongoing / post covid
ggplot(as.data.frame(alluvial_ac_ogpc), aes(y=freq, 
                     axis1=has_diag_acute_covid,
                     axis2=has_diag_og_covid,
                     axis3=has_diag_pc_covid)) +
  geom_alluvium(aes(fill = has_diag_acute_covid)) + 
  geom_stratum(width = 1/12, fill = "black", color = "grey") + 
  geom_label(stat = "stratum", aes(label = after_stat(stratum))) + 
  scale_x_discrete(limits = c("has_diag_acute_covid", "has_diag_og_covid", "has_diag_pc_covid"), expand = c(0.05, 0.05)) + 
  scale_y_continuous(limits = c(0, nrow(cohort)), expand = c(0.005, 0.005)) + 
  ggtitle("Patient flow from acute to ongoing and post covid conditions")

ggsave("output/ac_to_lc.png")

#Ongoing to self-care / community / pc / 
alluvial_og_destination <- cohort %>% 
  mutate("has_diag_og_covid" = case_when(!is.na(diag_ongoing_covid) ~ "Ongoing Covid", TRUE ~ "No Ongoing Covid"),
         "referral_self_care" = case_when(!is.na(referral_self_care) ~ "Self Care", TRUE ~ "No Self Care"),
         "referral_community_care" = case_when(!is.na(referral_self_care) ~ "Community Care", TRUE ~ "No Community Care"),
         "referral_pc_clinic" = case_when(!is.na(referral_self_care) ~ "Post Covid Clinic", TRUE ~ "No PC clinic")
         ) %>% 
  group_by(has_diag_og_covid,
           referral_self_care,
           referral_community_care,
           referral_pc_clinic
           ) %>% 
  summarise(freq = n()) %>% 
  filter(freq > 6)

#alluvial graph - og destinations
ggplot(as.data.frame(alluvial_og_destination), aes(y=freq, 
                                    axis1=has_diag_og_covid,
                                    axis2=referral_self_care,
                                    axis3=referral_community_care,
                                    axis4=referral_pc_clinic)) +
  geom_alluvium(aes(fill = has_diag_og_covid)) + 
  geom_stratum(width = 1/12, fill = "black", color = "grey") + 
  geom_label(stat = "stratum", aes(label = after_stat(stratum))) + 
  scale_x_discrete(limits = c("has_diag_og_covid", "referral_self_care", "referral_community_care", "referral_pc_clinic"), expand = c(0.05, 0.05)) + 
  scale_y_continuous(limits = c(0, nrow(cohort)), expand = c(0.005, 0.005)) + 
  ggtitle("Patient flow from ongoing covid to referral destinations") 

ggsave("output/og_destination.png")

#Ongoing to self-care / community / pc / 
alluvial_pc_destination <- cohort %>% 
  mutate("has_diag_post_covid" = case_when(!is.na(diag_post_covid) ~ "Post Covid", TRUE ~ "No Post Covid"),
         "referral_self_care" = case_when(!is.na(referral_self_care) ~ "Self Care", TRUE ~ "No Self Care"),
         "referral_community_care" = case_when(!is.na(referral_self_care) ~ "Community Care", TRUE ~ "No Community Care"),
         "referral_pc_clinic" = case_when(!is.na(referral_self_care) ~ "Post Covid Clinic", TRUE ~ "No PC clinic")
  ) %>% 
  group_by(has_diag_post_covid,
           referral_self_care,
           referral_community_care,
           referral_pc_clinic
  ) %>% 
  summarise(freq = n()) %>% 
  filter(freq > 6)

#alluvial graph - pc destinations
ggplot(as.data.frame(alluvial_pc_destination), aes(y=freq, 
                                                   axis1=has_diag_post_covid,
                                                   axis2=referral_self_care,
                                                   axis3=referral_community_care,
                                                   axis4=referral_pc_clinic)) +
  geom_alluvium(aes(fill = has_diag_post_covid)) + 
  geom_stratum(width = 1/12, fill = "black", color = "grey") + 
  geom_label(stat = "stratum", aes(label = after_stat(stratum))) + 
  scale_x_discrete(limits = c("has_diag_post_covid", "referral_self_care", "referral_community_care", "referral_pc_clinic"), expand = c(0.05, 0.05)) + 
  scale_y_continuous(limits = c(0, nrow(cohort)), expand = c(0.005, 0.005)) +
  ggtitle("Patient flow from post covid to referral destinations") 

ggsave("output/pc_destinations.png")

write_csv(time_acute_to_lc, "mean diff to days.csv")