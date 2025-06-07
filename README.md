# 📊 HeyMax Analytics Stack (Open Source)

This project implements a modern, lightweight analytics stack for HeyMax to help the business self-serve growth and engagement metrics. It is fully open source and designed for fast iteration with local tooling (DuckDB + dbt). It can be extended later to work with BigQuery and production-grade orchestration.

---

## 🔧 Tech Stack

| Component     | Tool         | Purpose                                |
|---------------|--------------|----------------------------------------|
| Data Storage  | DuckDB       | Local, embedded analytics database     |
| Transformation| dbt-core     | SQL-based data modeling and testing    |
| Dashboard     | Superset     | Visualizing growth & retention metrics |

---

## 📂 Project Structure

heymax_project/
├── data/
│ └── event_stream.csv # Raw user event logs
├── models/
│ ├── staging/
│ │ └── stg_events.sql
│ ├── marts/
│ │ ├── dim_users.sql
│ │ └── fct_events.sql
│ └── growth/
│ └── user_growth_metrics.sql (coming soon)
├── .gitignore
├── README.md
└── dbt_project.yml



---

## 🚀 Setup Instructions

### 1. Clone the repo

```bash
git clone https://github.com/YOUR_USERNAME/heymax-analytics.git
cd heymax-analytics