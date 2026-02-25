# Load necessary libraries
library(readxl)
library(tidyverse)
library(here)

# 1. Load data from separate Excel files using 'here'
# This assumes the files are in the root of your project folder
model_path <- here("data/model.xlsx")
covar_path <- here("data/covar.xlsx")

# Read the model file
df_model <- read_excel(model_path) %>%
  select(Identifier, `Model Type`)

# Read the covariate file
df_covar <- read_excel(covar_path) %>%
  select(Identifier, `Data Category`)

# 2. Perform many-to-many Inner Join
merged_df <- df_model %>%
  inner_join(df_covar, by = "Identifier", relationship = "many-to-many")

# 3. Filter and Aggregate
# Removing rows where Model Type is missing and excluding "Epidemiological"
count_table <- merged_df %>%
  filter(!is.na(`Model Type`), 
         `Data Category` != "Epidemiological") %>%
  group_by(`Data Category`, `Model Type`) %>%
  summarise(Count = n(), .groups = "drop")

# 4. Heatmap Visualization
heatmap_plot <- ggplot(count_table, aes(x = `Data Category`, y = `Model Type`, fill = Count)) +
  geom_tile(color = "white") + 
  geom_text(aes(label = Count), color = "black", size = 4) + 
  scale_fill_gradient(low = "#f7fbff", high = "#08306b") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  labs(title = "Model Type vs Covariate Category Heatmap",
       x = "Covariate Category", 
       y = "Model Type")

print(heatmap_plot)

# Save Heatmap

ggsave(
  here("output", "figures", "heat_map_results.png"), 
  plot = heatmap_plot, 
  device = "png", 
  dpi = 300, 
  width = 10, 
  height = 7
)

ggsave(
    here("output", "figures", "heat_map_results.tiff"), 
       plot = heatmap_plot, 
       device = "tiff", 
       dpi = 300, 
       compression = "lzw", 
       width = 10, 
       height = 7)



# ================ Exporting Heatmap Aggregate Data ================
# 1. Ensure the directory exists
if (!dir.exists(here("output", "table"))) dir.create(here("output", "table"), recursive = TRUE)

# 2. Save the count_table (the data shown in the heatmap)
# This includes Data Category, Model Type, and the calculated Count
write_csv(
  count_table, 
  here("output", "table", "heatmap_counts_summary.csv")
)

# 3. Optional: Save the full merged dataset 
# (The raw data after the many-to-many join but before aggregation)
write_csv(
  merged_df, 
  here("output", "table", "merged_model_covariate_raw.csv")
)