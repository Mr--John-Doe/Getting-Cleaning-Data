#Getting and Cleaning Data - Coursera  
##Code Book for *run_analysis.R*  
**************************************************  

###Assumptions  
This script assumes:  

+ a connection to the internet exists (in order to download packages if needed)  
+ the Samsung data is located in the working directory (or one of the sub-directories)  
+ only 1 single copy of this data exists   

###File Dependencies  
+ features.txt   ->>> *column names*  
+ activity_labels.txt   ->>> *activity descriptions*  
+ x_train.txt, y_train.txt, x_test.txt, y_test ->>> *data*  


###Package Dependencies  
- *base packages*  
- *plyr*  


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

###Data Description  
####original.data  
This data.frame contains both the _test_ and the _train_ datasets, unioned, and with the subject each row matches to.  

####tidy.data  
This data.frame is derived from original.data, and contains the activity description, source (train/test), subject, and all the AVG/STD variables.  

####output.agg.data  
This data.frame is derived from tidy.data, and contains the average for each variable grouped by subject and activity.  
 
###Data Transformations  
####original.data -> tidy.data   
1. select only the columns that contain one of the strings ('mean(','avg('), plus the columns source, subject, activity    

2. cast the "activity" column as _factor_  

3. convert "activity" column -> tolower()

4. replace column names: mean->Mean , std->Std , delete () and -

####tidy.data -> output.agg.data  
1. resulting dataset for *average(all_variables) group by (activity,subject)*  


**************************************************
**Author:** Joao Marques  
**Date:** 24/Aug/2014  
