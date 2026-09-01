## ABOUT THIS CODE ############################################################

# This R script estimates air quality pollutant emissions (PM2.5 or NOx)
# using an XGBoost model prepared by the University of Vermont Transportation Research Center.
# Users can specify the vehicle class (LDV, MDV, HDV) and pollutant (PM or NOx) in the USER INPUTS section.
# The script loads the pre-trained model and applies it to new input data to generate predictions.
# Input data format must match that used in model training (see example data set) and be located in the
# "UVM TRC XGBoost AQ Model/data/inputs" folder.

## SET UP ###################################################################

rm(list = ls())
gc()
pacman::p_load(tidyverse, xgboost, data.table)
set.seed(99999)

## USER INPUTS ##############################################################

# vehicle class options: "LDV", "MDV", "HDV"
VEHICLE_CLASS <- "LDV"

# pollutant options: "PM", "NOX"
POLLUTANT <- "PM"

# file directory where "UVM TRC XGBoost AQ Model" folder is located
DIRECTORY = "./UVM_TRC_XGBoost_AQ_Model"

# input data file name (csv) located in "UVM TRC XGBoost AQ Model/data/inputs"
INPUT_FILE <- "input_data_example.csv"

### DO NOT MODIFY BELOW THIS LINE ##############################################

## LOAD MODEL AND INPUTS ##########################################################

# start time
start_time <- Sys.time()
cat("Start Time:", format(start_time), "\n")

## load model ###

# read in model based on user inputs for vehicle class and pollutant
model_dir <- file.path(DIRECTORY, "models", POLLUTANT)
model_name <- paste0(tolower(VEHICLE_CLASS), "_model.ubj")
model_path <- file.path(model_dir, model_name)
model <- xgb.load(model_path)

# resolve the predictor variables the model was trained on.
# the .ubj files carry no feature names.
POLLUTANT_FEATURES <- list(
  PM  = c("ED_PM25_10m", "ED_PM25_250m", "ED_PM25_500m"),
  NOX = c("ED_3_NOX_10m", "ED_3_NOX_250m", "ED_3_NOX_500m")
)
features <- POLLUTANT_FEATURES[[POLLUTANT]]

# print message if model is successfully loaded
cat("Loaded model for", VEHICLE_CLASS, "and", POLLUTANT, "from", model_path, "\n")
cat("Expected predictor variables:", paste(features, collapse = ", "), "\n")

## load input data ###

input_dir <- file.path(DIRECTORY, "data", "inputs")
inputs_path <- file.path(input_dir, INPUT_FILE)
input <- fread(inputs_path)

# print if input data is successfully loaded
cat("Loaded input data from", inputs_path, "\n")
cat("Input data has", nrow(input), "rows and", ncol(input), "columns.\n")

# check if all required predictor variables are present in input data
missing_vars <- setdiff(features, colnames(input))
if (length(missing_vars) > 0) {
  stop("Input data is missing required predictor variables: ", paste(missing_vars, collapse = ", "))
} else {
  cat("All required predictor variables are present in input data.\n")
}

## MAKE PREDICTIONS ##############################################################

# create dataframe to store predictions
data <- input

# run xgboost prediction
predictions <- predict(model, newdata = as.matrix(data[, features, with = FALSE]))

# add predictions to data
data[, paste0("PRED_", POLLUTANT) := predictions]
cat("Generated", length(predictions), "predictions for", POLLUTANT, "\n")

## SAVE OUTPUTS ##################################################################

# write predictions to output file
output_dir <- file.path(DIRECTORY, "data", "outputs")
output_name <- paste0("predictions_", tolower(VEHICLE_CLASS), "_", tolower(POLLUTANT), ".csv")
output_path <- file.path(output_dir, output_name)
fwrite(data, output_path)
cat("Saved predictions to", output_path, "\n")

# end time
end_time <- Sys.time()
cat("End Time:", format(end_time), "\n")
cat("Total Duration:", round(difftime(end_time, start_time, units = "secs"), 2), "seconds\n")


