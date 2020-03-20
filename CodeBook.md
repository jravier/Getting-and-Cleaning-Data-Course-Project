---
title: "CodeBook"
subtitle: "Getting and Cleaning Data Course Project"
author: "jravier"
date: "20/03/2020"
output: html_document
---
This codebook describes first the source data.  
Next, It explains why the result data set is presented this way.  
It then describes the transformations steps performed to clean up the data.  
And it finaly details the form of the result data set.  

## Source
The source data for this project was collected from the accelerometers and Gyroscopes sensors inside a Samsung Galaxy S smartphone attached to the waist of testing persons while performing different activities.  

* The exact question(s) to which the analysis of this data is supposed to give answers is not verbalised in the information sources listed below (but may be given in the relevant scientific papers mentionned in them). Anyhow, we know from the experiment title that it has to do with **Human Activity Recognition**.  
* The initial data is available for download from https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip.  
* It contains a README.txt file and a codebook describing the data set.  
* A full description is also available at the site where the data was obtained:
http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones  
  
#### Source Parameters
The sensor outputs were recorded and post-treated for a set of observations in a experiment where the parameters were :  

* The subject (a person) studied in the experiment. 30 differents subject were studied.  
* The activity performed by the subject during the observation. 6 different activities were studied.  
So we have 30 x 6 = 180 different *parameter sets*.  

#### Source Observations
Multiple observations were recorded for each set of parameters (subject + activity), resulting in more than 10 000 observations.  
Observations were later randomly separated by subjects into 2 *observation sets* (*train* & *test*), probably for performing some machine learning on it, as inferred by the set names.

#### Source Variables
It consists of 561 variables (features), obtained (after pre-processing) by:

* First, either:
    + Taking the time-domain output of the X/Y/Z sensors (accelerometers and gyroscopes).  
    + Calculating some frequency-domain variables from these output.  
    + Calculating some higher level variables from the 2 *variable sets* above. More on this below...  
* Second, calculating statistically meaningful data out of the first step results, over the length of an observation: *mean*, *median*, *standard deviation*, *min*, *max*, etc.  
    + These are the source's final 561 features and so, our **Source Variables**.  

The source data contains a CodeBook describing the produced features, their units and how they were obtained : features_info.txt.  

#### Source Structure
For each set (*train* & *test*), the data is broken down into 3 files:

* a text file with only the 561 features values (one observation per line).  
* a text file with only the subjects ids (one observation per line).  
* a text file with only a code for the activity performed (one observation per line).  

Apart from the the ReadMe and the file describing the features, the data set has 2 others files, so that the information is complete:  

* A listing of the exact names of the features.  
* A dictionary of the code/names of the activities.  

## Question
In Data Science, question should come first but we're in the constraint of the course project, which goal is only to show how we can produce tidy data, without any analysis performed on it. 
However, in each case, the best tidyness depends on the question(s) we want to answer with the data analysis.  
I've thus decided to assign myself a question to keep in mind for tidying the data, (although not performing the analysis -- and well, not answering any question!), so my final data set is presented in the best way to answer it.  

#### So which question ?
First, we are asked to join again the 2 *observation sets* and to only keep the features calculating a mean or a standard deviation. This leads us to think that we don't want anymore to perform machine learning on the data.  
Moreover, we are asked to calculate the averages of these features over the 180 *parameter sets*.  
So it looks like we only want to do some *Exploratory Analysis* on the data (which is consistent with the content of the next course in the specialization!).
  
Second, we know that the data has to do with *Human Activity Recognition*.  
  
  
I will thus present my data set so it can easily be used to **Explore Body Information** in it.  
  
  
## Variables processing
Now that I've got my 'question', what remains to decide?  
We were asked to calculate the average of selected features for each of the *parameter sets*, so I only have left now to decide which variables to select and how to present them.

#### Variables selection
Looking at the features in the source, we see that some of them are more relevant to human activity than others:

* A few features don't describe *Body* motion, but *gravity*.  
    + It's important to keep these features since the raw measurements make no distinction between body or gravity acceleration, and we want to be able to verify that the decoupled data are consistent.  
    + But yet human activity will only be described by the *Body* features.
* The remaining features describe *Body* motion, but many are related to the motion recorded by *one axis* of the sensor in the phone.  
    + So they depend on the attitude of the phone (which side is up, or facing front, etc.).  
    + We still want to keep them to be able to assertain consistency of the more computed data.  
    + but,as is, they will be difficult to use for *Exploratory Analysis*.  
* The few last features, calculated from the other above, are more likely to be of interest for this *Exploratory Analysis*, since they describe *Body* motion in the independant referential of the gravity (which may be considered earth-fixed at this level). These are :  
    + Magnitude of the quantity being measured (absolute in any refential).  
    + It's angle to the gravity vector (pointing downward toward earth center).  

#### Variables ordering
Some features are in the time domain and others in the frequency domain. We keep those two set one after the other, as their meaning are very different. Subsequent ordering of the variables is made according to the following:

* Relevance of the information to the 'question': Independant *Body* motion data first, then X/Y/Z components in the phone referential and last (for time domain) gravity data.  
* Quantity being measured, as in the source (Acceleration, Acceleration Jerk, Gyroscope, Gyroscope Jerk).  
* Measured component (angle/magnitude or X/Y/Z) of the quantity.
* Measure taken: mean or std (standard deviation).  
    + Always together so *Exploratory Analysis* can be done seriously.
    + Please note that for angles, there are no mean or standard deviation calculated, but instead it is an angle calculated from mean vectors (averaging on the whole length of a source observation). Ordering of the operations is significant!

#### Variables renaming
Feature names in the source are self explanatory as what is measured, however:  

* There are a few inconsistencies (phrase 'Body' doubled in some names, an extra ')' in an angle...)  
* Domain is only expressed by one letter (t/f), and absent for some angles.
* The phrase 'Body' is not necessary since we understood that all measured quantities are relevant to *Body* motion, except for gravity.  

Since we wanted to descriminate features for reordering the variables, we already tagged them with domains, quantities, components and measures tokens. So renaming was straight forward using these tags.  
New variables names are the concatenations (sep = ".") of the following 4 tokens:  

* domain (time or freq)
* quantity (Acc, AccJerk, Gyro, GyroJerk, gravity). Enough self explanatory even if abbreviated.
* Component of the quantity. either:
    + AngletoGravity or Magnitude for the gravity referential
    + X, Y or Z for the phone sensors referential
* measure taken (mean or std). Enough self explanatory even if abbreviated.
    + Please note the special token "Mean" (capital M) for the angles, stressing that it is not the same as the means for the other components.

The tokens are separated by a dot in the names, so they are clearly identified.
It doesn't appear to be a problem for using the variables names in code.

## Transformation
Given the above explanations, the transformation is easy to describe. Here are the steps taken by the script doing it:  

1. Merges the training and the test sets to create one data set.
    + The information about which observation comes from which set is not kept, since we only want to perform *Exploratory Analysis* and this information is not relevant in this case. Any analysis going beyond exploration will anyway have to start over with the initial data sets.
2. Extracts only the measurements on the mean and standard deviation for each measurement.
    + Theses have to include the angles as well since they are relevant for *Exploratory Analysis*.
    + Done by loading the features list file and filtering on the features names, then selecting the relevant columns in the merged dataset.
3. Uses descriptive activity names to name the activities in the data set:
    + Done using the dictionary of the code/names of the activities,
    + Then loading and merging the 2 data sets containing the activity codes before adding to it a column with the corresponding activity name.
4. Appropriately labels the data set with descriptive variable names.
    + Here comes first the tagging of the feature names with meaningful tokens for : domain, quantity, component and measure taken.
    + New names are then build from the token, as explained above, and applied to the feature columns of the data set.
    + An additionnal 'Order' token is computed to take into account the relevancy of the feature for **Body motion Exploratory Analysis**, and then order the feature columns accordingly (cf. Variable ordering above).
    + A final substep is necessary to append the Subject IDs and Activity Names at the beginning of each observation row, resulting in a self containing data set.
5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
    


## Resulting data set
Presented in a table, with  an initial row for column headers (parameters and variables).
Written to a text file using R function write.table() using row.name=FALSE.  

#### Observations (180 rows)  
One row for each observation, corresponding to one element of the subject + activity *parameter sets*.  

#### Parameters (2 columns)  
Each one in a column at the beginning of each row.  
  
subject: the ID of the person at test (integer, 1:30)  
activity: the name of the activity (6 factors, as per the dictionary of the code/names in the source)  
  
#### Variables (73 columns)
Each one in a subsequent column, in the following order.  
  
time.Acc.AngletoGravity.Mean  
time.Acc.Magnitude.mean  
time.Acc.Magnitude.std  
time.AccJerk.AngletoGravity.Mean  
time.AccJerk.Magnitude.mean  
time.AccJerk.Magnitude.std  
time.Gyro.AngletoGravity.Mean  
time.Gyro.Magnitude.mean  
time.Gyro.Magnitude.std  
time.GyroJerk.AngletoGravity.Mean  
time.GyroJerk.Magnitude.mean  
time.GyroJerk.Magnitude.std  
time.Acc.X.mean  
time.Acc.X.std  
time.Acc.Y.mean  
time.Acc.Y.std  
time.Acc.Z.mean  
time.Acc.Z.std  
time.AccJerk.X.mean  
time.AccJerk.X.std  
time.AccJerk.Y.mean  
time.AccJerk.Y.std  
time.AccJerk.Z.mean  
time.AccJerk.Z.std  
time.Gyro.X.mean  
time.Gyro.X.std  
time.Gyro.Y.mean  
time.Gyro.Y.std  
time.Gyro.Z.mean  
time.Gyro.Z.std  
time.GyroJerk.X.mean  
time.GyroJerk.X.std  
time.GyroJerk.Y.mean  
time.GyroJerk.Y.std  
time.GyroJerk.Z.mean  
time.GyroJerk.Z.std  
time.gravity.Magnitude.mean  
time.gravity.Magnitude.std  
time.gravity.X.mean  
time.gravity.X.std  
time.gravity.Y.mean  
time.gravity.Y.std  
time.gravity.Z.mean  
time.gravity.Z.std  
time.X.AngletoGravity.Mean  
time.Y.AngletoGravity.Mean  
time.Z.AngletoGravity.Mean  
freq.Acc.Magnitude.mean  
freq.Acc.Magnitude.std  
freq.AccJerk.Magnitude.mean  
freq.AccJerk.Magnitude.std  
freq.Gyro.Magnitude.mean  
freq.Gyro.Magnitude.std  
freq.GyroJerk.Magnitude.mean  
freq.GyroJerk.Magnitude.std  
freq.Acc.X.mean  
freq.Acc.X.std  
freq.Acc.Y.mean  
freq.Acc.Y.std  
freq.Acc.Z.mean  
freq.Acc.Z.std  
freq.AccJerk.X.mean  
freq.AccJerk.X.std  
freq.AccJerk.Y.mean  
freq.AccJerk.Y.std  
freq.AccJerk.Z.mean  
freq.AccJerk.Z.std  
freq.Gyro.X.mean  
freq.Gyro.X.std  
freq.Gyro.Y.mean  
freq.Gyro.Y.std  
freq.Gyro.Z.mean  
freq.Gyro.Z.std  

#### Values
The value given for each variable of each observation in the result set is the average of all the values of the corresponding variable in the source, the observations being grouped by Subject and Activity.  
  
Units are the same as in the source. Depending of the domain and quantity measured:

* Time domain:
  + acc: m.s^-2^
  + accJerk: m.s^-3^
  + Gyro: rad.s^-1^
  + GyroJerk: rad.s^-2^
* Frequency domain: Hz

#### File Format
the resulting data set is stored as a table in a TXT file (west european text encoding)
If can be read back into R using read.table() with a parameter header = TRUE.
If you use another way to read it, these may be useful:
* It has a header row and 180 observations row, each of 75 columns
* Values are space-separted
* character strings are double-quoted
* Decimal point for numerical values is the dot(.) and decimal values are not rounded