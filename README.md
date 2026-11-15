# Customer Shopping Behavior Analysis

An end-to-end customer shopping analysis using Python, MySQL, and Power BI. The project explores customer mix, purchase amounts, product categories, season labels, shipping methods, subscriptions, and review ratings.

## Project snapshot

- 3,900 customer records with 3,900 unique customer IDs.
- Total recorded purchase amount: **$233,081**; average per customer row: **$59.76**.
- Clothing is the largest category by recorded purchase amount: **$104,264**.
- The dashboard has two pages: **Customer Behavior Dashboard** and **Shopping Insights**.

These are descriptive results from the supplied dataset. They do not establish cause and effect.

## Files

| File | Description |
|---|---|
| `customer_shopping_behavior.csv` | Source customer-level dataset |
| `Customer_Shopping_Behavior_Analysis.ipynb` | Data preparation and analysis notebook |
| `customer_behavior_sql_queries.sql` | Ten analysis queries written for MySQL 8.0 or later |
| `customer_behavior_dashboard_final.pbix` | Editable Power BI report |
| `Customer_Behavior_Dashboard.pdf` | Direct Power BI PDF export |
| `Customer_Shopping_Behavior_Analysis_Report.pdf` | Written analysis report |
| `Customer_Shopping_Behavior_Analysis_Portfolio_Presentation.pptx` | Editable presentation deck  |

## Reproduce the analysis

1. Open the notebook in Jupyter and install the Python packages used by the cells you plan to run. The analysis uses `pandas`; the MySQL connection example uses SQLAlchemy and PyMySQL.
2. Keep `customer_shopping_behavior.csv` beside the notebook, then run the data loading and preparation cells. The notebook standardizes column names, fills missing review ratings with the median for each category, and creates age quartiles.
3. Create a MySQL database named `customer_behavior`. Run the MySQL connection cell in the notebook to load the prepared data into a table named `customer`. The notebook asks for the database password when that cell runs. Its `if_exists="replace"` setting replaces an existing table named `customer` in that database.
4. Open `customer_behavior_sql_queries.sql` in MySQL 8.0 or later after the table is loaded. The script uses common MySQL syntax, including `LIMIT`, common table expressions, and window functions.
5. Open `customer_behavior_dashboard_final.pbix` in Power BI Desktop to explore the interactive report. The PDF files provide static views.

The notebook also contains optional PostgreSQL and SQL Server connection examples. Run only the connection section for the database you intend to use; the provided SQL query file is for MySQL.

## Method and interpretation notes

- Each row represents one unique customer in this file. The purchase amount is a customer-row value, not an order history or customer lifetime value.
- The raw review-rating field has 37 missing values. The notebook fills them using the median review rating within each product category before analysis.
- Age quartiles are calculated from this sample with `pandas.qcut`; their labels are sample-based groups, not fixed age bands.
- The SQL segment named `New` means exactly one previous purchase according to the `Previous Purchases` field. It does not mean a first-time buyer.
- The dataset has no transaction date or sales-channel field. It cannot show sales trends over time or compare online with in-store shopping.
- Group differences are descriptive and may reflect differences in customer mix or other unmeasured factors.


