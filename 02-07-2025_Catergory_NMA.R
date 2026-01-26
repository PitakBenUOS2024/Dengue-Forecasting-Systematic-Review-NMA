# from email:https://mail.google.com/mail/u/0/#label/%E2%8F%B0READ+LATER+%7C+WAIT+TO+REPLY%E2%8F%B0/KtbxLwGrSMNSbPJCBDQMRRCPXbkhjMTMqq

## =====================
library(data.table)
library(multinma)

# getwd()
# setwd('X:\\HAR_WG\\WG\\UKSEA_VAXHUB\\Systematic_Review_Dengue_Forecasting')
setwd('/Users/pitakbenjarattanaporn/Documents/Projects/Systematic_Review_Dengue_Forecasting/data')

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
(keep <- nmz[c(3,6,29)])
DR <- D[,..keep]
names(DR)[2] <- "Catergory"

DR

rmv <- c("Hasan, 2024","Patra, 2024") #single arm
DR <- DR[!Identifier %in% rmv]
DR[,summary(RMSE_log10)]
DR[,err:=3 + RMSE_log10]


DM_Category <- set_agd_arm( data= DR,
                   study = Identifier,
                   trt = Catergory,
                   y=err,
                   se=err/10,
                   trt_ref = "Time Series"
)

print(DM_Category)

plot(DM_Category)


smkfit_Category <- nma(DM_Category,
              trt_effects = "random",
              prior_intercept = normal(scale = 100),
              prior_trt = normal(scale = 100),
              prior_het = normal(scale = 1))

smkfit_Category

## relative effects
smk_releff_Category <- relative_effects(smkfit_Category, all_contrasts = FALSE)
smk_releff_Category
plot(smk_releff_Category, ref_line = 0)
# ggsave("Category_nma_releff.pdf",w=10,h=15)

## rank visualizations
smk_rankprobs_Category <- posterior_rank_probs(smkfit_Category, lower_better = TRUE)
smk_rankprobs_Category
plot(smk_rankprobs_Category)
# ggsave("Category_nma_rnkprb.pdf",w=10,h=10)


smk_cumrankprobs_Category <- posterior_rank_probs(smkfit_Category, lower_better = TRUE, cumulative = TRUE)
smk_cumrankprobs_Category
plot(smk_cumrankprobs_Category)
# ggsave("Category_nma_crnkprb.pdf",w=10,h=10)