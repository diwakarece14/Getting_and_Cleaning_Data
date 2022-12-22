# Load required utilities
if(!library(reshape2, logical.return = TRUE)) {
  # It didn't exist, so install the package, and then load it
  install.packages('reshape2')
  library(reshape2)
}

## Data Description & Source File URLs

dataDescription <- "http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones"
dataUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

# Download and Extract Zip Archive
download.file(dataUrl, destfile = "data.zip")
unzip("data.zip")

# 1. Merge training and test sets to create one data set

# Read Activity and Feature Labels
activity_labels <- read.table("./UCI HAR Dataset/activity_labels.txt")
features <- read.table("./UCI HAR Dataset/features.txt") 

# Read Test data
subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt")
X_test <- read.table("./UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("./UCI HAR Dataset/test/y_test.txt")

# Read Train data
subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt")
X_train <- read.table("./UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("./UCI HAR Dataset/train/y_train.txt")

# Combine subjects, activity labels, and features into test and train sets
test  <- cbind(subject_test, y_test, X_test)
train <- cbind(subject_train, y_train, X_train)

# Combine test and train sets into full data set
fullSet <- rbind(test, train)

# 2. Extract only measurements on mean and standard deviation

# Subset, keeeping mean, std columns; also keep subject, activity columns
allNames <- c("subject", "activity", as.character(features$V2))
meanStdColumns <- grep("subject|activity|[Mm]ean|std", allNames, value = FALSE)
reducedSet <- fullSet[ ,meanStdColumns]

# 3. Use descriptive activities names for activity measurements

# Use indexing to apply activity names to corresponding activity number
names(activity_labels) <- c("activityNumber", "activityName")
reducedSet$V1.1 <- activity_labels$activityName[reducedSet$V1.1]

# 4. Appropriately Label the Dataset with Descriptive Variable Names

# Use series of substitutions to rename varaiables
reducedNames <- allNames[meanStdColumns]    # Names after subsetting
reducedNames <- gsub("mean", "Mean", reducedNames)
reducedNames <- gsub("std", "Std", reducedNames)
reducedNames <- gsub("gravity", "Gravity", reducedNames)
reducedNames <- gsub("[[:punct:]]", "", reducedNames)
reducedNames <- gsub("^t", "time", reducedNames)
reducedNames <- gsub("^f", "frequency", reducedNames)
reducedNames <- gsub("^anglet", "angleTime", reducedNames)
names(reducedSet) <- reducedNames   # Apply new names to dataframe

# 5. Create tidy data set with average of each variable, by activity, by subject

# Create tidy data set

# Melt the data so we have a unique row for each combination of subject and activities
final.melted <- melt(reducedSet, id = c('subject', 'activity'))

# Cast it getting the mean value
final.mean <- dcast(final.melted, subject + activity ~ variable, mean)

# Emit the data out to a file
write.table(final.mean, file=file.path("tidy.txt"), row.names = FALSE, quote = FALSE)

# Call to read in tidy data set produced and validate steps
validate <- read.table("tidy.txt")
View(validate)
