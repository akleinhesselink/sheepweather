rm(list = ls())

ibutton <- readRDS('temp_data/ibutton.RDS')
quads <- read_csv('data-raw/quad_info.csv')
seasons <- read_csv('data-raw/season_table.csv')

ibutton %>% head

test <-
  ibutton %>%
  mutate( date = date(datetime)) %>%
  group_by( date, QuadName) %>%
  summarise( tmax = max(Value, na.rm = T), tmin = min(Value,na.rm = T), n = n())  %>%
  mutate( tmean = tmax + tmin/2) %>%
  filter( n > 6 ) %>%
  gather( stat, value, tmax, tmin, tmean ) %>%
  left_join(quads, by = 'QuadName') %>%
  select( PrecipGroup, date, value, Treatment, stat, value ) %>%
  spread( Treatment, value ) %>%
  mutate( month = month(date)) %>%
  left_join(seasons %>% select( month, season), by = 'month')

test <-
  test[ complete.cases(test), ] %>%
  mutate( shelter_effect = Drought - Irrigation )

plot_shelter_effect <-  function( ib_dat) {
  ggHist <-
    ib_dat %>%
    ggplot( aes( x = shelter_effect) ) +
    geom_histogram() +
    geom_vline(aes(xintercept = 0)) +
    facet_grid(stat ~ PrecipGroup)

  avg_effect  <-
    ib_dat %>%
    group_by(PrecipGroup, stat ) %>%
    summarise( avg_effect = mean(shelter_effect))

  mygg <-
    ggHist +
    geom_vline(data = avg_effect, aes( xintercept = avg_effect), color  = 'blue',  linetype = 2)

  return(mygg)
}

plot_shelter_effect(test)
