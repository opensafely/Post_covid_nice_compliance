library(tidyverse)
library(lubridate)

cohort_any_acute_covid_recorded <- read_csv('output/input_any_acute_covid_pri_care.csv',
                                            col_types = cols(
                                              acute_diag_dat = col_date(format = "%Y-%m-%d"),
                                              advice_given = col_date(format = "%Y-%m-%d"),
                                              interpreter_needed = col_date(format = "%Y-%m-%d"),
                                              interpreter_booked = col_date(format = "%Y-%m-%d"),
                                              age_at_diag = col_double(),
                                              prac_id = col_double(),
                                              prac_msoa = col_character(),
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
                                           risk_of_self_harm = col_date(format = "%Y-%m-%d"),
                                           mild_anxiety_or_depression = col_date(format = "%Y-%m-%d"),
                                           psych_referral = col_date(format = "%Y-%m-%d"),
                                           psych_referral_iapt = col_date(format = "%Y-%m-%d"),
                                           discussion_about_daily_living = col_date(format = "%Y-%m-%d"),
                                           self_care_advise_or_support = col_date(format = "%Y-%m-%d"),
                                           primary_care_managment = col_date(format = "%Y-%m-%d"),
                                           community_care = col_date(format = "%Y-%m-%d"),
                                           age_at_diag = col_double(),
                                           prac_id = col_double(),
                                           prac_msoa = col_character(),
                                           diagnostic_bp_test = col_double(),
                                           patient_id = col_double()),
                                         na = c("", "NA", "0"))

#generate number of NAs
#debug_ac <- cohort_any_acute_covid_recorded %>% is.na() %>% colSums() 
#debug_ac <- map(cohort_any_acute_covid_recorded, class)
#debug_ac <- cohort_any_acute_covid_recorded %>% group_by(year(acute_diag_dat)) %>% summarise(n = n()) # no lines
debug_ac <- tibble(nrow(cohort_any_acute_covid_recorded)) # any lines?
write.csv(debug_ac, 'output/debug_ac.csv')



#debug_oc <- cohort_ongoing_or_post_covid %>% is.na() %>% colSums()
#debug_oc <- map(cohort_ongoing_or_post_covid, class)
#debug_oc <- cohort_ongoing_or_post_covid %>% group_by(year(pc_or_oc_diag_dat)) %>% summarise(n = n()) # no lines?
debug_oc <- tibble(nrow(cohort_ongoing_or_post_covid)) # any lines?
write.csv(debug_oc, 'output/debug_oc.csv')