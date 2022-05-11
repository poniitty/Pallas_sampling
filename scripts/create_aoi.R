
library(sf)
library(tidyverse)

df <- data.frame(
  lon = c(377000, 383000, 383000, 377000, 377000),
  lat = c(7540000, 7540000, 7547000, 7547000, 7540000)
)

polygon <- df %>%
  st_as_sf(coords = c("lon", "lat"), crs = 3067) %>%
  summarise(geometry = st_combine(geometry)) %>%
  st_cast("POLYGON")

plot(st_geometry(polygon))

st_write(polygon, "output/aoi.gpkg")

# Previous points

d <- read_delim("data/other_shapes/Puropisteet.csv", delim = ";")

d <- d %>% st_as_sf(coords = c("E","N"), crs = 4326)

d %>% st_write("data/other_shapes/Puropisteet.gpkg")
