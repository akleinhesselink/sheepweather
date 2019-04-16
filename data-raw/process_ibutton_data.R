rm(list = ls())
library(tidyverse)
library(lubridate)

q_info <- read_csv('data-raw/quad_info.csv')
folders <- list.dirs('data-raw/iButton', recursive = FALSE , full.names = TRUE)

# outfile ----------------------------------------------------------- #

outfile <- 'temp_data/ibutton.RDS'

# ----------------------------------------------------------- #

data_list <- list(NA)

for( i in 1:length(folders)){  # process each folder

  record_file <- dir( folders[i] , pattern = 'record', full.names = TRUE, recursive = TRUE)

  record <- read.csv(record_file)

  datafiles <- dir(folders[i], pattern = '[2|3].*21\\.csv', full.names = TRUE) # list all data files in the folder

  header <- lapply( datafiles, readLines, 14)

  TZs <-
    lapply( header,
            function(x)
              {
              str_extract( x[ str_detect(x, "Mission Start") ] , '[A-Z]+(?= [0-9]{4})')
              })

  d <- lapply( datafiles, read.csv, skip = 14)

  names(d) <- gsub(pattern = '.csv', replacement = '', basename(datafiles))
  d <- mapply(d, TZs, FUN = function(x, tz) { x$tz <- tz; x } , SIMPLIFY = F)

  df <- do.call(rbind, d)
  df$id <- gsub( row.names(df), pattern = '\\.[0-9]+', replacement = '')

  df$datetime <- mdy_hms(df$Date.Time)

  df <- merge( df, record , by.x  = 'id', by.y  = 'ibutton')

  data_list[[i]] <- df
}

df <- do.call( rbind, data_list )  # bind the data lists from each folder

df <-
  df %>%
  filter( datetime > date(start_date) & datetime < date(end_date)) %>%
  select( id, datetime, plot, Value) %>%
  mutate( plot = paste0('X', plot))

saveRDS(df, file = outfile)

