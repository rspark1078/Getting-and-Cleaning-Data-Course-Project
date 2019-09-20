# Set up environment
rm(list = ls())

library(tidyverse)
library(data.table)
library(dplyr)


################################################################################################
## Loading Data Sets
################################################################################################

# label Info for both sets
lbl_feat <- read_table2("./data/projdata/features.txt", col_names = FALSE)
lbl_act <- read_table("./data/projdata/activity_labels.txt", col_names = FALSE)

# training sets
tr_lbl <- read_table(file = "./data/projdata/train/Y_train.txt", col_names = FALSE)
tr_sub <- read_table(file = "./data/projdata/train/subject_train.txt", col_names = FALSE)
tr_set <- read_table(file = "./data/projdata/train/X_train.txt", col_names = FALSE)

# test sets
ts_lbl <- read_table(file = "./data/projdata/test/Y_test.txt", col_names = FALSE)
ts_sub <- read_table(file = "./data/projdata/test/subject_test.txt", col_names = FALSE)
ts_set <- read_table(file = "./data/projdata/test/X_test.txt", col_names = FALSE)

################################################################################################
## Loading Inertial Signals Data sets (doing nothing now)
################################################################################################
tr_set_is_bodyacc_x <- read_table(file = "./data/projdata/train/Inertial Signals/body_acc_x_train.txt", col_names = FALSE)
tr_set_is_bodyacc_y <- read_table(file = "./data/projdata/train/Inertial Signals/body_acc_y_train.txt", col_names = FALSE)
tr_set_is_bodyacc_z <- read_table(file = "./data/projdata/train/Inertial Signals/body_acc_z_train.txt", col_names = FALSE)
tr_set_is_bodygyro_x <- read_table(file = "./data/projdata/train/Inertial Signals/body_gyro_x_train.txt", col_names = FALSE)
tr_set_is_bodygyro_y <- read_table(file = "./data/projdata/train/Inertial Signals/body_gyro_y_train.txt", col_names = FALSE)
tr_set_is_bodygyro_z <- read_table(file = "./data/projdata/train/Inertial Signals/body_gyro_z_train.txt", col_names = FALSE)
tr_set_is_totalacc_x <- read_table(file = "./data/projdata/train/Inertial Signals/total_acc_x_train.txt", col_names = FALSE)
tr_set_is_totalacc_y <- read_table(file = "./data/projdata/train/Inertial Signals/total_acc_y_train.txt", col_names = FALSE)
tr_set_is_totalacc_z <- read_table(file = "./data/projdata/train/Inertial Signals/total_acc_z_train.txt", col_names = FALSE)

ts_set_is_bodyacc_x <- read_table(file = "./data/projdata/test/Inertial Signals/body_acc_x_test.txt", col_names = FALSE)
ts_set_is_bodyacc_y <- read_table(file = "./data/projdata/test/Inertial Signals/body_acc_y_test.txt", col_names = FALSE)
ts_set_is_bodyacc_z <- read_table(file = "./data/projdata/test/Inertial Signals/body_acc_z_test.txt", col_names = FALSE)
ts_set_is_bodygyro_x <- read_table(file = "./data/projdata/test/Inertial Signals/body_gyro_x_test.txt", col_names = FALSE)
ts_set_is_bodygyro_y <- read_table(file = "./data/projdata/test/Inertial Signals/body_gyro_y_test.txt", col_names = FALSE)
ts_set_is_bodygyro_z <- read_table(file = "./data/projdata/test/Inertial Signals/body_gyro_z_test.txt", col_names = FALSE)
ts_set_is_totalacc_x <- read_table(file = "./data/projdata/test/Inertial Signals/total_acc_x_test.txt", col_names = FALSE)
ts_set_is_totalacc_y <- read_table(file = "./data/projdata/test/Inertial Signals/total_acc_y_test.txt", col_names = FALSE)
ts_set_is_totalacc_z <- read_table(file = "./data/projdata/test/Inertial Signals/total_acc_z_test.txt", col_names = FALSE)

################################################################################################
## Perform some minor cleanup to the data
################################################################################################

# Given no column names were established, define column names so makes sense when merging later
names(tr_lbl) <- "activity_id"
names(ts_lbl) <- "activity_id"
names(lbl_act) <- c("activity_id", "activity_des")
names(tr_sub) <- "sub_id"
names(ts_sub) <- "sub_id"
names(lbl_feat) <- c("id", "feat_desc")


# Just in case we combine both the test and training data sets, add another column in the s
# subjects data-sets (1) test, (2) train
# Just playing with different ways to add another column
tr_sub$sub_type = "train"
ts_sub <- mutate(ts_sub, sub_type = "test")

# To make merging/joining add a column with the keylin
lbl_feat$feat_id = paste0("X", as.character(lbl_feat$id))

# column bind the datasets for train and test
# This assumes the following when column binding
# 1) the order of the data file is the same as the source text file
# 2) the order doesn't change when you column bind
ts_data <- bind_cols(ts_sub, ts_lbl, ts_set)
tr_data <- bind_cols(tr_sub, tr_lbl, tr_set)

# row bind the train and test data set into one
all_data <- bind_rows(ts_data, tr_data)

################################################################################################
## Start Tidying Data!
################################################################################################

# make a subjects table
all_sub <- bind_rows(unique(ts_sub), unique(tr_sub)) %>% 
  arrange(sub_id)

# confirms that subject ids ("sub_id") is unique across the test and train data sets
nrow(all_sub) == length(unique(all_sub$sub_id))

# create tidy dataset
all_data_tidy <- gather(all_data, feat_id, feat_val, -c(sub_id, sub_type, activity_id))

# merge data to get lablels
m_data <- inner_join(all_data_tidy, lbl_feat, by = "feat_id") %>%
  inner_join(lbl_act, by = "activity_id")

# filter for mean and standard deviation observations.
m_data_filtered <- filter(m_data, grepl("std()",m_data$feat_desc) | grepl("mean()",m_data$feat_desc))

# perform group by
m_group <- group_by(m_data_filtered, sub_id, activity_des, feat_desc )

final_res <- summarize(m_group, mean_val =  mean(feat_val))
write.table(final_res, file = "./data/proj_results.txt", row.name = FALSE)

