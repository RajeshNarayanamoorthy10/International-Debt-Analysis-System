import streamlit as st
import pandas as pd
from sqlalchemy import create_engine
import plotly.express as px

# Page config
st.set_page_config(
    page_title="International Debt Analysis",
    page_icon="🌍",
    layout="wide"
)

# Database connection
engine = create_engine('mysql+pymysql://root:admin123@localhost:3306/international_debt_db')

st.title("🌍 International Debt Analysis Dashboard")
st.markdown("---")

# Load data
@st.cache_data
def load_data():
    df = pd.read_sql("SELECT * FROM debt_data", engine)
    countries = pd.read_sql("SELECT * FROM countries", engine)
    indicators = pd.read_sql("SELECT * FROM indicators", engine)
    return df, countries, indicators

df, countries, indicators = load_data()

# KPI Section
col1, col2, col3, col4 = st.columns(4)

with col1:
    st.metric("Total Countries", countries['country_code'].nunique())
with col2:
    st.metric("Total Indicators", indicators['series_code'].nunique())
with col3:
    st.metric("Total Records", f"{len(df):,}")
with col4:
    st.metric("Global Debt (USD)", f"{df['debt_value'].sum():.2e}")

st.markdown("---")
st.subheader("🏆 Top 10 Countries by Total Debt")

country_debt = df.merge(countries, on='country_code')
country_debt = country_debt.groupby('long_name')['debt_value'].sum().reset_index()
country_debt.columns = ['Country', 'Total Debt']
country_debt = country_debt.sort_values('Total Debt', ascending=False).head(10)

fig1 = px.bar(country_debt, x='Country', y='Total Debt',
              color='Total Debt',
              title='Top 10 Countries by Total Debt')
fig1.update_traces(texttemplate='%{y:.2s}', textposition='outside')
fig1.update_layout(xaxis_tickangle=-45)
st.plotly_chart(fig1, use_container_width=True)

st.markdown("---")
st.subheader("📈 Global Debt Trend (2000-2024)")

yearwise = df.groupby('year')['debt_value'].sum().reset_index()
yearwise.columns = ['Year', 'Total Debt']

fig2 = px.line(yearwise, x='Year', y='Total Debt',
               title='Global Debt Trend (2000-2024)',
               markers=True)
st.plotly_chart(fig2, use_container_width=True)

st.markdown("---")
st.subheader("🌍 Debt Distribution by Region")

region_debt = df.merge(countries, on='country_code')
region_debt = region_debt.groupby('region')['debt_value'].sum().reset_index()
region_debt.columns = ['Region', 'Total Debt']

fig3 = px.pie(region_debt, values='Total Debt', names='Region',
              title='Debt Distribution by Region')
st.plotly_chart(fig3, use_container_width=True)

st.markdown("---")
st.subheader("📊 Top 10 Indicators by Total Debt")

indicator_debt = df.merge(indicators, on='series_code')
indicator_debt = indicator_debt.groupby('indicator_name')['debt_value'].sum().reset_index()
indicator_debt.columns = ['Indicator', 'Total Debt']
indicator_debt = indicator_debt.sort_values('Total Debt', ascending=False).head(10)

fig4 = px.bar(indicator_debt, x='Total Debt', y='Indicator',
              orientation='h',
              color='Total Debt',
              title='Top 10 Indicators by Total Debt')
fig4.update_layout(yaxis={'categoryorder': 'total ascending'},
                   margin=dict(l=400))
st.plotly_chart(fig4, use_container_width=True)