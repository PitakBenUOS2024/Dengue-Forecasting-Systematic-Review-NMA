## =====================
library(here)
library(data.table)
library(multinma)
library(ggplot2)

# ================ load data
smkfit <- readRDS(here("output/base_case_NMA_REFF_NAIVE.rds"))

####################

smk_releff <- relative_effects(smkfit, all_contrasts = FALSE)
smk_releff

# This will display the DIC in your console
dic(smkfit)

plot(smk_releff, ref_line = 0) +
  labs(title = "Base Case NMA Relative Effect")

####################

# Convert the multinma relative effects object to a data frame
smk_data <- as.data.frame(smk_releff)

# Add a 'Treatment' column by extracting the treatment names from the row names
smk_data$Treatment <- smk_data$parameter

# Extract the clean treatment name (removing "d[" and "]") for better labels
smk_data$Treatment <- gsub("^d\\[|\\]$", "", smk_data$Treatment)

# Convert 'Treatment' to a factor with levels ordered by 'mean' (highest to )
smk_data$Treatment <- factor(
  smk_data$Treatment,
  levels = rev(smk_data$Treatment[order(smk_data$mean)])
)

####################

# Convert the multinma relative effects object to a data frame
smk_data <- as.data.frame(smk_releff)

# Add a 'Treatment' column by extracting the treatment names from the row names
smk_data$Treatment <- smk_data$parameter

# Extract the clean treatment name (removing "d[" and "]") for better labels
smk_data$Treatment <- gsub("^d\\[|\\]$", "", smk_data$Treatment)

# --- START: Insert the four modification lines here ---
# Replace full names with abbreviations
smk_data$Treatment <- gsub("Exponential Smoothing", "EM", smk_data$Treatment)
smk_data$Treatment <- gsub("Gaussian Process \\(GP\\)", "GP", smk_data$Treatment)
smk_data$Treatment <- gsub("DHR \\(Dynamic Harmonic Regression \\)", "DHR", smk_data$Treatment)
smk_data$Treatment <- gsub("NBM \\(negative binomial regression model\\)", "NBM", smk_data$Treatment)
# --- END: Insert the four modification lines here ---

# Convert 'Treatment' to a factor with levels ordered by 'mean' (highest to )
smk_data$Treatment <- factor(
  smk_data$Treatment,
  levels = rev(smk_data$Treatment[order(smk_data$mean)])
)


# Create the caterpillar plot using ggplot2
caterpillar_plot <- ggplot(smk_data, aes(x = Treatment, y = mean)) +
  # Add the 95% Credible Interval (2.5% to 97.5%)
  geom_errorbar(aes(ymin = `2.5%`, ymax = `97.5%`), width = 0.1, color = "darkgrey") +
  # Add the 50% Credible Interval (25% to 75%)
  geom_errorbar(aes(ymin = `25%`, ymax = `75%`), width = 0.2, linewidth = 1, color = "blue") +
  # Add the mean estimates (the "head" of the caterpillar)
  geom_point(size = 2.5, color = "blue") +
  # Add a vertical reference line at 0 (null effect)
  geom_hline(yintercept = 0, linetype = "dashed", color = "red") +
  # Flip the coordinates so the treatment names are on the y-axis (horizontal plot)
  coord_flip() +
  # Set informative labels and title
  labs(
  #  title = "Relative Effects",
    x = "Forecating Model",
    y = "Relative Effect"
  ) +
  # Apply a clean theme
  theme_minimal() +
  # Adjust the treatment labels position for better readability
  theme(
    axis.text.y = element_text(size = 8),
    plot.title = element_text(hjust = 0.5)
  )

# Print the plot
print(caterpillar_plot)

# Save the plot object 'p' to a file
ggsave(
  filename = here("output", "NMA_RE_Caterpillar_Plot.png"),
  plot = caterpillar_plot,
  width = 7.5, # Width of the image
  height = 8, # Height of the image
  units = "in", # Units for width/height
  dpi = 300 # Resolution (300 is print quality)
)

# Save the plot with PLOS-compliant settings
ggsave(
  filename = here("output", "NMA_RE_Caterpillar_Plot.tif"), 
  plot = caterpillar_plot, 
  device = "tiff", 
  dpi = 300,            # Required minimum resolution
  width = 7.5,          # Standard width for a full-page width figure (inches)
  height = 8,           # Adjust based on the number of models in your list
  units = "in", 
  compression = "lzw"   # Reduces file size without losing quality
)

message(paste("Figure saved to:", getwd(), "/", file_name))
