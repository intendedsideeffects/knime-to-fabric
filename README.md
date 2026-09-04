# KNIME to Fabric

A small comparison of how the same data transformation logic can be implemented using different tools in Microsoft Fabric.

The starting point was a simple KNIME workflow that aggregates transactional sales data, filters customer groups based on revenue and country, and joins the selected customers back to the original transaction data.

I recreated this logic using three different approaches:

- **Dataflow Gen2** – using Power Query transformations
- **SQL** – using aggregations, filters and joins
- **Python** – using pandas

The goal was not to find the "best" tool, but to understand how the same data operations translate between visual workflows, SQL and Python.

## Transformation Logic

The workflow follows the same general structure:

**Load → Aggregate → Filter → Combine → Join**

| KNIME | Dataflow Gen2 | SQL | Python |
|---|---|---|---|
| GroupBy | Group By | `GROUP BY` | `.groupby()` |
| Row Filter | Filter Rows | `WHERE` | Boolean filtering |
| Concatenate | Append / combined filter logic | `UNION ALL` | `pd.concat()` |
| Joiner | Merge Queries | `INNER JOIN` | `.merge()` |

## Repository

- `workflow.sql` – SQL implementation
- `workflow.py` – Python implementation
- `README.md` – project overview

## Note

The data used in this project is synthetic and does not represent real customer or company data.
