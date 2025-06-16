import streamlit as st
import pandas as pd
import altair as alt
import duckdb

DB_PATH = "heymax.duckdb"

@st.cache_data
def load_all_data():
    con = duckdb.connect(DB_PATH)
    growth = con.execute("SELECT * FROM growth_metrics").fetchdf()
    lifecycle = con.execute("SELECT * FROM user_lifecycle_metrics").fetchdf()
    triangle = con.execute("SELECT * FROM retention_triangle").fetchdf()

    growth['activity_date'] = pd.to_datetime(growth['activity_date'])
    lifecycle['activity_date'] = pd.to_datetime(lifecycle['activity_date'])

    for df in [growth, lifecycle]:
        if 'month_year_str' in df.columns:
            month_vals = [x for x in df['month_year_str'].unique() if pd.notnull(x)]
            df['month_year_str'] = pd.Categorical(
                df['month_year_str'],
                categories=sorted(month_vals, key=lambda x: pd.to_datetime("01 " + x)),
                ordered=True
            )
    return growth, lifecycle, triangle

growth_df, lifecycle_df, triangle_df = load_all_data()

tab1, tab2 = st.tabs(["📈 Growth Accounting", "🔺 Retention Triangle"])

# ---------------- TAB 1: Growth Accounting ----------------
with tab1:
    st.title("📈 MAU Growth Accounting Dashboard")

    view_type = st.radio("Select View", ["📊 Behavioral", "👤 User-level"], horizontal=True)
    granularity = st.radio("Select Time Granularity", ["Daily", "Weekly", "Monthly"], horizontal=True)

    if granularity == "Daily":
        period_col = "activity_date"
        suffix = ""
        x_type = "T"
    elif granularity == "Weekly":
        period_col = "week_number"
        suffix = "_weekly"
        x_type = "O"
    else:
        period_col = "month_year_str" if "month_year_str" in growth_df.columns else "month_year"
        suffix = "_monthly"
        x_type = "O"

    if view_type == "📊 Behavioral":
        df = growth_df.copy()
        df['period'] = df[period_col]

        metric_cols = ['new_users', 'retained_users', 'resurrected_users', 'churned_users', 'quick_ratio']
        present_cols = {}
        for col in metric_cols:
            full_col = col + suffix
            if full_col in df.columns:
                present_cols[full_col] = col

        if not present_cols:
            st.warning("No lifecycle columns found in growth_metrics for this view.")
            st.stop()

        df_selected = df[['period'] + list(present_cols.keys())].copy()
        df_selected = df_selected.rename(columns=present_cols)

        churned = df_selected.get('churned_users', pd.Series([0] * len(df_selected)))
        churned_safe = churned.replace(0, pd.NA)

        df_selected['retention_rate'] = df_selected.get('retained_users', 0) / (
            df_selected.get('retained_users', 0) + churned_safe
        )
        df_selected['quick_ratio'] = (
            df_selected.get('new_users', 0) + df_selected.get('resurrected_users', 0)
        ) / churned_safe

        df_selected['retention_rate'] = df_selected['retention_rate'].fillna(0)
        df_selected['quick_ratio'] = df_selected['quick_ratio'].fillna(0).clip(upper=10)
        agg_df = df_selected

    else:
        df = lifecycle_df.copy()
        df['period'] = df[period_col] if period_col in df.columns else df['activity_date']
        dedup = df.sort_values(['user_id', 'activity_date']).drop_duplicates(['user_id', 'user_status'])
        agg_df = dedup.groupby('period').user_status.value_counts().unstack(fill_value=0).reset_index()

        agg_df['new_users'] = agg_df.get('new', 0)
        agg_df['retained_users'] = agg_df.get('retained', 0)
        agg_df['resurrected_users'] = agg_df.get('resurrected', 0)
        agg_df['churned_users'] = agg_df.get('churned', 0)

        churned_safe = agg_df['churned_users'].replace(0, pd.NA)
        agg_df['retention_rate'] = agg_df['retained_users'] / (
            agg_df['retained_users'] + churned_safe
        )
        agg_df['quick_ratio'] = (agg_df['new_users'] + agg_df['resurrected_users']) / churned_safe
        agg_df['retention_rate'] = agg_df['retention_rate'].fillna(0)
        agg_df['quick_ratio'] = agg_df['quick_ratio'].fillna(0).clip(upper=10)

        if granularity == "Monthly":
            agg_df['period'] = agg_df['period'].astype(str)

    value_cols = [c for c in ['new_users', 'resurrected_users', 'churned_users'] if c in agg_df.columns]
    bar_df = agg_df.melt(id_vars=["period"], value_vars=value_cols,
                         var_name="user_type", value_name="count")
    bar_df['count'] = bar_df.apply(lambda row: -row['count'] if row['user_type'] == 'churned_users' else row['count'], axis=1)
    max_y = bar_df['count'].abs().max() if not bar_df.empty else 10

    color_scale = alt.Scale(
        domain=["new_users", "resurrected_users", "churned_users"],
        range=["#A2C8EC", "#8DE2B2", "#FF9D9D"]
    )

    bar = alt.Chart(bar_df).mark_bar(opacity=0.85).encode(
        x=alt.X('period:' + x_type, title="Period"),
        y=alt.Y('count:Q', title='User Count', scale=alt.Scale(zero=True, domain=[-max_y * 1.2, max_y * 1.2])),
        color=alt.Color('user_type:N', scale=color_scale, title="User Type"),
        tooltip=['period', 'user_type', 'count']
    )

    ret_line = alt.Chart(agg_df).mark_line(color='purple', strokeDash=[4, 4], strokeWidth=2).encode(
        x='period:' + x_type,
        y=alt.Y('retention_rate:Q', title='Retention Rate', scale=alt.Scale(zero=True, domainMin=0),
                axis=alt.Axis(titleColor='purple')),
        tooltip=['period', 'retention_rate']
    )

    quick_line = alt.Chart(agg_df).mark_line(color='steelblue', strokeDash=[2, 2], strokeWidth=2).encode(
        x='period:' + x_type,
        y=alt.Y('quick_ratio:Q', title='Quick Ratio', scale=alt.Scale(zero=True, domainMin=0),
                axis=alt.Axis(titleColor='steelblue')),
        tooltip=['period', 'quick_ratio']
    )

    chart = alt.layer(bar, ret_line, quick_line).resolve_scale(y='independent').properties(
        width=1150,
        height=550,
        title=f"{granularity} MAU Growth — {view_type.replace('📊 ', '').replace('👤 ', '')} View"
    )

    st.altair_chart(chart, use_container_width=True)

# ---------------- TAB 2: Retention Triangle ----------------
with tab2:
    st.title("🔺 Retention Triangle Heatmap")

    min_size = st.slider("Min Cohort Size", min_value=0, max_value=int(triangle_df['cohort_size'].max()), value=10, step=10)
    triangle_filtered = triangle_df[triangle_df['cohort_size'] >= min_size].copy()
    triangle_filtered['retention_rate'] = triangle_filtered['retention_rate'].fillna(0)
    triangle_filtered['cohort_week'] = triangle_filtered['cohort_week'].astype(str)

    chart = alt.Chart(triangle_filtered).mark_rect().encode(
        x=alt.X("retention_week:O", title="Week Since Signup"),
        y=alt.Y("cohort_week:O", title="Cohort Week", sort="descending"),
        color=alt.Color("retention_rate:Q", scale=alt.Scale(scheme="greens"), title="Retention Rate"),
        tooltip=["cohort_week", "retention_week", "retention_rate", "retained_users", "cohort_size"]
    ).properties(
        width=800,
        height=500
    )

    st.altair_chart(chart, use_container_width=True)

    csv = triangle_filtered.to_csv(index=False).encode('utf-8')
    st.download_button(
        label="📥 Download Filtered Retention Data as CSV",
        data=csv,
        file_name='retention_triangle.csv',
        mime='text/csv'
    )
