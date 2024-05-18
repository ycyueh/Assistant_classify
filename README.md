比較三種傳統分類模型對於資料異常檢測(Anomaly Detection)
( unsupervised 的演算法)
1.  One-Class SVM 
  訓練數據只有一個分類，透過這些正常樣本的特徵去學習一個決策邊界，   
  再透過這個邊界去判別新的資料點是否與訓練數據類似，超出邊界即視為異常，    
  異常/小樣本（FALSE），而為正常/大樣本（TRUE）。  
  One-Class SVM 返回的 y 值為 1 代表正常 (inlier)，返回值為 -1 代表異常 ( outlier )  
  note:邊界如何定義  
    by nu 參數（介於 0~1的比率）。舉例：nu =0.1，代表了：正常樣本卻誤判為異常的最多不超過 10%  
    nu: An upper bound on the fraction of training errors and a lower bound of the fraction of support vectors. Should be in the interval (0, 1]. By default 0.5 will be taken.
2. 高斯混合模型 (Gaussian mixture model)
  library(mclust)  
  針對某一類樣本去進行配適，當估計完成，得到對應的密度函數參數後，即可用來評估新資料是否與這群樣本來自於同樣的分類。  
  如果可能性很高，則判斷為同類 ; 如果可能性很低，則判斷為異類。  
  GMM 透過調整各（K）個高斯分布的 mean 跟 variance 並給予它們不同的權重（weights）來實現 approach  
  note:  
   "調整" 參數的方法是利用 EM演算法（Expectation-Maximization Algorithm）  
3. Isolation Forest 孤立森林  
   透過不斷選取特徵去區分子群後，透過判別每一個資料點的深度，決定是否為異常值。  
   透過計算樣本在每一棵樹的深度，去區分樣本是否為異常值  
   透過多棵樹去避開選取到無鑑別力特徵的問題  
