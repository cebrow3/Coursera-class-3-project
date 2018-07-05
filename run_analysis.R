##download data and unzip file
if(!file.exists("./data")){dir.create("./data")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip" 
download.file(fileUrl, destfile = "./data/ProjectData.zip")
unzip(zipfile = "./data/ProjectData.zip", exdir = "./data")

##read in the test and train raw data and combine- fulfills 1
traindata <- read.table(file.path("./data/UCI HAR Dataset/train/X_train.txt"))
testdata <-read.table(file.path("./data/UCI HAR Dataset/test/X_test.txt"))
alldata <- rbind(traindata, testdata)

##read in data features, modify variable names, and add to all data- fulfills 4
datafeatures <- read.table(file.path("./data/UCI HAR Dataset/features.txt"))
setnames(datafeatures, "V1", "featurenumber")
setnames(datafeatures, "V2", "featurename")
featurename <- datafeatures$featurename
featurename <- tolower(featurename)
featurename <- gsub("std", "sd", featurename)
featurename <- gsub("^t", "time", featurename)
featurename <- gsub("^f", "frequency", featurename)
## can replace more abbreviations based on features_info text
colnames(alldata) <- featurename

##extract only data that has mean or standard deviation measurement- fulfills 2
subsetdata <- grep("mean|sd", featurename)
meansddata <- subset(alldata, select = subsetdata)

##read in subject and activity data, adjust activity names, add to all data- fulfills 3
trainsubject <- read.table(file.path("./data/UCI HAR Dataset/train/subject_train.txt"))
testsubject <- read.table(file.path("./data/UCI HAR Dataset/test/subject_test.txt"))
allsubjects <- rbind(trainsubject, testsubject)
setnames(allsubjects, "V1", "subjectnumber")

trainactivity <- read.table(file.path("./data/UCI HAR Dataset/train/y_train.txt"))
testactivity <- read.table(file.path("./data/UCI HAR Dataset/test/subject_test.txt"))
allactivity <- rbind(trainactivity, testactivity)
setnames(allactivity, "V1", "activitynumber")

activitylabels <- read.table(file.path("./data/UCI HAR Dataset/activity_labels.txt"))
setnames(activitylabels, "V1", "activitynumber")
setnames(activitylabels, "V2", "activityname")
levels(activitylabels$activityname) <- tolower(levels(activitylabels$activityname))
levels(activitylabels$activityname) <- sub("_", "", levels(activitylabels$activityname))

meansddata <- cbind(allsubjects, allactivity, meansddata)
meansddata <- merge(activitylabels, meansddata, by = "activitynumber")
meansddata <-meansddata[,c(3,1,2, 4:89)] ##puts subjects first/personal pref

## create second tidy data set with feature means, grouped by activity and subject- fulfills 4
meansddata$activityname <- as.character(meansddata$activityname)
meansddata$subjectnumber <- as.character(meansddata$subjectnumber)
tidydata <- aggregate(. ~subjectnumber + activityname, meansddata, mean)
tidydata <- tidydata[order(tidydata$subjectnumber, tidydata$activityname),]
write.table(tidydata, "tidydata.txt", row.names = FALSE)
