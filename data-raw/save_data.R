rm(list = ls())

library(tidyverse)
library(usethis)

usses_decagon <- readRDS('temp_data/decagon_data_corrected_values.RDS')
usses_weather <- load('temp_data/weather.rda')
usses_spot_sm <- read_csv('temp_data/spring_spot_measurements.RDS')
usses_quads <- read_csv('data-raw/quad_info.csv')
usses_soilwat <- read_csv('temp_data/daily_VWC.csv')

use_data(usses_decagon, usses_weather, usses_spot_sm, usses_quads, usses_soilwat)
