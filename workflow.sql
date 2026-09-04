-- Create a customer-level summary
-- KNIME equivalent: GroupBy
WITH customer_summary AS (
    SELECT
        CustomerID,
        Country,
        SUM(Revenue) AS TotalRevenue,
        MIN(ContractDate) AS FirstPurchase
    FROM dbo.RWFD_sales_2008_2011
    GROUP BY
        CustomerID,
        Country
),

-- Apply three different customer filters
-- KNIME equivalent: Row Filters + Concatenate
filtered_customers AS (

    -- High-revenue customers from Germany
    SELECT *
    FROM customer_summary
    WHERE TotalRevenue > 30000
      AND Country = 'DE'

    -- Combine the results
    -- KNIME equivalent: Concatenate
    UNION ALL

    -- Lower-revenue customers from Austria
    SELECT *
    FROM customer_summary
    WHERE TotalRevenue < 10000
      AND Country = 'AT'

    UNION ALL

    -- Mid-range customers from Switzerland
    SELECT *
    FROM customer_summary
    WHERE TotalRevenue BETWEEN 10000 AND 20000
      AND Country = 'CH'
)

-- Join the selected customers back to the original transactions
-- KNIME equivalent: Joiner (Inner Join)
SELECT
    s.*,
    f.TotalRevenue,
    f.FirstPurchase
FROM dbo.RWFD_sales_2008_2011 AS s
INNER JOIN filtered_customers AS f
    ON s.CustomerID = f.CustomerID

-- Sort the final result
ORDER BY
    s.CustomerID,
    s.ContractDate;
