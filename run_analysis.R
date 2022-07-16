#See README.md for details

# Download the unzipped file and save the zipped file to local directory
# library :
library(dplyr)
# download zip file containing data if it hasn't already been downloaded
dataUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
dataFile <- "UCI HAR Dataset.zip"

if (!file.exists(dataFile)) {
  download.file(dataUrl, dataFile, mode = "wb")
}

#set working directory
getwd()
setwd("D:/Data Science/dataFile")

#get train data and subject
train_Values <- read.table('./UCI HAR Dataset/train/X_train.txt', header=FALSE)
train_Activity <- read.table('./UCI HAR Dataset/train/y_train.txt', header=FALSE)
train_Subjects <- read.table('./UCI HAR Dataset/train/subject_train.txt', header=FALSE)

# get test data and subject
test_Values <- read.table("./UCI HAR Dataset/test/X_test.txt", header=FALSE)
test_Activity <- read.table("./UCI HAR Dataset/test/y_test.txt", header=FALSE)
test_Subjects <-read.table("./UCI HAR Dataset/test/subject_test.txt", header=FALSE)

# get features data
features <- read.table("./UCI HAR Dataset/features.txt", header=FALSE)

# get activity data
activity <- read.table("./UCI HAR Dataset/activity_labels.txt", header=FALSE)

# rename activity columns to id and actions(walk,lay,etc.)
colnames(activity) <- c("activityId","activityLabel")


# 1. Merges the training and the test sets to create one data set

## concatenate tables to make single data table

my_dataset <- rbind(
  cbind(train_Subjects, train_Values, train_Activity), 
  cbind(test_Subjects, test_Values, test_Activity)
)

## Clean memory by removing concatenate tables

rm(train_Subjects, train_Values, train_Activity, 
   test_Subjects, test_Values, test_Activity)

## rename activity columns to id and actions(walk,lay,etc.)

colnames(my_dataset) <- c("subject", features[, 2], "activity")


# 2. Extracts only the measurements on the mean and standard deviation for each measurement

## create columns and select them in my_dataset for mean and standard deviation 

columns_names <- colnames(my_dataset)

my_dataset2 <- my_dataset %>%
                select(subject, activity, grep("\\bmean\\b|\\bstd\\b",columns_names))


# 3. Use descriptive activity names to name the activities in the data set

## transform activity to a factor variable

my_dataset2$activity <- as.factor(my_dataset2$activity)

# 4. Appropriately label the data set with descriptive variable names

colnames(my_dataset2) <- gsub("^f", "frequencyDomain", colnames(my_dataset2))
colnames(my_dataset2) <- gsub("^t", "timeDomain", colnames(my_dataset2))
colnames(my_dataset2) <- gsub("Acc", "Accelerometer", colnames(my_dataset2))
colnames(my_dataset2) <- gsub("Gyro", "Gyroscope", colnames(my_dataset2))
colnames(my_dataset2) <- gsub("Mag", "Magnitude", colnames(my_dataset2))
colnames(my_dataset2) <- gsub("Freq", "Frequency", colnames(my_dataset2))
colnames(my_dataset2) <- gsub("mean", "Mean", colnames(my_dataset2))
colnames(my_dataset2) <- gsub("std", "StandardDeviation", colnames(my_dataset2))
colnames(my_dataset2) < -gsub("BodyBody", "Body", colnames(my_dataset2))

# 5. Create a second, independent tidy set with the average of each variable for each activity and each subject

## group by subject and activity and summarise using mean
my_dataset_Means <- my_dataset2 %>% 
  group_by(subject, activity) %>%
  summarise_each(funs(mean))

### text file for final output

write.table(my_dataset_Means, "tidy_data.txt", row.names = FALSE, quote = FALSE)


