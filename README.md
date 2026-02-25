# Systematic Review: Dengue Forecasting Network Meta-Analysis

## Abstract / Summary
This repository contains the data and analytical code for a systematic review and Network Meta-Analysis (NMA) of Dengue forecasting models. The study evaluates the predictive performance of various model categories using Root Mean Square Error (RMSE) as the primary metric. By utilizing a Bayesian NMA framework, we compare diverse forecasting methodologies across different studies and identify which model types and covariate categories are most frequently and effectively employed.

---



## Installation & Requirements

### Software
This analysis used R veresion 4.4.1 and the following packages:


| Package | Version |
|---------|---------|
| multinma | 0.8.0 |
| data.table | 1.17.8 |
| ggplot2 | 4.0.0 |
| here | 1.0.2 |
| readxl | 1.4.5 |
| tidyverse |	2.0.0 |

### Required R Packages
You can install the necessary libraries using the following command:

```R
install.packages(c("multinma", "data.table", "ggplot2", "here", "readxl", "tidyverse"))
```

---

## Project Structure

```text
Systematic_Review_Dengue_Forecasting/
│
├── data/                       # Input data files
│   ├── PME.csv                 # Primary Performance Metric Extraction data
│   ├── covar.xlsx              # Covariate category data
│   └── model.xlsx              # Model type classification data
│
├── scripts/                    # Core analysis workflow
│   ├── 01_network_setup_vis.R  # Network visualization & comparison analysis
│   ├── 02_nma_rmse_analysis.R  # NMA Quantitative Synthesis (RMSE log-scale)
│   └── 03_heatmap.R            # Model Type vs Covariate Category Heatmap
│
├── output/                     # Generated results (gitignored except for structure)
│   ├── models/                 # Saved .Rds fitted model objects
│   ├── tables/                 # CSVs of Relative Effects, SUCRA, and counts
│   └── figures/                # PNG/TIFF exports (Caterpillar, SUCRA, Network)
│
├── .gitignore                  # Prevents tracking of large .Rds and .tiff files
└── README.md                   # Project overview and instructions
```
---

## Workflow: Execution Order

To reproduce the analysis, run the scripts in the following order:

1. **`scripts/01_network_setup_vis.R`**
    * Prepares the network geometry and categories.
    * Generates the **Network Diagram** and saves node size data to `output/table/`.

2. **`scripts/02_nma_rmse_analysis.R`**
    * Performs data cleaning, specifically filtering out non-positive values ($RMSE \leq 0$) before applying a $log_{10}$ transformation.
    * Fits the **Bayesian NMA model** using `multinma` (Note: This may take 30+ minutes).
    * Generates **Caterpillar Plots**, **SUCRA Curves**, and exports relative effect tables.

3. **`scripts/03_heatmap.R`**
    * Merges model types with covariate data (Climate, Socio-economic, etc.).
    * Produces the **Model vs. Covariate Heatmap** to visualize research trends.
---

## Data Sources

* **`PME.csv`**: Primary Performance Metric Extraction data.
* **`covar.xlsx` / `model.xlsx`**: Categorical data for secondary heatmap analysis.

---

## Citation

If you use this code or data in your research, please cite:

> Pitak Benjarattanaporn, Debebe Shaweno Adewo, Anthea Sutton, Andrew Lee, and Pete J. Dodd. (2026). **Dengue Forecasting Models: A Systematic Review Incorporating a Network Meta-Analysis and Comparative Analysis of Methodologies.** *medRxiv*. doi: [https://doi.org/10.64898/2026.02.18.26346534](https://doi.org/10.64898/2026.02.18.26346534)