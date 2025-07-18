# Install and load necessary packages if you haven't already
# install.packages("multinma")
# install.packages("dplyr")
# install.packages("forcats") # for factor manipulation, useful for trt_ref

library(multinma)
library(dplyr)
library(forcats) # For fct_relevel

# --- 0. Set up some example data ---
# Let's imagine we have 5 studies comparing 4 forecasting models (ModelA, ModelB, ModelC, ModelD).
# The outcome is some measure of accuracy, where lower values are better (e.g., RMSE, MAE).
# We'll use aggregate data with arm-level summaries.

set.seed(20250710) # For reproducibility

my_data <- tribble(
  ~study,   ~trt,     ~mean_outcome, ~sd_outcome, ~n, ~risk_of_bias,
  "Study1", "ModelA", 10.2,           1.5,         50, "Low",
  "Study1", "ModelB", 9.5,            1.3,         50, "Low",
  "Study2", "ModelB", 11.0,           1.8,         60, "Low",
  "Study2", "ModelC", 12.5,           1.9,         60, "Low",
  "Study3", "ModelA", 10.5,           1.6,         45, "Low",
  "Study3", "ModelC", 12.0,           1.7,         45, "Low",
  "Study4", "ModelA", 9.8,            1.4,         55, "High", # Let's mark this study as "High" risk of bias
  "Study4", "ModelD", 8.9,            1.2,         55, "High",
  "Study5", "ModelB", 10.0,           1.5,         70, "Low",
  "Study5", "ModelD", 9.2,            1.3,         70, "Low"
)

# Ensure 'trt' is a factor with ModelA as the reference
my_data <- my_data %>%
  mutate(trt = fct_relevel(as.factor(trt), "ModelA"))

# --- 1. Base Case NMA Setup ---
# We'll use ModelA as our primary reference.

net_base <- set_agd_arm(
  data = my_data,
  study = study,
  trt = trt,
  y = mean_outcome,
  se = sd_outcome / sqrt(n), # Standard error of the mean
  sample_size = n,
  trt_ref = "ModelA" # Our chosen reference for the base case
)

print(net_base)
plot(net_base)

# Fit the base-case NMA model (random effects, consistency)
# Use iter_warmup and iter_sampling for quicker example, increase for real analysis
fit_base <- nma(net_base,
                trt_effects = "random",
                consistency = "consistency",
                chains = 4,
                seed = 12345)

# Summarize base case results (e.g., relative effects vs ModelA)
print("--- Base Case Results (Relative Effects vs ModelA) ---")
print(relative_effects(fit_base))
print("--- Base Case SUCRA Ranks ---")
print(posterior_rank_probs(fit_base))
plot(posterior_rank_probs(fit_base), lower_better = TRUE, cumulative = TRUE)




# --- 1.Filter out Study4 (the high risk of bias study)
my_data_no_study4 <- my_data %>%
  filter(study != "Study4")

# Set up the network data again without Study4
net_no_study4 <- set_agd_arm(
  data = my_data_no_study4,
  study = study,
  trt = trt,
  y = mean_outcome,
  se = sd_outcome / sqrt(n),
  sample_size = n,
  trt_ref = "ModelA"
)

print("--- Network excluding Study4 ---")
print(net_no_study4)
plot(net_no_study4)

# Fit the NMA model with the reduced dataset
fit_no_study4 <- nma(net_no_study4,
                     trt_effects = "random",
                     consistency = "consistency",
                     chains = 4,
                     seed = 12345)

# Compare results
print("--- Results without Study4 (Relative Effects vs ModelA) ---")
print(relative_effects(fit_no_study4))
print("--- SUCRA Ranks without Study4 ---")
print(posterior_rank_probs(fit_no_study4))
plot(posterior_rank_probs(fit_no_study4))

# Visual comparison (example: posterior densities for one comparison)
# Note: For full comparison, you'd usually plot all or specific comparisons.
# Here, just ModelB vs ModelA, as an example.
plot(relative_effects(fit_base, trt_vs = "ModelA", trt = "ModelB"),
     xlab = "Mean Difference (ModelB vs ModelA)", main = "Base Case")
plot(relative_effects(fit_no_study4, trt_vs = "ModelA", trt = "ModelB"),
     xlab = "Mean Difference (ModelB vs ModelA)", main = "Excluding Study4")

# Interpretation: Observe if the point estimates, credible intervals, or overall rankings shift meaningfully.
# If they don't change much, your results are robust to the inclusion of Study4.
# If they do, Study4 might be influential, and you'd discuss this limitation.




# --- 2.Fit the NMA model using a fixed-effect specification
fit_fixed <- nma(net_base,
                 trt_effects = "fixed", # <<< Change this argument
                 consistency = "consistency",
                 chains = 4,
                 seed = 12345)

# Compare results
print("--- Fixed Effects Model Results (Relative Effects vs ModelA) ---")
print(relative_effects(fit_fixed))

print("--- Fixed Effects SUCRA Ranks ---")
print(posterior_rank_probs(fit_fixed))
plot(posterior_rank_probs(fit_fixed))



# --- 3.Define a new prior for heterogeneity (sigma)
new_prior_heterogeneity <- half_normal(scale = 2) # <<< Corrected: use 'scale = 2'

# Fit the NMA model with the new prior
fit_diff_prior <- nma(net_base,
                      trt_effects = "random",
                      consistency = "consistency",
                      prior_het = new_prior_heterogeneity,
                      chains = 4,
                      seed = 12345)


# Compare results
print("--- Different Prior Results (Relative Effects vs ModelA) ---")
print(relative_effects(fit_diff_prior))
plot(relative_effects(fit_diff_prior))

print("--- Different Prior SUCRA Ranks ---")
print(posterior_rank_probs(fit_diff_prior))
plot(posterior_rank_probs(fit_diff_prior))




# Corrected way to plot specific relative effects

# For the base case
plot(relative_effects(fit_base, trt_ref = "ModelA"),
     pars = "d[ModelB vs ModelA]", # This selects the specific parameter for ModelB vs ModelA
     xlab = "Mean Difference (ModelB vs ModelA)",
     main = "Base Case (ModelB vs ModelA)")

# For the analysis without Study4
plot(relative_effects(fit_no_study4, trt_ref = "ModelA"),
     pars = "d[ModelB vs ModelA]",
     xlab = "Mean Difference (ModelB vs ModelA)",
     main = "Excluding Study4 (ModelB vs ModelA)")

# For the fixed effects model
plot(relative_effects(fit_fixed, trt_ref = "ModelA"),
     pars = "d[ModelB vs ModelA]",
     xlab = "Mean Difference (ModelB vs ModelA)",
     main = "Fixed Effects (ModelB vs ModelA)")

# For the different prior model
plot(relative_effects(fit_diff_prior, trt_ref = "ModelA"),
     pars = "d[ModelB vs ModelA]",
     xlab = "Mean Difference (ModelB vs ModelA)",
     main = "Different Prior (ModelB vs ModelA)")
