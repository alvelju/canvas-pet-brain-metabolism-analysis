# CANVAS PET Metabolism Analysis

Research code for a study of regional cerebral glucose metabolism and clinical characteristics of CANVAS syndrome.

## Contents
- `matlab/`: PET spatial normalization (`normalizeAll.m`), reslicing to the AAL3 atlas grid (`resliceAll.m`), and extraction of regional mean PET values (`glucosa_por_zonasAll.m`).
- `notebooks/01_clinical_phenotypes.ipynb`: analysis of clinical phenotypes, including statistical testing, PCA, clustering, feature selection, and classification.
- `notebooks/02_symptom_onset.ipynb`: statistical analysis of symptom-onset age, correlations, PCA, and clustering.
- `references/zones_numbered.txt`: brain-region labels used by the analysis.

## Data availability and workflow
MATLAB scripts produce regional PET measurements. These were combined separately with clinical data provided by the medical research team to create an analysis dataset. **The MATLAB scripts and Python notebooks are not connected by an automated pipeline.**

The notebooks use `data_merged-3.xlsx`, a **synthetic dataset** containing artificially generated patient records that preserve the structure and general characteristics of the original research dataset.

The synthetic dataset is provided for demonstration and reproducibility purposes only. It does not contain real patient data, and any results obtained from it should not be interpreted as scientific findings from the original study.

Original PET images and clinical patient data are not included in this repository.

## Reproducibility notes
- The notebook **Python code cells are unchanged** from the original research files.
- Only notebook Markdown headings/descriptions were translated or added, and saved cell outputs and execution counts were cleared.
- MATLAB scripts are unchanged and require paths to be configured before running.
- The notebooks contain exploratory analysis and have not been independently rerun or validated for this public release.
- MATLAB processing requires MATLAB and SPM; Python notebooks require the packages imported in the code, including NumPy, pandas, SciPy, scikit-learn, Matplotlib, seaborn, statsmodels and openpyxl.
- The AAL3 atlas and FDG template must be supplied separately according to their respective terms.

## Caution
This repository is for research demonstration, not clinical use. Do not commit patient data or identifiable notebook outputs.
