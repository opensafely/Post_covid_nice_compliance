library(tidyverse)
library(lubridate)

cohort_any_acute_covid_recorded <- read_csv("output/input_any_acute_covid_pri_care.csv",
                                            col_types = cols(
                                              acute_diag_dat = col_date(format = "%Y-%m-%d"),
                                              advice_given = col_date(format = "%Y-%m-%d"),
                                              interpreter_needed = col_date(format = "%Y-%m-%d"),
                                              interpreter_booked = col_date(format = "%Y-%m-%d"),
                                              age_at_diag = col_double(),
                                              prac_id = col_double(),
                                              prac_msoa = col_character(),
                                              sex = col_character(),
                                              region = col_character(),
                                              imd = col_character(),
                                              age_group = col_character(),
                                              ethnicity = col_double(),
                                              patient_id = col_double()),
                                            na = c("", "NA", "0"))

cohort_ongoing_or_post_covid <- read_csv('output/input_ongoing_post_covid.csv',
                                         col_types = cols(
                                            pc_or_oc_diag_dat = col_date(format = "%Y-%m-%d"),
                                            diag_ongoing_covid = col_date(format = "%Y-%m-%d"),
                                            diag_post_covid = col_date(format = "%Y-%m-%d"),
                                            diagnostic_bloods = col_date(format = "%Y-%m-%d"),
                                            diagnostic_sit_stand = col_date(format = "%Y-%m-%d"),
                                            diagnostic_chest_xray = col_date(format = "%Y-%m-%d"),
                                            referral_paed = col_date(format = "%Y-%m-%d"),
                                            referral_psych = col_date(format = "%Y-%m-%d"),
                                            referral_psych_iapt = col_date(format = "%Y-%m-%d"),
                                            referral_respiratory = col_date(format = "%Y-%m-%d"),
                                            referral_cardiology = col_date(format = "%Y-%m-%d"),
                                            referral_pain = col_date(format = "%Y-%m-%d"),
                                            referral_gastro = col_date(format = "%Y-%m-%d"),
                                            referral_endocrinology = col_date(format = "%Y-%m-%d"),
                                            referral_neurology = col_date(format = "%Y-%m-%d"),
                                            referral_rheumatology = col_date(format = "%Y-%m-%d"),
                                            referral_dermatology = col_date(format = "%Y-%m-%d"),
                                            referral_ent = col_date(format = "%Y-%m-%d"),
                                            referral_inf_diseases = col_date(format = "%Y-%m-%d"),
                                            referral_pc_clinic = col_date(format = "%Y-%m-%d"),
                                            referral_pc_clinic_counts = col_number(),
                                            #referral_social_worker = col_date(format = "%Y-%m-%d"),
                                            risk_of_self_harm = col_date(format = "%Y-%m-%d"),
                                            mild_anxiety_or_depression = col_date(format = "%Y-%m-%d"),
                                            psych_referral = col_date(format = "%Y-%m-%d"),
                                            psych_referral_iapt = col_date(format = "%Y-%m-%d"),
                                            discussion_about_daily_living = col_date(format = "%Y-%m-%d"),
                                            #self_care_advise_or_support = col_date(format = "%Y-%m-%d"),
                                            primary_care_managment = col_date(format = "%Y-%m-%d"),
                                            community_care = col_date(format = "%Y-%m-%d"),
                                            age_at_diag = col_double(),
                                            prac_id = col_double(),
                                            prac_msoa = col_character(),
                                            diagnostic_bp_test = col_double(),
                                            sex = col_character(),
                                            region = col_character(),
                                            imd = col_factor(),
                                            age_group = col_character(),
                                            ethnicity = col_double(),
                                            patient_id = col_double()),
                                         na = c("", "NA", "0"))

cohort_all <- read_csv('output/input_all.csv',
                       col_types = cols(.default = col_date(),
                                        sex = col_factor(),
                                        region = col_factor(),
                                        imd = col_factor(),
                                        age_group = col_factor(),
                                        ethnicity = col_factor(),
                                        patient_id = col_guess())
)

# MSOA_Region_Lookup <- read_csv("analysis/MSOA_Region_Lookup.csv")
# 
# cohort_any_acute_covid_recorded <- cohort_any_acute_covid_recorded %>% 
#   left_join(MSOA_Region_Lookup,
#             by = c("msoa" = "MSOA11CD")) %>% 
#   rename("region" = "RGN11NM")
# 
# cohort_ongoing_or_post_covid <- cohort_ongoing_or_post_covid %>% 
#   left_join(MSOA_Region_Lookup,
#             by = c("msoa" = "MSOA11CD")) %>% 
#   rename("region" = "RGN11NM")
# 
# cohort_all <- cohort_all %>% 
#   left_join(MSOA_Region_Lookup,
#             by = c("msoa" = "MSOA11CD")) %>% 
#   rename("region" = "RGN11NM")

debug_all_counts <- cohort_all %>% summarise(across(.fns = ~sum(!is.na(.x))))
debug_all_crosstab <- table(!is.na(cohort_all$diag_any_lc_diag), !is.na(cohort_all$referral_pc_clinic))
write_csv(debug_all_counts, 'output/debug_all_counts.csv')
write.table(debug_all_crosstab, 'output/debug_all_diag_refer_crosstab.csv', sep = ",")

debug_ac_count <- tibble(nrow(cohort_any_acute_covid_recorded))
write_csv(debug_ac_count, 'output/debug_ac_counts.csv')

debug_oc_count <- tibble(nrow(cohort_ongoing_or_post_covid)) 
write_csv(debug_oc_count, 'output/debug_oc_counts.csv')

debug_referral_count <- cohort_ongoing_or_post_covid %>% summarise(ref_total = sum(referral_pc_clinic_counts, na.rm = TRUE))
write_csv(debug_referral_count, 'output/debug_referral_count.csv')

debug_nuts_1_region <- cohort_all %>% group_by(region) %>% summarise(n = n())
write_csv(debug_nuts_1_region, 'output/debug_nuts_1_region.csv')