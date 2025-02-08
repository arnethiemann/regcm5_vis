library(tidyverse)
library(readr)
library(terra)

#---- airport point time series ----
#test <- read_csv("../observation_data/ghcn/AE000041196.csv")


#---- GPCC data ----
gpcc <- rast(
  "../observation_data/gpcc_first_guess_daily/first_guess_daily_202404.nc",
  subds = "p"
)


