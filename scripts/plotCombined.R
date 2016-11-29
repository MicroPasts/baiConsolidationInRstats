#' ----
#' title: " A script for mapping the Bronze Age Index transcriptions as jpegs"
#' author: "Daniel Pett"
#' date: "26/11/2016"
#' output: jpeg
#' 
#' This has been tested on OSX El Capitan with R 3.2.2
#' ----

# Set working directory - OSX 
setwd("/Users/danielpett/Documents/research/micropasts/analysis/consBAI/")

# List required packages
list.of.packages <- c(
  "maptools", "rgdal", "geojsonio", "maps", 
  "sp", "mapdata", "rworldmap", "ggmap",
  "mapproj"
)

# Install packages if not already available
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)

library(maps)
library(ggmap)
library(mapproj)

# Create folder for merged files
if (!file.exists('plots/jpegs/combined/')){dir.create('plots/jpegs/combined/')}

# Read CSV and plot map
csvname <- paste0("csv/master/merged.csv")
fileName <- paste0("plots/jpegs/combined/combined.jpeg")
findspots <- read.csv(csvname, header=TRUE)
findspots <- findspots[,c(31,32)]
findspots <- na.omit(findspots)
center = c(mean(findspots$lon), mean(findspots$lat))  
map <- get_map(center,zoom=5,source = "google")
    print(ggmap(map,extent = "device", size = c(2560,2560), darken = 0.4, scale = 2) 
          + geom_point(data=findspots, size=0.4, color="red") + ggtitle(paste('Combined map of transcriptions'))
    )
    
# Save map
ggsave (fileName, dpi = 500)