
#' Daily soil moisture data from the US Sheep Experiment Station
#'
#' A dataset containing the average soil moisture in 12 study plots
#' at the US Sheep Experiment Station.  Each plot received either
#' ambient precipitation, a 50% increase in precipitation, or a 50%
#' decrease in precipitation. Monitored between 2012 and 2016.
#'
#' @format A data frame with 1022240 rows and 12 variables:
#' \describe{
#'   \item{simple_date}{Date in \%Y-\%m-\%d format}
#'   \item{datetime}{POSIXct datetime in \%Y-\%m-\%d \%H:\%M:\%s Mountain Time}
#'   \item{id}{decagon datalogger id}
#'   \item{plot}{unique plot id, matches QuadName in quad_info }
#'   \item{PrecipGroup}{plot group, each plot group contains drought, irrigation and ambient plots}
#'   \item{Treatment}{Treatment level Irrigation, Drought, Control}
#'   \item{port}{port used for the probe in the logger }
#'   \item{position}{position of decagon probe, number gives the depth and "W" or "E" indicates side of plot where probe was installed}
#'   \item{depth}{soil depth of decagon probe}
#'   \item{measure}{variable type, C (temperature in degree C), volumetric water content (VWC)}
#'   \item{stat}{factor giving type, all should be raw values }
#'   \item{v}{probe value, depends on measurement type above }
#' }
"usses_decagon"


#' Information on USSES monitoring quadrats
#'
#' Historical and experimental 1 x 1 m quadrats
#'
#' @format A data frame with 70 rows and 7 variables:
#' \describe{
#'   \item{QuadName}{character giving full quadrat name}
#'   \item{quad}{short code for each quadrat starting with "q"}
#'   \item{Grazing}{indicator for quadrats that recieve grazing from sheep}
#'   \item{Group}{sptial group for each quadrat}
#'   \item{paddock}{large pasture where quadrats are located, may be grazed or ungrazed}
#'   \item{Treatment}{Experimental treatment. Rainfall and competition were manipulated in some quadrats}
#'   \item{PrecipGroup}{Grouping for precipitation experiment.  Experimental plots were established in groups of three.}
#' }
"usses_quads"


#' Daily soil moisture data modeled by SOILWAT
#'
#' Daily soil moisture modeled from daily weather input using
#' the SOILWAT model maintained by the Burke-Lauenrothe lab.
#' rSOILWAT2 package is available at https://github.com/DrylandEcology/rSOILWAT2
#'
#' @format A data frame with 33141 rows and 8 variables:
#' \describe{
#'   \item{Year}{year}
#'   \item{DOY}{Day of year, 1-365}
#'   \item{Lyr_1}{Estimated volumetric soil moisture in layer}
#'   \item{Lyr_2}{Estimated volumetric soil moisture in layer}
#'   \item{Lyr_3}{Estimated volumetric soil moisture in layer}
#'   \item{Lyr_4}{Estimated volumetric soil moisture in layer}
#'   \item{Lyr_5}{Estimated volumetric soil moisture in layer}
#'   \item{Lyr_6}{Estimated volumetric soil moisture in layer}
#' }
"usses_soilwat"


#' Measures of soil moisture from around experimental monitoring plots
#'
#' Soil moisture was measured using decagon probes around each of the experimental
#' plots in the spring.
#'
#' @format A data frame with 624 rows and 10 variables:
#' \describe{
#'   \item{plot}{unique plot id, matches QuadName in quad_info }
#'   \item{VWC}{Volumetric water content}
#'   \item{date}{Date in \%Y-\%m-\%d format}
#'   \item{rep}{replicate measurement of soil moisture, indicates position around the plot}
#'   \item{quad}{short code for each quadrat starting with "q"}
#'   \item{Grazing}{indicator for quadrats that recieve grazing from sheep}
#'   \item{Group}{sptial group for each quadrat}
#'   \item{paddock}{large pasture where quadrats are located, may be grazed or ungrazed}
#'   \item{Treatment}{Experimental treatment. Rainfall and competition were manipulated in some quadrats}
#'   \item{PrecipGroup}{Grouping for precipitation experiment.  Experimental plots were established in groups of three.}
#' }
"usses_spot_sm"


#' Daily weather data from the US Sheep Experiment Station
#'
#' A dataset containing the date, the daily max, min and mean
#' mean temperatures, and the total rainfall and snowfall for
#' that date. Data recorded at the US Sheep Experiment Station
#' weather station GHCND:USC00102707
#'
#' @format A data frame with 101783 rows and 3 variables:
#' \describe{
#'   \item{date}{date in \%Y-\%m-\%d format}
#'   \item{ELEMENT}{weather variable: PRCP, TMAX, TMIN}
#'   \item{value}{value of weather variable, PRCP mm, TMAX (0.1 C), TMIN (0.1 C)}
#' }
#' @source \url{https://www1.ncdc.noaa.gov/pub/data/ghcn/daily/all/USC00102707.dly}
"usses_weather"

