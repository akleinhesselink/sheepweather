rm(list = ls())
#
# Test change in timezone during processing
#
library(tidyverse)
library(lubridate)

# Test 1.  import_and_format_decagon_data
old <- readRDS('temp_data/test_data/decagon_data.RDS')
new <- readRDS('temp_data/decagon_data.RDS')

dim(new)
dim(old)

all.equal(new, old)

# modify old so it matches new
old <-
  old %>%
  select( names(new))

old$date_started <- as_datetime(old$date_started)
old$date_uploaded <- as_datetime(old$date_uploaded)

all.equal(new, old)
old$plot <- paste0( 'X', as.character( old$plot ))
all.equal(new, old)

# arrange each the same way
old <- old %>% arrange(plot, period, port, id, date, measure, type, position, depth )
new <- new %>% arrange(plot, period, port, id, date, measure, type, position, depth )
all.equal(new, old)

tz( old$date ) <- 'UTC'
tz( old$new_date) <- 'UTC'
tz( old$modified_date) <- ''
tz( old$date_started) <- 'UTC'
tz( old$date_uploaded ) <- 'UTC'

all.equal(new, old)

old$f <- str_extract( as.character(old$f), '[^/]+/[^/]+$') # just use final folders in name
old$f <- factor(old$f)

all.equal(new, old)

old <-
  old %>%
  ungroup() %>%
  arrange(plot, period, port, id, Time, date, measure, date_started, date_uploaded,
          tail, hours, type, new_date, quad, Grazing, paddock, Group,
          Treatment, PrecipGroup, position, depth )

new <-
  new %>%
  ungroup() %>%
  arrange(plot, period, port, id, Time, date, measure, date_started, date_uploaded,
          tail, hours, type, new_date, quad, Grazing, paddock, Group,
          Treatment, PrecipGroup, position, depth )

all.equal(old, new)

all.equal( old %>% arrange(reading) ,
           new %>% arrange(reading))  # values match when sorted by reading

# Test 2.  check_dates out  ----------------------------------------------- #
rm(list = ls())

new <- read.csv('temp_data/check_dates.csv')
old <- read.csv('temp_data/test_data/check_dates.csv')

dim(new)
dim(old)
all.equal(new, old )

old$f <- str_extract( as.character(old$f), '[^/]+/[^/]+$') # just use final folders in name

all.equal(old, new)

# Test 3. check_dates_modified --------------------------------------------- #
rm(list = ls())

new <- read_csv('data-raw/check_dates_modified.csv')
old <- read_csv('temp_data/test_data/check_dates_modified.csv')

all.equal(old, new)

old$f <- str_extract( as.character(old$f), '[^/]+/[^/]+$') # just use final folders in name

all.equal(old, new) # They match!

# Test 4 check correct_decagon_dates
rm(list = ls())
new <- readRDS('temp_data/decagon_data_corrected_dates.RDS')
old <- readRDS('temp_data/test_data/decagon_data_corrected_dates.RDS')

dim(new)
dim(old)

old <- old %>% select(names(new))

all.equal(old, new)

tz( old$date ) <- 'UTC'
tz( old$new_date) <- 'UTC'
tz( old$modified_date) <- ''
tz( old$date_started) <- 'UTC'
tz( old$date_uploaded ) <- 'UTC'
old$plot <- paste0( 'X', as.character( old$plot ))
old$f <- str_extract( as.character(old$f), '[^/]+/[^/]+$') # just use final folders in name

season <- read_csv('data-raw/season_table.csv')
tod <- read_csv('data-raw/tod_table.csv')

old$hour <- hour(old$new_date)
old$year <- year(old$new_date)
old$month <- month(old$new_date)

names(season)

old <-
  old %>%
  select( -season, -season_label, -precip_seasons, -lag_year ) %>%
  select( -tod) %>%
  left_join( season, by = 'month') %>%
  left_join( tod, by = 'hour')

old$reading_diff <- as.numeric( old$reading_diff )
old$jump <- as.numeric(old$jump)
old$change <- as.numeric(old$change)

# arrange each the same way
old <- old %>% arrange(plot, period, port, id, new_date, measure, type, position, depth ) %>% data.frame()
new <- new %>% arrange(plot, period, port, id, new_date, measure, type, position, depth ) %>% data.frame()

all.equal(new, old)  # they match !

# 5. Test correct_readings
rm(list = ls())

new <- readRDS('temp_data/decagon_data_corrected_values.RDS')
old <- readRDS('temp_data/test_data/decagon_data_corrected_values.RDS')

old$plot <- paste0( 'X', old$plot )

# apply last few lines of new code
old$stat <- factor(old$stat, label = c('rolling mean', 'rolling sd', 'raw'))
old$plot <- as.character(old$plot)
old$bad_values <- factor(old$bad_window)
old$depth <- factor(old$depth, labels = c('25 cm deep', '5 cm deep', 'air temperature'))

old <-
  old %>%
  group_by(plot, position, period, measure ) %>%
  mutate( has_vals = sum(stat == 'raw' & !is.na(v) ) > 0 ) %>%
  filter( has_vals) %>%
  ungroup() %>%
  filter( stat == 'raw',
          bad_values == 0,
          good_date == 1,
          !is.na(v)) %>%
  rename( 'datetime' = new_date) %>%
  select(simple_date, datetime, id, plot, PrecipGroup, Treatment, port, position, depth, measure, stat, v)

names(new)
names(old)

dim(new)
dim(old)

tz( old$datetime ) <- 'UTC'

old <- old %>%
  arrange( datetime, simple_date, id, plot, PrecipGroup, Treatment, port, position, depth, measure)

new <- new %>%
  arrange( datetime, simple_date, id, plot, PrecipGroup, Treatment, port, position, depth, measure)

all.equal(data.frame(old), data.frame(new)) ## ThEY match !!!!

# test 6


load('data/usses_spot_sm.rda')
old_data <- readRDS('temp_data/test_data/usses_spot.RDS')

identical(usses_spot_sm, old_data)

# Test 3
load('data/usses_weather.rda')
old_data <- readRDS('temp_data/test_data/usses_weather.RDS')

identical(usses_weather, old_data)


# 6. Test spot values

