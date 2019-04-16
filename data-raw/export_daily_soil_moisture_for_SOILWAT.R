# clean soil moisture data

rm(list = ls () )
library(tidyverse)
library(lubridate)

# input ---------------------------------------------------- #

soil <- readRDS('temp_data/decagon_data_corrected_values.RDS')
  # comes from the correct decagon readings script

# output ---------------------------------------------------- #

output_dir <- 'temp_data/for_soilwat'
output_extension <- '_SoilWater.csv'

sms_label_file <- 'temp_data/for_soilwat/FieldSensors_MappedTo_SoilWatLayers.csv'
port_info_file <- 'temp_data/for_soilwat/port_info.csv'

# ---------------------------------------------------------------------------------------

new <-
  soil %>%
  ungroup () %>%
  select( datetime, id, plot, position, measure, stat, v) %>%
  filter( stat == 'raw', measure == 'VWC') %>%
  mutate( date = date(datetime)) %>%
  group_by( date, plot, position ) %>%
  summarise( v = mean(v, na.rm = T))  %>%
  select( date, plot, position, v)

# old <- readRDS('~/Dropbox/projects/old_USSES_projects/driversdata/data/idaho_modern/soil_moisture_data/data/processed_data/decagon_data_with_station_data.RDS')
#
# old <-
#   old %>%
#   ungroup () %>%
#   select( datetime, id, plot, position, measure, stat, v) %>%
#   filter( stat == 'raw', measure == 'VWC') %>%
#   mutate( date = date(datetime)) %>%
#   group_by( date, plot, position ) %>%
#   summarise( v = mean(v, na.rm = T))  %>%
#   mutate( YEAR = year(date), DOY = yday(date)) %>%
#   select( date, YEAR, DOY, plot, position, v)
#
# old$plot <- paste0('X', old$plot)
#
# joined <-
#   old %>%
#   left_join(new, by = c('date', 'YEAR', 'DOY', 'plot', 'position'))
#
# joined %>%
#   ggplot( aes(x = v.x, y= v.y)) + geom_point()

q_info <- read_csv('data-raw/quad_info.csv')

q_info <-
  q_info %>%
  rename( 'plot' = 'QuadName') %>%
  select( plot, Treatment)

out <-
  new %>%
  left_join(q_info, by = 'plot') %>%
  filter( Treatment == 'Control') %>%
  select(-Treatment) %>%
  spread( position, v) %>%
  select( date, plot, `5W`, `5E`, `25W`, `25E`)

port_labels <- data.frame( position = c('5W', '5E', '25W', '25E'),
                           SMS_label = paste0('VWC_L', 1:4), `depth (cm)` = c(5,5, 25,25 ) )

sms_labels <- data.frame(Label = c('USSES_X11_12_C', 'USSES_X1_2_C', 'USSES_X15_16_C', 'USSES_X7_8_C'),
                         SCANInstallation_Number = 1 ,
                         SMS_Number = 2, SMS1 = NA, SMS2 = NA, SMS3 = NA, SMS4 = NA )

all_dates <- expand.grid( date = seq( ymd( '2012-01-01'), ymd('2016-12-31'), by = 1),
             plot = unique(out$plot))

export <-
  all_dates %>%
  left_join(out, by = c('plot', 'date')) %>%
  mutate( YEAR = year(date), DOY = yday(date)) %>%
  select( plot, date, YEAR, DOY, `5W`:`25E`)  %>%
  rename( 'VWC_L1' = `5W`, 'VWC_L2' = `5E`, 'VWC_L3' = `25W`, 'VWC_L4' = `25E`)

out_list <- split( export, export$plot )

for( i in 1:length(out_list) ) {
  fname <- paste0("USSES_", names(out_list)[i], output_extension)
  write.csv(out_list[[i]], file.path(output_dir, fname), row.names = FALSE )
}

write.csv( sms_labels, sms_label_file, row.names = FALSE)
write.table( port_labels, port_info_file, sep = ',', row.names = FALSE)

