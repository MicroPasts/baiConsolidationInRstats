#' ----
#' title: " A script for generating statistic for MicroPasts contributors"
#' author: "Daniel Pett"
#' date: "28/11/2016"
#' output: jpeg_document
#' output: md_document
#' 
#' This has been tested on OSX El Capitan with R 3.2.2
#' ----

list.of.packages <- c(
  "jsonlite", "plyr", "ggplot2"
)

# Install packages if not already available
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)

# Set working directory - OSX 
setwd("/Users/danielpett/Documents/research/micropasts/analysis/consBAI/") 

# Set up list of projects to parse (should really put this a file to allow DRY)
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

# Create JSON folder if it does not exist
if (!file.exists('plots/statistics')){dir.create('plots/statistics')}
if (!file.exists('csv/statistics')){dir.create('csv/statistics')}

# Load libraries
library(jsonlite)
library(plyr)
library(ggplot2)
# Parse the user admin table
userTable <- read.csv("admin/all_users.csv")
userTable <- userTable[c("id", "fullname")]
names(userTable) <- c("userID", "fullname")

# Generate plots per project
for(project in projects) {
  csvName <- paste0("csv/raw/", project, "_raw.csv")
  data <- read.csv(csvName, header=TRUE)
  inputters <- as.data.frame(na.omit(data$userID))
  names(inputters) <- c("userID")
  whoDidIt <- merge(userTable, inputters, by = "userID")
  whoDidIt <- as.vector(whoDidIt)
  # Count values
  freq <- count(whoDidIt, "fullname")
  # Rename the columns
  names(freq) <- c("contributor", "tasks")
  # Order the data 
  orderedData <- arrange(freq,tasks)
  fileName <- paste0('csv/statistics/', project, "_freq.csv")
  write.csv(orderedData, file=fileName,row.names=FALSE, na='')
  
  # Filename for graph
  filename <- paste0('plots/statistics/', project, 'TasksCount.png')
  
  # Create graph
  
  ggplot(data=orderedData, aes(x=contributor, y=tasks, group=1)) + geom_line() + xlab('Contributor name') + ylab('Tasks contributed') + ggtitle(paste('Contributions for the', project, 'project'))
  # Save graph
  ggsave(file=filename, width=24, height=12, dpi=300)
}