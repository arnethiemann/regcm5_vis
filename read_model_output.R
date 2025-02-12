library(tidyverse)
library(ncdf4)
library(terra)

# function for extracting a netcdf variable into a raster stack
ncdfVar2raster <- function(file, variable, prefix = "regcm5_"){
  # open
  nc_data <- nc_open(file, write = F)
  
  # extract data
  var_arr <- ncvar_get(nc_data, variable)
  
  # get NA value
  fill_value <- ncatt_get(nc_data, variable, "_FillValue")
  
  # assign extent
  lon <- nc_data$dim$jx$vals
  lat <- nc_data$dim$iy$vals
  nc_time <- nc_data$dim$time$vals
  
  # close
  nc_close(nc_data); rm(nc_data)
  
  # if existing, replace NA values by actual NAs
  if (fill_value$hasatt) {
    var_arr[var_arr == fill_value$value] <- NA
  }
  
  
  # change axes and flip
  flip_and_swap <- function(slice) {
    flipped <- slice[, ncol(slice):1, drop = F]  # flip horizontally
    t(flipped) # transpose
  }
  
  # apply to the stack
  dimensions <- dim(var_arr)
  var_arr <- apply(var_arr, 3, flip_and_swap)
  
  # back to array dimensions
  var_arr <- array(var_arr, dim = c(dimensions[2], dimensions[1], dimensions[3]))
  var_arr_ras <- rast(var_arr)
  
  
  # add crs to raster
  terra::crs(var_arr_ras) <- "+proj=lcc +lon_0=-54 +lat_1=22 +lat_2=26"
  
  # calculate raster extent
  dLat <- abs(lat[2] - lat[1]) / 2
  dLon <- abs(lon[2] - lon[1]) / 2
  
  xmin <- min(lon) - dLon
  xmax <- max(lon) + dLon
  ymin <- min(lat) - dLat
  ymax <- max(lat) + dLat
  
  # assign raster extent
  ext(var_arr_ras) <- c(xmin, xmax, ymin, ymax)
  
  # add time to rasters
  nc_time <- as.POSIXct(nc_time * 3600, origin = "1949-12-01", tz = "UTC")
  
  names(var_arr_ras) <- paste("Date:", strftime(nc_time, format = "%Y-%m-%d %H:%M"))

  # assign raster stack to global environment
  assign(
    x = paste0(prefix, variable),
    value = var_arr_ras,
    envir = globalenv()
  )
}


# apply function over all variables of interest

mapply(
  ncdfVar2raster,
  file = "../output_10/ERA5_SRF.2024041100.nc",
  variable = c(
    "tas",         # temperature at 2m height            Kelvin
    "ts",          # surface temperature                 Kelvin
    "pr",          # precipitation                       kg m-2 s-1 = mm/second
    "evspsbl",     # evaporation
    "prc",         # convective precipitation
    "mrros",       # surface runoff
    "mrro",        # total runoff
    "clt",         # total cloud fraction
    "sfcWind",     # near-surface wind speed
    "psl",         # sea-level pressure
    "huss",        # near-surface specific humidity
    "hurs"         # near-surface relative humidity
  )
)
