#' ----
#' title: " A script for mapping the Bronze Age Index transcriptions"
#' author: "Daniel Pett"
#' date: "24/11/2016"
#' output: csv_document
#' 
#' This has been tested on OSX El Capitan with R 3.2.2
#' ----
list.of.packages <- c(
  "maptools", "rgdal", "geojsonio", "maps", "sp"
)

# Install packages if not already available
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)
# Set working directory - OSX 
setwd("/Users/danielpett/Documents/research/micropasts/analysis/consBAI/") 


projects <- c(
  'DrawerA14','SpearHeadsA2', 'arrowheads','BitandBobsA15',
  'DubiousBA','drawA10', 'dirkspart2', 'ornamentsA15', 'DrawerA16',
  'bmswords', 'singleA18', 'devizes', 'flangedAxesA1', 'flangedchiselsA1',
  'drawerA1', 'ferrulesA2', 'SwordsPt1','SwordsPt2','drawerA5A6',
  'A8tools','toolsA8', 'drawA9', 'crotals', 'irishGold', 'drawB16',
  'SwordsPt3', 'drawB8', 'ForeignJewelery', 'ForeignTools', 'IrishAxesPt1',
  'irishB10', 'IrishSwords', 'ForeignUnprov', 'ForeignSickles',
  'ForeignSwordsMisc', 'ForeignWeapons', 'IrishDirks', 'IrishDaggers',
  'IrishPalstavesPt1', 'IrishPalstavesPt2', 'IrishAxesPt2', 'irishB15',
  'BitsandBobsPt1', 'BitsandBobsPt2', 'miscellaneous', 'riverThames',
  'SlideFastenerA16', 'ThamesSwords', 'arretonHoard', 'OxfordBAI',
  'selborne', 'IrishAxesB5'
)

library(maps)
for(project in projects){
  csvname <- paste0("csv/consolidated/", project, "_cons.csv")
  output <- paste0("geoJSON/", project, ".geojson")
  points <- read.csv(csvname, header=TRUE)
  points <- points[,c("taskID","imageURL","lat", "lon")] 
  geojson_write(na.omit(points), lat = 'lat', lon = 'lon', file=output)
}
