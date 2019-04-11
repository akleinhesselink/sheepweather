rm(list = ls())

source('import_and_format_decagon_data.R')
source('check_decagon_dates.R')
source('correct_decagon_dates.R')
source('correct_decagon_readings.R')
source('process_spot_measurements.R')

source('download_climate_data.R')
source('save_weather.R')

# generate data for soilwat model 
source('export_daily_soil_moisture_for_SOILWAT.R')
source('export_climate_station_data_for_SOILWAT.R')

# read daily soilwat data  
# NOTE requires Rsoilwat31 package 
source('ExtractData_3Runs.R') # generate daily_VWC.csv



# source('make_rainfall.R')
# source('merge_decagon_with_climate_station_data.R')
