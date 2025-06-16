import streamlit as st
import duckdb
import pandas as pd
import matplotlib.pyplot as plt

# --- Connect to your DuckDB ---
con = duckdb.connect("heymax.duckdb")

# --- Load growth metrics from DB ---
@st.cache_data
def load_data():
    df = con.execute("SELECT * FROM growth_metrics ORDER BY activity_month").df()
    df["activity_month"] = pd.to_datetime(df["activity_month"])
    return df

df = load_data()

# --- Title and filters ---
st.title("📊 Monthly Growth Metrics Dashboard")
st.markdown("Analyze user lifecycle metrics: new, retained, churned, resurrected, and more.")

# --- Main metric chart ---
st.subheader("🧍‍♂️ User Lifecycle Metrics")
fig1, ax1 = plt.subplots()
ax1.plot(df["activity_month"], df["new_users"], label="New Users")
ax1.plot(df["activity_month"], df["retained_users"], label="Retained Users")
ax1.plot(df["activity_month"], df["resurrected_users"], label="Resurrected Users")
ax1.plot(df["activity_month"], df["churned_users"], label="Churned Users")
ax1.set_xlabel("Month")
ax1.set_ylabel("Users")
ax1.legend()
ax1.grid(True)
st.pyplot(fig1)

# --- Active users chart ---
st.subheader("🟢 Active Users")
st.line_chart(df.set_index("activity_month")["active_users"])

# --- Retention and quick ratio ---
st.subheader("📈 Retention Rate and Quick Ratio")
fig2, ax2 = plt.subplots()
ax2.plot(df["activity_month"], df["retention_rate"], label="Retention Rate")
ax2.plot(df["activity_month"], df["quick_ratio"], label="Quick Ratio")
ax2.set_xlabel("Month")
ax2.set_ylabel("Ratio")
ax2.legend()
ax2.grid(True)
st.pyplot(fig2)

# --- Data preview ---
with st.expander("📄 Show Raw Data"):
    st.dataframe(df)
