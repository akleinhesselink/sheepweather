rm(list = ls())

library( tidyverse )
library(lubridate)

# input ---------------------------------------------------- #

df <- readRDS('temp_data/decagon_data.RDS')

check <- read_csv('data-raw/check_dates_modified.csv')

season <- read_csv('data-raw/season_table.csv')
tod <- read_csv('data-raw/tod_table.csv')

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

df$f <- as.character(df$f)

df <- left_join(df, check , by =c( 'f', 'new_date', 'reading' )) # join changes to main df

df <-
  df %>%
  ungroup () %>%
  group_by(f, plot, port, measure ) %>%
  arrange( reading ) %>%
  mutate( hours_skipped = ifelse( row_number() == 1 & is.na(change), 0, hours_skipped ))

out <- df %>%  do ( fill_in_hours_skipped(. ) ) # apply fill in hours function to all measurement groups

# actually make the date changes here ----------------------------------------------------------------------------------

out <-
  out %>%
  mutate( new_date = new_date - 60*60*hours_skipped)

# ----------------------------------------------------------------------------------------------------------------------
out <-
  out %>%
  mutate ( good_date = ifelse ( new_date >= date_started - 60*60*48 & new_date <= date_uploaded + 60*60*48 , 1, 0))

# check earliest and latest dates -----------------------------------------------------------------

out %>%
  ungroup( ) %>%
  summarise ( max( new_date ), min( new_date ), which.min(new_date ), which.max(new_date ))

# ----------------------------------------------------------------------------

out <-
  out %>%
  ungroup() %>%
  mutate( simple_date = date(new_date),
          hour = hour( new_date ),
          year = year( new_date ),
          month = month( new_date ))

out <- out %>% left_join( season, by = 'month')
out <- out %>% left_join( tod, by = 'hour')

saveRDS( out , outfile)
