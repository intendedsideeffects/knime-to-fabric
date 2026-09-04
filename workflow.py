import pandas as pd

# Load the source data
sales = spark.sql("""
    SELECT *
    FROM dbo.RWFD_sales_2008_2011
""").toPandas()


# Create a customer-level summary
# KNIME equivalent: GroupBy
customer_summary = (
    sales
    .groupby(["CustomerID", "Country"], as_index=False)
    .agg(
        TotalRevenue=("Revenue", "sum"),
        FirstPurchase=("ContractDate", "min")
    )
)


# Apply three different customer filters
# KNIME equivalent: Row Filters
germany = customer_summary[
    (customer_summary["TotalRevenue"] > 30000) &
    (customer_summary["Country"] == "DE")
]

austria = customer_summary[
    (customer_summary["TotalRevenue"] < 10000) &
    (customer_summary["Country"] == "AT")
]

switzerland = customer_summary[
    (customer_summary["TotalRevenue"].between(10000, 20000)) &
    (customer_summary["Country"] == "CH")
]


# Combine the three filtered results
# KNIME equivalent: Concatenate
filtered_customers = pd.concat(
    [germany, austria, switzerland],
    ignore_index=True
)


# Join the selected customers back to the original transactions
# KNIME equivalent: Joiner (Inner Join)
result = sales.merge(
    filtered_customers[
        ["CustomerID", "TotalRevenue", "FirstPurchase"]
    ],
    on="CustomerID",
    how="inner"
)


# Sort the final result
result = (
    result
    .sort_values(["CustomerID", "ContractDate"])
    .reset_index(drop=True)
)


# Display the result
display(result)
