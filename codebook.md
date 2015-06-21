---
title: "codebook"
output: html_document
---

## Description of the DATA

The features selected for this database come from the accelerometer and gyroscope 3-axial raw signals tAcc-XYZ and tGyro-XYZ. These time domain signals (prefix 't' to denote time) were captured at a constant rate of 50 Hz. Then they were filtered using a median filter and a 3rd order low pass Butterworth filter with a corner frequency of 20 Hz to remove noise. Similarly, the acceleration signal was then separated into body and gravity acceleration signals (tBodyAcc-XYZ and tGravityAcc-XYZ) using another low pass Butterworth filter with a corner frequency of 0.3 Hz. 

Subsequently, the body linear acceleration and angular velocity were derived in time to obtain Jerk signals (tBodyAccJerk-XYZ and tBodyGyroJerk-XYZ). Also the magnitude of these three-dimensional signals were calculated using the Euclidean norm (tBodyAccMag, tGravityAccMag, tBodyAccJerkMag, tBodyGyroMag, tBodyGyroJerkMag). 

#### Time

* tBodyAcc
* tGravityAcc
* tBodyAccJerk
* tBodyGyro
* tBodyGyroJerk
* tBodyAccMag
* tGravityAccMag
* tBodyAccJerkMag
* tBodyGyroMag
* tBodyGyroJerkMag

Finally a Fast Fourier Transform (FFT) was applied to some of these signals producing fBodyAcc-XYZ, fBodyAccJerk-XYZ, fBodyGyro-XYZ, fBodyAccJerkMag, fBodyGyroMag, fBodyGyroJerkMag. (Note the 'f' to indicate frequency domain signals). 

#### Frequency

* fBodyAcc
* fBodyAccJerk
* fBodyGyro
* fBodyAccMag
* fBodyAccJerkMag
* fBodyGyroMag
* fBodyGyroJerkMag

### The set of variables that were estimated from these signals are: 

mean(): Mean value
std(): Standard deviation

## Data Set Information

The data used for this assignment comes from a group of 30 volunteers within the age bracket 19-48 years old.  Each person performed six activities (Walking, Walking Upstairs, Walking Downstairs, Sitting, Standing and Laying) while wearing a Samsung Galaxy S2 on their waist.  Using the embedded accelerometer and gyroscope, 3-axial linear acceleration and 3-axial angular velocity at a constant rate of 50Hz information was captured.


## Work Process Needed to Clean up the Data

1. Merges the training and the test sets to create one data set.
2. Extracts only the measurements on the mean and standard deviation for each measurement. 
3. Uses descriptive activity names to name the activities in the data set
4. Appropriately labels the data set with descriptive variable names. 
5. From the data set in step 4, creates a second, independent tidy data set with the average of 
each variable for each activity and each subject.


### PART 1. Merges the training and the test sets to create one data set.

* Create a folder for the data if it doesn't exist

```{r}
dataFolder <- "./data"
if(!file.exists(dataFolder)){dir.create(dataFolder)}
```

* Get the data from the server and put it in the data folder.

```{r}
fileUrl <- "http://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
fileName <- paste(dataFolder, "/Dataset.zip", sep="")
download.file(fileUrl, fileName, mode="wb")
```

* Unzip the file in the data folder

```{r}
unzip(zipfile=fileName, exdir=dataFolder)
dataPath <- file.path(dataFolder, "UCI HAR Dataset")
files <- list.files(dataPath, recursive=TRUE)
```

*  Read project data from the files related to the project. (Activity, Features, Subject)

##### ACTIVITY

```{r}
actDataTest  <- read.table(file.path(dataPath, "test", "y_test.txt"), header=FALSE)
actDataTrain <- read.table(file.path(dataPath, "train", "y_train.txt"), header=FALSE)
```

##### FEATURES

```{r}
featDataTest  <- read.table(file.path(dataPath, "test", "X_test.txt"), header=FALSE)
featDataTrain <- read.table(file.path(dataPath, "train", "X_train.txt"), header=FALSE)
```


##### SUBJECT

```{r}
subjDataTest  <- read.table(file.path(dataPath, "test", "y_test.txt"), header=FALSE)
subjDataTrain <- read.table(file.path(dataPath, "train", "y_train.txt"), header=FALSE)
```

* Merge the test and training data sets

```{r}
dataAct <- rbind(actDataTrain, actDataTest)
dataFeat <- rbind(featDataTrain, featDataTest)
dataSubj <- rbind(subjDataTrain, subjDataTest)
```

* Set Variable Names

```{r}
names(dataSubj) <- c("subject")
names(dataAct) <- c("activity")
dataFeatNames <- read.table(file.path(dataPath, "features.txt"), head= FALSE)
names(dataFeat) <- dataFeatNames$V2
```

*  Merge everything for one complete data set

```{r}
dataMerged <- cbind(dataSubj, dataAct)
data <- cbind(dataFeat, dataMerged)
```

### PART 2. Extracts only the measurements on the mean and standard deviation for each measurement.

* Subset the data for only variables with mean or standard deviation into a factor

```{r}
subdataFeatNames <- dataFeatNames$V2[grep('mean\\(\\)|std\\(\\)', dataFeatNames$V2)]
```

* Subset the data frame by the selected features

```{r}
selNames <- c(as.character(subdataFeatNames), "subject", "activity")
data <- subset(data, select= selNames)
```

### PART 3. Uses descriptive activity names to name the activities in the data set

* Get the descriptive activity names

```{r}
actLabels <- read.table(file.path(dataPath, "activity_labels.txt"), header= FALSE, colClasses="character")
```

* add descriptive names to the activity variable 

```{r}
data$activity <- factor(data$activity, levels=actLabels$V1, labels= actLabels$V2)
```

### PART 4. Appropriately labels the data set with descriptive variable names.

* Adjust the columns to be more easily readable.  (time, frequency, magnitude, accelerometer, gyroscope and body)

```{r}
names(data) <- gsub("std()", "STD", names(data))
names(data) <- gsub("mean()", "MEAN", names(data))
names(data) <- gsub("^t", "time", names(data))
names(data) <- gsub("^f", "frequency", names(data))
names(data) <- gsub("Mag", "Magnitude", names(data))
names(data) <- gsub("Acc", "Accelerometer", names(data))
names(data) <- gsub("Gyro", "Gyroscope", names(data))
names(data) <- gsub("BodyBody", "Body", names(data))
```

### PART 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

* Use the plyr library to create a second data set

```{r}
library(plyr)
data2 <- aggregate(. ~subject + activity, data, mean)
data2 <- data2[order(data2$subject,data2$activity),]
write.table(data2, file= "tidydata.txt", sep=",", row.names= FALSE)
```

### Create the Codebook
```
library(knitr)
knit2html("codebook.Rmd")
```