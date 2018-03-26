library(reshape2)

filename <- "getdata_dataset.zip"

## Download and unzip the dataset if not existing (file for Windows machine no method)
if (!file.exists(filename)){
  fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
  download.file(fileURL, filename)
}  
if (!file.exists("UCI HAR Dataset")) { 
  unzip(filename)
}

# Load activity labels + features
ActivityLabels <- read.table("UCI HAR Dataset/activity_labels.txt")
ActivityLabels[,2] <- as.character(activityLabels[,2])
Features <- read.table("UCI HAR Dataset/features.txt")
Features[,2] <- as.character(features[,2])

# Extract only the data on mean and standard deviation
FeaturesWanted <- grep(".*mean.*|.*std.*", Features[,2])
FeaturesWanted.names <- Features[FeaturesWanted,2]
FeaturesWanted.names = gsub('-mean', 'Mean', FeaturesWanted.names)
FeaturesWanted.names = gsub('-std', 'Std', FeaturesWanted.names)
FeaturesWanted.names <- gsub('[-()]', '', FeaturesWanted.names)


# Load the datasets
train <- read.table("UCI HAR Dataset/train/X_train.txt")[FeaturesWanted]
trainActivities <- read.table("UCI HAR Dataset/train/Y_train.txt")
trainSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
train <- cbind(trainSubjects, trainActivities, train)

test <- read.table("UCI HAR Dataset/test/X_test.txt")[FeaturesWanted]
testActivities <- read.table("UCI HAR Dataset/test/Y_test.txt")
testSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
test <- cbind(testSubjects, testActivities, test)

# merge datasets and add labels
allData <- rbind(train, test)
colnames(allData) <- c("subject", "activity", FeaturesWanted.names)

# turn activities & subjects into factors with Labels
allData$activity <- factor(allData$activity, levels = activityLabels[,1], labels = activityLabels[,2])
allData$subject <- as.factor(allData$subject)

allData.melted <- melt(allData, id = c("subject", "activity"))
allData.mean <- dcast(allData.melted, subject + activity ~ variable, mean)

write.table(allData.mean, "tidy.txt", row.names = FALSE, quote = FALSE)
