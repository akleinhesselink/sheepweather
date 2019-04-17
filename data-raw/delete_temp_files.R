rm(list = ls())

temp_files <- dir('temp_data', recursive = T, full.names = T)

file.remove(temp_files)
