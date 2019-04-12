rm(list = ls())

library( tidyverse )

# input ---------------------------------------------------- #

decagon_data <- readRDS('temp_data/decagon_data_corrected_values.RDS')
  # comes from the correct decagon readings script

rainfall <- readRDS('temp_data/daily_station_dat_rainfall.RDS')
  # comes from the make_rainfall script

# output ---------------------------------------------------- #

decagon_outfile <- 'temp_data/decagon_data_with_station_data.RDS'

# ---------------------------------------------------------------------------------------

decagon_data <-
  decagon_data %>%
  left_join(rainfall, by = 'simple_date')

saveRDS(decagon_data, decagon_outfile )


