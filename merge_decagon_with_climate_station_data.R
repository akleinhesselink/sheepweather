rm(list = ls()) 

library( tidyverse ) 
library(zoo) # for rollapply 

# input ---------------------------------------------------- # 

df <- readRDS('processed_data/decagon_data_corrected_values.RDS')
  # comes from the correct decagon readings script

rainfall <- readRDS('processed_data/daily_station_dat_rainfall.RDS')
  # comes from the make_rainfall script 

# output ---------------------------------------------------- # 

decagon_outfile <- 'temp_data/decagon_data_with_station_data.RDS' 

# ---------------------------------------------------------------------------------------
# clean-up decagon data  and add labels

df <- 
  df %>% 
  filter( stat == 'raw', bad_values == 0 )

df$depth_label <- factor( df$depth , levels = c('air temperature', '5 cm deep', '25 cm deep') , order = TRUE ) 
df$Treatment_label <- factor(df$Treatment, levels = c('Drought', 'Control', 'Irrigation'), order = TRUE)

df <- 
  df %>% 
  mutate ( unique_position = paste0( plot, '.', position))

df$datetime <- df$new_date

df <- 
  df %>% 
  left_join(rainfall, by = c('year','simple_date')) 


saveRDS(df, decagon_outfile ) 


