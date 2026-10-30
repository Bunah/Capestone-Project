# Reducing Customer Churn at Meridian Retail Group
An End-to-End Data Science Investigation

## 📊 Project Overview
Meridian Retail Group, a mid-sized multi-channel retailer, faces rising customer churn. This project diagnoses churn drivers, builds predictive models, and deploys an API for real-time churn scoring.

## 📂 Project Structure
capstone_project/
│
├── data/                # Raw and processed datasets
├── notebooks/           # Phase 8–10 Jupyter notebooks
├── models/              # Saved ML models + metadata
├── visualizations/      # Charts, plots, SHAP explanations
├── api/                 # FastAPI app + requirements.txt
└── reports/             # PDF report + PPTX presentation

## ⚙️ Methodology
1. **Data Cleaning & EDA** — RFM features, churn definition (>365 days inactive).
2. **Feature Engineering** — Recency, Frequency, Monetary, support ticket metrics.
3. **Modeling** — Logistic Regression, Decision Tree, Random Forest, Gradient Boosting.
4. **Interpretation** — Feature importance, SHAP global & customer-level plots.
5. **Deployment** — FastAPI service for real-time churn prediction.

## 📈 Results
- Gradient Boosting achieved ~99.9% accuracy (synthetic dataset).
- Logistic Regression ~98% accuracy.
- Random Forest ~99.8% accuracy.
- Decision Tree ~100% accuracy (likely overfitting).
- Key drivers: Recency, Frequency, Ticket Satisfaction.
- SHAP plots confirm inactivity and poor support drive churn risk.

## 💡 Recommendations
- Retention campaigns for inactive customers.
- Faster support resolution.
- Loyalty program upgrades for Silver-tier customers.
- Enhanced online engagement.


