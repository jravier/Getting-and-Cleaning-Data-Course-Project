library(data.table)
library(dplyr)
datapath="./.RData"
#initialdatasets=c("test", "train")


#####################################################################
## this function returns a dataframe containing the data set to be submitted
## as the result of the project. See the ReadMe file for more explanations.
CourseProject<-function(){
    ## 1. Merges the training and the test sets to create one data set.
    fulldataset<-rbind(fread(file.path(datapath, "test", "X_test.txt")),
                       fread(file.path(datapath, "train", "X_train.txt")))
    ## 2. Extracts only the measurements 
    ##    on the mean and standard deviation for each measurement.
    ##  a:  Start by reading the column names from the definition
    ##  b:  =>keep only the columns labeled with -mean() or -std()
    ##      !! Also keep the angle measurements between the Mean vectors (last cols)
    ##  c:  filter the data set colums to keep, by their number
    featurecols<-fread(file.path(datapath, "features.txt")) %>% 
        filter(grepl("-mean\\()|-std\\()|^angle\\(", V2))
    fulldataset<-select(fulldataset, featurecols$V1)
    
    ## 3. Uses descriptive activity names to name the activities in the data set
    ##  a: read the definitions (factors) of the activity codes
    ##  b: read and bind the 2 files (test & train) containing the activities
    ##      codes for each measurement
    ##  c: add a column to the result with the corresponding activity factor
    tblActivities<-read.table(file.path(datapath, "activity_labels.txt"))
    activities<-rbind(fread(file.path(datapath, "test", "y_test.txt")),
                      fread(file.path(datapath, "train", "y_train.txt")))
    activities$activity<-tblActivities[activities$V1, 2]
    
    ## 4. Appropriately labels the data set with descriptive variable names.
    #       making nicer colnames (title) for the dataset here, 
    #       breaking the original names (cf. codebook)
    #       into meaningful bits : domain, quantity, component, measure
    #       and rearranging them into ordered titles
    
    #domain (time or frequence) of the measure
    featurecols$domain=ifelse(grepl("^(t|angle\\()",featurecols$V2), "time", "freq")
    #measured quantity
    featurecols$quantity=ifelse(grepl("tGravityAcc",featurecols$V2), "gravity", 
                                gsub("^(?:t|f|angle\\(t|angle\\()(?:Body)*(\\w+?)(?:Mag-|(?:Mean|Mean\\)|),|-).+",
                                     "\\1", featurecols$V2))
    #measured component of the quantity
    featurecols$component=ifelse(grepl("^angle\\(",featurecols$V2), "AngletoGravity", 
                                 ifelse(grepl("Mag-",featurecols$V2), "Magnitude", 
                                        gsub("[^-]+?-[^-]+?-([XYZ])$","\\1", featurecols$V2)))
    #measurment taken on the component
    featurecols$measure=ifelse(grepl("^angle\\(",featurecols$V2), "(Mean)", 
                               gsub("[^-]+?-(\\w+?)\\(\\).*","\\1", featurecols$V2))

    #! construction of the new titles
    featurecols$title=paste(featurecols$domain, featurecols$quantity, 
                            featurecols$component, featurecols$measure, sep = ".")
    #! rename the variables in the dataset
    names(fulldataset)<-featurecols$title
    
    #! reorder variable colums into something more meaningful:
    # 1: domains (same as original dataset: time then frequency)
    # 2: Order: 
    #       a: body/not body : non BODY data are of lesser interest for application 
    #           and are put last (0)
    #       b: Referencial: data (X, Y, Z) bound to the captors referential are of lesser 
    #           interest (1) for application than data (Mag & angle) bound to a fixed 
    #           referencial such as gravity (2)
    # 4: measured Body quantities (same as original dataset: Acc, AccJerk, Gyro, GyroJerk)
    # 5: Component measured of that quantity: 
    #       higher level (angle to Gravity & magnitude) components are put 
    #       before lower level (X, Y ,Z are reltive to the phone captors) ones
    # 6: measure (same as original dataset: mean then std)
    featurecols$order=ifelse(grepl("gravity|X|Y|Z",featurecols$quantity), 0, 
                             ifelse(grepl("X|Y|Z",featurecols$component), 1, 2))
    featurecols<-arrange(featurecols, desc(domain), desc(order), quantity, component, measure)
    fulldataset<-select(fulldataset, featurecols$title)
    
    #! finally, append Subjects and activities identifiers to the left of the values
    subjects<-rbind(fread(file.path(datapath, "test", "subject_test.txt")),
                    fread(file.path(datapath, "train", "subject_train.txt")))
    fulldataset<-cbind("subject"=subjects$V1, "activity"=activities$activity, fulldataset)
    
    ## 5. From the data set in step 4, creates a second, 
    ##      independent tidy data set with the average of each variable 
    ##      for each activity and each subject.
    ##  a: melt all the measures into the narrow form, by subject and activity
    ##  b: cast the mean of each variable for each subject and activity
    dataMelt <- melt(fulldataset,id=c("subject","activity"),measure.vars=featurecols$title)
    SubjActMeans<-dcast(dataMelt, subject + activity ~ variable, mean)
    
    # END: return the result data set
    SubjActMeans
}


#####################################################################
## this function just write the data set to a text file.
##      It has a header line and 180 obsevations of 75 variables
##      Values are space-separted
##      character strings are double-quoted
##      Decimal point for numerical values is the dot(.)
WriteDataSet<-function(){
    write.table(CourseProject(), file="VariableMeansBySubjectAndActivity.txt", row.name=FALSE)
}

#####################################################################
## this function can be called to get information about initial the dataset.
## not used for producing the result dataset but useful at the beginning !
##
## It scans through the files in the data directory 
## and output for each file:
## - its relative file path/name
## - its size
## - the numbers of rows and columns in its content
##
## an internal parameter can be adjusted to exclude non data files in the directory
printInitialDataInfo<-function(){
    excludedfiles=c("README.txt", "features_info.txt")
    dataFlist<-list.files(datapath, recursive = TRUE)
    datalist=data.frame()
    for (f in dataFlist){
        if(!f %in% excludedfiles) {
            fp=file.path(datapath, f)
            content<-fread(fp)  #, sep=" ", as.is = TRUE
            fdesc<-list("file"=as.character(f),"size"=file.size(fp), "rows"=nrow(content), "cols"=ncol(content))
            datalist<-rbind(datalist,fdesc, stringsAsFactors=FALSE)
        }
    }
    print(datalist)
}


