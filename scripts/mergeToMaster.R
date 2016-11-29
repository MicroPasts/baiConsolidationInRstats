#' ----
#' title: " A script for consolidating the Bronze Age Index transcriptions in one large file"
#' author: "Daniel Pett"
#' date: "23/11/2016"
#' output: csv_document
#' 
#' This has been tested on OSX El Capitan with R 3.2.2
#' ----

# Set working directory - OSX 
setwd("/Users/danielpett/Documents/research/micropasts/analysis/consBAI/csv/consolidated")

# Create folder for merged files
if (!file.exists('csv/master')){dir.create('csv/master')}

# List all the CSV files
files <- list.files()

# Check the number of rows
total = list()
for(file in files){
  cs <- read.csv(file)
  total[[file]] <- nrow(cs)
}

# Bind the csv files together into a merged file
finalData <- do.call("rbind", lapply(files, read.csv, header = TRUE))

# Write the final CSV dump
write.csv(finalData, file='../master/merged.csv',row.names=FALSE, na="")

# Write out list of Flickr images
flickr <- finalData[c("flickrURL", "project")]
write.csv(flickr, file='../master/flickrUrls.csv',row.names=FALSE, na="")

# Check if rows before and after match
a <- sum(as.data.frame(total))
b <- nrow(finalData)
if( a == b){
  print('Number of rows match')
} else {
  print('The rows do not compare')
}