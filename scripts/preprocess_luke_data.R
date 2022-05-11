library(terra)
library(tidyverse)
library(sf)

aoi <- st_read("output/aoi.gpkg")

tifs <- list.files("/appl/data/geo/luke/vmi/2019", pattern = "img$", full.names = T)
vars <- c("/ika_vmi1x",
          "/keskipituus_vmi1x",
          "/latvuspeitto_vmi1x",
          "/lehtip_latvuspeitto_vmi1x",
          "/tilavuus_vmi1x")


roi_t <- st_as_sf(st_as_sfc(st_bbox(aoi)+c(-2000,-2000,2000,2000)))

for(var in vars){
  r <- rast(tifs[grepl(var, tifs)])
  
  r <- crop(r, roi_t)
  r[r > 32765] <- NA
  
  var_name <- gsub("_vmi1x_1519.img", "", tail(str_split(tifs[grepl(var, tifs)], "/")[[1]], 1))
  
  plot(r, main = var_name)
  
  writeRaster(r, paste0("output/VMI_",var_name,".tif"),
              datatype = ifelse(max(values(r), na.rm = T) < 256, "INT1U", "INT2S"),
              filetype = "GTiff", overwrite = T)
  
}

havu <- rast("output/VMI_latvuspeitto.tif") - rast("output/VMI_lehtip_latvuspeitto.tif")
havu[havu < 0] <- 0
writeRaster(havu, paste0("output/canopy_cover_conif.tif"),
            filetype = "GTiff", datatype = "INT1U", overwrite = T)

havu <- havu/rast("output/VMI_latvuspeitto.tif")*100
havu[havu < 0] <- 0
havu[rast("output/VMI_latvuspeitto.tif") == 0] <- 0
writeRaster(havu, paste0("output/canopy_portion_conif.tif"),
            filetype = "GTiff", datatype = "INT1U", overwrite = T)

havu <- 100-havu
havu[rast("output/VMI_latvuspeitto.tif") == 0] <- 0
writeRaster(havu, paste0("output/canopy_portion_decid.tif"),
            filetype = "GTiff", datatype = "INT1U", overwrite = T)

unlink(list.files(tempdir(), full.names = T, recursive = T))
