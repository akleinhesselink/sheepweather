% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/data.R
\docType{data}
\name{usses_decagon}
\alias{usses_decagon}
\title{Daily soil moisture data from the US Sheep Experiment Station}
\format{A data frame with 1022240 rows and 12 variables:
\describe{
  \item{date}{Date in \%Y-\%m-\%d format}
  \item{datetime}{POSIXct datetime in \%Y-\%m-\%d \%H:\%M:\%s local time}
  \item{id}{decagon datalogger id}
  \item{plot}{unique plot id, matches QuadName in quad_info }
  \item{PrecipGroup}{plot group, each plot group contains drought, irrigation and ambient plots}
  \item{Treatment}{Treatment level Irrigation, Drought, Control}
  \item{port}{port used for the probe in the logger }
  \item{position}{position of decagon probe, number gives the depth and "W" or "E" indicates side of plot where probe was installed}
  \item{depth}{soil depth of decagon probe}
  \item{measure}{variable type, C (temperature in degree C), volumetric water content (VWC)}
  \item{stat}{factor giving type, all should be raw values }
  \item{v}{measured value, depends on measurement type above }
}}
\usage{
usses_decagon
}
\description{
A dataset containing the average soil moisture in 12 study plots
at the US Sheep Experiment Station.  Each plot received either
ambient precipitation, a 50% increase in precipitation, or a 50%
decrease in precipitation. Monitored between 2012 and 2016.
}
\keyword{datasets}
