## Create one R script called run_analysis.R that does the following:
## 1. Merges the training and the test sets to create one data set.
## 2. Extracts only the measurements on the mean and standard deviation for each measurement.
## 3. Uses descriptive activity names to name the activities in the data set
## 4. Appropriately labels the data set with descriptive activity names.
## 5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject.

if (!require("data.table")) {
  install.packages("data.table")
}
if (!require("reshape2")) {
  install.packages("reshape2")
}

require("data.table")
require("reshape2")

## zip file was downloaded and saved under working directory
unzip("Getting and Cleaning Data Course Project")

setwd("C:/Users/varshith608/Documents/R/Getting and Cleaning Data Course Project")

##Load activity labels 
features<-read.table("UCI HAR Dataset/features.txt")
activity<-read.table("UCI HAR Dataset/activity_labels.txt")

features[,2] <- as.character(features[,2])
activity[,2] <- as.character(activity[,2])

##Part1 - merges train and test data in one dataset (full dataset at the end)
X<-rbind(XTest, XTrain)
Y<-rbind(YTest, YTrain)
Subject<-rbind(SubjectTest, SubjectTrain)


##  Extract only the data on mean and standard deviation

featuresWanted <- grep(".*mean.*|.*std.*", features[,2])
featuresWanted.names <- features[featuresWanted,2]
featuresWanted.names = gsub('-mean', 'Mean', featuresWanted.names)
featuresWanted.names = gsub('-std', 'Std', featuresWanted.names)
featuresWanted.names <- gsub('[-()]', '', featuresWanted.names)

##   Load the data sets

train <- read.table("./UCI HAR Dataset/train/X_train.txt")[featuresWanted]
trainActivities <- read.table("./UCI HAR Dataset/train/Y_train.txt")
trainSubjects <- read.table("./UCI HAR Dataset/train/subject_train.txt")
train <- cbind(trainSubjects, trainActivities, train)
test <- read.table("./UCI HAR Dataset/test/X_test.txt")[featuresWanted]
testActivities <- read.table("./UCI HAR Dataset/test/Y_test.txt")
testSubjects <- read.table("./UCI HAR Dataset/test/subject_test.txt")
test <- cbind(testSubjects, testActivities, test)


##    Merge train and test data sets and add thier labels

combinedData <- rbind(train, test)
colnames(combinedData) <- c("subject", "activity", featuresWanted.names)


##  Convert activities & subjects into factors, then convert to a data frame and then dcast the table

combinedData$activity <- factor(combinedData$activity, levels = activity[,1], labels = activity[,2])
combinedData$subject <- as.factor(combinedData$subject)
combinedData.melted <- melt(combinedData, id = c("subject", "activity"))
combinedData.mean <- dcast(combinedData.melted, subject + activity ~ variable, mean)

## Final tidy data set

write.table(combinedData.mean, "tidy.txt", row.names=FALSE, quote=FALSE, sep="\t")

