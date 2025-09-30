## ---------------------------
##
## Script name: Load_Packages
##
## Purpose of script: Install & load packages needed to run the dashboard
##
## Author: Owen Williams
## Date Created: 30/09/2025
##
## ---------------------------

options(repos = c(CRAN = "https://cloud.r-project.org"))

# Minimal top-level packages referenced by ui.R / server.R
# (Dependencies like rlang/scales come in automatically via tidyverse/ggplot2)

packages = c(
  "shiny",      # dashboard
  "tidyverse",  # tidy data.
  "readxl",     # read_excel for .xls/.xlsx
  "tools",      # allow multiple file extensions
  "tsibble"     # Handle dates
)


# Install any that are missing
for (p in packages) {
  if (!requireNamespace(p, quietly = TRUE)) {
    install.packages(p)
  }
}

message("All required packages are installed. You can now run the reports.")
