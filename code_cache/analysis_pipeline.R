############################################################# 
#
# NOTE: Running all the K-fold cross validation takes days 
#
#############################################################

rm(list = ls() ) 

library(tidyverse)
library(zoo)
library(texreg)
library(xtable)
library(gridExtra)
library(MASS)
library(lsmeans)
library(lme4)

# run data preparation files first --------------------------- # 

source('save_plot_theme.R')

source('code/prepare_data/prepare_data_for_STAN.R')

# analysis pipeline ------------------------------------------ # 

# 1. Soil moisture analysis 

