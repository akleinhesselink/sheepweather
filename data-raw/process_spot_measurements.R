##### Spring 2015 soil moisture
##### 

rm(list = ls())
library(tidyverse)

# input ---------------------------------------------------- # 

q_info <-read.csv('data-raw/quad_info.csv')

p1 <- read.csv('data-raw/spot_measures/2012-06-06_spot_measurements.csv', skip = 3)
p2 <- read.csv('data-raw/spot_measures/2015-04-29_spot_measurements.csv', skip = 2)
p3 <- read.csv('data-raw/spot_measures/2015-05-07_spot_measurements.csv')
p4 <- read.csv('data-raw/spot_measures/2016-05-10_spot_measurements.csv')
p5 <- read.csv('data-raw/spot_measures/2015-06-09_spot_measurements.csv')

# output ---------------------------------------------------- # 

outfile <- 'temp_data/spring_spot_measurements.RDS'

# ---------------------------------------------------- # 


p1$date <- '2012-06-06'
p1$Plot <- gsub( p1$Plot, pattern = '-', replacement = '_')
p1$rep <- c(1:2)
p1 <- p1 %>% rename( plot = Plot )
p2$date <- '2015-04-29'

df <- rbind( p2, p3, p4, p5)

df <- df %>% gather( key = rep, PCT, E1:W3 )

df <- rbind( p1, df )

q_info$plot <- gsub( q_info$QuadName, pattern = 'X', replacement = '')

df <- merge (df, q_info , by = 'plot')

df$date <- as.POSIXct(df$date, tz = 'MST')
df <- df %>% rename(VWC = PCT)

# test that it matches old data 
old_df <- readRDS('data/spring_spot_measurements.RDS')


old_df <- old_df %>% 
  arrange( plot, date , rep, QuadName, quad, Grazing, paddock, Group, Treatment, PrecipGroup) %>% 
  mutate( QuadName = as.character(QuadName))

df <- df %>% 
  arrange( plot, date , rep, QuadName, quad, Grazing, paddock, Group, Treatment, PrecipGroup) %>% 
  mutate( QuadName = as.character(QuadName))

identical(df, old_df)

all.equal(df, old_df)
# ------------------------------------------------------------ # 

saveRDS(df, outfile )

