# Data Exploration Notebook Guide (`0. data_exploration.ipynb`)

Concise guide for the exploratory analysis notebook that profiles the raw Google search history before NER extraction or graph loading.

## Purpose
- Baseline EDA on `search_history.json` to understand volume, timing, and activity mix.
- Quick clustering (TF-IDF + K-Means/Hierarchical) to surface interest themes without calling external APIs.
- Sanity checks on data quality and feature engineering ahead of downstream pipelines.

## Prerequisites
- Python 3.10+ with `requirements.txt` installed (`%pip install -q -r requirements.txt` in the notebook).
- NLTK data downloaded (the notebook runs `download_nltk_data.py`; rerun if first-time setup).
- Input file: `search_history.json` in the repo root.
- No API keys required and no Neo4j dependency.

## How to Run
1) Open `0. data_exploration.ipynb` and run top-to-bottom. Keep the kernel alive; several globals (e.g., `df`, `search_df`, `tfidf_matrix`) are reused across sections.
2) Ensure the `%pip` install cell completes; re-run if packages were missing.
3) If NLTK downloads fail, run `python download_nltk_data.py` from the repo root, then re-run the notebook.
4) Visual outputs (matplotlib/seaborn) are generated inline; no files are written by default.

## Notebook Structure (12 sections)
1) Setup & imports
2) Data loading: read `search_history.json` into `df`, basic counts
3) Cleaning & feature engineering: classify activity type, extract queries/domains, derive time fields
4) Data quality: missing values, dtypes overview
5) Descriptive stats & temporal analysis: hourly/daily distributions, top searches/pages
6) Visualizations: temporal plots and activity mix
7) Text preprocessing: NLTK tokenization, lemmatization, keyword extraction
8) TF-IDF vectorization: bi-grams, feature summary
9) Optimal K analysis: inertia, silhouette, Davies-Bouldin, Calinski-Harabasz
10) K-Means clustering: labels, sizes, top keywords, sample queries
11) Hierarchical clustering: Ward linkage, dendrogram sample, metric comparison
12) Cluster visualizations & summary report: side-by-side charts and a printed findings recap

## Outputs & What to Look For
- Console summaries: record counts, temporal coverage, keyword frequencies, clustering metrics.
- Plots: hourly/daily activity, pie charts for activity/cluster shares, dendrogram sample, cluster keyword bars.
- DataFrames in-memory only; no artifacts saved. Use the summary report cell for a concise findings list.

## When to Use This Notebook
- First pass to understand the dataset before running `1. search_extraction_analysis_v3.ipynb`.
- Rapidly identify noisy queries/domains or temporal gaps.
- Validate clustering readiness and choose an initial `K` for downstream topic modeling.

## Tips
- If you change `search_history.json`, re-run from the top to refresh derived columns.
- Adjust `TfidfVectorizer(max_features=200, ngram_range=(1, 2))` and `K_range = range(2, 13)` to explore different cluster granularities.
- For faster plotting on large data, sample queries before plotting the dendrogram.
