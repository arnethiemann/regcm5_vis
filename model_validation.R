library(tidyverse)
library(readr)
library(terra)

#---- airport point time series ----
#test <- read_csv("../observation_data/ghcn/AE000041196.csv")


#---- GPCC data ----
gpcc <- rast(
  "../observation_data/gpcc_first_guess_daily/first_guess_daily_202404.nc",
  subds = "p" # subset: p = precipitation
)

crs(gpcc) %>% writeLines()



# import precipitation model output
source("read_model_output.R")

crs(regcm5_pr) %>% writeLines()


# create daily sums of precipitation from model output
prec_rcm_daily <- tapp(regcm5_pr, "days", fun = "mean")

# sum up precipitation to mm/day
prec_rcm_daily <- prec_rcm_daily * 86400

# crop to bbox
#uae_vec <- vect("../geodata/uae_admin.gpkg") %>% 
#  terra::project(., gpcc)

aoi <- terra::ext(48,60,19,30)
gpcc_crop <- terra::crop(gpcc, aoi, touches = T)


# project and crop model output
prec_rcm_daily_repr <- terra::resample(prec_rcm_daily, gpcc_crop, "cubic")
plot(prec_rcm_daily_repr)

dim(gpcc_crop) == dim(prec_rcm_daily_repr)



# Find overlapping dates
common_timespan <- intersect(time(prec_rcm_daily_repr), time(gpcc_crop))

