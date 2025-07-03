library(data.table)
library(multinma)
library(ggplot2)


## Pitak's last sheet with rankings
D <- fread("PME.csv")


## number in each study
D[,num:=.N,by=Identifier]
D[,uniqueN(Identifier)]
D[,range(num)]
D[,unique(`Rank within study`)]

## =============== visualization


## trying Categories
DM_Category <- set_agd_arm( 
                   data= D[num>1 & !is.na(`Rank within study`) & !is.na(Category)],
                   study = Identifier,
                   trt = Category,
                   r=num,
                   E = `Rank within study`,
                   sample_size=num)

print(DM_Category)
plot(DM_Category, weight_nodes = TRUE) 

################[Warning take hours to run!!]######################

# Test_nma <- nma(DM_Category,
#               trt_effects = "random",
#               consistency = "consistency")

#~Out Put~

# > print(Test_nma)

# Note: Setting "Machine Learning" as the network reference treatment.

# A random effects NMA with a poisson likelihood (log link).
# Inference for Stan model: poisson.
# 4 chains, each with iter=2000; warmup=1000; thin=1; 
# post-warmup draws per chain=1000, total post-warmup draws=4000.
# 
#                       mean se_mean    sd      2.5%       25%       50%       75%     97.5% n_eff Rhat
# d[Deep Learning]      0.44    0.01  0.14      0.18      0.34      0.44      0.53      0.71   208 1.03
# d[Ensemble]           1.02    0.01  0.16      0.70      0.91      1.01      1.12      1.33   212 1.03
# d[Hybrid]             0.33    0.01  0.14      0.05      0.23      0.34      0.43      0.61   154 1.06
# d[Time Series]       -0.06    0.01  0.13     -0.31     -0.15     -0.06      0.03      0.21   206 1.02
# lp__             824471.32    1.85 33.77 824403.06 824448.82 824472.00 824494.70 824534.88   332 1.00
# tau                   0.88    0.00  0.02      0.84      0.87      0.88      0.90      0.92   208 1.01
# 
# Samples were drawn using NUTS(diag_e) at Fri May  9 10:47:00 2025.
# For each parameter, n_eff is a crude measure of effective sample size,
# and Rhat is the potential scale reduction factor on split chains (at convergence, Rhat=1).


#Pairwise model relative effects
Test_releff <- relative_effects(Test_nma, all_contrasts = TRUE)

# mean   sd  2.5%   25%   50%   75% 97.5% Bulk_ESS Tail_ESS Rhat
# d[Deep Learning vs. Machine Learning]  0.44 0.14  0.18  0.34  0.44  0.53  0.71      206      399 1.03
# d[Ensemble vs. Machine Learning]       1.02 0.16  0.70  0.91  1.01  1.12  1.33      211      302 1.03
# d[Hybrid vs. Machine Learning]         0.33 0.14  0.05  0.23  0.34  0.43  0.61      134      354 1.06
# d[Time Series vs. Machine Learning]   -0.06 0.13 -0.31 -0.15 -0.06  0.03  0.21      206      465 1.02
# d[Ensemble vs. Deep Learning]          0.58 0.10  0.38  0.51  0.58  0.65  0.78      214      481 1.02
# d[Hybrid vs. Deep Learning]           -0.10 0.08 -0.24 -0.16 -0.10 -0.05  0.05      176      270 1.03
# d[Time Series vs. Deep Learning]      -0.50 0.07 -0.64 -0.54 -0.50 -0.45 -0.36       76      270 1.06
# d[Hybrid vs. Ensemble]                -0.68 0.11 -0.91 -0.76 -0.68 -0.61 -0.45      178      336 1.04
# d[Time Series vs. Ensemble]           -1.08 0.11 -1.30 -1.15 -1.08 -1.00 -0.85      112      424 1.04
# d[Time Series vs. Hybrid]             -0.40 0.08 -0.55 -0.45 -0.39 -0.34 -0.24       63      263 1.07

plot(Test_releff, ref_line = 0)


#Model Ranking
Test_ranks <- posterior_ranks(Test_nma) # Lower_better = TRUE

plot(Test_ranks)

##################################################################

## trying to 'trick' multinma into doing comparison graph for Methods
DM_Model <- set_agd_arm( 
                   data= D[num>1 & !is.na(`Rank within study`)],
                   study = Identifier,
                   trt = Model2,
                   r=num,
                   E = `Rank within study`,
                   sample_size=num)

print(DM_Model)
plot(DM_Model, weight_nodes = TRUE) #too many



#Inclyde only ML

# 1. Filter the data to include only "Machine Learning" entries
D_ML <- D[Category == "Machine Learning"]

# 2. Calculate the number of "Machine Learning" methods within each study
D_ML[, num_ml := .N, by = Identifier]

# 3. Now, select studies that have more than one "Machine Learning" method
DM_ML <- set_agd_arm( data = D_ML[num_ml > 1 & !is.na(`Rank within study`)],
                   study = Identifier,
                   trt = Model2,
                   r = num_ml, # Use the count of ML methods
                   E = `Rank within study`,
                   sample_size = num_ml # Use the count of ML methods
)

plot(DM_ML, weight_nodes = TRUE)


# For Deep Learning
D_DL <- D[Category == "Deep Learning"]
D_DL[, num_dl := .N, by = Identifier]
DM_DL <- set_agd_arm( data = D_DL[num_dl > 1 & !is.na(`Rank within study`)],
                      study = Identifier,
                      trt = Model2,
                      r = num_dl,
                      E = `Rank within study`,
                      sample_size = num_dl
)

plot(DM_DL, weight_nodes = TRUE)

# For Time Series
D_TS <- D[Category == "Time Series"]
D_TS[, num_TS := .N, by = Identifier]
DM_TS <- set_agd_arm( data = D_TS[num_TS > 1 & !is.na(`Rank within study`)],
                      study = Identifier,
                      trt = Model2,
                      r = num_TS,
                      E = `Rank within study`,
                      sample_size = num_TS
)

plot(DM_TS, weight_nodes = TRUE)


# For Ensemble
D_Ensemble <- D[Category == "Ensemble"]
D_Ensemble[, num_ensemble := .N, by = Identifier]
DM_Ensemble <- set_agd_arm( data = D_Ensemble[num_ensemble > 1 & !is.na(`Rank within study`)],
                            study = Identifier,
                            trt = Model,
                            r = num_ensemble,
                            E = `Rank within study`,
                            sample_size = num_ensemble
)

plot(DM_Ensemble, weight_nodes = TRUE)

# For Hybrid
D_Hybrid <- D[Category == "Hybrid"]
D_Hybrid[, num_hybrid := .N, by = Identifier]
DM_Hybrid <- set_agd_arm( data = D_Hybrid[num_hybrid > 1 & !is.na(`Rank within study`)],
                          study = Identifier,
                          trt = Model,
                          r = num_hybrid,
                          E = `Rank within study`,
                          sample_size = num_hybrid
)

plot(DM_Hybrid, weight_nodes = TRUE)


## ================ Multi Categories
# For ML + TS
include_ML_n_TS <- c("Machine Learning", "Time Series") 
D_ML_n_TS <- D[Category %in% include_ML_n_TS,]
D_ML_n_TS[, num_ML_n_TS := .N, by = Identifier]
DM_ML_n_TS <- set_agd_arm( data = D_ML_n_TS[num_ML_n_TS > 1 & !is.na(`Rank within study`)],
                           study = Identifier,
                           trt = Model2,
                           r = num_ML_n_TS,
                           E = `Rank within study`,
                           sample_size = num_ML_n_TS
)

plot(DM_ML_n_TS, weight_nodes = TRUE)

# For Hybrid + Ensemble = Mixed methods
include_Hy_n_Es <- c("Hybrid", "Ensemble")
D_Hy_n_Es  <- D[Category %in% include_Hy_n_Es,]
D_Hy_n_Es [, num_Hy_n_Es := .N, by = Identifier]
DM_Hy_n_Es <- set_agd_arm( data = D_Hy_n_Es[num_Hy_n_Es > 1 & !is.na(`Rank within study`)],
                           study = Identifier,
                           trt = Model, #use "Model" not "Model2"
                           r = num_Hy_n_Es,
                           E = `Rank within study`,
                           sample_size = num_Hy_n_Es
)

plot(DM_Hy_n_Es, weight_nodes = TRUE)



## ================ PNG Saving
png("All_models_nma_plot.png", width = 900, height = 600) 
plot(DM_Model, weight_nodes = TRUE) + labs(title = "All_models")
dev.off()

png("Category_nma_plot.png", width = 800, height = 600) 
plot(DM_Category, weight_nodes = TRUE) + labs(title = "Category")
dev.off()


png("ML_nma_plot.png", width = 900, height = 600) 
plot(DM_ML, weight_nodes = TRUE) + labs(title = "ML")
dev.off()

png("DL_nma_plot.png", width = 800, height = 600) 
plot(DM_DL, weight_nodes = TRUE) + labs(title = "DL")
dev.off()

png("Time_Serie_nma_plot.png", width = 800, height = 600) 
plot(DM_TS, weight_nodes = TRUE) + labs(title = "Time_serie")
dev.off()


png("Ensemble_nma_plot.png", width = 900, height = 600) 
plot(DM_Ensemble, weight_nodes = TRUE) + labs(title = "Ensemble")
dev.off()

png("hybrid_nma_plot.png", width = 800, height = 600) 
plot(DM_Hybrid, weight_nodes = TRUE) + labs(title = "Hybrid")
dev.off()


png("ML_n_TS_nma_plot.png", width = 800, height = 600) 
plot(DM_ML_n_TS, weight_nodes = TRUE) + labs(title = "ML + TS")
dev.off()


png("hybrid_n_Ensemble_nma_plot.png", width = 800, height = 600) 
plot(DM_Hy_n_Es, weight_nodes = TRUE) + labs(title = "Hybrid + Ensemble")
dev.off()


## ================ rankings
# library(sport)
# 
# sdata <- D[,.(Key,'Model2',rank='Rank within study')]
# sdata[,id:=as.integer(as.factor(Key))]
# sdata <- sdata[!is.na(rank)] #exclude
# 
# dbl <- dbl_run(formula = rank | id ~ player('Model2'), data = sdata) #only one I could immediately use
# 
# print(dbl)
# plot(dbl,n=20)
# summary(dbl)
# 
# 
# rnks <- summary(dbl)$r
# print(as.data.frame(rnks[order(r,decreasing=TRUE)]))

