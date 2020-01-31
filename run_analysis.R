#1. Merges the training and the test sets to create one data set.

#Download the file, put the file in the data folder and unzip the file

if(!file.exists("./data")){dir.create("./data")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./data/Dataset.zip",method="curl")
unzip(zipfile="./data/Dataset.zip",exdir="./data")

#Read data from the files and create a variable to store it
UCIdata<- file.path("./data" , "UCI HAR Dataset")

#Read the Activity files
ActivityTest  <- read.table(file.path(UCIdata, "test" , "Y_test.txt" ),header = FALSE)
ActivityTrain <- read.table(file.path(UCIdata, "train", "Y_train.txt"),header = FALSE)

#Read the Subject files
SubjectTest  <- read.table(file.path(UCIdata, "test" , "subject_test.txt"),header = FALSE)
SubjectTrain <- read.table(file.path(UCIdata, "train", "subject_train.txt"),header = FALSE)

#Read the Features files
FeaturesTest  <- read.table(file.path(UCIdata, "test" , "X_test.txt" ),header = FALSE)
FeaturesTrain <- read.table(file.path(UCIdata, "train", "X_train.txt"),header = FALSE)

#Join the test and train data by rows
Subject <- rbind(SubjectTrain, SubjectTest)
Activity<- rbind(ActivityTrain, ActivityTest)
Features<- rbind(FeaturesTrain, FeaturesTest)

#Set names to variables
names(Subject)<-c("Subject")
names(Activity)<- c("Activity")
dataFeaturesNames <- read.table(file.path(UCIdata, "features.txt"),head=FALSE)
names(Features)<- dataFeaturesNames$V2

#Combine the data
dataCombine <- cbind(Subject, Activity)
Data <- cbind(Features, dataCombine)



#2.Extracts only the measurements on the mean and standard deviation for each measurement.
#Take the names in Features on the mean and standard deviation measurement
subdataFeaturesNames<-dataFeaturesNames$V2[grep("mean\\(\\)|std\\(\\)", dataFeaturesNames$V2)]

#Restructure the data with selected measurements
selected<-c(as.character(subdataFeaturesNames), "Subject", "Activity" )
Data<-subset(Data,select=selected)



#3.Uses descriptive activity names to name the activities in the data set
#Read the activity names from "activity_labels.txt"
activityLabels <- read.table(file.path(UCIdata, "activity_labels.txt"),header = FALSE)

#Name the columns in activityLabels
names(activityLabels)[1]<- "Activity"
names(activityLabels)[2]<- "Activitynames"

#Fill the activity labels in the data
DatawithActivitynames<-merge(Data,activityLabels,by="Activity")

#Delete the "Activity" column
Data<-DatawithActivitynames[,-1]


#4.Appropriately labels the data set with descriptive variable names.
#Features are labeled using descriptive names
names(Data)<-gsub("^t", "time", names(Data))
names(Data)<-gsub("^f", "frequency", names(Data))
names(Data)<-gsub("Acc", "Accelerometer", names(Data))
names(Data)<-gsub("Gyro", "Gyroscope", names(Data))
names(Data)<-gsub("Mag", "Magnitude", names(Data))
names(Data)<-gsub("BodyBody", "Body", names(Data))



#5.Creates a second, independent tidy data set with the average of each variable for each activity and each subject.
library(plyr)
Data2<-aggregate(. ~Subject + Activitynames, Data, mean)
Data2<-Data2[order(Data2$Subject,Data2$Activitynames),]
write.table(Data2, file = "tidydata.txt",row.name=FALSE)
