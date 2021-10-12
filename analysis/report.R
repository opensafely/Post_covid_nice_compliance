library(tidyverse)
library(lubridate)

#Compliance ratios from Section 1 of NG188 guidance

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

Rec_1_1_denom <- nrow(cohort_any_acute_covid_recorded)
Rec_1_1_num <- sum((cohort_any_acute_covid_recorded$advice_given - cohort_any_acute_covid_recorded$acute_diag_dat > 0), na.rm = TRUE)
Rec_1_1_ratio <- Rec_1_1_num / Rec_1_1_denom

Rec_1_8_denom <- cohort_any_acute_covid_recorded %>% filter(interpreter_needed > ymd("20190101")) %>% nrow()
Rec_1_8_num <- cohort_any_acute_covid_recorded %>% filter(interpreter_needed > ymd("20190101"),
                                                          interpreter_booked > ymd("20190101")) %>% nrow()
Rec_1_8_ratio <- Rec_1_8_num / Rec_1_8_denom

#Leaving Rec 1_10 until outpatient linkage is carried out

#Compliance ratios from Section 2 of NG188 guidance

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
                                           referral_social_worker = col_date(format = "%Y-%m-%d"),
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


Rec_2_4_denom <- nrow(cohort_ongoing_or_post_covid)
Rec_2_4_num <- cohort_ongoing_or_post_covid %>% filter(discussion_about_daily_living > ymd("20190101")) %>% nrow()
Rec_2_4_ratio <- Rec_2_4_num / Rec_2_4_denom

#Compliance ratios from Section 3 of NG188 guidance

#Rec_3_1 abandoned as not sure what 'relevant acute services' ought to be, vagueness as to what 

#3 diagnostic tests 

Rec_3_4_denom <- Rec_2_4_denom
Rec_3_4_num <- cohort_ongoing_or_post_covid %>% filter(diagnostic_bloods > ymd("20190101")) %>% nrow()
Rec_3_4_ratio <- Rec_3_4_num / Rec_3_4_denom

Rec_3_5_denom <- Rec_2_4_denom
Rec_3_5_num <- cohort_ongoing_or_post_covid %>% filter(diagnostic_sit_stand > ymd("20190101")) %>% nrow()
Rec_3_5_ratio <- Rec_3_5_num / Rec_3_5_denom

Rec_3_6_denom <- Rec_2_4_denom
Rec_3_6_num <- cohort_ongoing_or_post_covid %>% filter(diagnostic_bp_test > 0) %>% nrow()
Rec_3_6_ratio <- Rec_3_6_num / Rec_3_6_denom

Rec_3_7_denom <- Rec_2_4_denom
Rec_3_7_num <- cohort_ongoing_or_post_covid %>% filter(diagnostic_chest_xray > ymd("20190101")) %>% nrow()
Rec_3_7_ratio <- Rec_3_7_num / Rec_3_7_denom

Rec_3_8_denom <- cohort_ongoing_or_post_covid %>% filter(risk_of_self_harm > ymd("20190101")) %>% nrow()
Rec_3_8_num <- cohort_ongoing_or_post_covid %>% filter(risk_of_self_harm > ymd("20190101"),
                                                       referral_psych > ymd("20190101")) %>% nrow()
Rec_3_8_ratio <- Rec_3_8_num / Rec_3_8_denom

Rec_3_9_denom <- cohort_ongoing_or_post_covid %>% filter(mild_anxiety_or_depression > ymd("20190101")) %>% nrow()
Rec_3_9_num <- cohort_ongoing_or_post_covid %>% filter(mild_anxiety_or_depression > ymd("20190101"),
                                                       referral_psych_iapt > ymd("20190101")) %>% nrow()
Rec_3_9_ratio <- Rec_3_9_num / Rec_3_9_denom

Rec_3_10_denom <- Rec_2_4_denom
Rec_3_10_num <- cohort_ongoing_or_post_covid %>% filter(referral_pc_clinic > ymd("20190101")) %>% nrow()
Rec_3_10_ratio <- Rec_3_10_num / Rec_3_10_denom

#3 referral patterns, self-care, secondary care, treated in primary care

Rec_4_1_denom <- Rec_2_4_denom
Rec_4_1_num_self_management <- cohort_ongoing_or_post_covid %>% filter(self_care_advise_or_support > ymd("20190101")) %>% nrow()
Rec_4_1_num_community_referral <- cohort_ongoing_or_post_covid %>% filter(community_care > ymd("20190101")) %>% nrow()
Rec_4_1_prim_care <- cohort_ongoing_or_post_covid %>% filter(primary_care_managment > ymd("20190101")) %>% nrow()

#other referral destinations - would they go direct from primary care or be cross-referred from PC clinic (or both? - maybe needs thinking about)

Rec_5_7_denom <- cohort_ongoing_or_post_covid %>% filter(age_at_diag >= 60) %>% nrow()
Rec_5_7_num <- cohort_ongoing_or_post_covid %>% filter(age_at_diag >= 60, referral_social_worker > ymd("20190101")) %>% nrow()
Rec_5_7 <- Rec_5_7_num / Rec_5_7_denom

Rec_5_8_denom <- cohort_ongoing_or_post_covid %>% filter(age_at_diag < 19) %>% nrow()
Rec_5_8_num <- cohort_ongoing_or_post_covid %>% filter(age_at_diag < 19, referral_paed > ymd("20190101")) %>% nrow()
Rec_5_8 <- Rec_5_8_num / Rec_5_8_denom

ref_rates <-
  cohort_ongoing_or_post_covid %>%
    mutate("was_referred" = !is.na(cohort_ongoing_or_post_covid$referral_pc_clinic)) %>% 
    group_by(month = floor_date(pc_or_oc_diag_dat, "month")) %>% 
    summarise(ref_rate = sum(was_referred, na.rm = TRUE)/sum(!is.na(pc_or_oc_diag_dat), na.rm = TRUE))
  
write_csv(ref_rates, "ref_rates_by_month.csv")
rm(ref_rates)

#4 long covid rates by practice - need 

#5 variation in long covid rates
    #variables
    #demographic - age, ethnicity, health worker?, socioeconomic deprivation
    #comorbidities

rm(cohort_any_acute_covid_recorded, cohort_ongoing_or_post_covid, cohort_all)

mget(ls()) %>% bind_rows() %>% write_csv('output/ratios.csv')
