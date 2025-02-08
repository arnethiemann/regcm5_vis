# regcm5_vis
Visualizations for RegCM5 model outputs

## `read_nc.R`
Reads the model output. This works only with the `ncdf4` package and not using `terra` alone, as the output file doesn't follow the netcdf conventions. The script also transposes and horizontally flips the output.

## `model_validation.R`
Aims to validate the model output with observational data, here GPCC and GHCN.

GPCC (Deutscher Wetterdienst, 2022): https://opendata.dwd.de/climate_environment/GPCC/html/download_gate.html

GHCN (NOAA National Centers for Environmental Information (NCEI), 2021): https://www.ncei.noaa.gov/products/land-based-station/global-historical-climatology-network-daily


