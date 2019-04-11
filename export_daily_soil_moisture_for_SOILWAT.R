# clean soil moisture data 

rm(list = ls () )
library(tidyverse)

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
  ungroup() %>% 
  filter( measure == 'VWC', 
          stat == 'raw', 
          bad_values == 0, 
          Treatment == 'Control') %>% 
  mutate( depth = str_extract( depth, pattern = '[0-9]+' )) %>% 
  select(Treatment, plot, port, position, depth, new_date, v)

port_labels <- data.frame( position = rev( unique( soil_export$position) ), 
                           SMS_label = paste0('VWC_L', 1:4), `depth (cm)` = c(5,5, 25,25 ) )

sms_labels <- data.frame(Label = c('USSES_11_12_C', 'USSES_1_2_C', 'USSES_15_16_C', 'USSES_7_8_C'), 
                         SCANInstallation_Number = 1 , 
                         SMS_Number = 2, SMS1 = NA, SMS2 = NA, SMS3 = NA, SMS4 = NA )

temp <- 
  soil_export %>% 
  left_join(port_labels, by = 'position') %>% 
  ungroup() 

temp <- 
  temp %>% 
  select( plot, Treatment, new_date, v, SMS_label ) 

temp_avg <- 
  temp %>% 
  mutate( old_date = new_date) %>%
  mutate( date = as.Date( old_date, '%Y-%m-%d', tz = 'MST'), 
          DOY  = strftime( old_date, '%j'), 
          year = strftime( old_date , '%Y') ) %>% 
  group_by( plot, date, Treatment, year, DOY, SMS_label) %>% 
  summarise( VWC = mean(v, na.rm = TRUE), n = n()) %>% 
  ungroup() %>%
  spread(  SMS_label, VWC) %>% 
  rename( Date = date) 

all_dates <- 
  data.frame( date = seq.POSIXt(strptime( '2012-01-01', '%Y-%m-%d', tz = 'MST'), 
                                strptime( '2016-12-31', '%Y-%m-%d', tz = 'MST'), by = 24*3600) )

all_dates <- 
  expand.grid( plot = unique( temp_avg$plot), 
                          Date = as.Date( all_dates$date, tz = 'MST'))

temp_avg <- 
  left_join(all_dates, temp_avg , by = c('plot', 'Date')) %>% 
  mutate( doy = as.numeric( strftime( Date, '%j', 'MST') ))

out_list <- 
  temp_avg %>% 
  dplyr::select(plot, Date, doy, starts_with( 'VWC')) 

out_list <- split( out_list, out_list$plot )

for( i in 1:length(out_list) ) { 
  fname <- paste0("USSES_", names(out_list)[i], output_extension)
  write.csv(out_list[[i]], file.path(output_dir, fname), row.names = FALSE )
}

write.csv( sms_labels, sms_label_file, row.names = FALSE)
write.table( port_labels, port_info_file, sep = ',', row.names = FALSE)

