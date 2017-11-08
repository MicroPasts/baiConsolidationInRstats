#' ----
#' title: " A script for consolidating the Bronze Age Index transcriptions"
#' author: "Daniel Pett"
#' author: "Andrew Bevan"
#' date: "23/11/2016"
#' output: csv_document
#' 
#' This has been tested on OSX El Capitan with R 3.2.2
#' ----


list.of.packages <- c(
  "jsonlite"
)

# Install packages if not already available
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)

# Initiate library
library(jsonlite)

# Set working directory - OSX 
setwd("/Users/abevan/Projects/github/baiConsolidationInRstats/") 

# Read config file for project list
projects <- read.csv('admin/config.csv', sep=',')
projects <- as.character(projects$Projects)

baseSchema <- c(
  "info", "user_id", "task_id", "created", "finish_time",
  "calibration", "app_id", "user_ip", "timeout", "id", "weight",
  "patina", "site", "surface", "toSearch", "remarks", "dateDiscoveryMonth",
  "objectType", "gridRef", "thickness", "width", "other", 
  "composition", "associations", "description", "collection", "dateDiscoveryDay", 
  "dateDiscoveryYear", "rightCorner", "length", "edge", "publications",
  "userID", "taskID", "Lon", "Lat" 
)

# Print number of projects for reference
print(paste0("The number of projects to parse: ", length(projects)))

# Create four working sub-directories if they do not exist
if (!file.exists('csv')){ dir.create('csv') }
if (!file.exists('csv/raw')){ dir.create('csv/raw') }
if (!file.exists('csv/consolidated')){ dir.create('csv/consolidated') }
if (!file.exists('admin')){ dir.create('admin') }
if (!file.exists('archives')){ dir.create('archives') }
if (!file.exists('json')){ dir.create('json') }

# Load user data
#http://crowdsourced.micropasts.org/admin/users/export?format=csv (when logged in as admin)
users <- read.csv("admin/all_users.csv", header=TRUE)
users <- users[,c("id","fullname")]

# ID of good users to prioritse or bad ones to ignore
superusers <- c(433,580,64,226,473,243) # rank order, best first
ignoreusers <- c(652,677)

# Loop through each project
for (project in projects){
  # Print name of project processing
  print(paste0("Start processing ", project)) 
  
  # Form the export url
  baseUrl <- 'http://crowdsourced.micropasts.org/project/'
  tasks <- '/tasks/export?type=task&format=json'
  url <- paste0(baseUrl, project, tasks)
  archives <- paste0('archives/', project, 'Tasks.zip')
  taskPath <- paste0('json/', project,  '.json')
  # Import tasks from json, this method has changed due to coding changes by SciFabric to their code
    if (!file.exists(taskPath)){
        download.file(url,archives)
        unzip(archives)
        rename <- paste0(project,  '_task.json')
        file.rename(rename, taskPath)
    }
  
  # Read json files
  which(lapply(readLines(taskPath, warn=FALSE), function(x) tryCatch({jsonlite::fromJSON(x); 1}, error=function(e) 0)) == 0)
  trT <- fromJSON(paste(readLines(taskPath, warn=FALSE), collapse=""))
  trT <- cbind(trT$id,trT$info)
  trTfull <- trT
  # Extract just task id and image URL
  trT <- trT[,c(1,3,4)]
  names(trT) <- c("taskID","flickrURL", "imageURL")
  
  # Import task runs from json
  taskruns <- '/tasks/export?type=task_run&format=json'
    urlRuns <- paste0(baseUrl,project,  taskruns)
    archiveRuns <-paste0('archives/', project,  'TasksRun.zip')
            taskruns <- paste0('json/', project,  '_task_run.json')
    if (!file.exists(taskruns)){
        download.file(urlRuns,archiveRuns)
        unzip(archiveRuns)
        renameRuns <-paste0(project,  '_task_run.json')   
        file.rename(renameRuns, taskruns)
    }
  which(lapply(readLines(taskruns, warn=FALSE), function(x) tryCatch({jsonlite::fromJSON(x); 1}, error=function(e) 0)) == 0)
  trTr <- fromJSON(paste(readLines(taskruns, warn=FALSE), collapse=""))
  
  # Re-arrange slightly and drop some columns
  trTr <- cbind(trTr$info,trTr$user_id,trTr$task_id)
  names(trTr)[length(names(trTr))] <- "taskID"
  names(trTr)[length(names(trTr))-1] <- "userID"
  
  
   # Extract geojson data and append lon-lat columns
  geo <- trTr$geojson[[1]]$coordinates
  fun1 <- function(x){ if (is.null(x)){ x <- c(NA,NA) } else { x } }
  geo <- lapply(geo,fun1)
  geo <- data.frame(do.call("rbind",geo))
  names(geo) <- c("Lon","Lat")
  trTr$geojson <- NULL
  trTr <- cbind(trTr,geo)

  # Sort by user ID then by task ID
    trTr <- trTr[with(trTr, order(taskID, userID)), ]
  
  # Clean up some text issues
  tmp <- names(trTr) #preserve column names
  trTr <- apply(trTr, 2, function(x) gsub("[\r\n]", " [;] ", x))
  trTr <- apply(trTr, 2, function(x) gsub("[;]", ",", x, fixed=TRUE))
  trTr <- apply(trTr, 2, function(x) gsub("[:]", ",", x, fixed=TRUE))
  trTr <- apply(trTr, 2, function(x) gsub("\\s\\s", " ", x, fixed=TRUE))
  trTr <- apply(trTr, 2, function(x) gsub(" ,", ",", x, fixed=TRUE))
  trTr <- apply(trTr, 2, function(x) gsub("^\\s+|\\s+$", "", x)) #whitespace clean
  trTr <- data.frame(trTr)
  names(trTr) <- tmp
  trTr <- merge(trTr,trT, by="taskID")
  
  # Add inputter
  trTr$inputBy <- NA
  
  for (w in 1:length(users$id)){
    trTr$inputBy[trTr$userID==as.character(users$id[w]) & !is.na(trTr$userID)] <- as.character(users$fullname[w])
  }
  
  # Add anonymous if input ID unavailable
  trTr$inputBy[is.na(trTr$inputBy)] <- "Anon."          
  
  # Reorder the final columns
  preforder <- c("taskID","userID","objectType","rightCorner","collection","site",
                 "toSearch","Lon","Lat","gridRef","dateDiscoveryDay",
                 "dateDiscoveryMonth","dateDiscoveryYear","length","width","edge",
                 "weight","patina","surface","thickness","other","composition",
                 "associations","description","publications","remarks","inputBy",
                 "imageURL", "flickrURL")

  trTr<- trTr[,preforder,drop=TRUE]
  trTr <- trTr[ ,preforder]
  
  while (any(grepl("\\s\\s",trTr$site))){
    trTr$site <- gsub("\\s\\s", " ", trTr$site)
  }
  baseFilename <- project
  # Export raw data 
  csvname <- paste0('csv/raw/', baseFilename,  '_raw.csv')
  write.csv(trTr, file=csvname,row.names=FALSE, na="")
  
  ## Consolidation steps ##
  trTrc <- as.data.frame(trTr,stringsAsFactors=FALSE)
  # Get rid of factors in favour of plain text
  i <- sapply(trTrc, is.factor)
  trTrc[i] <- lapply(trTrc[i], as.character)
  
  # We will loop through each task run in turn.
  # For most columns, we return the top-ranked superuser's contribution if it exists.
  # If a superuser does not exist, then we first exclude really bad users, then check for agreement between two or more other users 
  # for all columns of data. If agreement over a non-empty value exists, we take that value. Otherwise, we combine the contributions of the 
  # users and separate them by a "|". These will need a manual check.
  # We keep a note of which action was taken in MyNotes.
  # Coordinates are treated similarly but we either return the median value in the case of 3 or more task runs, the agreed value where there 
  # are only two task runs and both agree  or NA if only two task runs and they don't
  
  taskids <- sort(unique(trTrc$taskID))
  superusersdf <- data.frame(userID=superusers,Rank=1:length(superusers),stringsAsFactors=FALSE)
  trTrc$Processing <- NA
  
  # Loop
  for (a in 1:length(taskids)){
    # cat(paste0(a,"; "))
    mydup <- trTrc[trTrc$taskID==taskids[a],]
    mydup <- mydup[!mydup$userID %in% ignoreusers,]
    if (nrow(mydup)==1){
      myrec <- mydup
      myrec$Processing <- "only good record"
    } else {
      sucheck <- superusersdf[superusersdf$userID %in% mydup$userID,]
      if (nrow(sucheck)>0){
        myrec <- mydup[mydup$userID==sucheck$userID[1] & !is.na(mydup$userID),]
        myrec$Processing <- "superuser"
      } else {
          mychars <- vector(mode="numeric", length=nrow(mydup))
          for (g in 1:nrow(mydup)){
              mychars[g] <- sum(nchar(mydup[g,names(mydup)[c(3:6,14:26)]]), na.rm=TRUE)
          }
          myrec <- mydup[which.max(mychars),]
          myrec$Processing <- "most detailed record"
      }
    }
    if (a==1){
      allrecs <- myrec
    } else {
      allrecs <- rbind(allrecs,myrec)
    }
  }
  # Round lonlat to 4 decimals for consistency and force NA conversion
  allrecs$Lon[!is.na(allrecs$Lon)] <- round(as.numeric(allrecs$Lon[!is.na(allrecs$Lon)]),4)
  allrecs$Lat[!is.na(allrecs$Lat)] <- round(as.numeric(allrecs$Lat[!is.na(allrecs$Lat)]),4)
  allrecs$project <- project
  # Export consolidated data
  csvname <- paste0('csv/consolidated/', baseFilename,  '_cons.csv')
  write.csv(allrecs, file=csvname,row.names=FALSE, na="")
  print(paste0(baseFilename, " processed")) 
}
