library(here)
library(data.table)
library(multinma)
library(ggplot2)


# ================ load data
D <- fread(here("data/PME.csv"))

## number in each study
D[, num := .N, by = Identifier]
D[, uniqueN(Identifier)]
D[, range(num)]
D[, unique(`Rank within study`)]
D[, occurs := 1]


# =============== visualisation NMA Diagram

DM_Category <- set_agd_arm(
  data = D[num > 1 & !is.na(`Rank within study`) & !is.na(Category)],
  study = Identifier,
  trt = Category,
  r = num,
  E = `Rank within study`,
  sample_size = occurs
)

print(DM_Category)

# 1. Create the base plot
p <- plot(DM_Category, weight_nodes = TRUE)

# 2. Increase Text Size (Layer 3)
p$layers[[3]]$aes_params$size <- 5

# 3. Increase Node Size and Move Legend
p <- p +
  scale_size_continuous(range = c(8, 22)) +
  theme(
    legend.position = "bottom",
    legend.box = "vertical"
  ) +
  scale_x_continuous(expand = expansion(mult = 0.2)) +
  # --- ADD THIS LINE TO RENAME THE LEGEND ---
  labs(size = "Number of comparisons") # 'size' refers to the node size aesthetic # nolint


D[, sum(occurs), by = Category] # NOTE I think these are the numbers for the sizes # nolint


# 4. Print to check
print(p)

# Save the plot object 'p' to a file
ggsave(
  filename = here("output", "figures", "network_diagram_with_number_of_comparisons.png"),
  plot = p,
  width = 9.4, # Width of the image
  height = 8, # Height of the image
  units = "in", # Units for width/height
  dpi = 300 # Resolution (300 is print quality)
)

## Save the plot with Journal-compliant settings
ggsave(
  filename = here("output", "figures", "network_diagram_with_number_of_comparisons.tif"),
  plot = p,
  device = "tiff",
  dpi = 300, # Required minimum resolution
  width = 7.5, # Standard width for a full-page width figure (inches)
  height = 8, # Adjust based on the number of models in your list
  units = "in",
  compression = "lzw" # Reduces file size without losing quality
)


# ================== Exporting Network Diagram Data ==================
# 1. Ensure the directory exists
if (!dir.exists(here("output", "table"))) dir.create(here("output", "table"), recursive = TRUE)

# 2. Save the arm-level data (The nodes and comparisons)
# This is the processed data inside the DM_Category object
fwrite(
  as.data.frame(DM_Category$arm), 
  here("output", "table", "network_arm_data.csv")
)

# 3. Save the specific Category counts (Used for node sizing)
# This mimics your logic: D[, sum(occurs), by = Category]
category_counts <- D[num > 1 & !is.na(`Rank within study`) & !is.na(Category), 
                     .(Number_of_Comparisons = sum(occurs)), 
                     by = Category]

fwrite(
  category_counts, 
  here("output", "table", "network_node_sizes.csv")
)