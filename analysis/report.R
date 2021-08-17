library(tidyverse)
library(lubridate)

#Compliance ratios from Section 1 of NG188 guidance

cohort_any_acute_covid_recorded <- read_csv('output/input_any_acute_covid_pri_care.csv')

Rec_1_1_denom <- nrow(cohort_any_acute_covid_recorded)
Rec_1_1_num <- sum((cohort_any_acute_covid_recorded$Rec_1_1_advice_given - cohort_any_acute_covid_recorded$acute_diag_dat > 0), na.rm = TRUE)
Rec_1_1_ratio <- Rec_1_1_num / Rec_1_1_denom

Rec_1_8_denom <- cohort_any_acute_covid_recorded %>% filter(Rec_1_8_interpreter_needed > ymd("20190101")) %>% nrow()
Rec_1_8_num <- cohort_any_acute_covid_recorded %>% filter(Rec_1_8_interpreter_booked > ymd("20190101")) %>% nrow()
Rec_1_8_ratio <- Rec_1_8_num / Rec_1_8_denom

#Leaving Rec 1_10 until outpatient linkage is carried out

#Compliance ratios from Section 2 of NG188 guidance

cohort_ongoing_or_post_covid <- read_csv('output/input_ongoing_post_covid.csv')

Rec_2_4_denom <- nrow(cohort_ongoing_or_post_covid)
Rec_2_4_num <- cohort_ongoing_or_post_covid %>% filter(Rec_2_4_discussion_about_daily_living > ymd("20190101")) %>% nrow()
Rec_2_4_ratio <- Rec_2_4_num / Rec_2_4_denom

rm(cohort_any_acute_covid_recorded, cohort_ongoing_or_post_covid)

mget(ls()) %>% bind_rows() %>% write_csv('output/ratios.csv')

#Compliance ratios from Section 3 of NG188 guidance

#2 number of patients with red flag diagnoses (by RF)

#3 diagnostic tests issues

#3 referral patterns, self-care, secondary care, treated in primary care

#4 long covid rates

#5 variation in long covid rates
    #variables
    #demographic - age, ethnicity, health worker?, socioeconomic deprivation
    #comorbidities
