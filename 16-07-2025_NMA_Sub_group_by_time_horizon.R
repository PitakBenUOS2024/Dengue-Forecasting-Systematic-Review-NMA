# make sub-group by time horizon (short,medium,long range)
# Use Soyiri and Reidpath, 2013 as the ref.

library(data.table)
library(multinma)
library(ggplot2)
library(readr)
library(dplyr)



D <- fread("PME.csv")

#creat RMSE_LOG10

#RMSE{CHAR} -> RMSE{NUM}
D[, RMSE := as.numeric(RMSE)]

#Or remove the value 0 since it is a outlier
D <- D[RMSE > 0 | RMSE < 0]

#remove negative value (n=3) out before the put in log scale
D <- D[RMSE >= 0]
D[, RMSE_log10 := log10(RMSE)]

unique(D$`Time Horizon (Months)`)

# Assuming D is your data frame/data.table

# 1. Clean and convert 'Time Horizon (Months)' to numeric
D <- D %>%
  mutate(
    Time_Horizon_Months_Numeric = as.numeric(
      case_when(
        `Time Horizon (Months)` == "not clear" ~ NA_real_, # Convert "not clear" to NA
        TRUE ~ as.numeric(`Time Horizon (Months)`) # Convert other values to numeric
      )
    )
  )


# 2. Create D_short_range dataframe
D_short_range <- D %>%
  filter(
    !is.na(Time_Horizon_Months_Numeric) &
      Time_Horizon_Months_Numeric >= (1/30.44) & # Approximately 1 day
      Time_Horizon_Months_Numeric <= 3           # Up to 3 months (quarter of a year)
  )

# 3. Create D_medium_range dataframe
D_medium_range <- D %>%
  filter(
    !is.na(Time_Horizon_Months_Numeric) &
      Time_Horizon_Months_Numeric > 3 &    # Greater than 3 months
      Time_Horizon_Months_Numeric <= 12    # Up to 12 months (a year)
  )

# 4. Create D_long_range dataframe
D_long_range <- D %>%
  filter(
    !is.na(Time_Horizon_Months_Numeric) &
      Time_Horizon_Months_Numeric > 12 &   # Greater than 12 months
      Time_Horizon_Months_Numeric <= 60    # Up to 60 months (five years)
  )


head(D_short_range)
head(D_medium_range)
head(D_long_range)

(nmz <- names(D))
(keep <- nmz[c(3,5,29)])

#Plots agd arm

#setup D_short_range df
DR_short_range <- D_short_range[,..keep]
names(DR_short_range)[2] <- "method"


rmv <- c("Hasan, 2024") #single arm
DR_short_range <- DR_short_range[!Identifier %in% rmv]
DR_short_range[,summary(RMSE_log10)]
DR_short_range[,err:=3 + RMSE_log10]


DM_short_range <- set_agd_arm( data= DR_short_range,
                   study = Identifier,
                   trt = method,
                   y=err,
                   se=err/10,
                   trt_ref = "ARIMA"
                   ) 

print(DM_short_range)

plot(DM_short_range) +
  labs(title = "Network Structure for Short-Range Studies")


#setup D_medium_range df
DR_medium_range <- D_medium_range[,..keep]
names(DR_medium_range)[2] <- "method"


rmv <- c("Hasan, 2024") #single arm
DR_medium_range <- DR_medium_range[!Identifier %in% rmv]
DR_medium_range[,summary(RMSE_log10)]
DR_medium_range[,err:=3 + RMSE_log10]


DM_medium_range <- set_agd_arm( data= DR_medium_range,
                               study = Identifier,
                               trt = method,
                               y=err,
                               se=err/10,
                               trt_ref = "ARIMA"
) 

print(DM_medium_range)

plot(DM_medium_range)+
  labs(title = "Network Structure for Medium-Range Studies")

#setup D_long_range df
DR_long_range <- D_long_range[,..keep]
names(DR_long_range)[2] <- "method"


rmv <- c("Hasan, 2024") #single arm
DR_long_range <- DR_long_range[!Identifier %in% rmv]
DR_long_range[,summary(RMSE_log10)]
DR_long_range[,err:=3 + RMSE_log10]


DM_long_range <- set_agd_arm( data= DR_long_range,
                                study = Identifier,
                                trt = method,
                                y=err,
                                se=err/10,
                              trt_ref = "ARIMA"
) 

print(DM_long_range)

plot(DM_long_range)+
  labs(title = "Network Structure for Long-Range Studies")


#fit short range horizon

fit_short_range <- nma(DM_short_range,
              trt_effects = "random",
              prior_intercept = normal(scale = 100),
              prior_trt = normal(scale = 100),
              prior_het = normal(scale = 5),
              iter = 4000 # Increase from default (often 2000) to 4000, 6000, or more
)

saveRDS(fit_short_range, file = "Short_range_NMA.rds")

print("--- Short range Effects Model Results  ---")
print(relative_effects(fit_short_range,))
plot(relative_effects(fit_short_range)) +
  labs(title = "Short range Studies Relative Effects Ranks")

print("--- Short range Effects Cumulative Ranks ---")
print(posterior_rank_probs(fit_short_range), cumulative = TRUE)
plot(posterior_rank_probs(fit_short_range, lower_better = TRUE, cumulative = TRUE)) + xlim(1, 10)  +
  labs(title = "Short range Studies Cumulative Ranks")


#fit medium range horizon

fit_medium_range <- nma(DM_medium_range,
                       trt_effects = "random",
                       prior_intercept = normal(scale = 100),
                       prior_trt = normal(scale = 100),
                       prior_het = normal(scale = 5),
                       iter = 4000 # Increase from default (often 2000) to 4000, 6000, or more
)

saveRDS(fit_medium_range, file = "Medium_range_NMA.rds")

print("--- medium range Effects Model Results  ---")
print(relative_effects(fit_medium_range,))
plot(relative_effects(fit_medium_range))+
  labs(title = "Medium range Studies Relative Effects Ranks")

print("--- medium range Effects Cumulative Ranks ---")
print(posterior_rank_probs(fit_medium_range), cumulative = TRUE)
plot(posterior_rank_probs(fit_medium_range, lower_better = TRUE, cumulative = TRUE)) + xlim(1, 31)  +
  labs(title = "Medium range Studies Cumulative Ranks")

#fit long range horizon

fit_long_range <- nma(DM_long_range,
                        trt_effects = "random",
                        prior_intercept = normal(scale = 100),
                        prior_trt = normal(scale = 100),
                        prior_het = normal(scale = 5),
                        iter = 4000 # Increase from default (often 2000) to 4000, 6000, or more
)

saveRDS(fit_long_range, file = "Long_range_NMA.rds")

print("--- long range Effects Model Results  ---")
print(relative_effects(fit_long_range,))
plot(relative_effects(fit_long_range))+
  labs(title = "Long range Studies Relative Effects Ranks")

print("--- long range Effects Cumulative Ranks ---")
print(posterior_rank_probs(fit_long_range), cumulative = TRUE)
plot(posterior_rank_probs(fit_long_range, lower_better = TRUE, cumulative = TRUE)) + xlim(1, 20) +
  labs(title = "Long range Studies Cumulative Ranks")








# Find the common methods across DR_short_range, DR_medium_range, and DR_long_range
# Get the unique methods from each data range
methods_short_range <- unique(DR_short_range$method)
methods_medium_range <- unique(DR_medium_range$method)
methods_long_range <- unique(DR_long_range$method)

# Find the intersection between the first two
common_methods_1_2 <- intersect(methods_short_range, methods_medium_range)

# Then find the intersection of that result with the third
common_methods_all <- intersect(common_methods_1_2, methods_long_range)

# Print the common methods
print(common_methods_all)


