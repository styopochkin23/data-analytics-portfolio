# 📧 Email Marketing & User Engagement Analysis

## 📌 Project Overview
This project focuses on analyzing user engagement with email campaigns for an e-commerce platform. The goal was to identify key markets, evaluate email delivery performance, and rank countries based on user activity using **SQL** and **Looker Studio**.

## 🛠️ Tools & Technologies
* **SQL (Google BigQuery):** Data extraction, cleaning, and transformation.
* **Looker Studio:** Data visualization and interactive dashboard creation.
* **Techniques Used:**
    * `CTEs` (Common Table Expressions) for modular query structure.
    * `Window Functions` (DENSE_RANK, SUM OVER) for ranking and aggregation.
    * `UNION ALL` to combine different data sources (account registrations vs. email logs).
    * `JOINs` to link user, session, and email data.

## 📊 Key Findings
* **Top Market:** The **United States** is the absolute leader in both the number of subscribers and email engagement, significantly outperforming other regions.
* **Global Reach:** The top 10 active countries include India, Canada, UK, and France.
* **Data Volume:** Analyzed dynamics for over **300k+** email events and **12k+** subscriber records.

## 📈 Dashboard Visualization
*The interactive dashboard visualizes the daily email sending dynamics and ranks countries by subscriber count.*

![Looker Studio Dashboard]([dashboard.png](https://lookerstudio.google.com/reporting/eaf4b1f0-9e53-4847-814f-0924e92b5937
))

## 💻 SQL Query Structure
The analysis was performed using a single optimized query structured as follows:
1.  **CTE `account_data`:** Aggregates account registration metrics.
2.  **CTE `email_data`:** Aggregates email interaction metrics (sent, opened, clicked).
3.  **Data Combination:** Uses `UNION ALL` to merge datasets into a long format.
4.  **Ranking:** Applies `DENSE_RANK()` to identify top-performing countries.

*(Full SQL code is available in the [SQL_Query.sql](SQL_Query.sql) file)*

## 🔢 Query Results (Snippet)
![BigQuery Results](sql_results.png)
