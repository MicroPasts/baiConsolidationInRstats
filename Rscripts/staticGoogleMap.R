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
library(ggmap)
library(mapproj)
for(project in projects[1:1]){
  csvname <- paste0("csv/consolidated/", project, "_cons.csv")
  fileName <- paste0("plots/jpegs/", project, ".jpeg")
  findspots <- read.csv(csvname, header=TRUE)
  findspots <- findspots[,c(31,32)]
  findspots <- na.omit(findspots)
  if(nrow(findspots) > 0){
    center = c(mean(findspots$lon), mean(findspots$lat))  
    map <- get_map(center,zoom=6,source = "google")
    print(ggmap(map,extent = "device", size = c(2560,2560), darken = 0.4, scale = 2) 
          + geom_point(data=findspots, size=0.9, color="red")
    )
    ggsave (fileName, dpi = 300)
  } else {
    print("No rows available to plot")
  }
}
