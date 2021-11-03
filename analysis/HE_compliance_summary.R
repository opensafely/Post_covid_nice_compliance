library(tidyverse)

# Define a function to take numerator and denominator dataframes and generate a table with num/denoms and ratios
# broken up by each health inequality variable

HE_summary <-function(num_df, denom_df, inequality_vars) {
  HE_summary_table <- setNames(data.frame(matrix(ncol = 5, nrow = 0)), c("HE_var", "Num", "Denom", "Ratio", "HE_category"))
  Rec_denom <- nrow(denominator_df)
  Rec_num <- nrow(numerator_df)
  Rec_ratio <- round(Rec_num / Rec_denom, 3)
  HE_summary_table[nrow(HE_summary_table)+1,] <- c("Total", Rec_num, Rec_denom, Rec_ratio, "Total")
  
  for (col in inequality_vars) {
    temp_num_tab <- num_df %>% group_by(num_df[[col]]) %>% summarise("Num" = (count = n())) %>% rename(HE_var = 1)
    temp_denom_tab <- denom_df %>% group_by(denom_df[[col]]) %>% summarise("Denom" = (count = n())) %>% rename(HE_var = 1)
    temp_full_table <- merge(temp_num_tab, temp_denom_tab, by="HE_var") %>% mutate("Ratio" = round(Num/Denom, 3), "HE_category" = col)
    HE_summary_table <- rbind(HE_summary_table, temp_full_table)
    HE_summary_table <- transform(HE_summary_table, Num = as.numeric(Num), Denom = as.numeric(Denom), Ratio = as.numeric(Ratio))
  }
  return(HE_summary_table)
}

# Create a function to produce summary bar charts showing uptake split by each HE variable
create_bar_chart <- function(df, x_var, y_var, heading) {
  test_fig <- ggplot(df, mapping = aes(x = x_var, y = y_var)) + 
    geom_bar(stat="identity", position="identity", fill="#004650") +
    geom_hline(yintercept = 0, size = 1, colour="#333333") + 
    NICE_theme +
    coord_flip() +
    theme(panel.grid.major.x = element_line(color="#cbcbcb"), panel.grid.major.y=element_blank()) +
    scale_y_continuous(limits=c(0,1),
                       breaks = seq(0, 1, by = 0.2),
                       labels = c("0","0.2", "0.4", "0.6", "0.8", "1.0")) +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 14)) +
    facet_wrap(~HE_category,ncol=2, scales = 'free') + 
    labs(title= heading, y = element_blank(), x = "Compliance Ratio")
}

# Import the relevant dataframes
acute_df <- read_csv("output/input_any_acute_covid_pri_care.csv",
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

og_pc_df <- read_csv("output/input_ongoing_post_covid.csv",
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
                       referral_social_worker = col_date(format = "%Y-%m-%d"),
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
                       sex = col_character(),
                       region = col_character(),
                       imd = col_double(),
                       age_group = col_character(),
                       ethnicity = col_double(),
                       patient_id = col_double()),
                     na = c("", "NA", "0"))


# Create list containing the inequality variables
inequality_vars <- c("sex", "region", "imd", "age_group", "ethnicity")

# For each recommendation, define datasets for the denominator and numerator, then use HE_summary_function 
# to create a summary dataframe containing denoms,nums, and ratios split by each HE variable

# Need to check all below to make sure the num/denoms are correct

##### Suspected or confirmed acute COVID‑19 #####
# Recommendation 1.1 - Provision of advice and information to people with suspected or confirmed acute COVID‑19
denominator_df <- acute_df
numerator_df <- acute_df %>% filter(advice_given >= acute_diag_dat)
HE_summary_1_1 <- HE_summary(numerator_df,denominator_df,inequality_vars)

# Recommendation 1.8 - Provision of interpreter when needed for people with suspected or confirmed acute COVID‑19
denominator_df <- acute_df %>% filter(!is.na(interpreter_needed))
numerator_df <- denominator_df %>% filter(!is.na(interpreter_booked), interpreter_booked >= interpreter_needed)
HE_summary_1_8 <- HE_summary(numerator_df,denominator_df,inequality_vars)

# Recommendation 2.4 - Have discussions about life and activities for people with ongoing COVID-19
denominator_df <- og_pc_df
numerator_df <- og_pc_df %>% filter(!is.na(discussion_about_daily_living), discussion_about_daily_living >= pc_or_oc_diag_dat)
HE_summary_2_4 <- HE_summary(numerator_df,denominator_df,inequality_vars)

##### Guidelines for new or ongoing 4 weeks or more after suspected or confirmed acute COVID‑19 #####
# Recommendation 3.4 - Offering blood tests to people with ongoing COVID‑19
denominator_df <- og_pc_df
numerator_df <- og_pc_df %>% filter(!is.na(diagnostic_bloods),  diagnostic_bloods >= pc_or_oc_diag_dat)
HE_summary_3_4 <- HE_summary(numerator_df,denominator_df,inequality_vars)

# Recommendation 3.5 - Offer of exercise tolerance test to people with ongoing COVID‑19
denominator_df <- og_pc_df
numerator_df <- og_pc_df %>% filter(!is.na(diagnostic_sit_stand), diagnostic_sit_stand >= pc_or_oc_diag_dat)
HE_summary_3_5 <- HE_summary(numerator_df,denominator_df,inequality_vars)

# Recommendation 3.6 - Offer blood pressure recording for people with ongoing COVID‑19 that also have posturing symptoms
denominator_df <- og_pc_df
numerator_df <- og_pc_df %>% filter(!is.na(diagnostic_bp_test))
HE_summary_3_6 <- HE_summary(numerator_df,denominator_df,inequality_vars)

# Recommendation 3.7 - Offer chest X-ray (between 4 and 12 weeks) to people with ongoing COVID‑19
denominator_df <- og_pc_df
numerator_df <- og_pc_df %>% filter(!is.na(diagnostic_chest_xray), diagnostic_chest_xray >= pc_or_oc_diag_dat)
HE_summary_3_7 <- HE_summary(numerator_df,denominator_df,inequality_vars)

# Recommendation 3.8 - Refer for psychiatric assessment if person has ongoing COVID-19 and severe psychiatric symptoms/ is self-harm risk
denominator_df <- og_pc_df %>% filter(!is.na(risk_of_self_harm))
numerator_df <- denominator_df %>% filter(!is.na(referral_psych), referral_psych >= pc_or_oc_diag_dat)    ## Check - 2 psych referral columns
HE_summary_3_8 <- HE_summary(numerator_df,denominator_df,inequality_vars)

# Recommendation 3.9 - Refer for psychological therapies if person has ongoing COVID-19 and anxiety or depression
# or to liaison psychiatry for more complex needs
denominator_df <- og_pc_df %>% filter(!is.na(mild_anxiety_or_depression))
numerator_df <- denominator_df %>% filter(!is.na(referral_psych_iapt), referral_psych_iapt >= pc_or_oc_diag_dat)
HE_summary_3_9 <- HE_summary(numerator_df,denominator_df,inequality_vars)

# Recommendation 3.10 - Refer to integrated multidisciplinary assessment service, after ruling out other diagnoses
denominator_df <- og_pc_df
numerator_df <- denominator_df %>% filter(!is.na(referral_pc_clinic), referral_pc_clinic >= pc_or_oc_diag_dat)
HE_summary_3_10 <- HE_summary(numerator_df,denominator_df,inequality_vars)

##### Guidelines for people with ongoing symptomatic COVID-19 or post-COVID syndrome who have been assessed in primary care #####
# Recommendation 4.1 - Provide advice on self management, provide support from primary care/community, rehab and mental health services
denominator_df <- og_pc_df
numerator_df <- og_pc_df %>% filter(!is.na(self_care_advise_or_support), self_care_advise_or_support >= pc_or_oc_diag_dat)
HE_summary_4_1_self_care_advice <- HE_summary(numerator_df,denominator_df,inequality_vars)
numerator_df <- og_pc_df %>% filter(!is.na(community_care), community_care >= pc_or_oc_diag_dat)
HE_summary_4_1_community_care <- HE_summary(numerator_df,denominator_df,inequality_vars)
numerator_df <- og_pc_df %>% filter(!is.na(primary_care_managment), primary_care_managment >= pc_or_oc_diag_dat)
HE_summary_4_1_prim_care <- HE_summary(numerator_df,denominator_df,inequality_vars)
                                            
# Recommendation 5.7 - Consider support for older people with short-term care packages,advance care planning 
# and support with social isolation, loneliness and bereavement
denominator_df <- og_pc_df %>% filter(age_at_diag >= 60)
numerator_df <- denominator_df %>% filter(!is.na(referral_social_worker), referral_social_worker >= pc_or_oc_diag_dat)
HE_summary_5_7 <- HE_summary(numerator_df,denominator_df,inequality_vars)

# Recommendation 5.8 - Consider referral for specialist advice (after 4 weeks) with specialist advice for 
# children with ongoing COVID-19 or post COVID syndrome
denominator_df <- og_pc_df %>% filter(age_at_diag <= 18)
numerator_df <- denominator_df %>% filter(!is.na(referral_paed), referral_paed >= pc_or_oc_diag_dat)
HE_summary_5_8 <- HE_summary(numerator_df,denominator_df,inequality_vars)


##### Create Figures #####

#Define a NICE theme to improve look of charts (taken and slightly modified from bbplot package)

font <- "Arial"
NICE_theme <- theme(
  plot.title = ggplot2::element_text(family=font, size=18, face="bold",color="#222222"),
  plot.caption = ggplot2::element_blank(),

  #Legend
  legend.position = "bottom",
  legend.text.align = 0,
  legend.background = ggplot2::element_blank(),
  legend.title = ggplot2::element_blank(),
  legend.key = ggplot2::element_blank(),
  legend.text = ggplot2::element_text(family=font, size=14, color="#222222"),

  #Axis format
  #axis.title = ggplot2::element_blank(),
  axis.text = ggplot2::element_text(family=font, size=8, color="#222222"),
  axis.text.x = ggplot2::element_text(margin=ggplot2::margin(5, b = 10)),
  axis.ticks = ggplot2::element_blank(),
  axis.line = ggplot2::element_blank(),

  #Grid lines
  panel.grid.minor = ggplot2::element_blank(),
  panel.grid.major.y = ggplot2::element_line(color="#cbcbcb"),
  panel.grid.major.x = ggplot2::element_blank(),

  #Blank background
  panel.background = ggplot2::element_blank(),
  panel.border = ggplot2::element_rect(color="#222222", fill=NA, size = 0.5),

  #Strip background (facet wrapped)
  strip.background = ggplot2::element_rect(color = "black", fill = "#c8c8c8", linetype = "solid", size = 1),
  strip.text = ggplot2::element_text(size = 14, color = "black", hjust = 0.5)
)


# Example figure - Faceted bar plot showing a summary of compliance to the rec, split by HE variable
HE_bar_1_1 <- create_bar_chart(HE_summary_1_1, HE_summary_1_1$HE_var, HE_summary_1_1$Ratio,
                            "Recommendation 1.1 - Acute COVID advice")
ggsave("output/HE_bar_1_1.png",HE_bar_1_1)
write_csv(HE_summary_1_1, "output/HE_summary_1_1.csv")
