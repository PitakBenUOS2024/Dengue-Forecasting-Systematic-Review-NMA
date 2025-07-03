# Install and load necessary packages
if(!requireNamespace("pROC", quietly = TRUE)){
  install.packages("pROC")
}
if(!requireNamespace("elo", quietly = TRUE)){
  install.packages("elo")
}
library(elo)
library(dplyr)

# 1. Load the Sample Data
rmse_data <- read.csv("sample_rmse_data.csv")
print("Loaded RMSE Data:")
print(rmse_data)

# 2. Prepare Data for elo Package
# We need to create a data frame where each row represents a single match
# between two models on the same dataset, with the outcome.

elo_input_data <- rmse_data %>%
  group_by(dataset_id) %>%
  arrange(rmse) %>%
  mutate(
    opponent = lead(model_id),
    score = ifelse(row_number() == 1, 1, 0) # Winner gets score 1
  ) %>%
  filter(!is.na(opponent)) %>%
  select(dataset_id, winner = model_id, loser = opponent, score) %>%
  ungroup()

print("\nPrepared Data for elo.run():")
print(elo_input_data)

# 3. Run Elo Rating
elo_rankings <- elo.run(winner = winner, loser = loser, score = score, data = elo_input_data, k = 200)

# 4. Get the Final Elo Ratings
final_elo <- final.elos(elo_rankings)
print("\nFinal Elo Ratings:")
print(sort(final_elo, decreasing = TRUE))

# Optional: Plot the Elo ratings over the matches
# plot(elo_rankings)