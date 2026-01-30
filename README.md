# TODO

## files

TODO: suggest renaming the files that are still used, with a prefix that gives people a sense of what order they should be run in. Then this document should explain briefly what each file does & also list the packages needed to run.

- [ ] 02-07-2025_Catergory_NMA.R
- [ ] 02-07-2025_NMA-By-Pete.R                           -> DELETED
- [ ] 03-10-2025_caterpillar-plot.R
- [ ] 09-05-2025_NMA.R
- [ ] 14-05-2025_RMSE-LOG_Plot.R
- [ ] 14-07-2025_SA-NMA-example.R
- [ ] 16-07-2025_NMA_Sub_group_by_time_horizon.R
- [ ] 22-07-2025_NMA-by-RDS.R
- [ ] 27-11-2025_NMA.R                                  (cleaned as example)
- [x] Example-of-NMA.R                                  -> DELETED

## Folder structure
project-root/
│
├── data-raw/          # Original, untouched CSVs/Excel files
├── data/              # Cleaned .Rds files (after preprocessing)
├── R/                 # Modular functions (e.g., plotting_functions.R)
├── output/            # Saved Stan models and result tables
├── scripts/           # The actual workflow
│   ├── 01_clean.R
│   ├── 02_run_model.R
│   └── 03_plots.R
├── .gitignore         # CRITICAL: Tell git to ignore large .html or .pdf files
└── README.md          # Brief overview of the analysis

## tip
- Don't track .rds models: Bayesian models are massive. If your model file is >50MB, don't push it to GitHub. Instead, save the summary tables or use Git LFS (Large File Storage).

- Use renv: Run renv::init() to capture the specific versions of multinma and rstan you are using. This ensures your code doesn't break for someone else 2 years from now.

# Systematic_Review_Dengue_Forecasting



