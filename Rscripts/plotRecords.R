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


# Read config file for project list
projects <- read.csv('admin/config.csv', sep=',')
projects <- projects$Projects

library(maps)
for(project in projects){
  csvname <- paste0("csv/consolidated/", project, "_cons.csv")
  output <- paste0("geoJSON/", project, ".geojson")
  points <- read.csv(csvname, header=TRUE)
  points <- points[,c("taskID","imageURL","lat", "lon")] 
  geojson_write(na.omit(points), lat = 'lat', lon = 'lon', file=output)
}
