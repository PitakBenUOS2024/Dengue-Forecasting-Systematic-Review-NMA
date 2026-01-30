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
- [x] 27-11-2025_NMA.R                                  (cleaned as example), move/rename >> scripts/network_setup_viz.R
- [x] Example-of-NMA.R                                  -> DELETED

## Project Structure

```text
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
├── .gitignore         # Prevents tracking of large files (e.g., .rds, .pdf)
└── README.md          # Overview of the analysis and NMA specifications
```


# Systematic_Review_Dengue_Forecasting



