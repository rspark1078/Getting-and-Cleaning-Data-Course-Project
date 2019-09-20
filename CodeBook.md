#######################################################################################
Data Sets Used
#######################################################################################

Referential Data Sets:
1) "features.txt: (561 obs) Provides column header information need to interpret both the training and test data sets.
2) "activity_labels.txt": (6 obs) Look up / Reference table.  

Training and Test Data Sets:
Both groups of data sets are structured in the same way. All training datasets contain 7352 observations / records and test datasets contain 2947 observations / reords.
1) "subject_[train/test].txt": single variable with the subject id
2) "Y_[train/test].txt": single variable of the actvity id. Reference back to "activity_labels" for description
3) "X_[train/test].txt": 561 variables (i.e. columns). Reference back to "features.txt" for variable / column names.

Each data set (train / test) have an equal number of records, so they need to be column bound before any analysis is performed which may alter the row or sequence. Also, I am assuming for the time being that the record index is preserved when data is loaded from flat file into the R environment. That is, the 965th line item in the text file equals the 965th record in R. (Note: This is not alwasy the case in when importing data into other DB environments).

#######################################################################################
Data Import / Data Cleaning
#######################################################################################
Utilized the read_table and read_table2 functions from the readr package. The advantage being that it can compensate for varying length of white space between each column, given the files did not appear to have a delimiter and was most likley a fixed width file. Example:

tr_sub <- read_table(file = "X_test.txt", col_names = FALSE)

It is important for the test dataset, col_names is set to FALSE, because we want R to provide the autoincrementing column name that we can leverage. For those instances where we know we will be joining / merging datasets, it is important to provide those the same name. See below for some examples:

names(tr_lbl) <- "activity_id"
names(ts_lbl) <- "activity_id"
names(lbl_act) <- c("activity_id", "activity_des")
names(tr_sub) <- "sub_id"
names(ts_sub) <- "sub_id"

Even between the train and test datasets, it is important to have standardized names as we will be using both inner_join and  bind_col functions which require the same value for simplicity.

#######################################################################################
Some key pionts in Joining and Tidying Up Data (Data Tranformations)
#######################################################################################
1) Column bind the test and train data sets (Subject, Y, X) with teh bind_cols() function as they have the same record count.
2) Combine the test and train datsets with the bind_rows() function as the data structure should be the same.
3) Use the gather() command. Pleae note that you should have a column / variable X1, X2, ... X561. 
4) Create another column / variable in the feature data set, that takes the appends "X" to the column number. THis will allow you to joing the actual variable name.
lbl_feat$feat_id = paste0("X", as.character(lbl_feat$id))
5) Join the datasets to include "activity"
6) filter the data for std() and mean() using the grep1() function







