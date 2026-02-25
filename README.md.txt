Retail Enterprise Analytics
Volunteer Analytics Consultant – Enterprise Simulation

Project Overview

This project simulates an enterprise-level retail analytics engagement for a multi-city supermarket chain.

The objective was to design and implement a full-stack analytics lifecycle — from raw structured data to executive-level dashboards and strategic recommendations.

The project covers:

Database architecture design

KPI engineering

Data quality validation

Exploratory data analysis

Star schema modeling

Executive Power BI dashboards

Strategic business recommendations

Business Context

The organization faced the following challenges:

Revenue growth stagnation

Profit margin fluctuations

Store-level performance variance

Inventory inefficiencies

Uncertainty in customer revenue distribution

The goal was to generate data-driven insights to support executive decision-making.

Enterprise Data Architecture

The database was designed using a relational model in SQL Server.

Fact Tables

Orders - 1 row per order (header level)

Order_Items - 1 row per product per order (line level)

Dimension Tables

Customers

Products

Stores

Suppliers

Inventory

Foreign key constraints were enforced to maintain referential integrity.

Grain awareness was maintained to prevent KPI inflation.

KPI Engineering Framework

Revenue = Quantity × Unit Price
Gross Profit = (Selling Price – Cost Price) × Quantity
Profit Margin % = Profit ÷ Revenue
Average Order Value (AOV) = Revenue ÷ DISTINCT Order Count
Sales Velocity = Total Units Sold

DISTINCT logic was applied to prevent double counting due to line-level granularity.

Dashboards Built (Power BI)

Executive Overview

Revenue

Profit

Margin %

Orders

Customers

AOV

Revenue trend by month

2. Store Performance

Revenue by city

Profit by store

Store ranking

Revenue per customer

Profit per unit

3. Product & Category Analysis

Revenue by category

Profit by category

Sub-category performance

Top 10 products

Low-performing SKUs

4. Customer Analysis

Revenue distribution

Loyalty segmentation

Gender contribution

Top customers

Revenue concentration %

Key Insights

Revenue Distribution

Top 10 customers contribute ~1% of total revenue.
Top 100 customers contribute ~7.86%.

Revenue is highly diversified with low concentration risk.

Store Performance

Hyderabad leads total revenue driven by higher transaction volume.
Mumbai leads in AOV but lower transaction count limits total revenue.

Volume scale drives leadership, not ticket size.

Category Strategy

Electronics delivers highest profit margins.
Grocery operates as primary volume engine.

Balanced portfolio with both margin and volume drivers.

Product Portfolio

No single SKU dominates revenue.
Low-performing products identified for rationalization.

Opportunity for SKU optimization and bundling strategies.

Data Quality & Validation

Validation checks implemented using SQL and Python:

NULL foreign key checks

Duplicate order detection

Referential integrity validation

Negative quantity/price checks

Selling price < cost price anomaly detection

A reusable Python data quality pipeline generates automated validation reports.

Tech Stack

Microsoft SQL Server

Python (pandas, numpy, matplotlib)

Power BI (Star schema + DAX measures)

Excel (validation & pivot analysis)

Repository Structure

Retail-Enterprise-Analytics/

  README.md

  /data_sample/
  /sql/
  /python/
  /powerbi/
  /images/
  /docs/
  /reports/

Key Technical Decisions

Separated Orders and Order_Items to preserve grain integrity

Used DISTINCTCOUNT for accurate AOV computation

Applied foreign key constraints before bulk loading

Designed star schema model in Power BI

Created Date dimension for time-series analysis

Limitations

Product master did not include product_name field

Inventory dataset is snapshot-based (no turnover timeline)

No promotional campaign dataset available

Future enhancements could include:

Cohort analysis

Inventory turnover modeling

Customer lifetime value modeling

Outcome

Successfully delivered an enterprise-style analytics solution including:

Structured SQL database

Validated KPIs

Python analytical pipeline

4-page executive Power BI dashboard

Board-level strategic recommendations

This project demonstrates full-stack data analytics capability suitable for enterprise environments.

Role

Volunteer Analytics Consultant
(Enterprise Retail Performance Simulation)