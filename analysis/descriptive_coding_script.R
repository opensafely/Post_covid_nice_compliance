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
              acute_covid_rate_per_100000 = round(acute_covid/total_patients * 100000, 1),
              ongoing_covid = sum(!is.na(diag_ongoing_covid)),
              ongoing_covid_rate_per_100000 = round(ongoing_covid/total_patients * 100000,1),
              post_covid = sum(!is.na(diag_post_covid)),
              post_covid_rate_per_100000 = round(post_covid/total_patients * 100000, 1),
              refer_post_covid_clinic = sum(!is.na(referral_pc_clinic)),
              refer_post_covid_clinic_rate_per_100000 = round(refer_post_covid_clinic/total_patients * 100000, 1),
              refer_self_care = sum(!is.na(referral_self_care)),
              refer_self_care_rate_per_100000 = round(refer_self_care / total_patients * 100000, 1),
              # mean_days_acute_diag_to_og = mean(diff_acute_to_og, na.rm = TRUE),
              # mean_days_acute_diag_to_pc = mean(diff_acute_to_pc, na.rm = TRUE),
              # mean_days_og_diag_to_pc_referral = mean(diff_og_diag_to_pc_referral, na.rm = TRUE),
              # mean_days_og_diag_to_website_referral = mean(diff_og_diag_to_yourcovidrecovery_referral, na.rm = TRUE),
              # mean_days_pc_diag_to_pc_clinic_referral = mean(diff_pc_diag_to_pc_referral, na.rm = TRUE),
              # mean_days_pc_diag_to_website_referral = mean(diff_pc_diag_to_yourcovidrecovery_referral, na.rm = TRUE)
              ) %>% 
  rename("Group" = {{ grouping_var }}) %>% 
  mutate("Demographic" = grouping_var_name) %>%   
  select(Demographic,
          everything()) %>% 
  ungroup()
  
}

#1. Table 1 cohort (all)?


# Start with time gap between acute and long covid diagnosis
cohort <- read_csv(file = "output/input_all.csv",
                   col_types = cols(patient_id = col_number(),
                                    age_group = col_factor(levels = c("0-17","18-24", "25-34", "35-44", "45-54", "55-69", "70-79", "80+")),
                                    region = col_factor(),
                                    sex = col_factor(),
                                    imd = col_factor(levels = c("1 (Most Deprived)", "2", "3", "4", "5 (Least Deprived)", "Unknown")),
                                    ethnicity = col_factor(),
                                    .default = col_date())
                   )

cohort_time <- cohort %>% 
   mutate("diff_acute_to_og" = ifelse((diag_ongoing_covid - diag_acute_covid) > 0, diag_ongoing_covid - diag_acute_covid, NA),
          "diff_acute_to_pc" = ifelse((diag_post_covid - diag_acute_covid > 0), diag_post_covid - diag_acute_covid, NA),
          "diff_og_diag_to_pc_referral" = ifelse((referral_pc_clinic - diag_ongoing_covid) > 0, referral_pc_clinic - diag_ongoing_covid, NA),
          "diff_og_diag_to_yourcovidrecovery_referral" = ifelse((referral_self_care - diag_ongoing_covid) > 0, referral_self_care - diag_ongoing_covid, NA),
          "diff_pc_diag_to_pc_referral" = ifelse((referral_pc_clinic - diag_post_covid) > 0, referral_pc_clinic - diag_ongoing_covid, NA),
          "diff_pc_diag_to_yourcovidrecovery_referral" = ifelse((referral_pc_clinic - diag_post_covid) > 0, referral_pc_clinic - diag_post_covid, NA))

#summarise time differences
time_acute_to_lc <- cohort_time %>% 
  summarise(mean_time_acute_to_og_diag = mean(diff_acute_to_og, na.rm = TRUE),
            mean_time_acute_to_pc_diag = mean(diff_acute_to_pc, na.rm = TRUE),
            mean_time_og_diag_to_pc_clinic_referral = mean(diff_og_diag_to_pc_referral, na.rm = TRUE),
            mean_time_og_diag_to_website_referral = mean(diff_og_diag_to_yourcovidrecovery_referral, na.rm = TRUE),
            mean_time_og_diag_to_pc_referral = mean(diff_pc_diag_to_pc_referral, na.rm = TRUE),
            mean_time_pc_diag_to_website_referral = mean(diff_pc_diag_to_yourcovidrecovery_referral, na.rm = TRUE)
            )

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
  filter(across(where(is.numeric), ~ . >6)) %>% 
  group_by(Demographic) %>% 
  mutate(acute_covid_percentage =  round(acute_covid / sum(acute_covid) * 100, 1),
         ongoing_covid_percentage = round(ongoing_covid / sum(ongoing_covid) * 100, 1),
         post_covid_percentage = round(post_covid / sum(post_covid) * 100, 1),
         refer_post_covid_clinic_percentage = round(refer_post_covid_clinic / sum(refer_post_covid_clinic) * 100, 1),
         refer_self_care_percentage = round(refer_self_care / sum(refer_self_care) * 100, 1)
         ) %>% 
  select(Demographic, Group, total_patients, starts_with("acute_"), starts_with("ongoing_"), starts_with("post_"), starts_with("refer_post"), starts_with("refer_self"), everything())

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

write_csv(line_graph_df, "output/line_graph.df.csv")

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

## OP table for OG / PC diagnoses

cohort_og_pc <- read_csv(file = "output/input_ongoing_post_covid.csv",
                         col_types = cols(patient_id = col_number(),
                                          age_group = col_factor(levels = c("0-17","18-24", "25-34", "35-44", "45-54", "55-69", "70-79", "80+")),
                                          imd = col_factor(levels = c("1 (Most Deprived)", "2", "3", "4", "5 (Least Deprived)", "Unknown")),
                                          region = col_factor(),
                                          sex = col_factor(),
                                          ethnicity = col_factor(),
                                          op_count_card = col_integer(), 
                                          op_count_rheum = col_integer(),
                                          op_count_respiratory = col_integer(), 
                                          op_count_pc = col_integer(), 
                                          referral_pc_clinic_counts = col_integer(),
                                          age_at_diag = col_integer(), 
                                          prac_id = col_integer(),
                                          prac_msoa = col_character(), 
                                          op_count_neuro = col_integer(), 
                                          diagnostic_bp_test = col_double(),
                                          .default = col_date(format = "%Y-%m-%d")))

generate_freq_tables_ogpc <- function(cohort_df, grouping_var){
  
  grouping_var_name = names(cohort_df %>% select({{ grouping_var}} ))
  
  cohort_df %>% 
    group_by({{ grouping_var }}) %>% 
    summarise(total_patients = n(),
              total_og_diags = sum(!is.na(diag_ongoing_covid), na.rm = TRUE),
              total_pc_diags = sum(!is.na(diag_post_covid), na.rm = TRUE),
              total_pc_referrals = sum(!is.na(referral_pc_clinic), na.rm = TRUE),
              total_pc_op_visits = sum(op_count_pc, na.rm = TRUE),
              mean_pc_op_visits = mean(op_count_pc, na.rm = TRUE),
              total_cardiology_op_visits = sum(op_count_card, na.rm = TRUE),
              mean_cardio_op_visits = mean(op_count_card, na.rm = TRUE),
              total_rheum_op_visits = sum(op_count_rheum, na.rm = TRUE),
              mean_rheum_op_visits = mean(op_count_rheum, na.rm = TRUE),
              total_respiratory_visits = sum(op_count_respiratory, na.rm = TRUE),
              mean_rheum_op_visits = mean(op_count_respiratory, na.rm = TRUE),
              total_neuro_visits = sum(op_count_neuro, na.rm = TRUE),
              mean_neuro_op_visits = mean(op_count_neuro, na.rm = TRUE)
    ) %>% 
    rename("Group" = {{ grouping_var }}) %>% 
    mutate("Demographic" = grouping_var_name) %>%   
    select(Demographic,
           everything()) %>% 
    ungroup()
}

freq_table_og_pc <- demo_vars %>% 
  map(~generate_freq_tables_ogpc(grouping_var = .data[[.x]],
                            cohort_df = cohort_og_pc)) %>%
  bind_rows()

write_csv(freq_table_og_pc, "output/freq_table_op.csv")
