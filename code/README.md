---
editor_options: 
  markdown: 
    wrap: 72
---

# EstimateAirQuality.r

## Overview

This R script estimates air pollutant concentrations (PM2.5 or
NOx) using a pre-trained XGBoost machine learning model developed by the
University of Vermont Transportation Research Center. The script loads a
saved model and applies it to new input data to generate predictions.

## Requirements

### R and RStudio

-   RStudio may be replaced with another IDE such as VisualStudioCode

### R Packages

-   `xgboost` - Machine learning model predictions
-   `data.table` - Fast data loading and manipulation
-   `pacman` - Package management

### Model Files

Pre-trained XGBoost models are located in:

```         
UVM TRC XGBoost AQ Model/models/[POLLUTANT]/[vehicle_class]_model.ubj
```

Where: - `[POLLUTANT]` = "PM" or "NOX" - `[vehicle_class]` = "ldv",
"mdv", or "hdv" (lowercase)

## Usage

### 1. Set User Inputs

Edit the USER INPUTS section at the top of the script:

``` r
# vehicle class options: "LDV", "MDV", "HDV"
VEHICLE_CLASS <- "LDV"

# pollutant options: "PM", "NOX"
POLLUTANT <- "PM"

# file directory where "UVM TRC XGBoost AQ Model" folder is located
DIRECTORY = "C:\\path\\to\\UVM TRC XGBoost AQ Model"

# input data file name (csv) located in "UVM TRC XGBoost AQ Model/data/inputs"
INPUT_FILE <- "input_data_example.csv"
```

### 2. Prepare Input Data

Input data must be saved as a CSV file in the `data/inputs` folder and
contain all required predictor variables. For the PM model, required
variables are: - `ED_PM25_10m` - `ED_PM25_250m` - `ED_PM25_500m` For the
NOX model, required variables are: - `ED_3_NOX_10m` - `ED_3_NOX_250m` -
`ED_3_NOX_500m`

Check your model's required variables by examining the script output:

```         
Expected predictor variables: ED_PM25_10m, ED_PM25_250m, ED_PM25_500m
```

### 3. Run the Script

Execute the script in R or RStudio:

``` r
source("EstimateAirQuality.r")
```

### 4. Output

Predictions are saved to:

```         
UVM TRC XGBoost AQ Model/data/outputs/predictions_[vehicle_class]_[pollutant].csv
```

The output file includes all input columns plus a new column: -
`PRED_[POLLUTANT]` - Model predictions for the specified pollutant

## Example Expected Output

```         
Loaded model for LDV and PM from .../models/PM/ldv_model.rds
Expected predictor variables: ED_PM25_10m, ED_PM25_250m, ED_PM25_500m
Loaded input data from .../data/inputs/input_data_example.csv
Input data has 1000 rows and 3 columns.
All required predictor variables are present in input data.
Generated 1000 predictions for PM
Saved predictions to .../data/outputs/predictions_ldv_pm.csv
Start Time: [timestamp]
End Time: [timestamp]
Total Duration: [X.XX] minutes
```

## Troubleshooting

### Error: "Could not determine predictor variables from the model"

-   Verify the model file exists and is in the correct location
-   Check that VEHICLE_CLASS and POLLUTANT variables are spelled
    correctly

### Error: "Input data is missing required predictor variables"

-   Verify all required columns are present in your input CSV
-   Check column names match exactly (case-sensitive)
-   The expected variables are printed when the model loads successfully

### Slow Runtime

-   Large datasets may take several minutes to process
-   Runtime is printed at the end of execution
-   Consider processing data in batches if file is very large

## Model Performance

Model details including comprehensive validation are available in the
manuscript "TITLE" available at "URL".

## Support

For issues or questions about the models, contact Greg Rowangould at
[Gregory.Rowangould\@UVM.edu](mailto:Gregory.Rowangould@UVM.edu){.email}.
