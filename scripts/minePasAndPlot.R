#' ----
#' title: " A script for mapping the PAS Bronze Age objects (publicly accessible records"
#' author: "Daniel Pett"
#' date: "26/11/2016"
#' output: jpeg
#' 
#' This has been tested on OSX El Capitan with R 3.2.2 and uses the PAS JSON API.
#' ----

setwd("/Users/danielpett/Documents/research/micropasts/analysis/consBAI/") #MacOSX

# Download data from PAS search
library(jsonlite)
url <- 'https://finds.org.uk/database/search/results/q/-knownas%3A%2A+gridref%3A%2A/broadperiod/BRONZE+AGE/format/json'
json <- fromJSON(url)
# Get the total records and paginate
total <- json$meta$totalResults
results <- json$meta$resultsPerPage
pagination <- ceiling(total/results)
# Filter the records
keeps <- c("id","old_findID","fromdate", "todate", "fourFigureLat", "fourFigureLon")
data <- json$results
data <- data[,(names(data) %in% keeps)]

# Bind the subsequent pages 
for (i in seq(from=2, to=pagination, by=1)){
  urlDownload <- paste(url, '/page/', i, sep='')
  pagedJson <- fromJSON(urlDownload)
  records <- pagedJson$results
  records <- records[,(names(records) %in% keeps)]
  data <-rbind(data,records)
}

# Create the folder to save data in
if (!file.exists('csv/PAS')){dir.create('csv/PAS')}

# Create data csv
write.csv(data, file='csv/PAS/bronzeAge.csv',row.names=FALSE, na="")

# Start the mapping process
findspots <- read.csv('csv/PAS/bronzeAge.csv', header=TRUE)

# Omit any blanks
findspots <- na.omit(findspots)
names(findspots) <- c("id","old_findID","fromdate", "todate", "lat", "lon")

# Center the map on average lat/lon
center = c(mean(findspots$lon), mean(findspots$lat))  
# Get the map
map <- get_map(center,zoom=6,source = "google")
print(ggmap(map,extent = "device", size = c(2560,2560), darken = 0.4, scale = 2) 
      + geom_point(data=findspots, size=0.9, color="red")
      + ggtitle(paste(paste0("Map of PAS records BA")))
)

# Create the folder to save data in
if (!file.exists('plots/PAS')){dir.create('plots/PAS')}
# Save the map
ggsave ('plots/PAS/baMap.jpeg', dpi = 300)