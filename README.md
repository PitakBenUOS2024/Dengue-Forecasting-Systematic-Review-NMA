# TODO

## files

TODO: suggest renaming the files that are still used, with a prefix that gives people a sense of what order they should be run in. Then this document should explain briefly what each file does & also list the packages needed to run.

- [ ] 02-07-2025_Catergory_NMA.R
- [x] 02-07-2025_NMA-By-Pete.R                           -> Where is RE and Cumrankprobs are. now add .RDS function
- [x] 03-10-2025_caterpillar-plot.R                      -> Merge the bloat function into " 02-07-2025_NMA-By-Pete.R  "
- [ ] 09-05-2025_NMA.R
- [ ] 14-05-2025_RMSE-LOG_Plot.R
- [ ] 14-07-2025_SA-NMA-example.R
- [ ] 16-07-2025_NMA_Sub_group_by_time_horizon.R
- [ ] 22-07-2025_NMA-by-RDS.R
- [x] 27-11-2025_NMA.R                                  (cleaned as example), move/rename -> scripts/network_setup_viz.R
- [x] Example-of-NMA.R                                  -> DELETED
- [ ] colab Python




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
│   ├── 01_clean.R
│   ├── 02_run_model.R
│   └── 03_plots.R
├── .gitignore         # Prevents tracking of large files (e.g., .rds, .pdf)
└── README.md          # Overview of the analysis and NMA specifications
```


# Systematic_Review_Dengue_Forecasting

## Software used in this analysis

This analysis used R veresion 4.5.0 and the following packages:


| Package | Version |
|---------|---------|
| R | 4.4.1 |
| multinma | 0.8.0 |
| data.table | 1.17.8 |
| ggplots2 | 4.0.0 |
| here | 1.0.2 |


## Data used in this analysis

A single archive of the public input data to reproduce this analysis has been posted on Zenodo at:
https://zenodo.org/xxx