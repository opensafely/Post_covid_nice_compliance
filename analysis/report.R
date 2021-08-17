library(tidyverse)
#library(lubridate)

#1_1 number of patients with PC recorded / ongoing covid reported

cohort_any_acute_covid_recorded <- read_csv('output/input_any_acute_covid_pri_care.csv')



cohort_any_acute_covid_recorded %>% 
    pivot_longer(where(is.Date), names_to = "date_events", values_to = "date") # %>% 
#    select(patient_id, prac_id, prac_msoa, everything()) %>%
#    filter(date_events %in% c('diag_ongoing_covid', 'diag_post_covid'),
#            !is.na(date)) %>%
#    group_by(date_events) %>%
#    summarise(counts = n()) %>%
#    write_csv("output/PC_count_table.csv")

write_csv(cohort_any_acute_covid_recorded, 'output/PC_count_table.csv')

#2 number of patients with red flag diagnoses (by RF)

#3 diagnostic tests issues

#3 referral patterns, self-care, secondary care, treated in primary care

