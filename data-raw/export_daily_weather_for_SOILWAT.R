# format for Caitlin Andrews and John Bradford:

rm(list = ls())
library( tidyverse )
library(lubridate)

# input ---------------------------------------------------- #

weather <- readRDS('temp_data/weather.RDS')

# output ---------------------------------------------------- #

out_dir <- 'temp_data/for_soilwat/weather_files'

# ---------------------------------------------------------------------------------------

weather <-
  weather %>%
  ungroup() %>%
  spread(ELEMENT, value ) %>%
  mutate( year = year(date) ) %>%
  filter( year < 2017) %>%
  mutate( DOY =  yday(date) ) %>%
  mutate( PPT = PRCP/10 ) # convert to cm

day_grid <- expand.grid( DOY = 1:365,
                         year = c(min(weather$year):max(weather$year)))

weather <- merge(day_grid, weather, by = c('year', 'DOY'), all.x = T, all.y = T)

# replace NA with -9999
weather <-
  weather %>%
  ungroup() %>%
  gather( variable, value, TMAX, TMIN, PRCP, PPT) %>%
  mutate( value = ifelse( is.na(value), -9999.0, value )) %>%
  spread( variable, value )

year_list <- split( weather[ , c('DOY', 'TMAX', 'TMIN', 'PPT') ], weather$year)

write_with_header <- function(x, file, header, f = write.table, ...){

  datafile <- file(file, open = 'wt')

  on.exit(close(datafile))

  if(!missing(header)) writeLines(header,con=datafile)

  f(x, datafile,...)
}

make_header <- function( prefix, df, station, year) {

  paste0( '#', prefix, station, ' year = ', year, '\n#', 'DOY', ' ', 'Tmax(C)', ' ', 'Tmin(C)', ' ', 'PPT(cm)')

}

for ( i in 1:length( year_list) ) {

  temp_df <- year_list[[i]]
  temp_year <- names(year_list)[[i]]

  temp_fname <- file.path( out_dir, paste0( 'weath.', temp_year) )
  temp_header <- make_header(prefix = 'weather for site ', df = temp_df, station = 'US Sheep Experiment Station', year = temp_year )

  write_with_header( x = temp_df, file = temp_fname, header = temp_header, f = write.table, sep = '\t', col.names = FALSE, row.names = FALSE)

}

