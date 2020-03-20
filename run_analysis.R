library(data.table)
library(dplyr)
#datapath="./.RData"
datapath="UCI HAR Dataset"

#####################################################################
##  run_analysis.R for the Getting and Cleaning Data Course Project
##
##      See the "How to use the script" section in the 
##      README.md file at the root of the repo
##          or just look a t the comments in the code 
##              & run one of the 3 functions below
##
#####################################################################

#####################################################################
## this function returns a dataframe containing the data set to be submitted
## as the result of the project. 
##      See the ReadMe for more explanations on how to use it.
##      See the CodeBook for more explanations on what and why.
##      The code is also well commented, so you may just go reading it!
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
    ##  c: add a column to the result with the corresponding activity factors
    tblActivities<-read.table(file.path(datapath, "activity_labels.txt"))
    activities<-rbind(fread(file.path(datapath, "test", "y_test.txt")),
                      fread(file.path(datapath, "train", "y_train.txt")))
    activities$activity<-tblActivities[activities$V1, 2]
    
    
    ## 4. Appropriately labels the data set with descriptive variable names.
    #       we make nicer colnames (title) for the dataset by looking 
    #       at the original names (cf. source codebook), then
    #       tagging them with meaningful tokens for : domain, quantity, component, measure
    #       and finally rearranging them into ordered titles
    
    #! Tagging:
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
    featurecols$measure=ifelse(grepl("^angle\\(",featurecols$V2), "Mean", 
                               gsub("[^-]+?-(\\w+?)\\(\\).*","\\1", featurecols$V2))

    #! Construction of the new titles
    featurecols$title=paste(featurecols$domain, featurecols$quantity, 
                            featurecols$component, featurecols$measure, sep = ".")
    #! Rename the variables in the dataset
    names(fulldataset)<-featurecols$title
    
    #! Reorder variable colums into something more meaningful: by order of sorting
    # 1: Domains (desc, same as original dataset: time then frequency)
    # 2: Order (desc): 
    #       a: body/not body : non BODY data (gravity) are of lesser interest for my question 
    #           and are put last (0)
    #       b: Referencial: data bound to the captors referential (X, Y, Z) are of lesser 
    #           interest (1) for my question than data bound to a fixed 
    #           referencial (Mag & angle) such as gravity. So they come first (2)
    # 4: Measured Body quantities (alphabetical, same as original dataset: Acc, AccJerk, Gyro, GyroJerk)
    # 5: Component measured of that quantity: (same as original dataset: alphabetical order)
    # 6: Measure taken (same as original dataset: mean then std)
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
## this function just call the 1st one & write the data set to a text file.
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


