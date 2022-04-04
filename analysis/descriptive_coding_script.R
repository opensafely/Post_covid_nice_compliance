# Script to generate descriptive stats from long covid coding

# LIBRARIES
library(tidyverse)
library(lubridate)
library(ggalluvial)
library(janitor)

#FUNCTIONS
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
              refer_yourcovidrecovery_website_only = sum(!is.na(referral_yourcovidrecovery_website_only)),
              refer_yourcovidrecovery_website_program = sum(!is.na(referral_yourcovidrecovery_website_program)),
              ) %>% 
  rename("Group" = {{ grouping_var }}) %>% 
  mutate("Demographic" = grouping_var_name) %>%   
  adorn_totals("row") %>% 
  select(Demographic,
          everything()) %>% 
  mutate(acute_covid_rate_per_100000 = round(acute_covid/total_patients * 100000, 1),
         acute_covid_rate_CI_lower = round(crude_rate_normal_approx(acute_covid, total_patients, "lower") * 100000, 1),
         acute_covid_rate_CI_upper = round(crude_rate_normal_approx(acute_covid, total_patients, "upper") * 100000, 1),
         ongoing_covid_rate_per_100000 = round(ongoing_covid/total_patients * 100000,1),
         ongoing_covid_rate_CI_lower = round(crude_rate_normal_approx(ongoing_covid, total_patients, "lower")*100000, 1),
         ongoing_covid_rate_CI_upper = round(crude_rate_normal_approx(ongoing_covid, total_patients, "upper")*100000, 1),
         post_covid_rate_per_100000 = round(post_covid/total_patients * 100000, 1),
         post_covid_rate_CI_lower = round(crude_rate_normal_approx(post_covid, total_patients, "lower") * 100000, 1),
         post_covid_rate_CI_upper = round(crude_rate_normal_approx(post_covid, total_patients, "upper") * 100000, 1),
         refer_post_covid_clinic_rate_per_100000 = round(refer_post_covid_clinic/total_patients * 100000, 1),
         refer_post_covid_clinic_rate_CI_lower = round(crude_rate_normal_approx(refer_post_covid_clinic, total_patients, "lower") * 100000, 1),
         refer_post_covid_clinic_rate_CI_upper = round(crude_rate_normal_approx(refer_post_covid_clinic, total_patients, "upper") * 100000, 1),
         refer_yourcovidrecovery_website_only_per_100000 = round(refer_yourcovidrecovery_website_only / total_patients * 100000, 1),
         refer_yourcovidrecovery_website_only_CI_lower = round(crude_rate_normal_approx(refer_yourcovidrecovery_website_only, total_patients, "lower") * 100000, 1),
         refer_yourcovidrecovery_website_only_CI_upper = round(crude_rate_normal_approx(refer_yourcovidrecovery_website_only, total_patients, "upper") * 100000, 1),
         refer_yourcovidrecovery_website_program_rate_per_100000 = round(refer_yourcovidrecovery_website_program / total_patients * 100000, 1),
         refer_yourcovidrecovery_website_program_rate_CI_lower = round(crude_rate_normal_approx(refer_yourcovidrecovery_website_program, total_patients, "lower") * 100000, 1),
         refer_yourcovidrecovery_website_program_rate_CI_upper = round(crude_rate_normal_approx(refer_yourcovidrecovery_website_program, total_patients, "upper") * 100000, 1)
         ) %>% 
  ungroup() 

}

crude_rate_normal_approx <- function(num, denom, upper_or_lower) {
  
  upper <- num/denom + 1.96*sqrt(num)/denom
  lower <- num/denom - 1.96*sqrt(num)/denom

  return(
    if (upper_or_lower == "upper"){
      upper
    } else if (upper_or_lower == "lower") {
      lower
    } else "error"
  )
  
  }
  
#REUSED VARIABLES
#demographic_variables
demo_vars <- c('sex', 'region', 'imd', 'ethnicity', 'age_group')

# Load cohort of all patients
cohort <- read_csv(file = "output/input_all.csv",
                   col_types = cols(patient_id = col_number(),
                                    age_group = col_factor(levels = c("0-17","18-24", "25-34", "35-44", "45-54", "55-69", "70-79", "80+")),
                                    region = col_factor(),
                                    sex = col_factor(),
                                    imd = col_factor(levels = c("1 (Most Deprived)", "2", "3", "4", "5 (Least Deprived)", "Unknown")),
                                    ethnicity = col_factor(),
                                    .default = col_date())
                   )

#Read in MSOA lookup
#https://geoportal.statistics.gov.uk/datasets/fe6c55f0924b4734adf1cf7104a0173e_0/explore?showTable=true
# MSOA_Region_Lookup <- read_csv("analysis/MSOA_Region_Lookup.csv")
# 
# cohort <- cohort %>%
#   left_join(MSOA_Region_Lookup,
#             by = c("msoa" = "MSOA11CD")) %>%
#   rename("region_msoa" = "RGN11NM")
# 
# rm(MSOA_Region_Lookup)

#Table 1 Cohort
Table_1 <- demo_vars %>% 
  map(~generate_freq_tables(grouping_var = .data[[.x]],
                            cohort_df = cohort)) %>%
  bind_rows() %>%
  filter(across(where(is.numeric), ~ . >6)) %>% 
  group_by(Demographic) %>% 
  select(Demographic, Group, N = total_patients)

write_csv(Table_1, "output/Table_1.csv")

#Fig 1 Line Graph of code counts
Fig_1 <- cohort %>% 
  select(-diag_acute_covid, -diag_any_lc_diag) %>%
  pivot_longer(cols = starts_with('referral')|starts_with('diag'), names_to = "code", names_repair = "minimal") %>% 
  group_by(code, month = floor_date(value, unit = "month")) %>% 
  summarise(n= n()) %>% 
  filter(!is.na(month), n > 10)

write_csv(Fig_1, "output/Fig_1_numbers.csv")

Fig_1 %>% 
  ggplot(aes(x= month, y= n, color = code)) + 
  geom_line()+
  theme_minimal() + 
  labs(title= "Fig. 1 - Counts of long covid diagnosis and referral codes over time") +
  scale_colour_hue(labels = c("Ongoing symptomatic COVID-19 Diagnosis Code",
                              "Post-COVID-19 Syndrome Diagnosis Code",
                              "Referral to Post-Covid Clinic Code",
                              "Referral to yourcovidrecovery.nhs.uk Website Code",
                              "Referral to yourcovidrecovery.nhs.uk Online Program Code")) + 
  theme(legend.position = "bottom", legend.direction = "vertical", legend.title = element_blank())

ggsave("output/Fig_1.png", width = 10, height = 7, units = "in")

#Table 2 referral_diag_table
Table_2 <- cohort %>% 
  group_by("Diagnosis" = case_when(!is.na(diag_any_lc_diag) ~ "Ongoing symptomatic or Post-COVID-19 syndrome diagnosis coded", TRUE ~ "No Diagnosis Coded"),
           ) %>%  
  summarise(n = n(),
            `Referral to yourcovidrecovery website` = sum(!is.na(referral_yourcovidrecovery_website_only)),
            `Referral to yourcovidrecovery program` = sum(!is.na(referral_yourcovidrecovery_website_program)),
            `Referral to Post-COVID clinic` = sum(!is.na(referral_pc_clinic))) %>% 
  arrange(desc(Diagnosis))
          
write_csv(Table_2, "output/Table_2.csv")

#Table 3 demographic splits
Table_3 <- demo_vars %>% 
  map(~generate_freq_tables(grouping_var = .data[[.x]],
                            cohort_df = cohort)) %>%
  bind_rows() %>%
  group_by(Demographic) %>% 
  mutate(acute_covid_percentage =  ifelse(Group == "Total", NA, round(acute_covid / sum(acute_covid) * 100, 1)),
         ongoing_covid_percentage = ifelse(Group == "Total", NA, round(ongoing_covid / sum(ongoing_covid) * 100, 1)),
         post_covid_percentage = ifelse(Group == "Total", NA, round(post_covid / sum(post_covid) * 100, 1)),
         refer_yourcovidrecovery_website_only_percentage = ifelse(Group == "Total", NA, round(refer_yourcovidrecovery_website_only / sum(refer_yourcovidrecovery_website_only) * 100, 1)),
         refer_yourcovidrecovery_website_program_percentage = ifelse(Group == "Total", NA, round(refer_yourcovidrecovery_website_program / sum(refer_yourcovidrecovery_website_program) * 100, 1)),
         refer_post_covid_clinic_percentage = ifelse(Group == "Total", NA, round(refer_post_covid_clinic / sum(refer_post_covid_clinic) * 100, 1))
         ) %>% 
  select(Demographic, Group, total_patients, starts_with("acute_"), starts_with("ongoing_"), starts_with("post_"), starts_with("refer_post"), starts_with("refer_yourcovidrecovery_website_only"), everything()) %>% 
  mutate(across(.fns = as.character)) %>% 
  ungroup()

Table_3[Table_3$Demographic == "imd" & Table_3$Group == "Unknown", 29:33] <- "*"
Table_3[Table_3$Demographic == "imd" & Table_3$Group == 3, 29:33] <- "*"

write_csv(Table_3, "output/Table_3.csv")

#alluvial datasets

#Ongoing to self-care / pc 
Fig_2 <- cohort %>% 
  filter(!is.na(diag_ongoing_covid)) %>% 
  mutate("has_diag_og_covid" = factor(case_when(!is.na(diag_ongoing_covid) ~ "Ongoing Covid", TRUE ~ "No Ongoing Covid"), ordered = TRUE),
         "referral_yourcovidrecovery_website_only" = factor(case_when(!is.na(referral_yourcovidrecovery_website_only) ~ "YCR (website only)", TRUE ~ "No Signpost"), ordered = TRUE),
         "has_diag_post_covid" = factor(case_when(!is.na(diag_post_covid) ~ "Post-COVID-19", TRUE ~ "No Post-COVID-19"), ordered = TRUE),
         #"referral_yourcovidrecovery_program"  = factor(case_when(!is.na(referral_yourcovidrecovery_website_program) ~ "YCR (website program)", TRUE ~ "No Referral"), ordered = TRUE),
        # "referral_pc_clinic" = factor(case_when(!is.na(referral_pc_clinic) ~ "Post Covid Clinic", TRUE ~ "No Referral"), ordered = TRUE)
         ) %>% 
  group_by(has_diag_og_covid,
           referral_yourcovidrecovery_website_only,
           has_diag_post_covid,
          # referral_yourcovidrecovery_program,
         #  referral_pc_clinic
           ) %>% 
  summarise(freq = n()) %>% 
  filter(freq > 6)

#alluvial graph - og destinations
ggplot(as.data.frame(Fig_2), aes(y=freq, 
                                    axis1=has_diag_og_covid,
                                    axis2=referral_yourcovidrecovery_website_only,
                                    axis3=has_diag_post_covid,
                                #    axis4=referral_yourcovidrecovery_program,
                                 #   axis5=referral_pc_clinic
                                )) +
  geom_alluvium(aes(fill = referral_yourcovidrecovery_website_only), aes.bind = TRUE) + 
  geom_stratum(width = 1/6, fill = "black", color = "grey") + 
  geom_label(stat = "stratum", aes(label = after_stat(stratum))) + 
  scale_x_discrete(limits = c("Ongoing Symptomatic Diagnosis",
                              "Yourcovidrecovery website",
                              "Post-COVID-19 Syndrome"
                              #"Yourcovidrecovery program",
                              #"Post-COVID-19 Clinic"
                              ),
                   expand = c(0.05, 0.05)) + 
  scale_y_continuous(limits = c(0, sum(!is.na(cohort$diag_ongoing_covid))), expand = c(0.005, 0.005)) + 
  ggtitle("Fig. 2 - Patient flow from ongoing covid to referral destinations") + 
  theme_minimal() + 
  theme(legend.position = "bottom", legend.title = element_blank())

ggsave("output/Fig_2.png", width = 10, height = 7, units = "in")
write_csv(Fig_2, "output/Fig_2_numbers.csv")

#Post covid to self-care / pc 
Fig_3 <- cohort %>% 
  filter(!is.na(diag_post_covid)) %>% 
  mutate("has_diag_post_covid" = case_when(!is.na(diag_post_covid) ~ "Post Covid", TRUE ~ "No Post Covid"),
         "referral_yourcovidrecovery_program" = case_when(!is.na(referral_yourcovidrecovery_website_program) ~ "YCR Website Program", TRUE ~ "No Referral"),
         "referral_pc_clinic" = case_when(!is.na(referral_pc_clinic) ~ "Post Covid Clinic", TRUE ~ "No Referral")
  ) %>% 
  group_by(has_diag_post_covid,
           referral_yourcovidrecovery_program,
           referral_pc_clinic
  ) %>% 
  summarise(freq = n()) %>% 
  filter(freq > 6)

#alluvial graph - pc destinations
ggplot(as.data.frame(Fig_3), aes(y=freq, 
                                                   axis1=has_diag_post_covid,
                                                   axis2=referral_yourcovidrecovery_program,
                                                   axis3=referral_pc_clinic)) +
  geom_alluvium(aes(fill = referral_yourcovidrecovery_program)) + 
  geom_stratum(width = 1/12, fill = "black", color = "grey") + 
  geom_label(stat = "stratum", aes(label = after_stat(stratum))) + 
  scale_x_discrete(limits = c("Post-COVID-19 Syndrome",
                              "Yourcovidrecovery program",
                              "Post-COVID-19 Clinic"),
                   expand = c(0.05, 0.05)) + 
  scale_y_continuous(limits = c(0, sum(!is.na(cohort$diag_post_covid))), expand = c(0.005, 0.005)) +
  ggtitle("Fig. 3 - Patient flow from Post-COVID-19 syndrome diagnosis code") + 
  theme_minimal() + 
  theme(legend.position = "bottom", legend.title = element_blank())

ggsave("output/Fig_3.png", width = 10, height = 7, units = "in")
write_csv(Fig_3, "output/Fig_3_numbers.csv")

RefDiag_tab <- cohort %>% 
  mutate(Diag = !is.na(diag_any_lc_diag),
         Referral = !is.na(referral_pc_clinic)|!is.na(referral_yourcovidrecovery_website_only)|!is.na(referral_yourcovidrecovery_website_program)) %>% 
  select(Diag, Referral) %>% 
  group_by(Diag, Referral) %>% 
  summarise(n = n()) %>% 
  pivot_wider(names_from = Referral, values_from = n, names_prefix = "Referral_")

write_csv(RefDiag_tab, "output/RefDiag_tab.csv")