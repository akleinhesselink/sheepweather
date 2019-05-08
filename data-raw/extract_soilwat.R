library(tidyverse)
library(rSOILWAT2)

outfile <- 'temp_data/daily_VWC.csv' # output name

# input

SW_out <- readRDS('data-raw/20190428_rSOILWAT2_v250_Simulation_US Sheep Experiment Station/rSOILWAT2_USSES/sw_output_USSES.rds')

# Extract and write to csv

data.frame( SW_out@VWCBULK@Day ) %>%
  write_csv( outfile)
