
# Topo indices

library(raster)
library(sf)
library(tidyverse)

library(Rsagacmd, lib.loc = "/projappl/project_2003061/Rpackages/")

saga_version("saga_cmd")
saga <- saga_gis(cores = future::availableCores())

dem <- raster("output/dem.tif")/100

dem <- saga$ta_preprocessor$fill_sinks_xxl_wang_liu(elev = dem)
swi <- saga$ta_hydrology$saga_wetness_index(dem = dem)

plot(swi$twi)

writeRaster(swi$twi, "output/swi.tif", format = "GTiff")

# Radiation

dem <- raster("output/dem.tif")/100
dem <- aggregate(dem, 5)

svi <- saga$ta_lighting$sky_view_factor(dem = dem, radius = 500)
plot(svi$svf)

rad <- saga$ta_lighting$potential_incoming_solar_radiation(grd_dem = dem,
                                                           grd_svf = svi$svf,
                                                           latitude = st_bbox(dem) %>% st_as_sfc() %>% 
                                                             st_centroid() %>% st_transform(crs = 4326) %>% 
                                                             st_coordinates() %>% as.data.frame() %>% pull(Y),
                                                           period = 2,
                                                           day = "2020-01-01",
                                                           day_stop = "2020-12-31",
                                                           days_step = 15,
                                                           hour_step = 2)

rad$grd_total[rad$grd_total == 0] <- NA
plot(rad$grd_total)

writeRaster(rad$grd_total, "output/pisr.tif", format = "GTiff")


# TPI

dem <- raster("output/dem.tif")/100

tpi <- saga$ta_morphometry$topographic_position_index_tpi(dem = dem)
plot(tpi)

writeRaster(tpi, "output/tpi.tif", format = "GTiff")

# Dist to forest

cc <- raster("output/VMI_latvuspeitto.tif")
plot(cc)
cc[cc < 10] <- NA
cc[cc >= 10] <- 1
cc <- saga$grid_tools$proximity_grid(cc)
plot(cc$distance)
cc$distance[cc$distance >= 100] <- 100

writeRaster(round(cc$distance), "output/dist_forest.tif", format = "GTiff")

