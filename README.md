# 📊 Growth Metrics Dashboard

This project sets up an end-to-end open-source data and analytics pipeline for HeyMax with an interactive analytics dashboard built using **Streamlit**, **DuckDB**, and **dbt** to analyze user lifecycle metrics over time. It supports both **monthly**, **weekly**, and **daily** views with charts, retention triangle tables, KPIs, filters, and LLM-based insights.

---

## 🚀 Features

- 📅 Toggle between **Monthly**, **Weekly**, and **Daily** metrics  
- 📈 Charts for:
  - New, Resurrected, Retained, Churned, and Active Users
  - Stacked bar + line charts (Quick Ratio, Retention Rate)
- 📐 Retention Triangle (monthly, weekly, and daily cohorts)
- 🎯 KPI cards for the latest period
- 🎛️ Filters: date range  
- 💬 Ask your data (powered by OpenAI’s GPT-4)
- ⬇️ Download filtered report as CSV

---

## 🧱 Tech Stack

| Layer        | Tool              |
|--------------|-------------------|
| Backend DB   | DuckDB            |
| Data Modeling| dbt               |
| Frontend     | Streamlit         |
| Visualization| Plotly            |
| LLM Chat     | OpenAI GPT (via API key) |
| Deployment   | GitHub            |


---

## 📁 Project Structure

```
project/
│
├── heymax_analytics/
│   ├── models/
│   │   ├── staging/
│   │   │   ├── stg_raw_events.sql
│   │   │   ├── stg_events.sql
│   │   │   └── schema.yml
│   │   ├── intermediate/
│   │   │   ├── dim_users.sql
│   │   │   ├── fct_events.sql
│   │   │   ├── user_lifecycle_daily.sql
│   │   │   ├── user_lifecycle_weekly.sql
│   │   │   ├── user_lifecycle_monthly.sql
│   │   │   └── schema.yml
│   │   ├── growth/
│   │   │   ├── growth_metrics.sql
│   │   │   ├── growth_metrics_week.sql
│   │   │   ├── growth_metrics_daily.sql
│   │   │   ├── retention_triangle.sql
│   │   │   ├── retention_triangle_week.sql
│   │   │   ├── retention_triangle_daily.sql
│   │   │   └── schema.yml
│   ├── data/event_stream.csv
│   ├── dbt_project.yml
│   ├── profiles.yml
│
├── dashboard.py
├── .github/workflows/dbt_run.yml
├── requirements.txt
├── heymax.duckdb
└── README.md
```

---

## ⚙️ Setup Instructions

### 1. Clone the Repository

```bash
git clone https://github.com/SANCHIT-GARG/heymax-analytics.git
cd heymax-analytics
```

### 2. Create a Virtual Environment (Python 3.11)

```bash
python3.11 -m venv heymax_env
source heymax_env/bin/activate
```

### 3. Install Dependencies

```bash
pip install -r requirements.txt
```

### 4. Run dbt Models

```bash
dbt build
```

### 5. Launch Streamlit Dashboard

Generate your own token to use LLM features: [OpenAI API](https://platform.openai.com/account/api-keys)

```bash
streamlit run dashboard.py
```

---

### 6. Deployment & CI/CD (Optional)

- CI pipeline `.github/workflows/dbt_run.yml` builds the project using dbt and updates the `heymax.duckdb` file
- You’ll receive an email notification with logs if the run fails or succeeds
- For CD:
  - Push your repo to GitHub
  - Connect repo with [Streamlit Cloud](https://streamlit.io/cloud)
  - Streamlit auto-deploys your app based on latest changes

---

## 🔐 OpenAI Secrets Setup

Create a file `.streamlit/secrets.toml`:

```toml
[openai]
api_key = "your-openai-key"
```

---

## ✨ Example Questions to Ask the LLM

- “What month had the highest churn rate?”
- “Compare new users vs resurrected users in April.”
- “Why did quick ratio drop in May?”
- “How many users were retained after 3 months from the March cohort?”

---

## 🧮 dbt Model Recommendations

| Model Name                  | Materialization   | Strategy                  | Format    | Notes |
|----------------------------|-------------------|---------------------------|-----------|-------|
| `stg_raw_events`           | `view`            | —                         | —         | Light transformations |
| `stg_events`               | `view`            | —                         | —         | Cleansed staging |
| `dim_users`                | `table`           | Full refresh              | Parquet   | Stable dim table |
| `fct_events`               | `incremental`     | `delete+insert`           | Parquet   | Append-safe fact model |
| `user_lifecycle_*`         | `table`           | Full refresh              | Parquet   | Use one per granularity (daily, weekly, monthly) |
| `growth_metrics*`          | `incremental`     | `delete+insert`           | Parquet   | Metric aggregations |
| `retention_triangle*`      | `table`           | Full refresh              | Parquet   | Best for snapshot-style matrix |

Use `{{ config(materialized='incremental', incremental_strategy='delete+insert', format='parquet') }}` for incremental models.


## 📬 Contact

Built with ❤️ by **Sanghavi Vemulapati**  
Questions or feedback? Reach out via [LinkedIn](https://www.linkedin.com/)  
📧 `your-email@example.com`