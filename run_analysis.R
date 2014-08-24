#  Script and Data Description
#### This R script downloads, extracts and cleans human activity data. 
#### This data and a full description of the data set is available at:
#### http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

#  Getting and Cleaning Data - Coursera 
## Instructions
#### You should create one R script called run_analysis.R that does the following. 
#### Merges the training and the test sets to create one data set.
##### Extracts only the measurements on the mean and standard deviation for each 
####    measurement. 
#### Uses descriptive activity names to name the activities in the data set
#### Appropriately labels the data set with descriptive variable names. 
#### Creates a second, independent tidy data set with the average of each variable 
####    for each activity and each subject. 


#Initialization
## Set working directory - DISABLE ON SUBMISSION
#setwd("C:/Personal Stuff/My Documents/00_Coursera/03_Getting and Cleaning Data/Project")

## Load necessary Libraries
message("Loading Libraries")
if (!require("plyr")) {
  install.packages("plyr")
}

library(plyr)

#Download and Load the data
## Download the file and timestamp dateDownloaded
####### message("dowloading and unzipping data")
####### temp <- tempfile()
####### download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",temp)
####### dateDownloaded <- date()
####### 
## Unzip the file and release the zip file
####### unzip(temp,overwrite=TRUE,exdir="dataset")
####### unlink(temp)
####### rm(temp)

## Preparation

message("Loading data")
### Find and set the data root folder 
folders <- list.dirs(recursive = TRUE)
dataRootFolder <- folders[grep(x=folders, pattern="*UCI HAR Dataset$"
                               , ignore.case = TRUE)]

### Find and load the description file containing the column names
file.colnames <- list.files(pattern="features.txt", full.names = TRUE
                            , ignore.case = TRUE, recursive = TRUE)
dset.colnames  <- read.table(file.colnames, sep="", stringsAsFactors=FALSE)

### Find and load the description for "activity"
file.activity_labels <- list.files(pattern="activity_labels.txt"
                                   , full.names = TRUE, ignore.case = TRUE
                                   , recursive = TRUE)
dim_activity  <- read.table(file.activity_labels, sep="", stringsAsFactors=FALSE)
colnames(dim_activity) <- c("id","activity")

### Get a list of files to load
file.datasets  <-
  cbind(
    c(
      list.files(path=paste(dataRootFolder,"/train", sep=""), pattern="x_train.txt"
                 , full.names = TRUE, ignore.case = TRUE)
      , list.files(path=paste(dataRootFolder,"/test", sep=""), pattern="x_test.txt"
                   , full.names = TRUE, ignore.case = TRUE)
    )
    ,
    c(list.files(path=paste(dataRootFolder,"/train", sep=""), pattern="y_train.txt"
                 , full.names = TRUE, ignore.case = TRUE)
      , list.files(path=paste(dataRootFolder,"/test", sep=""), pattern="y_test.txt"
                   , full.names = TRUE, ignore.case = TRUE)
    )
    ,
    c(list.files(path=paste(dataRootFolder,"/train", sep="")
                 , pattern="subject_train.txt", full.names = TRUE
                 , ignore.case = TRUE)
      , list.files(path=paste(dataRootFolder,"/test", sep="")
                   , pattern="subject_test.txt", full.names = TRUE
                   , ignore.case = TRUE)
    )
  )

### Assign col/row names
rownames(file.datasets) <- c("train", "test")
colnames(file.datasets) <- c("data", "activity_list", "subject")

## Bind data into a single dataset
### Initialize the data.frame
original.data <- data.frame()

### For each file pair
for(rowname in rownames(file.datasets)) 
{
  ### Read and bind data
  original.data <- rbind(
    original.data,
    cbind(
      c(rowname)
      , read.table(file.datasets[rowname,"activity_list"]
                   , sep="", dec = ".", quote = ""
                   , header=FALSE 
      )
      , read.table(file.datasets[rowname,"subject"] 
                   , sep="", dec = ".", quote = ""
                   , header=FALSE
      )
      , read.table(file.datasets[rowname,"data"] 
                   , sep="", dec = ".", quote = ""
                   , header=FALSE
      )
      
    )
  )
}

### Assign colnames
suppressWarnings(
  colnames(original.data) <- c("source","activity","subject",dset.colnames[,2])
)

### Clean up environment
#### Remove variables that are no longer needed
rm(dset.colnames
   ,file.activity_labels
   ,file.colnames
   ,file.datasets
   ,rowname
   ,folders
   ,dataRootFolder
)


# Subset and tidying data
message("subsetting and tidying data")
### Identify all mean/std columns
tidy.dataColumns <- sort(
  c("source","activity", "subject"
    , colnames(original.data)[grep(x=colnames(original.data)
                        ,pattern = "*mean(\\()"
                        ,ignore.case = TRUE)
                   ]
    , colnames(original.data)[grep(x=colnames(original.data)
                               ,pattern = "*std(\\()"
                               ,ignore.case = TRUE)
                          ]
  )
)

### Extract only the source, activity, and mean/std columns as identified on 
###  previous step
tidy.data <- original.data[ , names(original.data) %in% tidy.dataColumns]

### Merge activity description into dataset, removing the ID
tidy.data <- merge(dim_activity, tidy.data
                          , by.x="id", by.y="activity")

  
### Release original dataset and dim_activity
rm(dim_activity
   ,tidy.dataColumns)

#Tidy up the Data Set
### Remove the activity ID
tidy.data <- tidy.data[-1]

### set activity as factor
tidy.data$activity = as.factor(tidy.data$activity)

### Tidy the colnames
names(tidy.data) <- gsub("mean", "Mean", names(tidy.data)) # capitalize M
names(tidy.data) <- gsub("std", "Std", names(tidy.data)) # capitalize S
names(tidy.data) <- gsub("\\(\\)|-", "", names(tidy.data)) # remove "()" and "-"

### Tidy the Activity label
tidy.data$activity = tolower(tidy.data$activity)

# Calculate average(variables) group by (activity,subject)
output.agg.data <- aggregate(tidy.data[, -(1:3)],
                                by=list(tidy.data$subject
                                      , tidy.data$activity),
                                FUN=mean, na.RM = TRUE)

# Assign column names
colnames(output.agg.data)[1:2] <- c("subject","activity")

# Output the average(variables) group by (activity,subject)
write.table(output.agg.data, "average_by_subject_activity.txt", row.name=FALSE)