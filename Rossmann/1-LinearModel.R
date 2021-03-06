###############################
#                             #
# ROSSMANN - SALES PREDICTION #
#                             #
###############################

# ASSUMPTION: The required data files are downloaded from competition site and made available locally.
# COMPETITION SITE URL: https://www.kaggle.com/c/rossmann-store-sales

# Perform house-keeping
rm(list=ls())
gc()

# Set working directory
setwd("C:/home/kaggle/Rossman")

# Load Packages required
library("caTools")
library("lubridate")

# Set seed for reproducibility
set.seed(23456)

# Read train and test data sets from input CSV File
traindata <- read.csv("train.csv", header = T, stringsAsFactors = FALSE)
testdata  <- read.csv("test.csv",  header = T, stringsAsFactors = FALSE)

### Data Cleansing
# Convert Categorical String values into Numerical
traindata$Open  <- as.numeric(as.factor(traindata$Open))
traindata$Promo <- as.numeric(as.factor(traindata$Promo))
traindata$SchoolHoliday <- as.numeric(as.factor(traindata$SchoolHoliday))

# Convert Date String into Date object
traindata$Date <- ymd(traindata$Date)

# Extract days from Date and create a new variable
traindata$days <- day(traindata$Date)

# Extract Months from Date and create a new variable
traindata$months <- month(traindata$Date)

# Extract years from Date and create a new variable
traindata$years <- year(traindata$Date)

# Split train data into train and test data sets
split <- sample.split(traindata$Store, SplitRatio = 0.75)

# Create train data set to generate Model
train <- subset(traindata, split == TRUE)

# Create test data set to perform cross validation
test <- subset(traindata, split == FALSE)

# Remove CustomerID since this feature does not have any importance
train <- subset(train, select = -Customers)


### Model Generation
# Develop basic Linear model
salesmodel <- lm(Sales ~ . -Sales, data = train)

# Prepare test data for model prediction
test <- subset(test, select = -c(Customers))

# Predict Sales for test data
testsales <- predict(salesmodel, newdata = test[, -4])

# Evaluate Model performance
cor(testsales, test$Sales)


### Apply model on actual Test data
# Convert Categorical String values into Numerical in actual test data
testdata$Open <- as.numeric(as.factor(testdata$Open))
testdata$Promo<- as.numeric(as.factor(testdata$Promo))
testdata$SchoolHoliday<- as.numeric(as.factor(testdata$SchoolHoliday))

# Format test data's Date String into Date Object
testdata$Date <- as.Date(testdata$Date, format="%m/%d/%y")
testdata$Date <- ymd(testdata$Date)

# Extract days from Date and create a new variable
testdata$days <- day(testdata$Date)

# Extract Months from Date and create a new variable
testdata$months <- month(testdata$Date)

# Extract years from Date and create a new variable
testdata$years <- year(testdata$Date)


### Prediction
# Predict the Sales value
salesdata <- predict(salesmodel, newdata=testdata)

# Impute NA if any with median sales
salesdata[is.na(salesdata)] <- median(salesdata, na.rm = TRUE)

### Output
# Create data frame with Id and predicted values
salesdatadf <- data.frame(Id = seq(1: 41088), Sales = round(salesdata))

# Write to Output file
write.csv(salesdatadf, file = "1-LinearModel.csv", row.names = F, quote = F)

# Being basic Linear model, this scored 0.61328 in Private LB
