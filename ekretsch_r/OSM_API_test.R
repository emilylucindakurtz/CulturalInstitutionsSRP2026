library(osmdata)
library(sf)
library(tidyverse)

my_bbox <- opq(getbb("United States"))
