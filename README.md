---
title: "README"
subtitle: "Getting and Cleaning Data Course Project"
author: "jravier"
date: "20/03/2020"
output: html_document
---


## Overview:

This project is about Getting and Cleaning data. It requires to write a script tidying a data set.  
The input (source) is a data set from a real experiment on **Human Activity Recognition** using the Accelerometers and Gyroscopes sensors inside a Samsung Galaxy S smartphone attached to the waist of testing persons while performing different activities.  
The output (result) has to be a single tidy data set "with the average of each variable for each activity and each subject".

* The mentionned variable are "the measurements on the mean and standard deviation for each measurement" in the source. They are described in the source CodeBook.
* The mentionned activities and subjects are also described in the Source CodeBook.  
  
There is also a CodeBook for this project (cf. files list below), summarizing the source one and giving several other important things to know before reviewing this submission.

## included files:

* This README.md, at the root of this Github repository,
* The submitted result data set, uploaded to coursera web site.
    + it can be downloaded from https://coursera-assessments.s3.amazonaws.com/assessments/1584699849298/ffcfe4e2-42b1-48bb-9e0f-3e9aea8a4dce/VariableMeansBySubjectAndActivity.txt
    + alternatively, it can be viewed into R studio by running this piece of code:
```
        address <- "https://coursera-assessments.s3.amazonaws.com/assessments/1584699849298/ffcfe4e2-42b1-48bb-9e0f-3e9aea8a4dce/VariableMeansBySubjectAndActivity.txt"
        address <- sub("^https", "http", address)
        data <- read.table(url(address), header = TRUE) 
        View(data)
```
* The run_analysis.R script (at the root of this Github repository) used to process the downloaded source data and output a .txt file containing the result data set.
* A CodeBook.md file (also at the root of this Github repository), with the following information:
    + describes the source data set and how it can be obtained,
    + explains why the result data set is presented this way,
    + describes the transformations steps performed to clean up the source data in the R script,
    + gives details about the form of the result data set.

## How to use the script:
* Preliminary consideration before running the script:
    + It needs 2 Libraries (data.table & dplyr), so install them first.
    + The source .zip (see the CodeBook for the link to download it) file has to be unzipped to the working directory, meaning that all the source files should be in a "UCI HAR Dataset" directory in this working directory.
    + The run_analysis.R script has to be loaded into R using source('run_analysis.R').
        -    the path provided in this `source()` command has to be adapted if the script itself is not in the working directory.
        - it will load the 2 Libraries (data.table & dplyr) and set a `datapath` variable containing the name of the "UCI HAR Dataset" directory.
        - Nothing else will be executed since all the code reside in functions.
* The data transformation from source to result data set is done by running the `CourseProject()` function with no argument. e.g; to get the result data set in a variable named `result`, just run `result<-CourseProject()`.

* To directly write the result data set to a file named 'VariableMeansBySubjectAndActivity.txt', just run the second function `WriteDataSet()` with no argument.

* A 3rd function is left in the script, as it was useful at the beginning of the project (but doesn't do anything in the transformation): `printInitialDataInfo()` prints to the console a list of all the files in the source (including sub-directories), along with their sizes and the number of rows and columns of the data table in it. Beware that it only works on files with data table. So files not containing one should be excluded using the provided internal parameter.

## Note: 
The README for the source data set states that "Features are normalized and bounded within [-1,1]".  
While this is a good thing to do for gravity, I fail to understand why it should be the case for the other quantities measured: if there are no body motion or a sharp one, vectors' magnitudes should reflect the strength of of these motions...  
I would rather have normalized every accelerometer data to gravity. For Gyro, it would have required some calibration data.

## License:
The original source data set comes with the following Licence Statment (down to the end of this readme).  
  
Use of this dataset in publications must be acknowledged by referencing the following publication [1] 

[1] Davide Anguita, Alessandro Ghio, Luca Oneto, Xavier Parra and Jorge L. Reyes-Ortiz. Human Activity Recognition on Smartphones using a Multiclass Hardware-Friendly Support Vector Machine. International Workshop of Ambient Assisted Living (IWAAL 2012). Vitoria-Gasteiz, Spain. Dec 2012

This dataset is distributed AS-IS and no responsibility implied or explicit can be addressed to the authors or their institutions for its use or misuse. Any commercial use is prohibited.

Jorge L. Reyes-Ortiz, Alessandro Ghio, Luca Oneto, Davide Anguita. November 2012.
