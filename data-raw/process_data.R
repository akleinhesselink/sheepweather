rm(list = ls())

source('data-raw/import_and_format_decagon_data.R')
source('data-raw/check_decagon_dates.R')
source('data-raw/correct_decagon_dates.R')
source('data-raw/correct_decagon_readings.R')
source('data-raw/process_spot_measurements.R')

source('data-raw/download_climate_data.R')
source('data-raw/save_weather.R')

# generate data for soilwat model 
source('data-raw/export_daily_soil_moisture_for_SOILWAT.R')
source('data-raw/export_climate_station_data_for_SOILWAT.R')

# read daily soilwat data and save to csv file  
# NOTE requires Rsoilwat31 package 
source('data-raw/ExtractData_3Runs.R') # generate daily_VWC.csv



# source('make_rainfall.R')
# source('merge_decagon_with_climate_station_data.R')
