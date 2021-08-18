library(tidyverse)
library(lubridate)

#Compliance ratios from Section 1 of NG188 guidance

cohort_any_acute_covid_recorded <- read_csv('output/input_any_acute_covid_pri_care.csv')

Rec_1_1_denom <- nrow(cohort_any_acute_covid_recorded)
Rec_1_1_num <- sum((cohort_any_acute_covid_recorded$Rec_1_1_advice_given - cohort_any_acute_covid_recorded$acute_diag_dat > 0), na.rm = TRUE)
Rec_1_1_ratio <- Rec_1_1_num / Rec_1_1_denom

Rec_1_8_denom <- cohort_any_acute_covid_recorded %>% filter(Rec_1_8_interpreter_needed > ymd("20190101")) %>% nrow()
Rec_1_8_num <- cohort_any_acute_covid_recorded %>% filter(Rec_1_8_interpreter_needed > ymd("20190101"),
                                                          Rec_1_8_interpreter_booked > ymd("20190101")) %>% nrow()
Rec_1_8_ratio <- Rec_1_8_num / Rec_1_8_denom

#Leaving Rec 1_10 until outpatient linkage is carried out

#Compliance ratios from Section 2 of NG188 guidance

cohort_ongoing_or_post_covid <- read_csv('output/input_ongoing_post_covid.csv')

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
                                                       referral_psych > ymd("20190101")) %>% nrow()
Rec_3_9_ratio <- Rec_3_9_num / Rec_3_9_denom

Rec_3_10_denom <- Rec_2_4_denom
Rec_3_10_num <- cohort_ongoing_or_post_covid %>% filter(referral_pc_clinic > ymd("20190101")) %>% nrow()
Rec_3_10_ratio <- Rec_3_10_num / Rec_3_10_denom

#3 referral patterns, self-care, secondary care, treated in primary care

Rec_3_11_denom <- Rec_2_4_denom
Rec_3_11_num_self_management <- cohort_ongoing_or_post_covid %>% filter(self_care_advise_or_support > ymd("20190101")) %>% nrow()
Rec_3_11_num_community_referral <- cohort_ongoing_or_post_covid %>% filter(community_care > ymd("20190101")) %>% nrow()
Rec_3_11_prim_care <- cohort_ongoing_or_post_covid %>% filter(primary_care_managment > ymd("20190101")) %>% nrow()

#other referral destinations - would they go direct from primary care or be cross-referred from PC clinic (or both? - maybe needs thinking about)

#4 long covid rates by practice - need 

#5 variation in long covid rates
    #variables
    #demographic - age, ethnicity, health worker?, socioeconomic deprivation
    #comorbidities

rm(cohort_any_acute_covid_recorded, cohort_ongoing_or_post_covid)

mget(ls()) %>% bind_rows() %>% write_csv('output/ratios.csv')
