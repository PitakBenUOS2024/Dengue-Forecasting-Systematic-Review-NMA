# from email:https://mail.google.com/mail/u/0/#label/%E2%8F%B0READ+LATER+%7C+WAIT+TO+REPLY%E2%8F%B0/KtbxLwGrSMNSbPJCBDQMRRCPXbkhjMTMqq

## =====================
library(data.table)
library(multinma)

# getwd()
# setwd('X:\\HAR_WG\\WG\\UKSEA_VAXHUB\\Systematic_Review_Dengue_Forecasting')

## Pitak's last sheet with rankings
D <- fread("PME.csv")

#creat RMSE_LOG10

#RMSE{CHAR} -> RMSE{NUM}
D[, RMSE := as.numeric(RMSE)]

#Or remove the value 0 since it is a outlier
D <- D[RMSE > 0 | RMSE < 0]

#remove negative value (n=3) out before the put in log scale
D <- D[RMSE >= 0]
D[, RMSE_log10 := log10(RMSE)]


#setup DR df
(nmz <- names(D))
(keep <- nmz[c(3,5,29)])
DR <- D[,..keep]
names(DR)[2] <- "method"

DR




# rmv <- c("Hasan, 2024") #single arm
# DR <- DR[!Identifier %in% rmv]
DR[,summary(RMSE_log10)]
DR[,err:=3 + RMSE_log10]

DM <- set_agd_arm( data= DR,
                   study = Identifier,
                   trt = method,
                   y=err,
                   se=err/10
)

print(DM)

plot(DM)

# Take sometimes to run (e.g., 30 min)
smkfit <- nma(DM,
              trt_effects = "random",
              prior_intercept = normal(scale = 100),
              prior_trt = normal(scale = 100),
              prior_het = normal(scale = 5),
              iter = 4000 # Increase from default (often 2000) to 4000, 6000, or more
              )


## relative effects
smk_releff <- relative_effects(smkfit, all_contrasts = FALSE)
smk_releff
plot(smk_releff, ref_line = 0)
# ggsave("nma_releff.pdf",w=10,h=15)

## rank visualizations
#Adjust Rank only 1 to 10
smk_rankprobs <- posterior_rank_probs(smkfit, lower_better = TRUE)
smk_rankprobs 
plot(smk_rankprobs) + xlim(1, 47)
# ggsave("nma_rnkprb.pdf",w=10,h=10)


smk_cumrankprobs <- posterior_rank_probs(smkfit, lower_better = TRUE, cumulative = TRUE)
smk_cumrankprobs
plot(smk_cumrankprobs) + xlim(1, 47)
# ggsave("nma_crnkprb.pdf",w=10,h=10)