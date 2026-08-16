/*
Note: All exercises in this file were independently analyzed and solved
by the author. In some cases, the original task descriptions were
translated, reorganized, and grammar-corrected with the assistance
of Claude (Anthropic).
*/

use TSQLV4

-- =========================================================
-- 1
/*
Explain the difference between Union and Union All,
under what conditions their results are equal, and which one
should be used.
*/
-- =========================================================

--Union only returns distinct values but Union All joins the all data in 
--all tables and can contain dublicated values.
--when there are no similar results they both return the same results

-- =========================================================
-- 2
/*
Write code that generates the numbers 1 through 10.
*/
-- =========================================================

Drop Table if Exists dbo.Numbers
Create table Numbers (n int not null)
insert into Numbers values (1),(2),(3),(4),(5),(6),(7),(8),(9),(10);

select *
from numbers;

-- =========================================================
-- 3
/*
Write code that returns, in parallel, the customers and
salespeople who had sales in January 2016
but had no activity in February 2016.
*/
-- Tables involved: TSQLV4 database, Orders table
-- =========================================================

Select custid, empid
from sales.orders
where orderdate>='2016-01-01'
  and orderdate < '2016-02-01'
except 
select custid, empid
from Sales.Orders
where orderdate>='2016-02-01'
  and orderdate < '2016-03-01';

--solved below by NOT EXISTS (Just another method)
				
SELECT Distinct o1.custid,o1.empid
FROM Sales.Orders AS o1
WHERE o1.orderdate >= '2016-01-01'
  AND o1.orderdate <  '2016-02-01'
  AND NOT EXISTS
  (
      SELECT 1
      FROM Sales.Orders AS o2
      WHERE o2.custid = o1.custid
        AND o2.empid = o1.empid
        AND o2.orderdate >= '2016-02-01'
        AND o2.orderdate <  '2016-03-01'
  )
ORDER BY
    o1.custid,
    o1.empid;

-- =========================================================
-- 4
/*
Write code that returns the customer and salesperson together,
for cases where they had sales in both
January 2016 and February 2016.
*/
-- =========================================================

select custid, empid
from sales.Orders
where orderdate >= '2016-01-01' and orderdate < '2016-02-01'
intersect
select custid, empid
from sales.Orders
where orderdate >= '2016-02-01' and orderdate < '2016-03-01';

-- =========================================================
-- 5
/*
Customers and salespeople who, in parallel, had sales in
January 2016 and February 2016
but had no activity in 2015.
*/
-- Tables involved: TSQLV4 database, Orders table
-- =========================================================

SET STATISTICS IO ON;
SET STATISTICS TIME ON;

(select custid, empid
from sales.Orders
where orderdate >= '2016-01-01' and orderdate < '2016-02-01'
intersect
select custid, empid
from sales.Orders
where orderdate >= '2016-02-01' and orderdate < '2016-03-01')

except

select custid, empid
from sales.Orders
where orderdate >= '2015-01-01' and orderdate < '2016-01-01'
ORDER BY
    custid,
    empid;

--solved below by Exist and NOT EXISTS (more efficiant probebly)

Select Distinct
    o1.custid,
    o1.empid
from Sales.Orders as o1
where
    -- active in January 2016
    Exists
    (select 1
        from Sales.Orders as o2
        where o2.custid = o1.custid
          and o2.empid = o1.empid
          and o2.orderdate >= '2016-01-01'
          and o2.orderdate <  '2016-02-01')
    -- active in February 2016
    and exists
    (select 1
        from Sales.Orders as o3
        where o3.custid = o1.custid
          and o3.empid = o1.empid
          and o3.orderdate >= '2016-02-01'
          and o3.orderdate <  '2016-03-01')
    -- no activity in 2015
    and not exists
    (select 1
        from Sales.Orders as o4
        where o4.custid = o1.custid
          and o4.empid = o1.empid
          and o4.orderdate >= '2015-01-01'
          and o4.orderdate <  '2016-01-01')
Order by
    o1.custid,
    o1.empid;

-- =========================================================
-- 6 (Optional, Advanced)


Select country, region, city
From HR.Employees

Union ALL

Select country, region, city
from Production.Suppliers

order by region desc, country, city
/*
In the code above, you must guarantee that Employees table rows
are returned first, followed by Suppliers table rows, and that
within each section the data is sorted by
country, region, city.
*/
-- Tables involved: TSQLV4 database, Employees and Suppliers tables
-- =========================================================

	Select country, region, city
from
	(Select 1 as src,  --Employees comes first
    country, region, city
    from HR.Employees

    Union all

    select
        2 as src,  --Suppliers after Employees
        country, region, city
    from Production.Suppliers) as t

Order by
    src,       --Employees first, then Suppliers
    country, region, city