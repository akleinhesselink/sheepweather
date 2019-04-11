rm(list = ls())
library(tidyverse)

# input --------------------------------------------------- #
dubois_exp_stn_url <- "https://www1.ncdc.noaa.gov/pub/data/ghcn/daily/all/USC00102707.dly"
data_readme_url <- "https://www1.ncdc.noaa.gov/pub/data/ghcn/daily/readme.txt"

# output -------------------------------------------------- #

data_file <- 'data/usses_climate.txt'
readme_file <- 'data/climate_readme.txt'

exists <- all( file.exists(c(data_file, readme_file)) )

if( exists ){
  print('files already present --- cancel download')
}else if( !exists ){
  print('downloading files... ')
  write_lines( read_lines(dubois_exp_stn_url), path = data_file)
  write_lines( read_lines(data_readme_url), path = readme_file)
}

