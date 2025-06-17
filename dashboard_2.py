import streamlit as st
import duckdb
import pandas as pd
import plotly.graph_objects as go

# --- Connect to DuckDB ---
con = duckdb.connect("heymax.duckdb")

@st.cache_data
def load_growth_data():
    df = con.execute("SELECT * FROM growth_metrics ORDER BY activity_month").df()
    df["activity_month"] = pd.to_datetime(df["activity_month"])
    df["month_str"] = df["activity_month"].dt.strftime("%Y-%m")
    df.fillna(0, inplace=True)
    for col in ["new_users", "resurrected_users", "churned_users", "retained_users", "active_users", "retention_rate", "quick_ratio"]:
        df[col] = pd.to_numeric(df[col], errors="coerce").fillna(0)
    df["month_str"] = pd.Categorical(df["month_str"], categories=df["month_str"].unique(), ordered=True)
    return df

df = load_growth_data()

st.title("📊 Growth Metrics Dashboard")

# --- Toggle Metrics Section ---
st.subheader("📌 Select Metrics to Display in Combined Chart")

selected_bars = st.multiselect(
    "Bar Metrics (User Counts)",
    ["New Users", "Resurrected Users", "Retained Users", "Churned Users"],
    default=["New Users", "Resurrected Users", "Retained Users", "Churned Users"]
)

selected_lines = st.multiselect(
    "Line Metrics (Ratios)",
    ["Retention Rate", "Quick Ratio"],
    default=["Retention Rate", "Quick Ratio"]
)

# --- Reusable Bar Chart Function ---
def make_bar(title, y_col, color, label):
    fig = go.Figure()
    fig.add_trace(go.Bar(
        x=df["month_str"].tolist(),
        y=df[y_col].tolist(),
        name=label,
        marker_color=color,
        text=df[y_col],
        textposition="outside"
    ))
    fig.update_layout(
        title=title,
        xaxis_title="Month",
        yaxis_title="Users",
        bargap=0.2,
        showlegend=False
    )
    return fig

# --- Individual Charts ---
st.subheader("🧍 New Users")
st.plotly_chart(make_bar("New Users by Month", "new_users", "#4CAF50", "New Users"), use_container_width=True)

st.subheader("🧟 Resurrected Users")
st.plotly_chart(make_bar("Resurrected Users by Month", "resurrected_users", "#FFC107", "Resurrected Users"), use_container_width=True)

st.subheader("🔁 Retained Users")
st.plotly_chart(make_bar("Retained Users by Month", "retained_users", "#2196F3", "Retained Users"), use_container_width=True)

st.subheader("🔻 Churned Users")
st.plotly_chart(make_bar("Churned Users by Month", "churned_users", "#f44336", "Churned Users"), use_container_width=True)

st.subheader("🟢 Active Users")
st.plotly_chart(make_bar("Active Users by Month", "active_users", "#00BCD4", "Active Users"), use_container_width=True)

# --- Combined Chart ---
st.subheader("📊 Combined Growth Breakdown")

fig = go.Figure()

# Conditionally add Bar traces
if "New Users" in selected_bars:
    fig.add_trace(go.Bar(x=df["month_str"].tolist(), y=df["new_users"].tolist(), name="New Users", marker_color="#4CAF50"))

if "Resurrected Users" in selected_bars:
    fig.add_trace(go.Bar(x=df["month_str"].tolist(), y=df["resurrected_users"].tolist(), name="Resurrected Users", marker_color="#FFC107"))

if "Retained Users" in selected_bars:
    fig.add_trace(go.Bar(x=df["month_str"].tolist(), y=df["retained_users"].tolist(), name="Retained Users", marker_color="#2196F3"))

if "Churned Users" in selected_bars:
    fig.add_trace(go.Bar(x=df["month_str"].tolist(), y=[-v for v in df["churned_users"].tolist()], name="Churned Users", marker_color="#f44336"))

# Conditionally add Line traces
if "Retention Rate" in selected_lines:
    fig.add_trace(go.Scatter(
        x=df["month_str"].tolist(),
        y=(df["retention_rate"] * 100).round(2).tolist(),
        name="Retention Rate (%)",
        mode="lines+markers",
        yaxis="y2",
        line=dict(color="orange", dash="dot")
    ))

if "Quick Ratio" in selected_lines:
    fig.add_trace(go.Scatter(
        x=df["month_str"].tolist(),
        y=df["quick_ratio"].round(2).tolist(),
        name="Quick Ratio",
        mode="lines+markers",
        yaxis="y2",
        line=dict(color="purple")
    ))

fig.update_layout(
    barmode="relative",
    title="Growth Breakdown (Stacked + Churn + Ratios)",
    xaxis=dict(title="Month", type="category"),
    yaxis=dict(title="User Count"),
    yaxis2=dict(title="Ratios", overlaying="y", side="right"),
    legend=dict(orientation="h", y=1.12, x=0.5, xanchor="center")
)

st.plotly_chart(fig, use_container_width=True)

import plotly.express as px

# --- Retention Triangle Heatmap ---
import plotly.graph_objects as go

# st.subheader("🔺 Retention Triangle Heatmap")
st.subheader("🔺 Retention Triangle Table")

@st.cache_data
def load_retention_triangle():
    df = con.execute("SELECT * FROM retention_triangle ORDER BY cohort_month").df()
    df["cohort_month"] = pd.to_datetime(df["cohort_month"]).dt.strftime("%Y-%m")
    df.set_index("cohort_month", inplace=True)
    df = df * 100  # convert to percentage
    return df.round(1)

ret_df = load_retention_triangle()

# Display as clean table
st.dataframe(ret_df.style.format("{:.1f}%").background_gradient(cmap="Blues"), use_container_width=True)


# @st.cache_data
# def load_retention_triangle():
#     df = con.execute("SELECT * FROM retention_triangle ORDER BY cohort_month").df()
#     df["cohort_month"] = pd.to_datetime(df["cohort_month"]).dt.strftime("%Y-%m")
#     df.fillna(0, inplace=True)
#     return df

# ret_df = load_retention_triangle()

# # Manually prep values
# x_labels = list(ret_df.columns[1:])  # ['m0', 'm1', ...]
# y_labels = ret_df["cohort_month"].tolist()
# z_values = ret_df[x_labels].values  # already numeric, no need to multiply again

# # Convert to % and round
# z_percent = (z_values * 100).round(1)

# # Now plot with correct dimensions
# fig = go.Figure(data=go.Heatmap(
#     z=z_percent,
#     x=x_labels,
#     y=y_labels,
#     colorscale="Blues",
#     text=z_percent,
#     texttemplate="%{text}%",
#     colorbar=dict(title="Retention %")
# ))

# fig.update_layout(
#     title="Retention Triangle (Cohort vs. Months Since Signup)",
#     xaxis_title="Month Index",
#     yaxis_title="Cohort Month",
#     yaxis_autorange="reversed"
# )

# st.plotly_chart(fig, use_container_width=True)


