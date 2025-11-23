# 📊 Growth Metrics Dashboard

This project sets up an end-to-end open-source data and analytics pipeline for HeyMax with an interactive analytics dashboard built using **Streamlit**, **DuckDB**, and **dbt** to analyze user lifecycle metrics over time. It supports both **monthly**, **weekly**, and **daily** views with charts, retention triangle tables, KPIs, filters, and LLM-based insights.

Access the live dashboard here: https://heymax-analytics-dev.streamlit.app/

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
├── .github/
│   ├──workflows/
│   │   ├──dbt_run.yml
│
├── heymax_dashboard/
│   ├── dashboard.py
│
├── heymax_database/
│   ├── heymax.duckdb
│
├── heymax_dbt/
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
│   │   │   ├── growth_metrics_monthly.sql
│   │   │   ├── growth_metrics_week.sql
│   │   │   ├── growth_metrics_daily.sql
│   │   │   ├── retention_triangle_monthly.sql
│   │   │   ├── retention_triangle_week.sql
│   │   │   ├── retention_triangle_daily.sql
│   │   │   └── schema.yml
│   ├── data/
│   │   ├── event_stream.csv
│   ├── dbt_project.yml
│   ├── profiles.yml
│
├── heymax_documentation/
│   ├── HeyMax_Analytics_Documentation.pdf
│
├── requirements.txt
│
└── README.md
```

---

## ⚙️ Setup Instructions

### 1. Clone the Repository

```bash
git clone https://github.com/SANCHIT-GARG/heymax-analytics.git
cd <path to cloned project>
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

### 4. Build dbt Models (Run docs generate and docs build command for auto-generated documentation for your dbt project)

```bash
cd heymax_dbt/
dbt build
dbt docs generate
dbt docs serve
```

### 5. Launch Streamlit Dashboard

Generate your own token to use LLM features: [OpenAI API](https://platform.openai.com/account/api-keys)

```bash
cd ../heymax_dashboard/
streamlit run dashboard.py
```

---

### 6. Deployment & CI/CD (Optional): Push your code to GitHub

- For CI:
    - `.github/workflows/dbt_run.yml` builds the project using dbt and updates the `heymax.duckdb` file
    - Configure your GitHub repository secrets to securely store your email credentials for CI email notifications:
        - Go to your repository on GitHub → Settings → Secrets and variables → Actions → New repository secret
        - Add the following secrets:
            - `EMAIL_USER` — your email address (used as the sender)
            - `EMAIL_PASSWORD` — your email account password or app-specific password
        - In your CI workflow (`.github/workflows/dbt_run.yml`), reference these secrets as environment variables to enable email notifications
    - You’ll receive an email notification with logs if the run fails or succeeds
    - The CI is also configured to run on every commit and scheduled to run everyday 8 am. This can be modified based on requirements. 
- For CD:
    - Connect your GitHub repository with [Streamlit Cloud](https://streamlit.io/cloud):
        - Sign in to Streamlit Cloud and click **"New app"**.
        - Select your GitHub repo and branch (e.g., `main`).
        - Set the app entry point to `heymax_dashboard/dashboard.py`.
    - Streamlit Cloud will automatically build and deploy your app whenever you push changes to the connected branch.
    - You can monitor deployment logs and app status directly from the Streamlit Cloud dashboard.

---

## 🔐 OpenAI Secrets Setup

On [Streamlit Cloud](https://streamlit.io/cloud) under your project - 
    - Click on Manage --> Settings
    - Add Below Secret
        ```
        OPENAI_API_KEY = "your-openai-key"
        ```

---

## ✨ Example Questions to Ask the LLM

- “What month had the highest churn rate?”
- “Compare new users vs resurrected users in April.”
- “Why did quick ratio drop in May?”
- “How many users were retained after 3 months from the March cohort?”

---

## 🧮 dbt Modelling

| Model Name                  | Materialization   | Strategy                  | Format   |
|----------------------------|-------------------|---------------------------|-----------|
| `stg_raw_events`           | `table`           | Full refresh              | Parquet   |
| `stg_events`               | `table`           | Full refresh              | Parquet   |
| `dim_users`                | `table`           | `delete+insert`           | Parquet   | 
| `fct_events`               | `incremental`     | `delete+insert`           | Parquet   |
| `user_lifecycle_*`         | `incremental`     | `delete+insert`           | Parquet   |
| `growth_metrics*`          | `View`            | -                         | -         |
| `retention_triangle*`      | `View`            | -                         | -         |



Happy building!
Reach out via [LinkedIn](https://www.linkedin.com/in/nsanchitgarg/)  
📧 `sanchit.garg07@gmail.com`