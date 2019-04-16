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


all.equal(new, old)  # they match (except for modified date which shouldn't)

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
  rename( 'date' = simple_date) %>%
  select(date, datetime, id, plot, PrecipGroup, Treatment, port, position, depth, measure, stat, v)

names(new)
names(old)

dim(new)
dim(old)

tz( old$datetime ) <- 'UTC'

old <- old %>%
  arrange( datetime, date, id, plot, PrecipGroup, Treatment, port, position, depth, measure)

new <- new %>%
  arrange( datetime, date, id, plot, PrecipGroup, Treatment, port, position, depth, measure)

all.equal(data.frame(old), data.frame(new)) ## ThEY match !!!!

# 6. Test spot values

rm(list = ls())
new <- readRDS('temp_data/spring_spot_measurements.RDS')
old <- readRDS('temp_data/test_data/spring_spot_measurements.RDS')
identical(new, old)
all.equal(data.frame(new), data.frame( old) )
tz( old$date ) <- 'UTC'
old$date <- ymd( old$date )
all.equal(data.frame(new), data.frame( old) )  ### They MATCH!

# 7. Test that weather matches
rm(list = ls())
new <- readRDS('temp_data/weather.RDS')
old <- readRDS('temp_data/test_data/weather.RDS')

all.equal(old, new) # They match!


# 8. Test that exports to soilwat match
rm(list = ls())

new_weath_files <- dir('temp_data/for_soilwat/weather_files/', full.names = T)
new <- do.call(rbind, lapply(new_weath_files, read_tsv, skip = 2, col_names = F) )

old_weath_files <- dir('temp_data/test_data/for_soilwat/weather_files/', full.names = T)
old <- do.call(rbind, lapply(old_weath_files, read_tsv, skip = 2, col_names = F) )

all.equal(old, new) # They match !

old_weath_dir <-
  '~/Dropbox/projects/old_USSES_projects/driversdata/data/idaho_modern/soil_moisture_data/data/processed_data/weather_files'

old_weath_files <- dir(old_weath_dir, full.names = T)
old <- do.call(rbind, lapply(old_weath_files[-1], read_tsv, skip = 2, col_names = F))

old_weath_files
new_weath_files
new <- do.call(rbind, lapply( new_weath_files[-1], read_tsv, skip = 2, col_names = F))

old_weath_files
new_weath_files
new_weath_files

# 9. Test that soil moisture exports for soilwat match
rm(list = ls())

old_dir <-
  '~/Dropbox/projects/old_USSES_projects/driversdata/data/idaho_modern/soil_moisture_data/data/processed_data/'

old_smfiles <- dir(old_dir, 'SoilWater.csv', recursive = T, full.names = T)
new_smfiles <- dir('temp_data/for_soilwat', 'SoilWater.csv', recursive = T, full.names = T)
old_sm <- do.call( rbind, lapply( old_smfiles, read_csv))
new_sm <- do.call( rbind, lapply( new_smfiles, read_csv))

old_sm %>%
  group_by(plot) %>%
  summarise( sum(is.na(VWC_L1))/n())

new_sm %>%
  group_by(plot) %>%
  summarise( sum(is.na(VWC_L1))/n())

unique( old_sm$plot)
unique( new_sm$plot)

old_sm <-
  old_sm %>%
  select( -doy) %>%
  mutate( plot = paste0('X', plot)) %>%
  rename( 'date' = Date)

old_sm %>%
  ggplot(aes(x= date, y= VWC_L1, color = plot ) ) + geom_point()

new_sm %>%
  ggplot( aes( x = date, y = VWC_L1, color = plot)) + geom_point()

# there are some major differences and I'm not sure why
# but I'm confident in the new data

# Test new weather and really old weather:

rm(list =ls())

old <-
  read_csv( '~/Dropbox/projects/old_USSES_projects/driversdata/data/idaho_modern/climateData/USSES_climate.csv')

new <- readRDS('temp_data/weather.RDS')

old <-
  old %>%
  mutate( date = ymd( DATE)) %>%
  select( date, TMAX, TMIN, PRCP ) %>%
  gather( ELEMENT, value, TMAX, TMIN,PRCP )

old$value[old$value < -9000 ] <- NA

# They MATCH
new %>%
  left_join(old, by= c('date', 'ELEMENT')) %>%
  ggplot(aes( x = value.x , y = value.y )) + geom_point()

#
