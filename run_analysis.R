# Course Project

# The purpose of this project is to demonstrate your ability to collect, work with, and clean a data set. The goal is to prepare tidy data that can be used for later analysis. You will be graded by your peers on a series of yes/no questions related to the project. You will be required to submit: 1) a tidy data set as described below, 2) a link to a Github repository with your script for performing the analysis, and 3) a code book that describes the variables, the data, and any transformations or work that you performed to clean up the data called CodeBook.md. You should also include a README.md in the repo with your scripts. This repo explains how all of the scripts work and how they are connected.  
# One of the most exciting areas in all of data science right now is wearable computing - see for example this article . Companies like Fitbit, Nike, and Jawbone Up are racing to develop the most advanced algorithms to attract new users. The data linked to from the course website represent data collected from the accelerometers from the Samsung Galaxy S smartphone. A full description is available at the site where the data was obtained: 
#  http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones 
# Here are the data for the project: 
#  https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 
# You should create one R script called run_analysis.R that does the following. 
# 1. Merges the training and the test sets to create one data set.
# 2. Extracts only the measurements on the mean and standard deviation for each measurement. 
# 3. Uses descriptive activity names to name the activities in the data set
# 4. Appropriately labels the data set with descriptive variable names. 
# 5. From the data set in step 4, creates a second, independent tidy data set with the average of 
# each variable for each activity and each subject.


### PART 1. Merges the training and the test sets to create one data set.

# Create a folder for the data if it doesn't exist
dataFolder <- "./data"
if(!file.exists(dataFolder)){dir.create(dataFolder)}

# Get the data from the server and put it in the data folder.
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
fileName <- paste(dataFolder, "/Dataset.zip", sep="")
download.file(fileUrl, fileName)

# Unzip the file in the data folder
unzip(zipfile=fileName, exdir=dataFolder)
dataPath <- file.path(dataFolder, "UCI HAR Dataset")
files <- list.files(dataPath, recursive=TRUE)

# Read project data from the files related to the project. (Activity, Features, Subject)

# ACTIVITY
actDataTest  <- read.table(file.path(dataPath, "test", "y_test.txt"), header=FALSE)
actDataTrain <- read.table(file.path(dataPath, "train", "y_train.txt"), header=FALSE)

# FEATURES
featDataTest  <- read.table(file.path(dataPath, "test", "X_test.txt"), header=FALSE)
featDataTrain <- read.table(file.path(dataPath, "train", "X_train.txt"), header=FALSE)

# SUBJECT
subjDataTest  <- read.table(file.path(dataPath, "test", "y_test.txt"), header=FALSE)
subjDataTrain <- read.table(file.path(dataPath, "train", "y_train.txt"), header=FALSE)

# Merge the test and training data sets
dataAct <- rbind(actDataTrain, actDataTest)
dataFeat <- rbind(featDataTrain, featDataTest)
dataSubj <- rbind(subjDataTrain, subjDataTest)

# Set Variable Names
names(dataSubj) <- c("subject")
names(dataAct) <- c("activity")
dataFeatNames <- read.table(file.path(dataPath, "features.txt"), head= FALSE)
names(dataFeat) <- dataFeatNames$V2

# Merge everything for one complete data set
dataMerged <- cbind(dataSubj, dataAct)
data <- cbind(dataFeat, dataMerged)


### PART 2. Extracts only the measurements on the mean and standard deviation for each measurement.

# Subset the data for only variables with mean or standard deviation into a factor
subdataFeatNames <- dataFeatNames$V2[grep('mean\\(\\)|std\\(\\)', dataFeatNames$V2)]

# Subset the data frame by the selected features
selNames <- c(as.character(subdataFeatNames), "subject", "activity")
data <- subset(data, select= selNames)


### PART 3. Uses descriptive activity names to name the activities in the data set

# Get the descriptive activity names
actLabels <- read.table(file.path(dataPath, "activity_labels.txt"), header= FALSE, colClasses="character")

# add descriptive names to the activity variable 
data$activity <- factor(data$activity, levels=actLabels$V1, labels= actLabels$V2)


### PART 4. Appropriately labels the data set with descriptive variable names.

# Adjust the columns to be more easily readable.  (time, frequency, magnitude, accelerometer, gyroscope and body)
names(data) <- gsub("std()", "STD", names(data))
names(data) <- gsub("mean()", "MEAN", names(data))
names(data) <- gsub("^t", "time", names(data))
names(data) <- gsub("^f", "frequency", names(data))
names(data) <- gsub("Mag", "Magnitude", names(data))
names(data) <- gsub("Acc", "Accelerometer", names(data))
names(data) <- gsub("Gyro", "Gyroscope", names(data))
names(data) <- gsub("BodyBody", "Body", names(data))


### PART 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

# Use the plyr library to create a second data set
library(plyr)
data2 <- aggregate(. ~subject + activity, data, mean)
data2 <- data2[order(data2$subject,data2$activity),]
write.table(data2, file= "tidydata.txt", sep=",", row.names= FALSE)