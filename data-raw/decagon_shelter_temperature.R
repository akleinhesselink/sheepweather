rm(list = ls())

library(tidyverse)
library(lubridate)

load('data/usses_decagon.rda')
load('data/usses_weather.rda')
seasons <- read_csv('data-raw/season_table.csv')
quad_info <- read_csv('data-raw/quad_info.csv')

air_temps <-
  usses_decagon %>%
  filter( measure == 'C' & position == 'air') %>%
  mutate( hour = hour(datetime), month = month(date) , year = year(date))

soil_temps <-
  usses_decagon %>%
  filter( measure == 'C' & position != 'air') %>%
  mutate( hour = hour(datetime))

daily_air <-
  air_temps %>%
  distinct(datetime, date, plot, v) %>%
  group_by(date, plot) %>%
  summarise( TMAX  = max(v), TMIN = min(v), TMEAN = (TMAX + TMIN)/2)  %>%
  gather( stat, decagon , TMAX, TMIN, TMEAN )

daily_soil <-
  soil_temps %>%
  filter( depth == '5 cm deep') %>%
  distinct( datetime, date, plot, v) %>%
  group_by(date, plot) %>%
  summarise( TMAX  = max(v), TMIN = min(v), TMEAN = (TMAX + TMIN)/2)  %>%
  gather( stat, decagon , TMAX, TMIN, TMEAN )

station <-
  usses_weather %>%
  filter(  ELEMENT != 'PRCP') %>%
  spread( ELEMENT, value ) %>%
  mutate( TMEAN = (TMAX + TMIN)/2 )  %>%
  gather( stat, station, TMAX, TMIN, TMEAN)

test_air <-
  daily_air %>%
  mutate( month = month(date)) %>%
  left_join(seasons %>% select(month, season), by = 'month') %>%
  left_join(quad_info %>% select(Treatment, QuadName, PrecipGroup), by = c('plot' = 'QuadName'))  %>%
  left_join(station, by = c('date', 'stat')) %>%
  mutate( anom = decagon - station)


test_soil <-
  daily_soil %>%
  mutate( month = month(date)) %>%
  left_join(seasons %>% select(month, season), by = 'month') %>%
  left_join(quad_info %>% select(Treatment, QuadName, PrecipGroup), by = c('plot' = 'QuadName'))  %>%
  left_join(station, by = c('date', 'stat')) %>%
  mutate( anom = decagon - station)

test_air %>%
  filter( anom < 20 , anom > -20 ) %>%
  mutate( year = year( date) ) %>%
  group_by(stat, year, month, Treatment) %>%
  arrange( year, month) %>%
  ggplot( aes( x =  month )) +
  #geom_point(aes(y = anom, color = Treatment), alpha = 0.8) +
  stat_summary(aes( y = anom, color = Treatment), fun.y = 'mean', geom = 'line') +
  scale_color_manual(values = c('black', 'red', 'blue')) +
  facet_grid(stat~year) +
  scale_x_continuous(breaks = c(1:12))

test_soil %>%
  filter( anom < 20 , anom > -20 ) %>%
  mutate( year = year( date) ) %>%
  group_by(stat, year, month, Treatment) %>%
  summarise( anom = mean(anom, na.rm = T), n = n_distinct(plot)) %>%
  arrange( year, month) %>%
  ggplot( aes( x =  month )) +
  geom_point(aes(y = anom, color = Treatment), alpha = 0.5) +
  stat_summary(aes( y = anom, color = Treatment), fun.y = 'mean', geom = 'line') +
  scale_color_manual(values = c('black', 'red', 'blue')) +
  facet_wrap(~year) +
  scale_x_continuous(breaks = c(1:12))



