library('tidyverse')

df_input <- read_csv(
  here::here("output", "input.csv"),
  col_types = cols(patient_id = col_integer(),age_at_diag = col_integer())
)

plot_age <- ggplot(data=df_input, aes(df_input$age_at_diag)) + geom_histogram()

ggsave(
  plot= plot_age,
  filename="descriptive.png", path=here::here("output"),
)