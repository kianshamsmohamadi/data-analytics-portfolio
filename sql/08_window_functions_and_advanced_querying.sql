/*
Note: All exercises in this file were independently analyzed and solved
by the author. In some cases, the original task descriptions were
translated, reorganized, and grammar-corrected with the assistance
of Claude (Anthropic).
*/

/* Note on the table created below:
For exercises in this set it was instructed to use dbo.Orders table
this is a diffrent table than the dbo.Orders that was instructed to creat in Data Modification section
structure and the data thats needed in this table was shown in the course but it was no provided so I
created it and named it dbo.OrderQty so it wont mix up with previous dbo. sales*/

USE TSQLV4;

drop table if exists dbo.orderQty;
Create table dbo.orderQty (custid nvarchar (4) not null,
						  orderid int not null,
						  qty int not null,
						  orderdate date not null,
						  empid int not null);

insert into dbo.orderQty (custid, orderid, qty, orderdate, empid) values
('A', 30001, 10, '2014-08-02', 3),
('A', 10001, 12, '2014-12-24', 2),
('B', 10005, 20, '2014-12-24', 1),
('A', 40001, 40, '2015-01-09', 2),
('C', 10006, 14, '2015-01-18', 1),
('B', 20001, 12, '2015-02-12', 2),
('A', 40005, 10, '2016-02-12', 3),
('C', 20002, 20, '2016-02-16', 1),
('B', 30003, 15, '2016-04-18', 2),
('C', 30004, 22, '2014-04-18', 3),
('D', 30007, 30, '2016-09-07', 3);

select *
from dbo.orderQty;

-- =========================================================
-- 1
/*
Write code on the dbo.orders table that computes, for each
customer sale, the RANK and DENSE_RANK values -- partitioned
by custid and ordered by qty.
*/
-- =========================================================

-- dbo.orderQty was used. refer to the note at the begining of the file

select custid, orderid, qty,
		Rank () Over (partition by custid order by qty) as rnk,
		Dense_rank () Over (partition by custid order by qty) as drnk
from dbo.orderQty
order by custid, qty;


-- =========================================================
-- 2
/*
The code below, run on the Sales.OrderValues view, returns
distinct val values along with a row number. Can you provide
an alternative solution that achieves this same result?
*/
-- =========================================================

USE TSQLV4;

SELECT val, ROW_NUMBER() OVER(ORDER BY val) AS rownum
FROM Sales.OrderValues
GROUP BY val;

-- My alternative solution:

USE TSQLV4;

SELECT distinct val, dense_rank() OVER(ORDER BY val) AS rownum
FROM Sales.OrderValues

-- =========================================================
-- 3
/*
Write code on the dbo.orders table that, for each customer sale:
- Computes the difference between the current order's qty and
  the previous order's qty for that same customer.
- Computes the difference between the current order's qty and
  the next order's qty for that same customer.
*/
-- =========================================================

select custid, orderid, qty,
qty-lag (qty) over (partition by custid order by orderdate, orderid) as diffprev,
qty-lead (qty) over(partition by custid order by orderdate, orderid) as diffnext
from dbo.orderQty
Order by custid, orderdate, orderid;

-- =========================================================
-- 4
/*
Write code on the dbo.orders table that returns one row per
employee, with one column for each order year, showing the
number of orders that employee had in each year.
*/
-- Tables involved: TSQLV4 database, dbo.Orders table
-- =========================================================

select empid, [2014] as cnt2014, [2015] as cnt2015, [2016] as cnt2016
from (select empid, year(orderdate) as oyear, orderid
	  from dbo.orderQty) as S
pivot (count(orderid) for oyear in ([2014], [2015], [2016])) as P;


-- =========================================================
-- Extera 1 (Couching Session)
/*
rebuild the Exercise 5-2 from 07_table_expressions_and_cte exercises with Window Functions:

Write code on Sales.VEmpOrders that computes the QTY value as a
running total per row, for each salesperson and each year.
*/
-- =========================================================

--copy of the view creation step done in CTE section for using in this exercise
Drop View if Exists sales.VEmpOrders
Go

Create View Sales.VEmpOrders
with Schemabinding
as
Select O.empid, Year(O.orderdate) as orderyear , sum(D.qty) as qty
from sales.Orders as O
join sales.OrderDetails as D
on O.orderid=D.orderid
group by O.empid, Year(O.orderdate);
Go
-- old (CTE) solution:
Select empid, orderyear, qty,
(Select sum(V2.qty)
from sales.VEmpOrders as V2
where V1.Empid=V2.empid and V1.orderyear>=V2.orderyear) as runqty
from sales.VEmpOrders as V1
order by empid, orderyear;

-- new (Window function) solution:
select empid, orderyear, qty,
sum(qty) over (partition by empid order by orderyear
				rows between unbounded preceding and current row) as runqty
from sales.VEmpOrders
order by empid, orderyear;

-- =========================================================
-- Extera 2 (Couching Session)
/*
rebuild the Exercise 10 from 04_subqueries exercises with Window Functions:

For each order, compute the number of days between it and that
customer's previous purchase.
*/
-- use orderdate as the primary sort element and orderid as the tiebreaker.
-- Tables involved: TSQLV4 database, Sales.Orders table
-- =========================================================

-- old (Sunbqueries) solution:
Select
    o1.custid,
    o1.orderdate,
    o1.orderid,
    DATEDIFF(day,(select MAX(o2.orderdate)
				  from Sales.Orders as o2
				  where o2.custid = o1.custid
				  and (o2.orderdate < o1.orderdate
                   or (o2.orderdate = o1.orderdate and o2.orderid < o1.orderid))),
			 o1.orderdate) as daysdiff
from Sales.Orders as o1
order by o1.custid, o1.orderdate, o1.orderid;

-- new (Window function) solution:

select custid,orderdate, orderid,
datediff (day, lag(orderdate) over (partition by custid order by orderdate, orderid), orderdate) as  daysdiff
from Sales.Orders
order by custid, orderdate, orderid;

-- =========================================================
-- Extra 3 (Couching Session)
/*
using dbo.orderQty (your Exercise 1/3 table), for each customer, return every
order along with that customer's lowest-qty order (FIRST_VALUE, ordered by
qty ascending) and highest-qty order (LAST_VALUE, ordered by qty ascending,
with the correct frame).
*/
-- =========================================================

select custid, qty,
First_Value (qty) over (partition by custid order by qty) as lowestqty,
Last_Value (qty) over (partition by custid order by qty
						rows between current row and unbounded following) as highestqty
from dbo.orderQty
order by custid, qty asc;

-- =========================================================
--Extra 4 (Couching Session)

--rebuild the Extra Exercise from 07_table_expressions_and_cte with Window Functions:
/* Return each employee's empid, firstname, lastname,
their total number of orders, and their total quantity
sold — but only for employees whose total quantity sold
is abovethe average total quantity sold across all employees.*/
-- =========================================================

-- old (CTE) solution:
With EmpTotals as
(Select O.empid, count (distinct O.orderid) as numorders, sum(D.qty) as totalqty
from sales.orders as O
inner join sales.OrderDetails as D
on o.orderid=D.orderid
group by o.empid),

AvgQty as
(select avg(totalqty) as avgqty
from EmpTotals)

select ET.empid, E.firstname, E.lastname, ET.totalqty, ET.numorders, (ET.totalqty-AQ.avgqty) as above
from EmpTotals as ET
inner join hr.Employees as E
on ET.empid=E.empid
cross join AvgQty as AQ
where ET.totalqty > AQ.avgqty
order by totalqty desc;

-- new (window function) solution:


with empqty as
(select O.empid, count(O.orderid) as numorders, sum(qty) as totalqty
from sales.Orders as O
join sales.OrderDetails as D
on O.orderid=D.orderid
group by O.empid),

withavg as
(select EQ.empid,E.firstname, E.lastname, EQ.numorders, EQ.totalqty,
		EQ.totalqty-(avg(EQ.totalqty) over ()) as above
from empqty as EQ
join hr.Employees as E
on EQ.empid=E.empid)

select *
from withavg
where above>0
order by totalqty desc;

-- =========================================================
--Extra 4 (Couching Session)

/* using dbo.orderQty, write a query using GROUPING SETS that returns, in one result set:

Total qty per employee per year
Total qty per employee (all years combined)
Grand total qty (everything)

can you reach the same results with ROLLLUP? answer then write it regardless

can it be done with CUBE?  answer then write it regardless*/
-- =========================================================

--with grouping sets
select empid, year(orderdate) as orderyear, sum(qty) as sumqty
from dbo.orderQty
group by grouping sets(
(empid, Year(orderdate)),(empid),()
);

--with rollup (it WILL reach the same result)

select empid, year(orderdate) as orderyear, sum(qty) as sumqty
from dbo.orderQty
group by Rollup (Empid, year(orderdate));

--with rollup (it WONT reach the same result)

select empid, year(orderdate) as orderyear, sum(qty) as sumqty
from dbo.orderQty
group by Cube (Empid, year(orderdate));


-- =========================================================
--Extra 5 (Couching Session)

/* take the pivoted result from your Exercise 4 (empid, cnt2014, cnt2015, cnt2016)
and unpivot it back into a long format — one row per empid + year, with columns
empid, orderyear, ordercount.*/
-- =========================================================

--fist I will bring the query in exercise 4 as a CTE

with piv as (
select empid, [2014] as cnt2014, [2015] as cnt2015, [2016] as cnt2016
from (select empid, year(orderdate) as oyear, orderid
	  from dbo.orderQty) as S
pivot (count(orderid) for oyear in ([2014], [2015], [2016])) as P
)

-- I will trim the values in orderyear to contain only the
-- right 4 digts (4 numbers representing the year) with RIGHT 
select empid, RIGHT(orderyear, 4) as orderyear, ordercount
from piv
unpivot (
ordercount for orderyear in (cnt2014, cnt2015, cnt2016)
) as unpiv;

-- =========================================================
--Extra 6 (Couching Session)

/*
Write a Dynamic Pivot query on the dbo.orderQty table that returns
one row per employee, with one column for each distinct order year
found in the data (the same result as the earlier static Pivot
exercise (exercise 4)), but without hardcoding the year values in the column
list -- the set of year columns should be determined automatically
from the actual data at runtime.
*/
-- Tables involved: dbo.orderQty table
-- =========================================================

DECLARE @cols AS NVARCHAR(MAX);
DECLARE @colsalias AS NVARCHAR(MAX);
DECLARE @query AS NVARCHAR(MAX);

SELECT @cols = STRING_AGG(QUOTENAME(year_column), ',')
FROM (SELECT DISTINCT YEAR(orderdate) AS year_column FROM dbo.orderQty) AS Y;
SELECT @colsalias = STRING_AGG(QUOTENAME(year_column)+' as cnt'+cast(year_column as nvarchar(max)), ',')
FROM (SELECT DISTINCT YEAR(orderdate) AS year_column FROM dbo.orderQty) AS Y;

SET @query = '
SELECT empid, ' + @colsalias + '
FROM (SELECT empid, YEAR(orderdate) AS oyear, orderid FROM dbo.orderQty) AS S
PIVOT (COUNT(orderid) FOR oyear IN (' + @cols + ')) AS P';

EXEC sp_executesql @query;