let
    // Load the source data
    Source = RWFD_sales_2008_2011,

    // Create a customer-level summary
    // KNIME equivalent: GroupBy
    #"Customer summary" =
        Table.Group(
            Source,
            {"CustomerID", "Country"},
            {
                {"TotalRevenue", each List.Sum([Revenue]), type nullable number},
                {"FirstPurchase", each List.Min([ContractDate]), type nullable date}
            }
        ),

    // Apply three different customer filters
    // KNIME equivalent: Row Filters
    Germany =
        Table.SelectRows(
            #"Customer summary",
            each [TotalRevenue] > 30000
                and [Country] = "DE"
        ),

    Austria =
        Table.SelectRows(
            #"Customer summary",
            each [TotalRevenue] < 10000
                and [Country] = "AT"
        ),

    Switzerland =
        Table.SelectRows(
            #"Customer summary",
            each [TotalRevenue] >= 10000
                and [TotalRevenue] <= 20000
                and [Country] = "CH"
        ),

    // Combine the three filtered results
    // KNIME equivalent: Concatenate
    #"Filtered customers" =
        Table.Combine(
            {
                Germany,
                Austria,
                Switzerland
            }
        ),

    // Join the selected customers back to the original transactions
    // KNIME equivalent: Joiner (Inner Join)
    #"Merged queries" =
        Table.NestedJoin(
            Source,
            {"CustomerID"},
            #"Filtered customers",
            {"CustomerID"},
            "CustomerSummary",
            JoinKind.Inner
        ),

    #"Expanded customer summary" =
        Table.ExpandTableColumn(
            #"Merged queries",
            "CustomerSummary",
            {"TotalRevenue", "FirstPurchase"},
            {"TotalRevenue", "FirstPurchase"}
        ),

    // Sort the final result
    #"Sorted rows" =
        Table.Sort(
            #"Expanded customer summary",
            {
                {"CustomerID", Order.Ascending},
                {"ContractDate", Order.Ascending}
            }
        )

in
    #"Sorted rows"
