# 🌍 International Debt Analysis System

## 📌 Project Overview
An end-to-end data analytics pipeline for analyzing World Bank International Debt Statistics. 
This project covers data cleaning, exploratory data analysis, SQL analytics, and an interactive dashboard.

## 🛠️ Tech Stack
- **Python** — Data processing & EDA
- **Pandas** — Data manipulation
- **MySQL** — Database storage & SQL analytics
- **SQLAlchemy** — Python-MySQL integration
- **Plotly** — Interactive visualizations
- **Streamlit** — Interactive dashboard
## 📊 Dataset
- **Source**: World Bank International Debt Statistics (Jan 2022)
- **Records**: 1,023,779 rows after cleaning
- **Countries**: 120
- **Indicators**: 574
- **Years**: 2000–2024

## 🔄 Project Pipeline
1. **Data Loading** — Loaded 5 CSV files using Pandas
2. **Data Cleaning** — Handled nulls, dropped irrelevant columns, converted wide to long format using melt()
3. **EDA** — Country-wise, indicator-wise, year-wise, region-wise analysis
4. **MySQL** — Designed 3-table relational database with FK relationships
5. **SQL Queries** — 30 analytical queries (Basic, Intermediate, Advanced)
6. **Dashboard** — Interactive Streamlit dashboard with Plotly charts

## 📈 Key Insights
- 🇨🇳 **China** has the highest total debt
- 🏝️ **Tonga** has the lowest total debt
- 📈 Global debt grew from **34T to 170T** between 2000-2024
- 🌏 **East Asia & Pacific** holds 37.6% of global debt
- 💰 **Upper middle income** countries hold 71.5% of global debt

## ⚙️ How to Run
1. Clone the repository
```bash
git clone https://github.com/RajeshNarayanamoorthy10/International-Debt-Analysis-System.git
```
2. Install dependencies
```bash
pip install -r requirements.txt
```
3. Run Streamlit dashboard
```bash
streamlit run dashboard/app.py
```

## 👨‍💻 Author
**Rajesh Narayanamoorthy**  
Data Science Bootcamp — GUVI