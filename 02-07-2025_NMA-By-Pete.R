# from email:https://mail.google.com/mail/u/0/#label/%E2%8F%B0READ+LATER+%7C+WAIT+TO+REPLY%E2%8F%B0/KtbxLwGrSMNSbPJCBDQMRRCPXbkhjMTMqq

## =====================
library(data.table)
library(multinma)
library(ggplot2)
library(readr)

# getwd()
# setwd('X:\\HAR_WG\\WG\\UKSEA_VAXHUB\\Systematic_Review_Dengue_Forecasting')

# --- 0. Set up some data ---

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


rmv <- c("Hasan, 2024") #single arm
DR <- DR[!Identifier %in% rmv]
DR[,summary(RMSE_log10)]
DR[,err:=3 + RMSE_log10]

DM <- set_agd_arm( data= DR,
                   study = Identifier,
                   trt = method,
                   y=err,
                   se=err/10,
                   trt_ref = "ARIMA" # <<< THIS IS REFERENCE MODEL. ARIMA beacause it's Most Basic Model
)

print(DM)

plot(DM)



# --- 1. Base Case NMA Setup ---
# Take sometimes to run (e.g., 30 min)
smkfit <- nma(DM,
              trt_effects = "random",
              prior_intercept = normal(scale = 100),
              prior_trt = normal(scale = 100),
              prior_het = normal(scale = 5),
              iter = 4000 # Increase from default (often 2000) to 4000, 6000, or more
              )

saveRDS(smkfit, file = "base_case_NMA.rds")

## relative effects
smk_releff <- relative_effects(smkfit, all_contrasts = FALSE)
smk_releff
plot(smk_releff, ref_line = 0)+
  labs(title = "Base Case NMA Relative Effect")
# ggsave("nma_releff.pdf",w=10,h=15)

## rank visualizations
 
# smk_rankprobs <- posterior_rank_probs(smkfit, lower_better = TRUE)
# smk_rankprobs 
# plot(smk_rankprobs) + xlim(1, 47)#Adjust Rank
# # ggsave("nma_rnkprb.pdf",w=10,h=10)


smk_cumrankprobs <- posterior_rank_probs(smkfit, lower_better = TRUE, cumulative = TRUE)
smk_cumrankprobs
plot(smk_cumrankprobs) + xlim(1, 47) +
  labs(title = "Base Case NMA Cumulative Rank Probability")
# ggsave("nma_crnkprb.pdf",w=10,h=10)


# Sensitivity Analysis 

# --- 2.Filter out Low QA studies Setup ---

# Filter out Low and Medium quality (n=24)
L_n_M_rmv <- c("Anggraeni, 2021", "Chakraborty, 2020", "Doni, 2020", "Jayashree, 2015", "Kerdprasop, 2020", "Mahdiana, 2017", "Nabilah, 2023", "Prome, 2024", "Shashvat, 2023", "Guo, 2018", "Ho, 2015", "Juraphanthong, 2021", "Khaira, 2020", "Ligue, 2022", "Liu, 2019", "Mustaffa, 2024", "Othman, 2022", "Pham, 2018", "Rajendran, 2023", "Shashvat, 2019", "Tian, 2024", "Weng, 2024", "Zhao, 2020", "Rangarajan, 2019") #single arm
my_data_no_l_n_m_study <- DR[!Identifier %in% L_n_M_rmv]

net_high_Q_studies <- set_agd_arm( data= my_data_no_l_n_m_study,
                   study = Identifier,
                   trt = method,
                   y=err,
                   se=err/10,
                   trt_ref = "ARIMA" # <<< THIS IS REFERENCE MODEL. Naïve beacause it's Most Basic Model
)

print("--- Network excluding Low and Medium qulity studies ---")
print(net_high_Q_studies)
plot(net_high_Q_studies)


fit_high_Q_studies <- nma(net_high_Q_studies,
                            trt_effects = "random",
                            prior_intercept = normal(scale = 100),
                            prior_trt = normal(scale = 100),
                            prior_het = normal(scale = 5),
                            iter = 4000 # Increase from default (often 2000) to 4000, 6000, or more
)


saveRDS(fit_high_Q_studies, file = "high_quality_case_NMA.rds")


# Compare results
print("--- Results without Low and Medium qulity studies ---")
print(relative_effects(fit_high_Q_studies))
plot(relative_effects(fit_high_Q_studies), ref_line = 0)+
  labs(title = "High quality studies NMA Relative Effect")


print("--- SUCRA Ranks without Low and Medium qulity studies ---")
print(posterior_rank_probs(fit_high_Q_studies, lower_better = TRUE, cumulative = TRUE))
plot(posterior_rank_probs(fit_high_Q_studies, lower_better = TRUE, cumulative = TRUE)) + xlim(1, 39)+
  labs(title = "High quality studies NMA Cumulative Rank Probability")


# --- 3.Fixed Effects Setup ---

fit_fixed <- nma(DM,
                 trt_effects = "fixed",
                 prior_intercept = normal(scale = 100),
                 prior_trt = normal(scale = 100),
                 prior_het = normal(scale = 5),
                 iter = 4000 # Increase from default (often 2000) to 4000, 6000, or more
)

saveRDS(fit_fixed, file = "fixed_effect_case_NMA.rds")


print("--- Fixed Effects Model Results ---")
print(relative_effects(fit_fixed))
plot(relative_effects(fit_fixed), ref_line = 0)+
  labs(title = "Fixed Effect studies NMA Relative Effect")

# print("--- Fixed Effects SUCRA Ranks ---")
# print(posterior_rank_probs(fit_fixed))
# plot(posterior_rank_probs(fit_fixed, lower_better = TRUE))

print("--- Fixed Effects Cumulative Ranks ---")
print(posterior_rank_probs(fit_fixed), cumulative = TRUE)
plot(posterior_rank_probs(fit_fixed, lower_better = TRUE, cumulative = TRUE)) + xlim(1, 47)+
  labs(title = "Fixed Effect studies NMA Cumulative Rank Probability")
