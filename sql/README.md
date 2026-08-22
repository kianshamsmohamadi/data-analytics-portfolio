# SQL Exercises — TSQLV4

SQL practice work based on Itzik Ben-Gan's *T-SQL Fundamentals*, run against
the TSQLV4 sample database in SQL Server / SSMS.

Files are organized by topic, in the order they were learned:

| File | Topic |
|---|---|
| `01_table_design.sql` | Table normalization (2NF/3NF) |
| `02_single_table_queries.sql` | SELECT, WHERE, aggregates, CASE, sorting |
| `03_joins.sql` | INNER/LEFT JOIN, CROSS JOIN |
| `04_subqueries.sql` | Scalar/correlated subqueries, IN vs EXISTS |
| `05_set_operators.sql` | UNION, UNION ALL, INTERSECT, EXCEPT |
| `06_data_modification.sql` | INSERT, UPDATE, DELETE, OUTPUT, SELECT INTO |
| `07_table_expressions_and_cte.sql` | Derived tables, CTEs, recursive CTEs, views (incl. SCHEMABINDING), inline TVFs, CROSS APPLY, window functions (ROW_NUMBER) |
| `08_window_functions_and_advanced_querying.sql` | RANK/DENSE_RANK, PARTITION BY, LAG/LEAD, FIRST_VALUE/LAST_VALUE, window aggregates, PIVOT/UNPIVOT, Dynamic Pivot, GROUPING SETS/ROLLUP/CUBE |

Each file contains the original exercise prompt as a comment above the
corresponding query. Where a task description had an inconsistency between
its wording and its expected sample output, a short note documents how it
was resolved. Where a bug was found during review, the fix and the
reasoning behind it are noted inline.
