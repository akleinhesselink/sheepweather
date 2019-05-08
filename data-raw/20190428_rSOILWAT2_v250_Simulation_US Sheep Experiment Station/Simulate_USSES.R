################################################################################
#
#------ Simulate soil moisture with SOILWAT2 for a site at the
#       US Sheep Experiment Station for Andy Kleinhesselink
#
################################################################################


# last update: 2019-05-08 by Daniel Schlaepfer, danielrschlaepfer@gmail.com


#--- Load rSOILWAT2 v2.5.0
has_rSOILWAT2 <- requireNamespace("rSOILWAT2",
  versionCheck = list(op = ">=", version = "2.5.0"))

if (!has_rSOILWAT2) {
  warning("We currently need a rSOILWAT2-devel for the weather generator...")
  # Install from github
  system2(command = "git", args = paste("clone -b v2.5.0 --single-branch",
    "--recursive https://github.com/DrylandEcology/rSOILWAT2.git rSOILWAT2"))
  tools::Rcmd(args = paste("INSTALL rSOILWAT2"))
}

library("rSOILWAT2")


#--- Set up work space
dir_prj <- if (requireNamespace("here")) here::here() else normalizePath(".")

dir_rsw <- file.path(dir_prj, "rSOILWAT2_USSES")
dir.create(dir_rsw, recursive = TRUE, showWarnings = FALSE)
dir_rsw_csv <- file.path(dir_rsw, "Output_csv")
dir.create(dir_rsw_csv, recursive = TRUE, showWarnings = FALSE)


#-------------------------------------------------------------------------------
#------ Prepare inputs

# USSES Headquarters: 19 Office Loop, Dubois, ID 83423
#   112 deg_W 12' 00.88'' / 44 deg_N 14' 38.79'' / 1672 m asl
#   -112.2002 / 44.24411

#--- prepare rSOILWAT2 input object with rSFSW2 in order to put all together:
# estimate vegetation cover, biomass density, rooting distributions,
# bare-soil evaporation coefficients, etc.
source(file.path(dir_prj, "rSFSW2_USSES", "SFSW2_project_code.R"))

# Copy inputs into dedicated folder
env_in <- new.env()
load(file.path(dir_prj, "rSFSW2_USSES", "3_Runs",
  "1_DefaultSettings_USSES", "sw_input.RData"), envir = env_in)

saveRDS(env_in[["swRunScenariosData"]][[1]],
  file = file.path(dir_rsw, "sw_input_USSES.rds"))
rm(env_in)

sw_in <- readRDS(file.path(dir_rsw, "sw_input_USSES.rds"))


# Read forcing weather data from files on disk
sw_weath <- getWeatherData_folders(
  LookupWeatherFolder = file.path(dir_prj, "rSFSW2_USSES", "1_Input",
    "treatments", "LookupWeatherFolder"),
  weatherDirName = "USSES_weather_files", filebasename = "weath",
  startYear = 1925, endYear = 2016)

sw_weath_df <- dbW_weatherData_to_dataframe(sw_weath)

# --> 486 missing values --> turn on weather generator
swWeather_UseMarkov(sw_in) <- TRUE

# recode missing values to be consistent with rSOILWAT2/SOILWAT2
sw_weath <- lapply(sw_weath, function(x) {
  temp <- slot(x, "data")
  temp[temp == -9999] <- NA
  slot(x, "data") <- temp
  x
})

# Check that weather data are well-behaved
clim <- calc_SiteClimate(weatherList = sw_weath)


# calculate weather generator inputs
res <- dbW_estimate_WGen_coefs(sw_weath, na.rm = TRUE)
swMarkov_Conv(sw_in) <- res[["mkv_woy"]]
swMarkov_Prob(sw_in) <- res[["mkv_doy"]]


# ------ Simulation with data prepared beforehand and separate weather data

# Execute the simulation run
sw_out <- sw_exec(inputData = sw_in, weatherList = sw_weath, quiet = TRUE)

saveRDS(sw_out,
  file = file.path(dir_rsw, "sw_output_USSES.rds"))

# write daily output to csv files
vars <- c("TEMP", "PRECIP", "SOILINFILT", "VWCBULK", "VWCMATRIC",
  "SWCBULK", "SWPMATRIC", "SURFACEWATER", "TRANSP", "EVAPSOIL", "EVAPSURFACE",
  "INTERCEPTION", "LYRDRAIN", "HYDRED", "AET", "PET", "SNOWPACK", "DEEPSWC",
  "SOILTEMP", "CO2EFFECTS")

for (var in vars) {
  write.csv(slot(slot(sw_out, var), "Day"), row.names = FALSE,
    file = file.path(dir_rsw_csv, paste0("USSES_Output_", var, ".csv")))
}
