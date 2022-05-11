
library(sf)
library(tidyverse)

aoi <- st_read("output/aoi.gpkg")

list.files("/appl/data/geo/mml/maastotietokanta/2022/gpkg", full.names = T)
st_layers("/appl/data/geo/mml/maastotietokanta/2022/gpkg/MTK-muut_22-03-03.gpkg")

p <- bind_rows(read_sf("/appl/data/geo/mml/maastotietokanta/2022/gpkg/MTK-muut_22-03-03.gpkg", "kansallispuisto"),
               read_sf("/appl/data/geo/mml/maastotietokanta/2022/gpkg/MTK-muut_22-03-03.gpkg", "luonnonpuisto"),
               read_sf("/appl/data/geo/mml/maastotietokanta/2022/gpkg/MTK-muut_22-03-03.gpkg", "luonnonsuojelualue"))

nature_reserves <- st_crop(p, aoi)

plot(st_geometry(nature_reserves))

st_write(nature_reserves, "output/nature_reserves.gpkg")

# Roads

st_layers("/appl/data/geo/mml/maastotietokanta/2022/gpkg/MTK-tie_22-03-03.gpkg")

p <- read_sf("/appl/data/geo/mml/maastotietokanta/2022/gpkg/MTK-tie_22-03-03.gpkg", "tieviiva")

roads <- st_crop(p, aoi)

plot(st_geometry(roads))

st_write(roads, "output/roads.gpkg")

# buildings

st_layers("/appl/data/geo/mml/maastotietokanta/2022/gpkg/MTK-rakennus_22-03-03.gpkg")

p <- read_sf("/appl/data/geo/mml/maastotietokanta/2022/gpkg/MTK-rakennus_22-03-03.gpkg", "rakennus")

buildings <- st_crop(p, aoi)

plot(st_geometry(buildings))

st_write(buildings, "output/buildings.gpkg")



