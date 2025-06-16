# HeyMax Analytics Stack 🚀

This project sets up an end-to-end open-source data and analytics pipeline for HeyMax — built using:

- 🐣 DuckDB as the lightweight analytical warehouse
- 🛠 dbt for modeling (with staging, core, and growth layers)
- 📊 Streamlit for interactive growth dashboards
- ✅ All in a single GitHub repo — easily portable and reproducible

---

## 📦 Project Structure

```
heymax_project/
├── dashboard.py              # Streamlit app
├── heymax.duckdb             # DuckDB file created by dbt
├── requirements.txt          # All dependencies with versions
├── README.md                 # You're reading it
│
├── heymax_analytics/         # dbt project folder
│   ├── dbt_project.yml
│   ├── models/
│   │   ├── staging/          # stg_events.sql (materialized as table to inspect raw data)
│   │   ├── core/             # dim_users, fct_events (materialized as parquet tables)
│   │   └── growth/           # active users, growth accounting, cohort
│   └── models/schema.yml     # model docs + tests
│
└── .gitignore
```

---

## ⚙️ Setup Instructions

### 1. Clone and create virtual environment
```bash
git clone https://github.com/yourusername/heymax_project.git
cd heymax_project
python3 -m venv venv
source venv/bin/activate
```

### 2. Install Python dependencies
```bash
pip install -r requirements.txt
```

### 3. Run dbt models
```bash
cd heymax_analytics
dbt run
dbt test
```

### 4. Launch the dashboard
```bash
cd ..
streamlit run dashboard.py
```

---

## 🧪 Features & Metrics

- **Daily / Weekly / Monthly Active Users**
- **Growth Accounting**
  - New Users
  - Retained
  - Resurrected
  - Churned
  - Quick Ratio (based on DAU; gaps indicate missing data)
- **Retention Cohort** heatmap with triangle format
- **Streamlit interactivity**
  - Date range filters
  - Metric selector (DAU/WAU/MAU-based growth accounting)
  - Country filter (added)
  - Line / Area chart toggles

---

## 📈 Performance Optimizations (DuckDB)

DuckDB handles most indexing internally, but you can improve performance by:

- ✅ **Materializing dbt models to Parquet** (e.g. fct_events, dim_users) for better read efficiency
- ✅ **Partitioning by `event_date` or `country`** if loading from files
- ✅ **Filtering with indexed columns** (e.g. user_id, event_date)
- ✅ **Using vectorized execution + stats pushdown** (automatic)

> Note: Raw staging table (`stg_events`) is intentionally materialized as table for inspection.

### 🔁 Model Materialization Summary
| Model         | Materialization | Format  | Notes                            |
|---------------|------------------|---------|----------------------------------|
| stg_events    | table            | default | Retained for raw data inspection |
| dim_users     | table            | parquet | Efficient columnar access        |
| fct_events    | table            | parquet | Optimized for analytical queries |

### 📦 Why Parquet?
Parquet is a columnar storage format that excels for analytics:
- 🚀 **Faster Reads** — only loads queried columns (vs. row-wise storage)
- 💾 **Highly Compressed** — reduces storage footprint
- 🔍 **Vectorized Execution** — better scan + filter performance in DuckDB
- 🔄 **Interoperability** — widely supported by Spark, Pandas, BigQuery, etc.

---

## 🌐 Deployment (optional)

To deploy on [Streamlit Cloud](https://streamlit.io/cloud):
1. Push this repo to GitHub
2. Go to https://streamlit.io/cloud and link your GitHub repo
3. Set the entrypoint as `dashboard.py`
4. Done! 🎉

---

## 🔧 Requirements

### Python Version
- Python ≥ 3.9 (recommended)

### requirements.txt
```txt
streamlit==1.33.0
pandas==2.2.2
duckdb==0.10.1
altair==5.3.0
dbt-duckdb==1.9.0
watchdog==4.0.0
```

---

## 📈 Next Steps for Scaling

This stack is modular and built to grow. Here's how to take it to the next level:

| Upgrade Area          | Suggested Tools            | Benefit |
|-----------------------|-----------------------------|---------|
| Database              | BigQuery, Snowflake         | Handles large-scale data and concurrent users |
| Data Orchestration    | Airflow, dbt Cloud, Dagster | Automate dbt runs, alerts, and dependencies |
| Dashboard             | Looker, Superset, Metabase  | Production-grade dashboards with RBAC and performance |
| Streaming Ingestion   | Pub/Sub, Kafka, Fivetran    | Enable near real-time metrics pipelines |
| CI/CD                 | GitHub Actions, dbt tests   | Auto-validate models and deploy updates |

> ✅ If you're using BigQuery as your data warehouse, we recommend migrating your dashboards to **Looker** for long-term scalability, better data governance, and secure stakeholder access.

---

## ⚙️ Automation & Streaming Support

### CI/CD with GitHub Actions
- Set up workflows to:
  - Run `dbt build` and tests on push
  - Auto-deploy to Streamlit Cloud (or other cloud runners)
  - Send Slack/email alerts on failure

### Kafka for Real-time Ingestion (Simulated)
- Mock streaming data via a Kafka producer
- Write a listener script that:
  - Listens for new messages
  - Writes new rows to a CSV/parquet file in `data/`
  - Triggers a `dbt run` + auto-refresh Streamlit dashboard

> Add a `streaming/` folder for simulated producers and watchers

---

## 📬 Questions?
Feel free to reach out or submit an issue. Happy building!

— Built with ❤️ by the first Analytics Engineer at HeyMax





repo link. 
cd heymax-analytics


models/
├── staging/
│   ├── stg_events.sql
│   └── schema.yml
├── intermediate/
│   ├── dim_users.sql
│   ├── fct_events.sql
│   ├── user_lifecycle.sql
│   └── schema.yml
├── marts/
│   ├── growth_metrics.sql
│   └── schema.yml