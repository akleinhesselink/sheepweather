rm(list = ls()) 

library( tidyverse ) 

# input ---------------------------------------------------- # 

load('temp_data/temp_check_decagon_dates.rda')

check <- read_csv('data-raw/check_dates_modified.csv')

# output ---------------------------------------------------- # 

outfile <- 'temp_data/decagon_data_corrected_dates.RDS'

#  ---------------------------------------------------- # 

fill_in_hours_skipped <- function( x ) { 
  
  hs = 0 
  
  for( i in 1:nrow(x)) {
    
    if (is.na( x$change[i] )) {
      
      x$hours_skipped[i] <- hs
      
    }else if(x$change[i] == 1 ){
      
      print(paste('old hs', hs ))
      
      hs <- x$hours_skipped[i] <- x$hours_skipped[i] + hs
      
      print(paste('new hs', hs))
      
    }else if(x$change[i] == 0 ){
      
      hs <- x$hours_skipped[i] <- 0 } 
  }
  
  return( x )
}


# determined for each jump whether it should be corrected or remain in place 
# change = 1  indicates jumps that should be changed 
# make changes on the csv file above 

check$new_date <- as.POSIXct ( as.character( check$new_date ) , format = '%Y-%m-%d %H:%M:%S', tz = 'MST' ) 

df %>% 
  filter( reading == 76) %>% 
  select( date, new_date, Time, plot )  %>% 
  distinct()

df <- left_join(df, check , by =c( 'f', 'new_date', 'reading' )) # join changes to main df 

df <- df %>% 
  ungroup () %>% 
  group_by(f, plot, port, measure ) %>% 
  arrange( reading ) %>% 
  mutate( hours_skipped = ifelse( row_number() == 1 & is.na(change), 0, hours_skipped ))

out <- df %>%  do ( fill_in_hours_skipped(. ) ) # apply fill in hours function to all measurement groups 

# actually make the date changes here ----------------------------------------------------------------------------------

out <- out %>% 
  mutate( new_date = as.POSIXct(new_date - 60*60*hours_skipped, origin = '1970-01-01 00:00:00', tz = 'MST'))

# ----------------------------------------------------------------------------------------------------------------------
out <- out %>% 
  mutate ( good_date = ifelse ( new_date >= date_started - 60*60*48 & new_date <= date_uploaded + 60*60*48 , 1, 0))

# check earliest and latest dates -----------------------------------------------------------------

out %>% 
  ungroup( ) %>% 
  summarise ( max( new_date ), min( new_date ), which.min(new_date ), which.max(new_date ))

# ---------------------------------------------------------------------------- 

out <- 
  out %>% 
  ungroup() %>%
  mutate( simple_date = as.Date(new_date, tz = 'MST'), 
          hour = strftime( new_date, '%H', tz = 'MST'), 
          year = strftime( new_date, '%Y', tz = 'MST'), 
          month = strftime( new_date, '%m', tz = 'MST'))

out$month <- as.numeric( out$month)
out$hour <- as.numeric( out$hour)

out <- merge( out, season, by = 'month')
out <- merge( out, tod, by = 'hour')

saveRDS( out , outfile)
