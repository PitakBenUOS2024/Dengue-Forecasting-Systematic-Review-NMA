# setwd('X:\\HAR_WG\\WG\\UKSEA_VAXHUB\\Systematic_Review_Dengue_Forecasting')

loaded_base_case <- readRDS("base_case_NMA.rds")
# loaded_high_q_case <- readRDS("hig_quality_case_NMA.rds")
# loaded_fixed_eff_case <- readRDS("fixed_effect_case_NMA.rds")

# base_case_releff <- relative_effects(loaded_base_case, all_contrasts = FALSE)
# high_q_case_releff <- relative_effects(loaded_high_q_case, all_contrasts = FALSE)
# fixed_eff_case <- relative_effects(loaded_fixed_eff_case, all_contrasts = FALSE)

summary(loaded_base_case)
# summary(loaded_fixed_eff_case)

print(relative_effects(loaded_base_case))
plot(relative_effects(loaded_base_case), ref_line = 0)+
  labs(title = "Base Case NMA Relative Effect")


Base_case_rank <- posterior_rank_probs(loaded_base_case, lower_better = TRUE, cumulative = TRUE, sucra = TRUE)
print(Base_case_rank)
plot(Base_case_rank) + xlim(1, 47) +
  labs(title = "Base Case NMA Cumulative Rank Probability")

