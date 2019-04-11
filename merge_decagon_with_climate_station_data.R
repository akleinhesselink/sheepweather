rm(list = ls()) 

library( tidyverse ) 
library(zoo) # for rollapply 

# input ---------------------------------------------------- # 

df <- readRDS('processed_data/decagon_data_corrected_values.RDS')
  # comes from the correct decagon readings script

station_dat <- read.csv('data/climate/USSES_climate.csv')
  # ??? 

load('data/weather.rda')

# output ---------------------------------------------------- # 

rainfall_outfile <- 'temp_data/daily_station_dat_rainfall.RDS'
decagon_outfile <- 'temp_data/decagon_data_with_station_data.RDS' 

# ---------------------------------------------------------------------------------------

weather$date <- as.POSIXct( strptime( weather$date, '%Y-%m-%d', tz = 'MST') )
station_dat$date <-  as.POSIXct( strptime( station_dat$DATE, '%Y%m%d', tz = 'MST')  ) 

weather <- 
  weather %>% 
  spread( ELEMENT, value)

station_dat <- 
  station_dat %>% 
  select( date, PRCP, TMAX, TMIN) %>% 
  gather( ELEMENT, value, PRCP, TMAX, TMIN) %>% 
  mutate( value = ifelse( value == -9999, NA, value)) %>% 
  spread( ELEMENT, value ) 

# testing ------------------------------------------ # 
# goal is to make weather like station_dat 

weather %>% head
station_dat %>% head

all( weather$date %in% station_dat$date )
all( station_dat$date %in% weather$date)

station_dat %>% 
  arrange( desc(PRCP) ) %>% head

weather %>% 
  arrange( desc(PRCP)) %>% head


weather %>% 
  filter( is.na(PRCP), is.na(TMAX), is.na(TMIN) )

station_dat %>% 
  filter( is.na(PRCP), is.na(TMAX), is.na(TMIN) )


#
station_dat <- 
  station_dat %>% 
  mutate( TMEAN = ( TMAX + TMIN ) / 2 ) %>% 
  select(date, PRCP, TMEAN) %>% 
  mutate( rainfall = rollapply(PRCP, 2, sum, fill = 0, na.rm = TRUE, align = 'right') ) %>%
  mutate( rainfall = ifelse( rainfall > 0.0 & TMEAN > 3 & !is.na(rainfall), 'rainy', 'not rainy')) %>%
  mutate( rainfall = ifelse( is.na(rainfall), 'not rainy', rainfall))

weather <- 
  weather %>% 
  mutate( TMEAN = ( TMAX + TMIN ) / 2 ) %>% 
  select(date, PRCP, TMEAN) %>% 
  mutate( rainfall = rollapply(PRCP, 2, sum, fill = 0, na.rm = TRUE, align = 'right') ) %>%
  mutate( rainfall = ifelse( rainfall > 0.0 & TMEAN > 3 & !is.na(rainfall), 'rainy', 'not rainy')) %>%
  mutate( rainfall = ifelse( is.na(rainfall), 'not rainy', rainfall))


# create a factor listing each rainy period, including the day before the rain  
station_dat_date_range <- range( station_dat$date )

station_dat <- 
  station_dat %>% 
  arrange( desc(date) ) %>% 
  mutate( prerain = lag( rainfall, 1) ) %>%
  mutate( prerain = ifelse( prerain == 'rainy' & rainfall == 'not rainy', TRUE, FALSE)) %>%
  arrange( date) %>% 
  mutate( prcp_event = factor( cumsum ( prerain ) )) %>% 
  group_by( prcp_event, prerain) %>% 
  mutate( total_rain = cumsum(PRCP) )


weather <- 
  weather %>% 
  arrange( desc(date) ) %>% 
  mutate( prerain = lag( rainfall, 1) ) %>%
  mutate( prerain = ifelse( prerain == 'rainy' & rainfall == 'not rainy', TRUE, FALSE)) %>%
  arrange( date) %>% 
  mutate( prcp_event = factor( cumsum ( prerain ) )) %>% 
  group_by( prcp_event, prerain) %>% 
  mutate( total_rain = cumsum(PRCP) )

#
station_dat <- 
  station_dat %>% 
  ungroup() %>% 
  mutate( simple_date = as.Date( date, tz = 'MST')) %>% 
  mutate( year = strftime( simple_date, '%Y', tz = 'MST')) %>%  
  group_by( year ) %>% 
  arrange( year, simple_date ) %>% 
  mutate( ann_cum_PRCP = cumsum(PRCP))

weather <- 
  weather %>% 
  ungroup() %>% 
  mutate( simple_date = as.Date( date, tz = 'MST')) %>% 
  mutate( year = strftime( simple_date, '%Y', tz = 'MST')) %>%  
  group_by( year ) %>% 
  arrange( year, simple_date ) %>% 
  mutate( ann_cum_PRCP = cumsum(PRCP))

saveRDS(weather, rainfall_outfile )

# clean-up decagon data -------------------
df <- 
  df %>% 
  filter( stat == 'raw', bad_values == 0 )

df$depth_label <- factor( df$depth , levels = c('air temperature', '5 cm deep', '25 cm deep') , order = TRUE ) 
df$Treatment_label <- factor(df$Treatment, levels = c('Drought', 'Control', 'Irrigation'), order = TRUE)

df <- 
  df %>% 
  mutate ( unique_position = paste0( plot, '.', position))

df$datetime <- df$new_date

station_dat$simple_date <- as.Date( station_dat$date, tz = 'MST')

df <- 
  df %>% 
  left_join( station_dat, by = c('year','simple_date')) 

saveRDS(df, decagon_outfile ) 
