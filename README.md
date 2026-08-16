# 🏦 Loan Default Risk Analysis & Bayesian Credit Scoring System

## 📌 Project Overview
An end-to-end data analysis project simulating real-world BFSI 
(Banking, Financial Services & Insurance) analytics work done at 
companies like TCS, Infosys, and Cognizant.

The project analyzes loan applicant data to identify default risk 
drivers and builds a Bayesian probability-based credit risk scorer 
from scratch — without any machine learning black boxes.

---

## 🎯 Problem Statement
Banks lose significant revenue when loan applicants default on 
repayments. This project answers:
- Which applicant segments carry the highest default risk?
- What combination of features (credit history, EMI burden, income) 
  best predicts default probability?
- How can we score every applicant with a risk tier 
  (High / Medium / Low) using probability theory?

---

## 🗂️ Project Structure
loan-default-risk-analysis/
│
├── data/
│ ├── loan_applicants_raw.csv # Raw dataset with intentional mess
│ └── loan_applicants_clean.csv # Cleaned dataset
│
├── notebooks/
│ ├── 01_data_generation_cleaning.ipynb # Phase 1
│ ├── 02_eda_visualization.ipynb # Phase 2
│ └── 03_bayesian_risk_scorer.ipynb # Phase 4
│
├── sql/
│ ├── 01_basic_queries.sql # Q1-Q5
│ ├── 02_intermediate_queries.sql # Q6-Q12
│ └── 03_advanced_queries.sql # Q13-Q18
│
└── README.md
---

## 🔧 Tech Stack
| Tool | Purpose |
|------|---------|
| Python | Core programming language |
| Pandas & NumPy | Data manipulation & cleaning |
| Matplotlib & Seaborn | Data visualization |
| MySQL | SQL analysis (18 business queries) |
| Probability Theory | Bayesian risk scoring |

---

## 📊 Dataset
- **Size:** 6,000 synthetic loan applicant records
- **Domain:** Banking / BFSI
- **Features:** Income, loan amount, EMI, credit history, 
  region, employment type, age, dependents
- **Target:** `default_status` (1 = defaulted, 0 = repaid)
- **Portfolio default rate:** ~12% (realistic BFSI benchmark)
- **Intentional data quality issues:** Missing values, duplicates, 
  inconsistent text casing, outliers, impossible ages

---

## 🚀 Project Phases

### Phase 1 — Data Generation & Cleaning
- Generated realistic messy dataset using NumPy/Pandas
- Removed 80 duplicate applicant records
- Standardized inconsistent categorical text 
  (e.g. "salaried" / "SALARIED" / "Salaried ")
- Fixed impossible age values (1, 2, 150, 200) → treated as missing
- Median imputation for skewed numeric columns (income, loan amount)
- Treated missing credit history as "No History" category 
  (meaningful signal in banking, not random noise)
- Log-transformed IQR for outlier detection on right-skewed income data
- Winsorized outlier incomes instead of dropping rows

### Phase 2 — Exploratory Data Analysis
Built 5 visualization sets answering specific business questions:
1. Distribution plots (income, loan amount, age)
2. Default rate by category (credit history, region, employment, education)
3. Correlation heatmap of numeric features
4. Loan amount vs income scatter (colored by default status)
5. EMI burden analysis with default rate by EMI bucket

### Phase 3 — SQL Analysis (MySQL)
Wrote 18 business SQL queries across 3 difficulty tiers:
- **Basic (Q1-Q5):** Aggregations, GROUP BY, ORDER BY, LIMIT
- **Intermediate (Q6-Q12):** Multi-column GROUP BY, date functions, 
  CASE WHEN, HAVING
- **Advanced (Q13-Q18):** Window functions (RANK, ROW_NUMBER, LAG, 
  running totals), correlated subqueries, CTEs

### Phase 4 — Bayesian Credit Risk Scorer
Built a probability-based risk scoring engine from scratch:
- **Prior:** P(Default) = 11.95% portfolio baseline
- **Likelihoods:** Conditional default probabilities per feature
  - P(Default | Bad Credit) = 39.94%
  - P(Default | Good Credit) = 6.84%
  - P(Default | No History) = 19.33%
- **Naive Bayes scoring:** Combined likelihoods normalized 
  against prior
- **Risk tiers:** High / Medium / Low validated against 
  actual default rates

---

## 🔑 Key Findings
- **Credit history** is the strongest default predictor — 
  Bad credit applicants default at 40% vs 7% for Good credit
- **EMI burden** adds moderate signal when combined with 
  credit history
- **Income bracket alone** is a weak predictor — 
  EMI-to-income ratio matters more than raw income
- **Regional variation** exists in default rates
- **Self-employed** applicants show higher default rates 
  than salaried

---

## 👤 Author
**Soumik Mandal**
B.Tech CSE (Data Science) — Narula Institute of Technology, Kolkata
3rd Year | Batch 2024-2028
