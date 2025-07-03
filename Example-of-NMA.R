# Load the multinma package
library(multinma)

# Load the atrial fibrillation dataset (example dataset included in the package)
data("atrial_fibrillation")

# Prepare the data for network meta-analysis using set_agd_arm
# This function is used to format aggregate data with one row per arm per study
af_net <- set_agd_arm(
  data = atrial_fibrillation, # The dataset
  study = studyc,             # Study identifier
  trt = trtc,                 # Treatment identifier
  r = r,                     # Number of events
  n = n                      # Total sample size in the arm
  # trt_class = trt_class     # Optional: Treatment class identifier
)

# Print the prepared data (optional)
print(af_net)
plot(af_net)

# Create a network plot, weighting nodes by sample size
#  -  Uses the prepared data (af_net)
#  -  Sets weight_nodes to TRUE to weight nodes by sample size
#  -  Adds a title using ggplot2's labs function
library(ggplot2) # Load ggplot2 for adding the title
plot(af_net, weight_nodes = TRUE) +
  labs(title = "NMA Network (Node size = Sample Size)")

# You can further customize the plot, for example, to show treatment classes:
# plot(af_net, weight_nodes = TRUE, show_trt_class = TRUE) +
#   labs(title = "NMA Network with Treatment Classes")


# Perform the network meta-analysis using nma
#  -  Uses a random-effects model (trt_effects = "random")
#  -  Assumes consistency (consistency = "consistency")
af_nma <- nma(af_net,
              trt_effects = "random",
              consistency = "consistency")

# Print the results of the NMA (optional)
print(af_nma)



