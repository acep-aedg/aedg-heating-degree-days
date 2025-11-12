library(sf)
library(httr)
library(crayon)
library(jsonlite)
library(tidyverse)


source(file = 'R/extract.r')
source(file = 'R/preprocess.r')
source(file = 'R/transform.r')

snap_hdd_url <- "http://data.snap.uaf.edu/data/Base/AK_WRF/Arctic_EDS_degree_days/heating_degree_days.zip" 
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

# pull HDD data for all AEDG communities
download_and_save_degree_days(
  coordinates_file = 'data/aedg/communities_coordinates.geojson', 
  out_file = 'data/snap/heating_degree_days.json', 
  base_url = 'https://earthmaps.io/degree_days/heating',
  start_year = '1980', 
  end_year = '2017',
  summarized = T
)

# convert json output to csv
hdd_json_to_csv(
  hdd_json = 'data/snap/heating_degree_days.json',
  out_csv = 'data/snap/heating_degree_days.csv')
  