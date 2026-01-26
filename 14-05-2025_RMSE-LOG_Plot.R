library(data.table)
library(multinma)

setwd('/Users/pitakbenjarattanaporn/Documents/Projects/Systematic_Review_Dengue_Forecasting/data') #data folder on local machine

## Pitak's last sheet with rankings
D <- fread("PME.csv")


## number in each study
D[,num:=.N,by=Identifier]
D[,uniqueN(Identifier)]
D[,range(num)]
D[,unique(`Rank within study`)]

#RMSE{CHAR} -> RMSE{NUM}
D[, RMSE := as.numeric(RMSE)]

#replace with value 0 (n=2) to very small number
# epsilon <- .Machine$double.eps
# D[RMSE == 0, RMSE := epsilon]
# D[, RMSE_log10 := log10(RMSE)]
# summary(D[, RMSE_log10])

#Or remove the value 0 since it is a outlier
D <- D[RMSE > 0 | RMSE < 0]

#remove negative value (n=3) out before the put in log scale
D <- D[RMSE >= 0]
D[, RMSE_log10 := log10(RMSE)]

sd(D$RMSE_log10, na.rm = TRUE)
summary(D[, RMSE_log10])

#calculates summary for the Log_RMSE within each Category group
library(dplyr)

D %>%
    summarise(
    Count = n(),
    Mean_RMSE_log10 = mean(RMSE_log10, na.rm = TRUE),
    Median_RMSE_log10 = median(RMSE_log10, na.rm = TRUE),
    SD_RMSE_log10 = sd(RMSE_log10, na.rm = TRUE),
    SE_RMSE_log10 = SD_RMSE_log10 / sqrt(Count),
    Min_RMSE_log10 = min(RMSE_log10, na.rm = TRUE),
    Max_RMSE_log10 = max(RMSE_log10, na.rm = TRUE)
  )

D %>%
  group_by(Category) %>%
  summarise(
    Count = n(),
    Mean_RMSE_log10 = mean(RMSE_log10, na.rm = TRUE),
    Median_RMSE_log10 = median(RMSE_log10, na.rm = TRUE),
    SD_RMSE_log10 = sd(RMSE_log10, na.rm = TRUE),
    SE_RMSE_log10 = SD_RMSE_log10 / sqrt(Count),
    Min_RMSE_log10 = min(RMSE_log10, na.rm = TRUE),
    Max_RMSE_log10 = max(RMSE_log10, na.rm = TRUE)
  )%>%
  arrange(Mean_RMSE_log10)

#DL
D %>%
  filter(Category == "Deep Learning") %>%
  group_by(Model2) %>%
  summarise(
    Count = n(),
    Mean_RMSE_log10 = mean(RMSE_log10, na.rm = TRUE),
    Median_RMSE_log10 = median(RMSE_log10, na.rm = TRUE),
    SD_RMSE_log10 = sd(RMSE_log10, na.rm = TRUE),
    Min_RMSE_log10 = min(RMSE_log10, na.rm = TRUE),
    Max_RMSE_log10 = max(RMSE_log10, na.rm = TRUE)
  )%>%
  arrange(Mean_RMSE_log10)


#Ensemble
D %>%
  filter(Category == "Ensemble") %>%
  group_by(Model) %>%
  summarise(
    Count = n(),
    Mean_RMSE_log10 = mean(RMSE_log10, na.rm = TRUE),
    Median_RMSE_log10 = median(RMSE_log10, na.rm = TRUE),
    SD_RMSE_log10 = sd(RMSE_log10, na.rm = TRUE),
    Min_RMSE_log10 = min(RMSE_log10, na.rm = TRUE),
    Max_RMSE_log10 = max(RMSE_log10, na.rm = TRUE)
  )%>%
  arrange(Mean_RMSE_log10)


# Hybrid
D %>%
  filter(Category == "Hybrid") %>%
  group_by(Model) %>%
  summarise(
    Count = n(),
    Mean_RMSE_log10 = mean(RMSE_log10, na.rm = TRUE),
    Median_RMSE_log10 = median(RMSE_log10, na.rm = TRUE),
    SD_RMSE_log10 = sd(RMSE_log10, na.rm = TRUE),
    Min_RMSE_log10 = min(RMSE_log10, na.rm = TRUE),
    Max_RMSE_log10 = max(RMSE_log10, na.rm = TRUE)
  )%>%
  arrange(Mean_RMSE_log10)


# ML
D %>%
  filter(Category == "Machine Learning") %>%
  group_by(Model2) %>%
  summarise(
    Count = n(),
    Mean_RMSE_log10 = mean(RMSE_log10, na.rm = TRUE),
    Median_RMSE_log10 = median(RMSE_log10, na.rm = TRUE),
    SD_RMSE_log10 = sd(RMSE_log10, na.rm = TRUE),
    Min_RMSE_log10 = min(RMSE_log10, na.rm = TRUE),
    Max_RMSE_log10 = max(RMSE_log10, na.rm = TRUE)
  )%>%
  arrange(Mean_RMSE_log10)


# Time series
D %>%
  filter(Category == "Time Series") %>%
  group_by(Model2) %>%
  summarise(
    Count = n(),
    Mean_RMSE_log10 = mean(RMSE_log10, na.rm = TRUE),
    Median_RMSE_log10 = median(RMSE_log10, na.rm = TRUE),
    SD_RMSE_log10 = sd(RMSE_log10, na.rm = TRUE),
    Min_RMSE_log10 = min(RMSE_log10, na.rm = TRUE),
    Max_RMSE_log10 = max(RMSE_log10, na.rm = TRUE)
  )%>%
  arrange(Mean_RMSE_log10)

#~~~~~Catergory Summary~~~~~
# Calculate summary for RMSE_log10 within each Category group
# and sort by Mean_RMSE_log10
category_summary <- D %>%
  group_by(Category) %>%
  summarise(
    Count = n(),
    Mean_RMSE_log10 = mean(RMSE_log10, na.rm = TRUE),
    Median_RMSE_log10 = median(RMSE_log10, na.rm = TRUE),
    SD_RMSE_log10 = sd(RMSE_log10, na.rm = TRUE),
    Min_RMSE_log10 = min(RMSE_log10, na.rm = TRUE),
    Max_RMSE_log10 = max(RMSE_log10, na.rm = TRUE)
  ) %>%
  mutate(
    SE_RMSE_log10 = SD_RMSE_log10 / sqrt(Count)
  ) %>%
  arrange(Mean_RMSE_log10)

# Print the summary
print(category_summary)

# Optionally, save the summary to a CSV file
# fwrite(category_summary, "category_summary_r.csv")



#~~~~~Plot~~~~~
library(ggplot2)
library(patchwork) # To combine plots


# Density plot by Category
p1 <- ggplot(D, aes(x = RMSE_log10, fill = Category)) +
  geom_density(alpha = 0.5) +
  facet_wrap(~ Category) +
  labs(
    title = "Density of RMSE_log10 by Category",
    x = "RMSE_log10",
    y = "Density",
    fill = "Category"
  ) +
  theme_minimal() +
  theme(legend.position = "bottom") # Move legend to the bottom for better layout

# Density plot without grouping
p2 <- ggplot(D, aes(x = RMSE_log10)) +
  geom_density(fill = "steelblue", alpha = 0.7) +
  labs(
    title = "Overall Density of RMSE_log10",
    x = "RMSE_log10",
    y = "Density"
  ) +
  theme_minimal()

# Combine the two plots
combined_plot <- p1 / p2 

print(combined_plot)


#Plot DL's models

D_deep_learning <- D %>%
  filter(Category == "Deep Learning")

ggplot(D_deep_learning, aes(x = RMSE_log10, fill = Model2)) +
  geom_density(alpha = 0.5) +
  labs(
    title = "Density of RMSE_log10 by Model2 (Deep Learning Category)",
    x = "RMSE_log10",
    y = "Density",
    fill = "Model2"
  ) +
  theme_minimal() +
  theme(legend.position = "bottom")

#Plot Ensemble
D_Ensemble <- D %>%
  filter(Category == "Ensemble")

ggplot(D_Ensemble, aes(x = RMSE_log10, fill = Model)) +
  geom_density(alpha = 0.5) +
  labs(
    title = "Density of RMSE_log10 by Model (Ensemble)",
    x = "RMSE_log10",
    y = "Density",
    fill = "Model"
  ) +
  theme_minimal() +
  theme(legend.position = "bottom")

#plot Hybrid
D_Hybrid <- D %>%
  filter(Category == "Hybrid")

ggplot(D_Hybrid, aes(x = RMSE_log10, fill = Model)) +
  geom_density(alpha = 0.5) +
  labs(
    title = "Density of RMSE_log10 by Model (Hybrid)",
    x = "RMSE_log10",
    y = "Density",
    fill = "Model"
  ) +
  theme_minimal() +
  theme(legend.position = "bottom")


#plots ML
D_machine_learning <- D %>%
  filter(Category == "Machine Learning")

ggplot(D_machine_learning, aes(x = RMSE_log10, fill = Model2)) +
  geom_density(alpha = 0.5) +
  labs(
    title = "Density of RMSE_log10 by Model2 (Machine Learning)",
    x = "RMSE_log10",
    y = "Density",
    fill = "Model2"
  ) +
  theme_minimal() +
  theme(legend.position = "bottom")


#plots time series
D_time_series <- D %>%
  filter(Category == "Time Series")

ggplot(D_time_series, aes(x = RMSE_log10, fill = Model2)) +
  geom_density(alpha = 0.5) +
  labs(
    title = "Density of RMSE_log10 by Model2 (Time Series)",
    x = "RMSE_log10",
    y = "Density",
    fill = "Model2"
  ) +
  theme_minimal() +
  theme(legend.position = "bottom")

