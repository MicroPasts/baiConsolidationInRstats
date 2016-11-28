#' ----
#' title: " A script for generating statistic for MicroPasts contributors"
#' author: "Daniel Pett"
#' date: "28/11/2016"
#' output: jpeg_document
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

# Read config file for project list
projects <- read.csv('admin/config.csv', sep=',')
projects <- projects$Projects

#Create JSON folder if it does not exist
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