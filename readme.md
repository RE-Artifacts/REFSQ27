# Towards Developer Engagement with Requirements during Code Review - Supplemental Material

## Purpose

This repository contains the supplemental information for the REFSQ research preview entitled **"Towards Developer Engagement with Requirements during Code Review"**.
This work investigates developer behavior during code reviews, with and without the task of selecting requirements that are relevant to the merge request.

## Description of Artifact

This repository includes the list of requirements used in the study, anonymized data from the screen recordings and eye tracker, and analysis script used to generate the figures and statistics in the paper.

### Directory Structure
```
activity_no_reqs.csv            # list of sequential activities by each subject in Period 1
activity_no_reqs.csv            # list of sequential activities by each subject in Period 2
code_review_stats.R             # code used to analyze data
readme.md                       # this file
requirements_detail.csv         # eye tracking data from Period 2
selected_reqs.csv               # list of requirements selected by each subject in Period 2
strawbeberya.zip                # source code for Strawbeberya project
strawbeberya_reqs.csv           # requirements list used in Period 2
study-docs.pdf                  # study protocol documents, including timing and merge request information
```

## Setup

### Statistics
To analyze results, download and install **R**. For ease of use, we recommend **RStudio**. The analyses in the paper were created using RStudio for OSX (Version: 2023.12.0+369) and R version 4.4.0 (2024-04-24).

Install the following R packages:  

```
ggplot2
tidyr
dplyr
stats
paletteer
PMCMRplus
```

## License

This work is licensed under a Creative Commons Attribution-NonCommercial-No Derivative Works 4.0 International License.