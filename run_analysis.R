#Create temp file because permission denied in current wd for some reason
 temp <- tempfile()
#download file
 download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip", temp)

#read each table, for features table ensure the values are character, and add column names activity id
 y_test <- read.table(unzip(temp, "UCI HAR Dataset/test/y_test.txt"))
 x_test <- read.table(unzip(temp, "UCI HAR Dataset/test/X_test.txt"))
 subject_test <- read.table(unzip(temp, "UCI HAR Dataset/test/subject_test.txt"))
 y_train <- read.table(unzip(temp, "UCI HAR Dataset/train/y_train.txt"))
 x_train <- read.table(unzip(temp, "UCI HAR Dataset/train/X_train.txt"))
 subject_train <- read.table(unzip(temp, "UCI HAR Dataset/train/subject_train.txt"))
features <- read.table(unzip(temp, "UCI HAR Dataset/features.txt"),  colClasses = c("character"))
activity_labels<- read.table(unzip(temp, "UCI HAR Dataset/activity_labels.txt"), col.names = c("ActivityId", "Activity"))


# Combine and merge data
training <- cbind(cbind(x_train, subject_train), y_train)
test <- cbind(cbind(x_test, subject_test), y_test)
full_data <- rbind(training, test)

# dataset full_data does not have any column labels, so next step is to label columns
# features has all the column names, then we add two rows for subject and activity id and only keep the second column
labels <- rbind(rbind(features, c(562, "Subject")), c(563, "ActivityId"))[,2]

# now we assign labels to the columns in full_data
names(full_data) <- labels



# Extract columns with mean and standard deviation and also subject and activity id;
mean_std <- full_data[,grepl("mean|std|Subject|ActivityId", names(full_data))]

library(plyr)

#join activity labels to mean_std dataset by activityid and match just the "first" matching row
mean_std <- join(mean_std, activity_labels, by = "ActivityId", match = "first")

library(dplyr)
#summarize the dataset by subject and activity
summary_data<- mean_std %>%
  group_by(Subject,Activity) %>%
  summarize_all (funs(mean))

#check names
names(summary_data)
# Remove parentheses
names(summary_data) <- gsub('\\(|\\)',"",names(summary_data))


#Creates a second, independent tidy data set
write.table(summary_data, file = "dataclean_wk4assn.txt")

