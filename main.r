library(sf)
library(httr2)
library(crayon)
library(jsonlite)
library(tidyverse)
library(weathermetrics)


source(file = 'R/download_file.r')
source(file = 'R/subset_fips_and_coords.r')
source(file = 'R/download_daymet.r')
source(file = 'R/calculate_hdd.r')

aedg_communities_url <- "https://github.com/acep-aedg/aedg-data-pond/raw/refs/heads/main/data/final/communities.geojson"

# download AEDG communities data
download_file(
  aedg_communities_url, 
  'data/aedg', 
  overwrite = T)

# subset fips_code and coordinates from AEDG communities
subset_fips_and_coords(
  'data/aedg/communities.geojson', 
  'data/aedg/communities_coordinates.geojson')

# this takes a while
download_daymet(
  coordinates_file = 'data/aedg/debug.geojson',
  out_file = 'data/daymet/l0/debug.csv',
  base_url = 'https://daymet.ornl.gov/single-pixel/api/data',
  vars = "tmax,tmin",
  start_date = "2020-01-01",
  end_date = "2024-12-31",
  skip_header = 6  
)

calculate_hdd(
  input_data = 'data/daymet/l0/debug.csv',
  output_data = 'data/daymet/l1/debug.csv',
)
