rm(list =ls())

library(tidyverse)


# Some precip values are slightly higher in the
# monthly NCDC data.
# however my daily data matches the daily NCDC data

# INPUT --------------------------------------------------------- #

load('data/usses_weather.rda')
weather <- usses_weather
ncdc_monthly <- read_csv('data-raw/monthly_station_data_ncdc_download.csv')
ncdc_daily <- read_csv('data-raw/daily_station_data_ncdc_download.csv')

# --------------------------------------------------------- #

ncdc_daily$date <- ymd( ncdc_daily$DATE )

ncdc_monthly <-
  ncdc_monthly %>% select( DATE, PRCP, TAVG) %>%
  mutate( year = str_extract(DATE, '[0-9]{4}'),
          month = str_extract(DATE, '[0-9]{2}$')) %>%
  mutate( YEAR = as.numeric(year)) %>%
  mutate( MONTH = as.numeric(month)) %>%
  select( YEAR, MONTH, PRCP, TAVG) %>%
  gather( ELEMENT, value, PRCP:TAVG)


monthly_ncdc_from_daily <-
  ncdc_daily %>%
  mutate( year = year(date), month = month(date)) %>%
  group_by( year, month) %>%
  mutate( TAVG = (TMIN + TMAX)/2 ) %>%
  summarise( TAVG = mean(TAVG, na.rm  = T),  PRCP = sum(PRCP, na.rm = T))

joined_daily <-
  weather %>% left_join(
    ncdc_daily %>%
      gather( ELEMENT, value, PRCP:TMIN), by = c('date', 'ELEMENT')) %>%
  select( date, ELEMENT, value.x, value.y)

joined_daily %>%
  ggplot(aes( x = value.x, y = value.y)) +
  geom_point()

joined_daily %>%
  filter( ELEMENT == "PRCP") %>%
  filter( value.x == 0 )

missing_prcp <-
  joined_daily %>%
  filter( ELEMENT == 'PRCP' ) %>%
  group_by( month = month(date), year  = year(date) ) %>%
  summarise( missing = sum(is.na(value.x))) %>%
  filter( missing > 0) %>%
  filter( year < 2019)


monthly_ncdc_from_daily
ncdc_monthly

monthly <-
  weather %>%
  spread( ELEMENT, value ) %>%
  mutate( TAVG = (TMAX + TMIN)/2 ) %>%
  mutate( MONTH = month(date), YEAR = year(date)) %>%
  group_by( YEAR, MONTH)  %>%
  summarise( TAVG = mean(TAVG, na.rm = T), TMAX = mean(TMAX, na.rm = T), TMIN = mean(TMIN, na.rm = T), PRCP = sum(PRCP, na.rm = T)) %>%
  gather( ELEMENT, value, PRCP, TMAX, TMIN, TAVG) %>%
  filter(ELEMENT %in% c('PRCP', 'TAVG'))

joined_test <-
  monthly %>%
  left_join(ncdc_monthly, by = c('YEAR', 'MONTH', 'ELEMENT'))

joined_test %>%
  filter( is.na(value.y))

joined_test %>%
  filter( ELEMENT == 'PRCP') %>%
  mutate( diff = value.x - value.y)


joined_test %>%
  ggplot(aes(x = value.x, y = value.y)) +
  geom_point() +
  facet_wrap(~ELEMENT, scale = 'free')
