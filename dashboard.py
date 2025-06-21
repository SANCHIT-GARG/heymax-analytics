import streamlit as st
import duckdb
import pandas as pd
import re
import plotly.graph_objects as go
import openai

# --- Connect to DuckDB ---
con = duckdb.connect("heymax.duckdb")

@st.cache_data
def load_data():
    # Monthly
    monthly_df = con.execute("SELECT * FROM growth_metrics_monthly ORDER BY activity_month").df()
    monthly_df["activity_month"] = pd.to_datetime(monthly_df["activity_month"])
    monthly_df["period_str"] = monthly_df["activity_month"].dt.strftime("%Y-%m")
    # monthly_df.fillna(0, inplace=True)
    for col in ["new_users", "resurrected_users", "churned_users", "retained_users", "active_users", "retention_rate", "quick_ratio"]:
        monthly_df[col] = pd.to_numeric(monthly_df[col], errors="coerce") #.fillna(0)
    monthly_df["period_str"] = pd.Categorical(monthly_df["period_str"], categories=monthly_df["period_str"].unique(), ordered=True)

    # Weekly
    weekly_df = con.execute("SELECT * FROM growth_metrics_week ORDER BY activity_week").df()
    weekly_df["activity_week"] = pd.to_datetime(weekly_df["activity_week"])
    weekly_df["period_str"] = weekly_df["activity_week"].dt.strftime("%Y-%m-%d")
    # weekly_df.fillna(0, inplace=True)
    for col in ["new_users", "resurrected_users", "churned_users", "retained_users", "active_users", "retention_rate", "quick_ratio"]:
        weekly_df[col] = pd.to_numeric(weekly_df[col], errors="coerce") #.fillna(0)
    weekly_df["period_str"] = pd.Categorical(weekly_df["period_str"], categories=weekly_df["period_str"].unique(), ordered=True)

    # Daily
    daily_df = con.execute("SELECT * FROM growth_metrics_daily ORDER BY activity_date").df()
    daily_df["activity_date"] = pd.to_datetime(daily_df["activity_date"])
    daily_df["period_str"] = daily_df["activity_date"].dt.strftime("%Y-%m-%d")
    # daily_df.fillna(0, inplace=True)
    for col in ["new_users", "resurrected_users", "churned_users", "retained_users", "active_users", "retention_rate", "quick_ratio"]:
        daily_df[col] = pd.to_numeric(daily_df[col], errors="coerce") #.fillna(0)
    daily_df["period_str"] = pd.Categorical(daily_df["period_str"], categories=daily_df["period_str"].unique(), ordered=True)

    # Retention Triangles
    retention_month = con.execute("SELECT * FROM retention_triangle_monthly ORDER BY cohort_month").df()
    retention_month["cohort_month"] = pd.to_datetime(retention_month["cohort_month"]).dt.strftime("%Y-%m")
    retention_month.fillna(0, inplace=True)

    retention_week = con.execute("SELECT * FROM retention_triangle_week ORDER BY cohort_week").df()
    retention_week["cohort_week"] = pd.to_datetime(retention_week["cohort_week"]).dt.strftime("%Y-%m-%d")
    retention_week.fillna(0, inplace=True)

    retention_day = con.execute("SELECT * FROM retention_triangle_daily ORDER BY cohort_date").df()
    retention_day["cohort_date"] = pd.to_datetime(retention_day["cohort_date"]).dt.strftime("%Y-%m-%d")
    retention_day.fillna(0, inplace=True)

    return monthly_df, weekly_df, daily_df, retention_month, retention_week, retention_day

# Load Data
monthly_df, weekly_df, daily_df, retention_month, retention_week , retention_day = load_data()

# st.set_page_config(page_title="Growth Metrics Dashboard", layout="wide")
st.title("📊 Growth Metrics Dashboard")
# --- UI Toggle ---
view_option = st.radio("Select Time Granularity:", ["Monthly", "Weekly","Daily"])

if view_option == "Monthly":
    df = monthly_df
    retention_df = retention_month
    cohort_col = "cohort_month"
    time_col = "period_str"
    label = "Month"
elif view_option == "Weekly":
    df = weekly_df
    retention_df = retention_week
    cohort_col = "cohort_week"
    time_col = "period_str"
    label = "Week"
elif view_option == "Daily":
    df = daily_df
    retention_df = retention_day
    cohort_col = "cohort_date"
    time_col = "period_str"
    label = "Day"

# --- Filters ---
st.sidebar.header(f"📅 Filter by {label}")

# Detect actual date column (datetime)
date_col_map = {
    "Monthly": "activity_month",
    "Weekly": "activity_week",
    "Daily": "activity_date"
}
true_time_col = date_col_map[view_option]
df[true_time_col] = pd.to_datetime(df[true_time_col])  # Ensure proper type

# Determine min/max
min_date = df[true_time_col].min().date()
max_date = df[true_time_col].max().date()

# Sidebar inputs with default to full range
start_date = st.sidebar.date_input(f"Start {label}", value=min_date, min_value=min_date, max_value=max_date)
end_date = st.sidebar.date_input(f"End {label}", value=max_date, min_value=min_date, max_value=max_date)

# Validate and filter
if start_date > end_date:
    st.sidebar.warning("⚠️ Start date is after end date. Please correct it.")
    filtered_df = df.iloc[0:0]
else:
    mask = (df[true_time_col].dt.date >= start_date) & (df[true_time_col].dt.date <= end_date)
    filtered_df = df[mask]


# --- Sidebar LLM Chat ---
st.sidebar.markdown("💡 ** Generate Insights with AI **")
user_prompt = st.sidebar.text_area("Ask a question about the filtered data:" , 
                                   placeholder="e.g. What is the best month for business?")

if st.sidebar.button("🔍 Generate Insight") and user_prompt:
    # Sample data snapshot for context (limit for token usage)
    # context_df = filtered_df.to_markdown(index=False)
    # retention_preview = retention_df.to_markdown()

    context = f"""
    You are a helpful data analyst assistant. Based on the user's filtered data below, answer their question.
    Give bulleted insights in less than 100 words.

    Filtered Growth Metrics:
    {filtered_df}

    Retention Triangle (first few rows):
    {retention_df}

    Question:
    {user_prompt}
    """
    
    # Use the code below to use Streamlit secrets in production.
    client = openai.OpenAI(api_key=st.secrets["OPENAI_API_KEY"]) 

    # Alternatively, you can set the API key directly in your environment or use a config file. (Local Setup)
    # OPENAI_API_KEY
    # client = openai.OpenAI(api_key=OPENAI_API_KEY)

    # 🔁 Call the OpenAI model
    response = client.chat.completions.create(
        model="gpt-4o",  # or "gpt-4o-mini" if using Hugging Face proxy
        messages=[{"role": "user", "content": context}]
    )

    st.sidebar.markdown("### 📊 Insight")
    st.sidebar.write(response.choices[0].message.content)



# --- KPIs ---
st.subheader("📌 Key Performance Indicators")
if not filtered_df.empty:
    latest = filtered_df.sort_values(by=time_col).iloc[-1]
    k1, k2, k3, k4, k5 = st.columns(5)
    k1.metric("🧍 New Users", int(latest["new_users"]))
    k2.metric("🧟 Resurrected", int(latest["resurrected_users"]))
    k3.metric("🔁 Retained", int(latest["retained_users"]))
    k4.metric("🔻 Churned", int(latest["churned_users"]))
    k5.metric("⚡ Quick Ratio", f"{latest['quick_ratio']:.2f}")

# --- Tabs ---
tab1, tab2 = st.tabs(["📈 Individual Metrics", "📊 Combined Breakdown + Retention"])

def make_bar(title, y_col, color, label, period_col="period_str"):
    fig = go.Figure()
    fig.add_trace(go.Bar(
        x=filtered_df[period_col].tolist(),
        y=filtered_df[y_col].tolist(),
        name=label,
        marker_color=color,
        text=filtered_df[y_col],
        textposition="outside"
    ))
    fig.update_layout(
        title=title,
        xaxis=dict(
            title=label,
            type="category",
            tickangle=-45  # 🧭 Rotate x-ticks to reduce overlap
        ),
        yaxis_title="Users",
        bargap=0.2,
        showlegend=False
    )
    return fig

def make_combined_chart(df, period_col, label):
    fig = go.Figure()

    # ✅ Bars: ensure correct values (not row counts)
    fig.add_trace(go.Bar(x=df[period_col].tolist(), y=df["new_users"].tolist(), name="New Users", marker_color="#4CAF50"))
    fig.add_trace(go.Bar(x=df[period_col].tolist(), y=df["resurrected_users"].tolist(), name="Resurrected", marker_color="#FFC107"))
    # fig.add_trace(go.Bar(x=df[period_col].tolist(), y=df["retained_users"].tolist(), name="Retained", marker_color="#2196F3"))
    fig.add_trace(go.Bar(x=df[period_col].tolist(), y=[-v for v in df["churned_users"].tolist()], name="Churned", marker_color="#f44336"))


    # ✅ Clean line data
    retention_rate = (df["retention_rate"] * 100).round(2)
    quick_ratio = df["quick_ratio"].round(2)

    fig.add_trace(go.Scatter(
        x=df[period_col][retention_rate.notna()].to_list(),
        y=retention_rate[retention_rate.notna()].to_list(),
        name="Retention Rate (%)",
        mode="lines+markers",
        yaxis="y2",
        line=dict(color="blue", dash="dot")
    ))

    fig.add_trace(go.Scatter(
        x=df[period_col][quick_ratio.notna()].to_list(),
        y=quick_ratio[quick_ratio.notna()].to_list(),
        name="Quick Ratio",
        mode="lines+markers",
        yaxis="y2",
        line=dict(color="purple")
    ))

    # ----------------------
    # Calculate aligned y-ranges
    # ----------------------

    # Left (User count)
    y1_min = min((df["new_users"] + df["resurrected_users"]).min(), -df["churned_users"].max())
    y1_max = (df["new_users"] + df["resurrected_users"]).max()

    # Right (Ratios)
    y2_min = min(retention_rate.min(skipna=True), quick_ratio.min(skipna=True))
    y2_max = max(retention_rate.max(skipna=True), quick_ratio.max(skipna=True))    
    # Normalize both to same proportional range around zero
    y1_range = max(abs(y1_min), abs(y1_max))
    y2_range = max(abs(y2_min), abs(y2_max))

    fig.update_layout(
        barmode="relative",
        title="📊 Combined Growth Breakdown",
        height=600,  # ⬆️ Increase height for better visibility
        margin=dict(t=80, b=100, l=80, r=80),  # ⬅️ More breathing room around the chart
        xaxis=dict(
            title=label,
            type="category",
            tickangle=-45  # 🧭 Rotate x-ticks to reduce overlap
        ),
        yaxis=dict(
            title="User Count",
            range=[-y1_range, y1_range],
            zeroline=True,
            showgrid=True
        ),
        yaxis2=dict(
            title="Ratios",
            overlaying="y",
            side="right",
            range=[-y2_range, y2_range],
            zeroline=True,
            showgrid=False
        ),
        legend=dict(
            orientation="h",
            yanchor="bottom",
            y=-0.35,
            xanchor="center",
            x=0.5,
            font=dict(size=12)
        ),
        title_font=dict(size=20)
    )

    return fig


def show_retention_table(retention_df, cohort_col):
    melted = retention_df.melt(id_vars=cohort_col, var_name="period_index", value_name="retention")
    melted["retention"] = (melted["retention"] * 100).round(1)
    # Ensure period_index is sorted in ascending natural order (e.g., m0, m1, ..., m10)

    def period_sort_key(val):
        match = re.match(r"([a-zA-Z]+)(\d+)", str(val))
        if match:
            prefix, num = match.groups()
            return (prefix, int(num))
        return (str(val), 0)

    melted = melted.sort_values("period_index", key=lambda x: x.map(period_sort_key))
    pivoted = melted.pivot(index=cohort_col, columns="period_index", values="retention").fillna(0)
    # Sort columns in ascending natural order
    pivoted = pivoted.reindex(sorted(pivoted.columns, key=period_sort_key), axis=1)
    st.dataframe(pivoted.style.background_gradient(cmap="Blues", axis=1, vmin=0, vmax=100).format("{:.1f}"))

# --- Tab 1 ---
with tab1:
    st.plotly_chart(make_bar("🧍 New Users", "new_users", "#4CAF50", "New Users"), use_container_width=True)
    st.plotly_chart(make_bar("🧟 Resurrected Users", "resurrected_users", "#FFC107", "Resurrected Users"), use_container_width=True)
    st.plotly_chart(make_bar("🔁 Retained Users", "retained_users", "#2196F3", "Retained Users"), use_container_width=True)
    st.plotly_chart(make_bar("🔻 Churned Users", "churned_users", "#f44336", "Churned Users"), use_container_width=True)
    st.plotly_chart(make_bar("🟢 Active Users", "active_users", "#00BCD4", "Active Users"), use_container_width=True)

# --- Tab 2 ---
with tab2:

    # 📊 Display raw data table first
    st.subheader("📄 Raw Growth Metrics Data")
    st.dataframe(filtered_df)

    st.plotly_chart(make_combined_chart(filtered_df, "period_str", "Period"), use_container_width=True)

    csv_growth = filtered_df.to_csv(index=False).encode("utf-8")
    st.download_button("⬇️ Download Growth Metrics", data=csv_growth, file_name=f"{view_option.lower()}_growth_metrics.csv", mime="text/csv")

    st.subheader("📐 Retention Triangle (%)")
    show_retention_table(retention_df, cohort_col)

    csv_retention = retention_df.to_csv(index=False).encode("utf-8")
    st.download_button("⬇️ Download Retention Cohort", data=csv_retention, file_name=f"{view_option.lower()}_retention_cohort.csv", mime="text/csv")
