library(terra)
library(sf)
library(tidyverse)

latest <- st_read("/appl/data/geo/mml/dem2m/2008_latest/dem2m.shp")

aoi <- st_read("output/aoi.gpkg") %>% 
  st_transform(crs = st_crs(latest))

latest_t <- latest[aoi,]

# Merge files

f <- latest_t$path

rast.list <- list()
for(ii in 1:length(f)) { rast.list[ii] <- rast(f[ii]) }

rast.list <- terra::src(rast.list)
rast.mosaic <- mosaic(rast.list)

rast.mosaic <- terra::crop(rast.mosaic, aoi)

plot(rast.mosaic)

if(max(values(rast.mosaic)) < 650){
  writeRaster(round(rast.mosaic*100), paste0("output/dem.tif"),
              datatype = "INT2U", overwrite = T)
} else {
  writeRaster(round(rast.mosaic*100), paste0("output/dem.tif"),
              datatype = "INT4U", overwrite = T)
}

unlink(list.files(tempdir(), full.names = T, recursive = T))
