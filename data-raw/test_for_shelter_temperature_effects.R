rm(list = ls())

library(lubridate)
library(tidyverse)

quads   <- read_csv('data-raw/quad_info.csv')
seasons <- read_csv('data-raw/season_table.csv')
ibutton <- readRDS('temp_data/daily_ibutton.RDS')
load('data/usses_weather.rda')
load('data/usses_decagon.rda')

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


season_anoms <-
  station %>%
  left_join(
    bind_rows(
      daily_air %>% rename('value' = decagon) %>% mutate(type = 'decagon'),
      ibutton %>% rename( 'value' = ibutton)  %>% mutate( type = 'ibutton') %>% select(-n) ),
    by = c('date', 'stat')) %>%
  filter( !is.na(plot)) %>%
  mutate( anom = value - station ) %>%
  filter( stat == 'TMEAN', abs(anom) < 20 ) %>%
  mutate( month = month(date), year = year(date)) %>%
  left_join(quads, by = c('plot' = 'QuadName')) %>%
  left_join(seasons, by = 'month') %>%
  select( month, plot, Treatment, type, year, season, date, anom) %>%
  group_by( month, plot, Treatment, type, season ) %>%
  filter( month %in% c(4:6) ) %>%
  summarise( anom = mean(anom))

m1 <- lm( data =  season_anoms, anom ~ Treatment + type )

summary(m1)

m1 <- MASS::stepAIC(m1)

summary( m1 )

emmeans(m1, ~ Treatment ) %>%
  data.frame() %>%
  ggplot( aes(  x = Treatment , y = emmean, ymin = lower.CL, ymax = upper.CL )) +
  geom_point(position = position_dodge(width = 0.2)) +
  geom_errorbar(position = position_dodge(width = 0.2))

