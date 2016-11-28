#' ----
#' title: " A script for generating thank you list for MicroPasts contributors"
#' author: "Daniel Pett"
#' date: "28/11/2016"
#' output: csv_document
#' output: md_document
#' 
#' This has been tested on OSX El Capitan with R 3.2.2
#' ----
list.of.packages <- c(
  "jsonlite", "rmarkdown"
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

# Initiate library
library(jsonlite)

# Parse the user admin table
userTable <- read.csv("admin/all_users.csv")
userTable <- userTable[c("id", "fullname")]
names(userTable) <- c("userID", "fullname")

# Create list for rbind to use
peopleTest = list()

# Loop through projects - uses raw data to get all contributors
for (project in projects) {
   csvName <- paste0("csv/raw/", project, "_raw.csv")
   data <- read.csv(csvName, header=TRUE)
   inputters <- as.data.frame(na.omit(data$userID))
   names(inputters) <- c("userID")
   whoDidIt <- merge(userTable, inputters, by = "userID")
   whoDidIt <- as.vector(whoDidIt)
   # Get the unique names
   whoDidIt <- unique(whoDidIt)
   # Append the project people to a list
   peopleTest[[project]] <- whoDidIt
}

# Bind the data together
final <- do.call(rbind, peopleTest)

# Choose only one column
final <- final$fullname
final <- as.data.frame(final)
names(final) <- c("Full name")
final <- unique(final)

# Check and create CSV directories if needed
if (!file.exists('csv/thankYous')){ dir.create('csv/thankYous') }

# Write the csv file
csv <- 'csv/thankYous/baiThankYou.csv'
write.csv(final, file=csv,row.names=FALSE, na="")

# Now generate the markdown document
markdown <- file('thankyou.md')
text <- "# Contributors to Transcribing the Bronze Age Index  
"
content <- paste0(text,paste(as.character(final$`Full name`), collapse=", "))
writeLines(content, markdown)