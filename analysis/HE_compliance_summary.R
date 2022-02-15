library(tidyverse)
library(lubridate)

### Define functions ###

# Function to produce a summary table of num, denom, ratios per month, split by HE variables
monthly_table <-function(num_df, denom_df, inequality_vars, rec_no) {
  summary_tab <- denom_df %>% group_by(year_month) %>% summarise("Denom" = n())
  temp <- num_df %>% group_by(year_month) %>% summarise("Num" = n())
  summary_tab$Num <- as.numeric(temp$Num)
  summary_tab <- summary_tab %>% mutate("Ratio" = Num/Denom, "HE_var" = "total", "HE_category" = "total")
  
  for (ineq_var in inequality_vars) {
    temp <- denom_df %>% group_by(year_month, denom_df[ineq_var]) %>% summarise("Denom" = n())
    temp_num <- num_df %>% group_by(year_month, num_df[ineq_var]) %>% summarise("Num" = n())
    temp$Num <- as.numeric(temp_num$Num)
    temp <- temp %>% mutate("Ratio" = round(Num/Denom,3), "HE_category" = ineq_var) %>% rename("HE_var" = ineq_var)
    summary_tab <- rbind(summary_tab, temp)
    summary_tab <- transform(summary_tab, Num = as.numeric(Num), Denom = as.numeric(Denom), Ratio = as.numeric(Ratio)) %>% 
      arrange(HE_category, HE_var, year_month)
  }
  write_csv(summary_tab, gsub(" ", "", paste("output/monthly_summary_tab_",rec_no, ".csv")))
  return(summary_tab)
}

# Function to make a line graph
create_line_plot <- function(monthly_df, ineq_var, heading, rec_no = NULL) {
  temp <- ggplot(monthly_df, mapping = aes(x = year_month, y = Ratio)) +
    geom_line(mapping = aes(colour = HE_var)) + 
    scale_y_continuous(limits=c(0,1), expand = c(0,0), breaks = seq(0, 1, by = 0.2), labels = c("0","0.2", "0.4", "0.6", "0.8", "1.0")) +
    scale_x_date(breaks = unique(monthly_df$year_month)[seq(1,length(unique(monthly_df$year_month)),by=3)]) +
    labs(title= heading, subtitle = paste("Split by",ineq_var), x = element_blank(), y = "Compliance Ratio") +
    nice_line_theme
  return(temp)
}

# Function to create multiple line graphs. Shows uptake over time split by each health inequality variable
create_line_plots <- function(df, heading, rec_no) {
  for (ineq_var in unique(df$HE_category)) {
    temp <- df %>% filter(HE_category == ineq_var)
    temp_fig <- create_line_plot(temp, ineq_var, heading, rec_no)
    ggsave(gsub(" ", "", paste("output/line_chart_", rec_no, "_", ineq_var, ".png")), temp_fig)
  }
}

### Import theme to improve look of graphs ###

font <- "Arial"

nice_line_theme <- ggplot2::theme(
  #Text formatting: title, and caption
  plot.title = ggplot2::element_text(family = font, size=28, face="bold", colour ="#222222"),
  plot.subtitle = ggplot2::element_text(family = font, size=20, colour ="#222222"),
  plot.caption = ggplot2::element_blank(),
  
  # Format legend
  legend.position = "bottom",
  legend.text.align = 0,
  legend.background = ggplot2::element_blank(),
  legend.title = ggplot2::element_blank(),
  legend.key = ggplot2::element_blank(),
  legend.text = ggplot2::element_text(family=font, size=12, colour="#222222"),
  
  #Format Axes
  axis.title.x = ggplot2::element_blank(),
  axis.title.y = ggplot2::element_text(family=font, size=14, colour="#222222"),
  axis.text.x =  ggplot2::element_text(family=font, size=10, colour="#222222", angle = 45, hjust=1),
  axis.text.y = ggplot2::element_text(family=font, size=14, colour="#222222"),
  axis.ticks.x = ggplot2::element_line(colour = "#222222", size = 0.5),
  axis.ticks.y = ggplot2::element_blank(),
  axis.line.x = ggplot2::element_line(colour = "#222222", size = 0.5),
  axis.line.y = ggplot2::element_blank(),
  
  #Grid lines
  panel.grid.minor = ggplot2::element_blank(),
  panel.grid.major.y = ggplot2::element_line(color="#c8c8c8"),
  panel.grid.major.x = ggplot2::element_blank(),
  panel.background = ggplot2::element_blank(),
)

### Create list containing the inequality variables ###
inequality_vars <- c("sex", "region", "imd", "age_group", "ethnicity")

### Import the relevant dataframe ###

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
                                msoa = col_character(),
                                imd = col_character(),
                                age_group = col_character(),
                                ethnicity = col_double(),
                                patient_id = col_double()),
                              na = c("", "NA", "0"))

### Dataframe preprocessing ###
#Convert prac MSOA to region
#Read in MSOA lookup
#https://geoportal.statistics.gov.uk/datasets/fe6c55f0924b4734adf1cf7104a0173e_0/explore?showTable=true
MSOA_Region_Lookup <- read_csv("analysis/MSOA_Region_Lookup.csv")

acute_df <- acute_df %>% 
  left_join(MSOA_Region_Lookup,
            by = c("prac_msoa" = "MSOA11CD")) %>% 
  rename("region" = "RGN11NM")

# Add start and end date to filter data, add year_month column for monthly calculations
start_date = ymd("2019-06-01")
end_date = ymd("2021-05-30")

acute_df <- acute_df %>% filter(!is.na(acute_diag_dat)) %>% 
  mutate(year_month = floor_date(acute_diag_dat, "month")) %>% 
  filter((year_month >= start_date) & (year_month <= end_date))


##### Suspected or confirmed acute COVID‑19 #####

# Recommendation 1.1 - Provision of advice and information to people with suspected or confirmed acute COVID‑19
denominator_df <- acute_df
numerator_df <- acute_df %>% filter(!is.na(advice_given))
monthly_table_1_1 <- monthly_table(numerator_df,denominator_df,inequality_vars, "1_1")

# Recommendation 1.8 - Provision of interpreter when needed for people with suspected or confirmed acute COVID‑19
denominator_df <- acute_df %>% filter(!is.na(interpreter_needed))
numerator_df <- denominator_df %>% filter(!is.na(interpreter_booked)) # interpreter_booked >= interpreter_needed
monthly_table_1_8 <- monthly_table(numerator_df,denominator_df,inequality_vars, "1_8")

##### Create Figures #####

# Create a line charts showing monthly uptake, split by health inequalities
create_line_plots(monthly_table_1_1, "Recommendation 1.1", "1_1")
