# Script to generate descriptive stats from long covid 

library(tidyverse)
library(lubridate)
library(ggalluvial)

# Start with time gap between acute and long covid diagnosis

cohort <- read_csv("output/input_all.csv", col_types = cols(patient_id = col_number(),
                                                            .default = col_date()))

cohort <- cohort %>% 
   mutate("diff_acute_to_og" = diag_ongoing_covid - diag_acute_covid,
          "diff_acute_to_pc" = diag_post_covid - diag_acute_covid)

alluvial <- cohort %>% 
  mutate("has_diag_acute_covid" = case_when(!is.na(diag_acute_covid) ~ "Acute Covid", TRUE ~ "No Acute Covid"),
         "has_diag_og_covid" = case_when(!is.na(diag_ongoing_covid) ~ "Ongoing Covid", TRUE ~ "No Ongoing Covid"),
         "has_diag_pc_covid" = case_when(!is.na(diag_post_covid) ~ "Post Covid", TRUE ~ "No Post Covid")) %>% 
  group_by(has_diag_acute_covid,
           has_diag_og_covid,
           has_diag_pc_covid) %>% 
  summarise(freq = n())

ggplot(as.data.frame(alluvial), aes(y=freq, 
                     axis1=has_diag_acute_covid,
                     axis2=has_diag_og_covid,
                     axis3=has_diag_pc_covid)) +
  geom_alluvium(aes(fill = has_diag_acute_covid)) + 
  geom_stratum(width = 1/12, fill = "black", color = "grey") + 
  geom_label(stat = "stratum", aes(label = after_stat(stratum))) + 
  scale_x_discrete(limits = c("has_diag_acute_covid", "has_diag_og_covid", "has_diag_pc_covid"), expand = c(0.05, 0.05)) + 
  scale_y_continuous(limits = c(0, nrow(alluvial)))

test_op <- c("1", "2")
write_csv(test_op, "test_op.csv")
