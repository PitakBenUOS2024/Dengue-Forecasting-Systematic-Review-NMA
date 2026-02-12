library(here)
library(data.table)
library(multinma)
library(ggplot2)

# ================ load data ================ 
D <- fread(here("data/PME.csv"))

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
                   trt_ref = "Naïve" # <<< THIS IS REFERENCE MODEL.
)

print(DM)

plot(DM)



# ==================== NMA Setup =============================# 
# Take sometimes to run (e.g., 30 min)
nma_fit <- nma(DM,
              trt_effects = "random",
              prior_intercept = normal(scale = 100),
              prior_trt = normal(scale = 100),
              prior_het = normal(scale = 5),
              iter = 4000 # Increase from default (often 2000) to 4000, 6000, or more
              )


# saveRDS(nma_fit, file = here("output", "models", "NMA_REFF_NAIVE.rds"))

# Read the file from the nested folder
# nma_fit <- readRDS(here("output", "models", "NMA_REFF_NAIVE.rds"))
print(nma_fit)

# ==================== Relative Effects Value =============================
nma_releff <- relative_effects(nma_fit, all_contrasts = FALSE)
print(nma_releff)

# This will display the DIC in your console
dic(nma_fit)

# Convert the multinma relative effects object to a data frame
nma_re_df <- as.data.frame(nma_releff)

# Add a 'Treatment' column by extracting the treatment names from the row names
nma_re_df$Treatment <- nma_re_df$parameter

# Extract the clean treatment name (removing "d[" and "]") for better labels
nma_re_df$Treatment <- gsub("^d\\[|\\]$", "", nma_re_df$Treatment)

# Replace full names with abbreviations
nma_re_df$Treatment <- gsub("Exponential Smoothing", "EM", nma_re_df$Treatment)
nma_re_df$Treatment <- gsub("Gaussian Process \\(GP\\)", "GP", nma_re_df$Treatment)
nma_re_df$Treatment <- gsub("DHR \\(Dynamic Harmonic Regression \\)", "DHR", nma_re_df$Treatment)
nma_re_df$Treatment <- gsub("NBM \\(negative binomial regression model\\)", "NBM", nma_re_df$Treatment)

# Convert 'Treatment' to a factor with levels ordered by 'mean' (Lowest to hightest )
nma_re_df$Treatment <- factor(nma_re_df$Treatment, levels = nma_re_df$Treatment[order(nma_re_df$mean, decreasing = TRUE)])

# Create the caterpillar plot using ggplot2
caterpillar_plot <- ggplot(nma_re_df, aes(x = Treatment, y = mean)) +
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

# ================ Plot =============================

ggsave(
  filename = here("output", "RE_Caterpillar_Plot.png"),
  plot = caterpillar_plot,
  width = 7.5, # Width of the image
  height = 8, # Height of the image
  units = "in", # Units for width/height
  dpi = 300 # Resolution (300 is print quality)
)

# Save the plot with Journal-compliant settings
ggsave(
  filename = here("output", "RE_Caterpillar_Plot.tif"), 
  plot = caterpillar_plot, 
  device = "tiff", 
  dpi = 300,            # Required minimum resolution
  width = 7.5,          # Standard width for a full-page width figure (inches)
  height = 8,           # Adjust based on the number of models in your list
  units = "in", 
  compression = "lzw"   # Reduces file size without losing quality



## ==================== Cumulative Rank Probability & SUCRA Curves =============================
 
nma_ranks <- posterior_rank_probs(nma_fit, lower_better = TRUE)
nma_ranks 
plot(nma_ranks) + xlim(1, 47) +
  labs(title = "Rank Probability")

# SUCRA Curves
nma_sucra <- posterior_rank_probs(nma_fit, lower_better = TRUE, cumulative = TRUE)
nma_sucra
plot(nma_sucra) + xlim(1, 47) +
  labs(title = "Cumulative Rank Probability")

# ================ Plot =============================

ggsave(
  filename = here("output","cumulative_rank_probability.png"),
  plot = plot(nma_sucra) + xlim(1, 47), # Call the plot function here
  dpi = 300,            # Required minimum resolution
  width = 7.5,          # Standard width for a full-page width figure (inches)
  height = 8,           # Adjust based on the number of models in your list
  units = "in", 
  compression = "lzw"   # Reduces file size without losing quality

# Save the plot with Journal-compliant settings
ggsave(
  filename = here("output","cumulative_rank_probability.tif"),
  plot = plot(nma_sucra) + xlim(1, 47), # Call the plot function here
  device = "tiff", 
  dpi = 300,            # Required minimum resolution
  width = 7.5,          # Standard width for a full-page width figure (inches)
  height = 8,           # Adjust based on the number of models in your list
  units = "in", 
  compression = "lzw"   # Reduces file size without losing quality
)







