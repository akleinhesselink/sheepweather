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
soil_export <-
  soil %>%
  rename( 'date' = simple_date) %>%
  ungroup() %>%
  filter( measure == 'VWC',
          stat == 'raw',
          Treatment == 'Control') %>%
  mutate( depth = str_extract( depth, pattern = '[0-9]+' )) %>%
  select(date, plot, position, depth,  v)

port_labels <- data.frame( position = rev( unique( soil_export$position) ),
                           SMS_label = paste0('VWC_L', 1:4), `depth (cm)` = c(5,5, 25,25 ) )

sms_labels <- data.frame(Label = c('USSES_11_12_C', 'USSES_1_2_C', 'USSES_15_16_C', 'USSES_7_8_C'),
                         SCANInstallation_Number = 1 ,
                         SMS_Number = 2, SMS1 = NA, SMS2 = NA, SMS3 = NA, SMS4 = NA )

temp_avg <-
  soil_export %>%
  left_join(port_labels, by = 'position') %>%
  ungroup() %>%
  select( plot, date, SMS_label, v) %>%
  group_by( date, plot, SMS_label) %>%
  summarise( VWC = mean(v, na.rm = TRUE), n = n()) %>%
  ungroup() %>%
  spread(  SMS_label, VWC)

all_dates <- expand.grid( date = seq( ymd( '2012-01-01'), ymd('2016-12-31'), by = 1),
             plot = unique(temp_avg$plot))

out_list <-
  all_dates %>%
  left_join(temp_avg , by = c('plot', 'date')) %>%
  mutate( YEAR = year(date), DOY = yday(date)) %>%
  select(plot, date, YEAR, DOY, starts_with('VWC'))

out_list <- split( out_list, out_list$plot )

for( i in 1:length(out_list) ) {
  fname <- paste0("USSES_", names(out_list)[i], output_extension)
  write.csv(out_list[[i]], file.path(output_dir, fname), row.names = FALSE )
}

write.csv( sms_labels, sms_label_file, row.names = FALSE)
write.table( port_labels, port_info_file, sep = ',', row.names = FALSE)

