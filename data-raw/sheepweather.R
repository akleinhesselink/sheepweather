rm(list = ls())

#
# run this file to save all the data to the data folder
# will run the process data script which takes several
# minutes

library(tidyverse)
library(usethis)

source('data-raw/process_data.R')  # takes several minutes

usses_decagon <- readRDS('temp_data/decagon_data_corrected_values.RDS')
use_data(usses_decagon, overwrite = T)

rm(list = ls())

usses_weather <- readRDS('temp_data/weather.RDS')
use_data(usses_weather, overwrite = T)

rm(list = ls())

usses_ibutton <- readRDS('temp_data/daily_ibutton.RDS')
usses_spot_sm <- readRDS('temp_data/spring_spot_measurements.RDS')
usses_quads <- read_csv('data-raw/quad_info.csv')
usses_soilwat <- read_csv('temp_data/daily_VWC.csv')

use_data(usses_spot_sm, usses_quads, usses_soilwat, usses_ibutton, overwrite = T)
