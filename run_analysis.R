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
colnames(dim_activity) <- c("id","activityDesc")

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
dset.data <- data.frame()

### For each file pair
for(rowname in rownames(file.datasets)) 
{
  ### Read and bind data
  dset.data <- rbind(
    dset.data,
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
  colnames(dset.data) <- c("source","activity","subject",dset.colnames[,2])
)

### Clean up environment
#### Remove variables that are no longer needed
rm(dset.colnames
   ,file.activity_labels
   ,file.colnames
   ,file.datasets
   ,rowname
   ,folders
)


# Subset and tidying data
message("subsetting and tidying data")
### Identify all mean/std columns
dset.subsetColumns <- sort(
  c("source","activity", "subject"
    , colnames(dset.data)[grep(x=colnames(dset.data)
                        ,pattern = "*mean(\\()"
                        ,ignore.case = TRUE)
                   ]
    , colnames(dset.data)[grep(x=colnames(dset.data)
                               ,pattern = "*std(\\()"
                               ,ignore.case = TRUE)
                          ]
  )
)

### Extract only the source, activity, and mean/std columns as identified on 
###  previous step
dset.subset <- dset.data[ , names(dset.data) %in% dset.subsetColumns]

### Merge activity description into dataset, removing the ID
dset.subset <- merge(dim_activity, dset.subset
                          , by.x="id", by.y="activity")

  
### Release original dataset and dim_activity
rm(dset.data,dim_activity)

#Tidy up the Data Set
### Remove the activity ID
dset.subset <- dset.subset[-1]

### set activity as factor
dset.subset$activityDesc = as.factor(dset.subset$activityDesc)

### Tidy the colnames
names(dset.subset) <- gsub("mean", "Mean", names(dset.subset)) # capitalize M
names(dset.subset) <- gsub("std", "Std", names(dset.subset)) # capitalize S
names(dset.subset) <- gsub("\\(\\)|-", "", names(dset.subset)) # remove "()" and "-"

### Tidy the Activity label
dset.subset$activityDesc = tolower(dset.subset$activityDesc)

# Calculate average(variables) group by (activity,subject)
tidy.subset <- aggregate(dset.subset[, -(1:3)],
                                by=list(dset.subset$subject
                                      , dset.subset$activityDesc),
                                FUN=mean, na.RM = TRUE)

# Assign column names
colnames(tidy.subset)[1:2] <- c("subject","activity")

# Output the average(variables) group by (activity,subject)
write.table(tidy.subset, "average_by_subject_activity.txt", row.name=FALSE)