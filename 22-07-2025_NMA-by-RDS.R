# setwd('X:\\HAR_WG\\WG\\UKSEA_VAXHUB\\Systematic_Review_Dengue_Forecasting')
setwd('/Users/pitakbenjarattanaporn/Documents/Projects/Systematic_Review_Dengue_Forecasting/data') #data folder on local machine

loaded_base_case <- readRDS("base_case_NMA_REFF_NAIVE.rds")
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
plot(Base_case_rank) + xlim(1, 47) #+
  labs(title = "Base Case NMA Cumulative Rank Probability")

  
# Convert the rank object to a data frame
Base_rank_df <- as.data.frame(Base_case_rank)

# 1. Create and store the plot object
rank_plot <- plot(Base_case_rank) + 
  xlim(1, 47) +
  labs(x = "Rank", y = "Cumulative Probability") +
  theme_minimal()

# 2. Save the plot object (rank_plot) instead of the data frame
file_name <- "Fig3_Cumulative_Rank_Probability.tif"

ggsave(
  filename = file_name, 
  plot = rank_plot,      # Use the plot object here
  device = "tiff", 
  dpi = 300, 
  width = 8, 
  height = 10,           # Height increased to accommodate 47 models
  units = "in", 
  compression = "lzw"
)

message(paste("Figure saved to:", getwd(), "/", file_name))

# Save to CSV
#write.csv(Base_rank_df, "Base_case_NMA_Ranks.csv", row.names = FALSE)
