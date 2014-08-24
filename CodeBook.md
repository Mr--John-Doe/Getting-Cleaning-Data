#Getting and Cleaning Data - Coursera
##Code Book for *run_analysis.R*
**************************************************
###Objective
This file describes variables, data, and any transformations or work performed by the R script *run_analysis.R*. This script was developed to fulfil the following requirements:

Using the file present here (https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip) and described here (http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones), perform the following actions:

  1. Merge the training and the test sets to create one data set.

  2. Extract only the measurements on the mean and standard deviation for each measurement. 

  3. Use descriptive activity names to name the activities in the data set

  4. Appropriately label the data set with descriptive variable names. 

  5. Create a second, independent tidy data set with the average of each variable for each activity and each subject. 

###Code Summary
The code performs the following main steps:

1. __Initialisation__  
  .a. install packages (*plyr*) if necessary  
  .b. load packages (*plyr*)  
  
2. __Load Data__  
  .a. find the necessary files  
  .b. merge all data into one single dataset  
  .c. clean up the environment (remove no longer needed variables)

3. __Subset and Tidy Data__  
  .a. identify AVG/STD columns for extraction  
  .b. extract only those variables to separate dataset
  .c. merge dataset with the Activity Description
  .d. Tidy up the column names

4. __Create new Average dataset__  
  .a. Calculate the *average(all_variables) group by (activity,subject)*
  .b. Create a new dataset with the previous calculation
  
5. __Output the dataset[4.] into file *average_by_subject_activity.txt*__  

  
###Package Dependencies
- *base packages*
- *plyr*


###File Dependencies
+ features.txt   ->>> *column names*  
+ activity_labels.txt   ->>> *activity descriptions*  
+ x_train.txt, y_train.txt, x_test.txt, y_test ->>> *data*  


###Assumptions
This script assumes:
*
+ a connection to the internet exists (in order to download packages if needed)  
+ the Samsung data is located in the working directory (or one of the sub-directories)  
+ only 1 single copy of this data exists  


**************************************************
**Author:** Joao Marques  
**Date:** 24/Aug/2014  
