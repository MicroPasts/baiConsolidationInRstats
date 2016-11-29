#' ----
#' title: " A script for mapping the Bronze Age Index transcriptions as jpegs"
#' author: "Daniel Pett"
#' date: "26/11/2016"
#' output: jpeg
#' 
#' This has been tested on OSX El Capitan with R 3.2.2
#' ----
list.of.packages <- c(
  "maptools", "rgdal", "geojsonio", "maps", 
  "sp", "mapdata", "rworldmap", "ggmap",
  "mapproj"
)

# Install packages if not already available
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)
# Set working directory - OSX 
setwd("/Users/danielpett/Documents/research/micropasts/analysis/consBAI/") 
# Create folder for merged files
if (!file.exists('plots/jpegs/projects/')){dir.create('plots/jpegs/projects/')}
# Read config file for project list
projects <- read.csv('admin/config.csv', sep=',')
projects <- projects$Projects

library(maps)
library(ggmap)
library(mapproj)
for(project in projects){
  print(project)
  csvname <- paste0("csv/consolidated/", project, "_cons.csv")
  fileName <- paste0("plots/jpegs/projects/", project, ".jpeg")
  findspots <- read.csv(csvname, header=TRUE)
  findspots <- findspots[,c(31,32)]
  findspots <- na.omit(findspots)
  if(nrow(findspots) > 0){
    center = c(mean(findspots$lon), mean(findspots$lat))  
    map <- get_map(center,zoom=6,source = "google")
    print(ggmap(map,extent = "device", size = c(2560,2560), darken = 0.4, scale = 2) 
          + geom_point(data=findspots, size=0.9, color="red")
          + ggtitle(paste(paste0("Map for project: ", project)))
    )
    ggsave (fileName, dpi = 300)
  } else {
    print("No rows available to plot")
  }
}
