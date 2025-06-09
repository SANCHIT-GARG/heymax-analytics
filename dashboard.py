import streamlit as st
import duckdb
import pandas as pd
import altair as alt

# Connect to your local DuckDB file
con = duckdb.connect('heymax.duckdb')

st.title("📊 HeyMax Growth Dashboard")

# Tabs for different metrics
tab1, tab2, tab3 = st.tabs(["Active Users", "Growth Accounting", "Retention Cohort"])

# # Fetch list of countries
# all_countries = con.execute("SELECT DISTINCT country FROM fct_events ORDER BY country").fetchdf()["country"].dropna().tolist()
# selected_countries = st.sidebar.multiselect("🌍 Filter by Country", all_countries, default=all_countries)

# country_clause = f"WHERE country IN ({', '.join(repr(c) for c in selected_countries)})" if selected_countries else ""

with tab1:
    st.header("🟢 Active Users")

    all_countries = con.execute("SELECT DISTINCT country FROM fct_events ORDER BY country").fetchdf()["country"].dropna().tolist()
    selected_countries = st.multiselect("Filter by Country", all_countries, default=all_countries)
    country_clause = f"WHERE country IN ({', '.join(repr(c) for c in selected_countries)})" if selected_countries else ""

    metric = st.selectbox("Select Frequency", ["Daily", "Weekly", "Monthly"])

    if metric == "Daily":
        df = con.execute(f"SELECT * FROM daily_active_users {country_clause}").fetchdf()
        date_col = "activity_date"
        value_col = "dau"
    elif metric == "Weekly":
        df = con.execute(f"SELECT * FROM weekly_active_users {country_clause}").fetchdf()
        date_col = "week_start"
        value_col = "wau"
    else:
        df = con.execute(f"SELECT * FROM monthly_active_users {country_clause}").fetchdf()
        date_col = "month_start"
        value_col = "mau"

    if not df.empty:
        min_date = df[date_col].min()
        max_date = df[date_col].max()

        date_range = st.date_input("Date range", [min_date, max_date])

        if isinstance(date_range, (list, tuple)) and len(date_range) == 2:
            start_date, end_date = date_range
            df = df[(df[date_col] >= pd.to_datetime(start_date)) & (df[date_col] <= pd.to_datetime(end_date))]
        else:
            df = df[df[date_col] == pd.to_datetime(date_range)]

        chart_type = st.radio("Chart Type", ["Line", "Area"], horizontal=True)

        if chart_type == "Line":
            chart = alt.Chart(df).mark_line().encode(x=f"{date_col}:T", y=f"{value_col}:Q", color="country:N").properties(width=700)
        else:
            chart = alt.Chart(df).mark_area(opacity=0.7).encode(x=f"{date_col}:T", y=f"{value_col}:Q", color="country:N").properties(width=700)

        st.altair_chart(chart)
    else:
        st.warning("No data available for the selected filters.")

with tab2:
    st.header("📈 Growth Accounting Metrics")

    countries = con.execute("SELECT DISTINCT country FROM growth_accounting ORDER BY country").fetchdf()["country"].dropna().tolist()
    selected = st.multiselect("Select Countries", countries, default=countries)
    clause = f"WHERE country IN ({', '.join(repr(c) for c in selected)})" if selected else ""

    growth = con.execute(f"SELECT * FROM growth_accounting {clause}").fetchdf()

    if not growth.empty:
        st.dataframe(growth)

        chart = alt.Chart(growth).transform_fold(
            ['new_users', 'retained_users', 'resurrected_users', 'churned_users']
        ).mark_line().encode(
            x='activity_date:T',
            y='value:Q',
            color='key:N'
        ).properties(width=700)

        st.altair_chart(chart)

        st.subheader("Quick Ratio")
        st.line_chart(growth.set_index("activity_date")["quick_ratio"])
    else:
        st.warning("No growth data available for the selected filters.")


with tab3:
    st.header("📊 Retention Cohort Heatmaps by Country")

    cohort = con.execute("SELECT * FROM retention_cohort").fetchdf()

    if not cohort.empty:
        countries = cohort["country"].dropna().unique().tolist()
        selected_countries = st.multiselect("Select Countries to Compare", countries, default=countries[:1])

        for country in selected_countries:
            st.subheader(f"📍 Country: {country}")
            country_df = cohort[cohort["country"] == country]

            # Get cohort sizes
            cohort_sizes = country_df[country_df["days_since_signup"] == 0][["cohort_date", "retained_users"]]
            cohort_sizes = cohort_sizes.rename(columns={"retained_users": "cohort_size"})

            country_df = pd.merge(country_df, cohort_sizes, on="cohort_date", how="left")
            country_df["retention_rate"] = country_df["retained_users"] / country_df["cohort_size"]

            st.write("Raw counts (retained users):")
            heatmap_data = country_df.pivot(index="cohort_date", columns="days_since_signup", values="retained_users")
            st.dataframe(heatmap_data)

            st.write("📈 Retention Heatmap (% of cohort retained):")
            chart = alt.Chart(country_df).mark_rect().encode(
                x=alt.X("days_since_signup:O", title="Days Since Signup"),
                y=alt.Y("cohort_date:T", title="Cohort Date"),
                color=alt.Color("retention_rate:Q", scale=alt.Scale(scheme="blues"), title="Retention %"),
                tooltip=["cohort_date:T", "days_since_signup:O", "retention_rate:Q"]
            ).properties(width=700, height=400)

            st.altair_chart(chart)
    else:
        st.warning("No retention data available.")

