rm(list = ls())

source('data-raw/import_and_format_decagon_data.R')
source('data-raw/check_decagon_dates.R')
source('data-raw/correct_decagon_dates.R')
source('data-raw/correct_decagon_readings.R')
source('data-raw/process_spot_measurements.R')

source('data-raw/download_weather.R')
source('data-raw/save_weather.R')

# generate data for soilwat model
source('data-raw/export_daily_soil_moisture_for_SOILWAT.R')
source('data-raw/export_daily_weather_for_SOILWAT.R')

# read daily soilwat data and save to csv file
# NOTE requires rSoilwat2 package

source('data-raw/extract_soilwat.R') # generate daily_VWC.csv


source('data-raw/process_ibutton_data.R')   # read in and clean up
source('data-raw/aggregate_ibutton_data.R') # aggregate to daily

