library(ncdf4)
library(CFtime)
library(tidyverse)
library(terra)

nc_data <- nc_open("../output_10/output_map_10/ERA5_SRF.2024041100.nc", write = F)


lon <- nc_data$dim$jx$vals
lat <- nc_data$dim$iy$vals
nc_time <- nc_data$dim$time$vals

precip_arr <- ncvar_get(nc_data, "pr") # in"kg m-2 s-1" = mm/second
# max(precip_arr)

fill_value <- ncatt_get(nc_data, "pr", "_FillValue")

nc_close(nc_data)

# if prevalent, replace NA value by actual NAs
if (fill_value$hasatt) {
  precip_arr[precip_arr == fill_value$value] <- NA
}


# change axes and flip
flip_and_swap <- function(slice) {
  flipped <- slice[, ncol(slice):1, drop = F]  # flip horizontally
  t(flipped) # transpose
}

# apply on the stack
dimensions <- dim(precip_arr)
precip_arr <- apply(precip_arr, 3, flip_and_swap)

# back to array dimensions
precip_arr <- array(precip_arr, dim = c(dimensions[2], dimensions[1], dimensions[3]))
precip_arr_ras <- rast(precip_arr)


# add crs to raster
terra::crs(precip_arr_ras) <- "+proj=lcc +lon_0=-54 +lat_1=22 +lat_2=26"

# calculate raster extent
dLat <- abs(lat[2] - lat[1]) / 2
dLon <- abs(lon[2] - lon[1]) / 2

xmin <- min(lon) - dLon
xmax <- max(lon) + dLon
ymin <- min(lat) - dLat
ymax <- max(lat) + dLat

ext(precip_arr_ras) <- c(xmin, xmax, ymin, ymax)

# add time to rasters
nc_time <- as.POSIXct(nc_time * 3600, origin = "1949-12-01", tz = "UTC")

names(precip_arr_ras) <- paste("Date:", nc_time)

# create color ramp for precipitation
rain_ramp <- colorRampPalette(c("white", "darkblue"))
rain_ramp(10)


# test plot
plot(precip_arr_ras[[40:48]], col = rain_ramp(10))
