rm(list = ls())

library( tidyverse )
library(lubridate)
# input ---------------------------------------------------- #

df <- readRDS(file = 'temp_data/decagon_data.RDS')
  # This comes from the import and format decagon data script

# output ---------------------------------------------------- #

check_date_file <- 'temp_data/check_dates.csv'

# correct bad dates  ------------------------------------------------------------------------------

reading_list <-
  df %>%
  ungroup () %>%
  select( f, plot, id , period, new_date, reading ) %>%
  mutate( f = factor(f)) %>%
  distinct()

table( reading_list$f, reading_list$period ) # one file per period

jumps <- reading_list %>%
  group_by(f ) %>%
  arrange( f , reading ) %>%
  mutate( time_numeric = as.numeric(new_date )) %>%
  mutate ( time_diff = c(NA, diff(time_numeric, 1 ))) %>%
  mutate( hours_skipped = time_diff/3600 - 2 ) %>%
  mutate( reading_diff = c(NA, diff(reading, 1))) %>%
  ungroup() %>%
  mutate( jump = ifelse( reading_diff == 1 & (hours_skipped != 0 ), 1, 0 )) %>%
  mutate( lead_jump = lead( jump, 1 ))

jumps %>%
  group_by ( f ) %>%
  summarise( n_jumps =  sum(jump, na.rm = T)) %>%
  filter ( n_jumps > 0  )

check <-
  jumps %>%
  select( f, new_date, reading, hours_skipped, reading_diff, jump ) %>%
  filter( jump > 0 , hours_skipped != 0 & reading_diff == 1 ) %>%
  filter( f != '2015_2/EL5739 4Nov15-1838.txt') %>%
  filter( f != '2015_2/EL5742 4Nov15-1820.txt') %>%
  filter( !( abs(hours_skipped) < 10000 & f == '2015_2/EL5743 4Nov15-1828.txt')) %>%
  filter( f != '2013_1/EM20070.txt') %>%
  filter( f != '2013_1/EM20085.txt') %>%
  filter( !(f== '2014_2/15_reordered.txt' & hours_skipped < 4 )) %>%
  arrange( new_date, f  )

#-----------------------------------------------------------------------------------------
write.csv(check,
          check_date_file,
          row.names = FALSE) # write list of changes, this is then edited by hand
