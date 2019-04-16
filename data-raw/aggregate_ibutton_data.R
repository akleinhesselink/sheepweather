rm(list = ls())

library(lubridate)
library(tidyverse)

ibutton <- readRDS('temp_data/ibutton.RDS')

ibutton <-
  ibutton %>%
  mutate( date = date(datetime)) %>%
  group_by( date, plot ) %>%
  summarise( TMAX = max(Value, na.rm = T), TMIN = min(Value,na.rm = T), n = n())  %>%
  mutate( TMEAN = (TMAX + TMIN)/2) %>%
  gather( stat, ibutton, TMAX, TMIN, TMEAN )

saveRDS(ibutton, file = 'temp_data/daily_ibutton.RDS')

