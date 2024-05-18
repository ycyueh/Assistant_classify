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

######## One-Class SVM ##########
###################################
# Install and load the necessary package
#install.packages("e1071")
library(e1071)  #for support vector machine (SVM) modeling in R,
# Perform anomaly detection
#異常/小樣本（FALSE），而為正常/大樣本（TRUE）。
#One-Class SVM 返回的 y 值為 1 代表正常 (inlier)，返回值為 -1 代表異常 ( outlier )
##Resampling###########
n = 100
my_seeds <- c(1:n) # These are n seeds, 1, 2, 3...n. Change to whatever.     
SVM_list <- list()
SVM_list_2 <- list()
for (i in 1:n){
  set.seed(my_seeds[i])
  ##########################
  ##########################
  train_df <- df %>% group_by(y) %>% sample_frac(0.75, prob = c(prob_y1, prob_y0))
  
  #
  test_df  <- anti_join(df, train_df, by = 'index')
  train_df2<-train_df[which(train_df$y==0),]
  #加入訓練集小樣本
  test_df <-rbind(test_df,train_df[which(train_df$y==1),])
  train_df %<>% ungroup() %>% select(-y,-index)
  
  
  test_unlabel <- test_df %>% select(-y,-index)
  # Train a One-Class SVM model
  model <- svm(train_df, type = 'one-class', kernel = 'radial', nu = 0.05)
  # Perform anomaly detection
  svmpredictions <- predict(model, test_unlabel)
  SVM_list[[i]] = table(Real = test_df$y, pred = (!svmpredictions)*1 )
}
