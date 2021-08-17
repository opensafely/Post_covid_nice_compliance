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

cohort_ongoing_or_post_covid <- read_csv()

Rec_2_4_denom

write_csv(cohort_any_acute_covid_recorded, 'output/PC_count_table.csv')

#2 number of patients with red flag diagnoses (by RF)

#3 diagnostic tests issues

#3 referral patterns, self-care, secondary care, treated in primary care

