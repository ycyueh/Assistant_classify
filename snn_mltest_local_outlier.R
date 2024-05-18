#install.packages("reticulate")
# Load required library
###https://rpubs.com/JordanLin/OCC_iris 
library(reticulate)

use_python("C:\\Users\\USER\\anaconda3\\python.exe")


# Specify the file path
file_path <- "data_B100_S10_dist0.01"

# Use reticulate to load data from the pickle file
data <- reticulate::py_load_object(file_path)

df = as.data.frame(rbind(data[[1]],data[[2]]))
df$y = c(rep(0,nrow(data[[1]])),rep(1,nrow(data[[2]]))) #0:100; 1:10

library(magrittr)
library(tidyverse)
df$index =c(1:nrow(df))
prob_y1 <- sum(df$y == 1) / length(df$y)  # y=1的比例
prob_y0 <- sum(df$y == 0) / length(df$y)  # y=0的比例
train_df <- df %>% group_by(y) %>% sample_frac(0.75, prob = c(prob_y1, prob_y0))
table(train_df$y)
test_df  <- anti_join(df, train_df, by = 'index')
table(test_df$y)

############ Local Outlier Factor#####################
######################################################
# Install and load the necessary package
# Install and load required libraries
#install.packages("dbscan")
n=100
my_seeds <- c(1:n) 
library(dbscan)
## resampling
loflist<-list()
for (i in 1:10) {
  set.seed(my_seeds[i])
  ##########################
  ##########################
  train_df <- df %>% group_by(y) %>% sample_frac(0.75, prob = c(prob_y1, prob_y0))
  #
  test_df  <- anti_join(df, train_df, by = 'index')
  #加入訓練集小樣本
  test_df <-rbind(test_df,train_df[which(train_df$y==1),])
  
  train_df %<>% ungroup() %>% select(-y,-index)
  
  test_unlabel = test_df %>% select(-y,-index)
  
  # Train the LOF model on the training data
  lof_model <- lof(train_df)
  
  # Predict LOF scores for the test data using the trained model
  test_lof_scores <- lof(test_unlabel)
  
  test_lof_scores>1 ##為異常值(小：1)
  loflist[[i]]<-table(test_df$y,1*(test_lof_scores>1))
  
}
