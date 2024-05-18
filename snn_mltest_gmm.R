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
###### GMM############
######################
# Install and load the mclust package
#install.packages("mclust")
library(mclust)

##Resampling###########
n=100
my_seeds <- c(1:n) # These are 10 seeds, 1, 2, 3...10. Change to whatever.     
gmmkeep<-list()
for (i in 1:n){
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
  
  model <- Mclust(train_df, G = 2)  # You can adjust the number of clusters (G) as needed
  
  # Predict cluster assignments for the test data
  predictions <- predict(model, newdata = test_unlabel)
  threshold = which.max(c(sum(model$classification==1),sum(model$classification==2)))
  
  # Access the predicted cluster assignments
  predicted_clusters = ifelse(predictions$classification==threshold,0,1)
  gmmkeep[[i]] = table(Real = test_df$y, pred = predicted_clusters )
  
}

## Isolation Forest
# Install and load required library

