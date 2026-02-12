# TODO

## files

TODO: suggest renaming the files that are still used, with a prefix that gives people a sense of what order they should be run in. Then this document should explain briefly what each file does & also list the packages needed to run.

- [x] ~~02-07-2025_Catergory_NMA.R~~
- [x] 02-07-2025_NMA-By-Pete.R (renamed:nma_rmse_analysis)                          -> Where is RE and Cumrankprobs are. now add .RDS function 
- [x]  ~~03-10-2025_caterpillar-plot.R  -> Merge the bloat function into " 02-07-2025_NMA-By-Pete.R  "~~
- [x] ~~09-05-2025_NMA.R~~
- [x] ~~14-05-2025_RMSE-LOG_Plot.R~~
- [x] ~~14-07-2025_SA-NMA-example.R~~
- [x] ~~16-07-2025_NMA_Sub_group_by_time_horizon.R~~
- [x] ~~ 22-07-2025_NMA-by-RDS.R~~
- [x] 27-11-2025_NMA.R (renamed: network_setup_viz.R)                                 (cleaned as example), move/rename -> scripts/network_setup_viz.R
- [x] ~~Example-of-NMA.R                                  -> DELETED~~
- [x] ~~colab Python~~
- Data
    - [ ] PME
    - [ ] covar and Model



### EXAMPLE: https://github.com/petedodd/bmitb/tree/main

## Project Structure

```text
project-root/
│
├── data/              # Cleaned .CSV files (after preprocessing)
├── R/                 # Helper functions
│   ├── data_prep.R    # Functions for transforming long-to-wide format
│   └── plotting_fx.R  # Specific code for NMA, SUCRA, and Heatmaps
├── output/            
│   ├── models/        # Large .Rds objects of the fitted models
│   ├── tables/        # CSVs of relative effects (OR/MD) and SUCRA ranks
│   └── figures/       # The core visuals (NMA Diagrams, Forest Plots, SUCRA Curves,Heatmaps)
├── scripts/           # The actual workflow
│   ├── network_setup_vis.R # Network setup & analysis of the forecasting model categories.
│   ├── nma_rmse_analysis.R # NMA Quantitative Synthesis 
│   └── heatmap.R      # Heatmap of frequency of usage of specific Covariate Category and Model Type combinations across all studies
├── .gitignore         # Prevents tracking of large files (e.g., .rds, .pdf)
└── README.md          # Overview of the analysis and NMA specifications
```


# Systematic_Review_Dengue_Forecasting

## Software used in this analysis

This analysis used R veresion 4.4.1 and the following packages:


| Package | Version |
|---------|---------|
| multinma | 0.8.0 |
| data.table | 1.17.8 |
| ggplots2 | 4.0.0 |
| here | 1.0.2 |
| readxl | 1.4.5 |
| tidyverse |	2.0.0 |


## Data used in this analysis

A single archive of the public input data to reproduce this analysis has been posted on Zenodo at:
https://zenodo.org/xxx