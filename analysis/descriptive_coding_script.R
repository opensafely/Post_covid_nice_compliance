# Script to generate descriptive stats from long covid 

library(tidyverse)
library(lubridate)
library(ggalluvial)

#function to generate frequency tables
generate_freq_tables <- function(cohort_df, grouping_var){

  grouping_var_name = names(cohort_df %>% select({{ grouping_var}} ))
  
  cohort_df %>% 
    group_by({{ grouping_var }}) %>% 
    summarise(total_patients = n(),
              acute_covid = sum(!is.na(diag_acute_covid)),
              ongoing_covid = sum(!is.na(diag_ongoing_covid)),
              post_covid = sum(!is.na(diag_post_covid)),
              refer_post_covid_clinic = sum(!is.na(referral_pc_clinic)),
              refer_self_care = sum(!is.na(referral_self_care)),
              mean_days_acute_to_og = mean(diff_acute_to_og, na.rm = TRUE),
              mean_days_acute_to_pc = mean(diff_acute_to_pc, na.rm = TRUE)
              ) %>% 
  rename("Group" = {{ grouping_var }}) %>% 
  mutate("Demographic" = grouping_var_name) %>%   
  select(Demographic,
          everything())
  
}

# Start with time gap between acute and long covid diagnosis
cohort <- read_csv(file = "output/input_all.csv",
                   col_types = cols(patient_id = col_number(),
                                    age_group = col_factor(),
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

#referral_diag_table
diag_referral_tab <- cohort %>% 
  group_by("diag" = case_when(!is.na(diag_any_lc_diag) ~ "OG/PC Diagnosis Coded", TRUE ~ "No OG/PC Diagnosis Coded"),
           ) %>%  
  summarise(n = n(),
            referral_self_care = sum(!is.na(referral_self_care)),
            referral_pc_clinic = sum(!is.na(referral_pc_clinic)))
  
write_csv(diag_referral_tab, "output/diag_v_referral.csv")

#demographic_variables
demo_vars <- c('sex', 'region', 'imd', 'ethnicity', 'age_group')

#freq_table
freq_table <- demo_vars %>% 
  map(~generate_freq_tables(grouping_var = .data[[.x]],
                            cohort_df = cohort)) %>%
  bind_rows() %>%
  filter(across(where(is.numeric), ~ . >6))

#alluvial datasets
alluvial_ac_ogpc <- cohort %>% 
  filter(!is.na(diag_acute_covid)) %>% 
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
  geom_alluvium(fill = "light green") +
  geom_stratum(width = 1/12, fill = "black", color = "grey") +
  geom_label(stat = "stratum", aes(label = after_stat(stratum))) +
  scale_x_discrete(limits = c("has_diag_acute_covid", "has_diag_og_covid", "has_diag_pc_covid"), expand = c(0.05, 0.05)) +
  scale_y_continuous(limits = c(0, sum(!is.na(cohort$diag_acute_covid))), expand = c(0.005, 0.005)) +
  ggtitle("Patient flow from acute to ongoing and post covid conditions")

ggsave("output/ac_to_lc.png")

#Ongoing to self-care / pc 
alluvial_og_destination <- cohort %>% 
  filter(!is.na(diag_ongoing_covid)) %>% 
  mutate("has_diag_og_covid" = case_when(!is.na(diag_ongoing_covid) ~ "Ongoing Covid", TRUE ~ "No Ongoing Covid"),
         "referral_yourcovidrecovery.nhs.uk" = case_when(!is.na(referral_self_care) ~ "Self Care", TRUE ~ "No Self Care"),
         "referral_pc_clinic" = case_when(!is.na(referral_pc_clinic) ~ "Post Covid Clinic", TRUE ~ "No PC clinic")
         ) %>% 
  group_by(has_diag_og_covid,
           referral_yourcovidrecovery.nhs.uk,
           referral_pc_clinic
           ) %>% 
  summarise(freq = n()) %>% 
  filter(freq > 6)

#alluvial graph - og destinations
ggplot(as.data.frame(alluvial_og_destination), aes(y=freq, 
                                    axis1=has_diag_og_covid,
                                    axis2=referral_yourcovidrecovery.nhs.uk,
                                    axis3=referral_pc_clinic)) +
  geom_alluvium(fill = "pink") + 
  geom_stratum(width = 1/12, fill = "black", color = "grey") + 
  geom_label(stat = "stratum", aes(label = after_stat(stratum))) + 
  scale_x_discrete(limits = c("has_diag_og_covid", "referral_yourcovidrecovery.nhs.uk", "referral_pc_clinic"), expand = c(0.05, 0.05)) + 
  scale_y_continuous(limits = c(0, sum(!is.na(cohort$diag_ongoing_covid))), expand = c(0.005, 0.005)) + 
  ggtitle("Patient flow from ongoing covid to referral destinations") 

ggsave("output/og_destination.png")

#Post covid to self-care / pc 
alluvial_pc_destination <- cohort %>% 
  filter(!is.na(diag_post_covid)) %>% 
  mutate("has_diag_post_covid" = case_when(!is.na(diag_post_covid) ~ "Post Covid", TRUE ~ "No Post Covid"),
         "referral_yourcovidrecovery.nhs.uk" = case_when(!is.na(referral_self_care) ~ "Self Care", TRUE ~ "No Self Care"),
         "referral_pc_clinic" = case_when(!is.na(referral_pc_clinic) ~ "Post Covid Clinic", TRUE ~ "No PC clinic")
  ) %>% 
  group_by(has_diag_post_covid,
           referral_yourcovidrecovery.nhs.uk,
           referral_pc_clinic
  ) %>% 
  summarise(freq = n()) %>% 
  filter(freq > 6)

#alluvial graph - pc destinations
ggplot(as.data.frame(alluvial_pc_destination), aes(y=freq, 
                                                   axis1=has_diag_post_covid,
                                                   axis2=referral_yourcovidrecovery.nhs.uk,
                                                   axis3=referral_pc_clinic)) +
  geom_alluvium(fill = "light blue") + 
  geom_stratum(width = 1/12, fill = "black", color = "grey") + 
  geom_label(stat = "stratum", aes(label = after_stat(stratum))) + 
  scale_x_discrete(limits = c("has_diag_post_covid", "referral_yourcovidrecovery.nhs.uk", "referral_pc_clinic"), expand = c(0.05, 0.05)) + 
  scale_y_continuous(limits = c(0, sum(!is.na(cohort$diag_post_covid))), expand = c(0.005, 0.005)) +
  ggtitle("Patient flow from post covid to referral destinations") 

ggsave("output/pc_destinations.png")

write_csv(time_acute_to_lc, "output/mean_diff_to_days.csv")
write_csv(freq_table, "output/freq_table.csv")

#add lc and referral codes through time

line_graph_df <- cohort %>% 
  select(-diag_acute_covid, -diag_any_lc_diag) %>%
  pivot_longer(cols = starts_with('referral')|starts_with('diag'), names_to = "code", names_repair = "minimal") %>% 
  group_by(code, month = floor_date(value, unit = "month")) %>% 
  summarise(n= n()) %>% 
  filter(!is.na(month), n > 10)

#all diag & refer codes
line_graph_df %>% 
  ggplot(aes(x= month, y= n, color = code)) + 
  geom_line()+
  theme_minimal() + 
  labs(title= "Long Covid diagnosis and referral codes through time")

ggsave("output/coding_through_time.png")

#remove ycr code for scale
line_graph_df %>% 
  filter(code != "referral_self_care") %>% 
  ggplot(aes(x= month, y= n, color = code)) + 
  geom_line()+
  theme_minimal() + 
  labs(title= "Long Covid diagnosis and referral codes through time")
  
ggsave("output/coding_through_time_noycr.png")
