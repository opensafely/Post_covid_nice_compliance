library(tidyverse)
library(lubridate)

#1 number of patients with PC recorded / ongoing covid reported

cohort_df <- here::here("output", "input.csv") %>%
  read_csv()

cohort_df %>% 
    pivot_longer(where(is.Date), names_to = "date_events", values_to = "date") %>% 
    select(patient_id, prac_id, prac_msoa, everything()) %>%
    filter(date_events %in% c('diag_ongoing_covid', 'diag_post_covid'),
            !is.na(date)) %>%
    group_by(date_events) %>%
    summarise(counts = n()) %>%
    write_csv("output/PC_count_table.csv")

#2 number of patients with red flag diagnoses (by RF)

#3 diagnostic tests issues

#3 referral patterns, self-care, secondary care, treated in primary care

