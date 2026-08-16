/*
Note: All exercises in this file were independently analyzed and solved
by the author. In some cases, the original task descriptions were
translated, reorganized, and grammar-corrected with the assistance
of Claude (Anthropic).
*/

-- =========================================================
-- 1
/*
The code below attempts to filter sales that fall on the last
day of the month, but returns the error shown. State the
reason for the error and a valid solution to fix it.
*/

USE TSQLV4;
GO

SELECT orderid, orderdate, custid, empid,
  DATEFROMPARTS(YEAR(orderdate), 12, 31) AS endofyear
FROM Sales.Orders
WHERE orderdate <> endofyear;

/*
Msg 207, Level 16, State 1, Line 233
Invalid column name 'endofyear'.
*/
-- =========================================================

/* The reason for the error is defining the endofyear alias in the
SELECT clause and then using it in the WHERE clause. SQL Server's
logical processing order evaluates WHERE before SELECT, so it
does not yet recognize the endofyear alias.

Note: the original task description said "last day of the month,"
but the hardcoded DATEFROMPARTS(YEAR(orderdate), 12, 31) always
computes December 31 -- i.e. end of YEAR, not end of month.
Resolved by treating "end of year" as the intended logic,
consistent with the formula actually provided. */

with EndofYear as
(select orderid, orderdate, custid, empid, DATEFROMPARTS(YEAR(orderdate), 12, 31) AS endofyear
from sales.orders)

select orderid, orderdate, custid, empid, endofyear
FROM EndofYear
WHERE orderdate <> endofyear;

-- =========================================================
-- 2-1
/*
For each salesperson, obtain their most recent order date.
*/
-- Tables involved: TSQLV4 database, Sales.Orders table
-- =========================================================

Select empid, max(orderdate) as maxorderdate
from sales.orders
group by empid;

-- =========================================================
-- 2-2
/*
Take the code from the previous step and write it as a Derived
Table, then use a join with the Orders table to obtain the
Orders-related values for each salesperson's last order date.
*/
-- Tables involved: Sales.Orders
-- =========================================================

-- CTE form
with LastDate as
(select empid, Max(orderdate) as maxorderdate
from sales.orders
group by empid)
select O.empid, O.orderdate, O.orderid, O.custid
from sales.orders as O
join LastDate as L
on O.empid=L.empid and O.orderdate=L.maxorderdate;

-- Derived table form
select O.empid, O.orderdate, O.orderid, O.custid
from sales.orders as O
join (select empid, Max(orderdate) as maxorderdate
from sales.orders
group by empid) as L
on O.empid=L.empid and O.orderdate=L.maxorderdate;

-- =========================================================
-- 3-1
/*
Write code that assigns a row number to every order, based on
order date and order ID.
*/
-- Tables involved: Sales.Orders
--
-- Note: the original task description said numbering should
-- reset "per customer," but the expected sample output shows
-- rownum incrementing continuously (1, 2, 3...) across different
-- custid values with no resets. Resolved by numbering the full
-- table with no PARTITION BY, matching the actual sample output.
-- =========================================================

Select orderid, orderdate, custid, empid,
	   Row_Number() Over (Order By orderdate, orderid) as rownum
from sales.Orders

-- =========================================================
-- 3-2
/*
Write code that returns rows 11 through 20 of the previous
exercise's result. Write the previous exercise's code inside a CTE.
*/
-- Tables involved: Sales.Orders
-- =========================================================

with NumedOrders as
(select orderid, orderdate, custid, empid, Row_Number() Over (Order By orderdate, Orderid) as rownum
From Sales.Orders)

Select orderid, orderdate, custid, empid, rownum
From NumedOrders
where rownum between 11 and 20;

-- =========================================================
-- 4 (Optional, Advanced)
/*
Write a recursive query that obtains the chain of managers for
employee number 9.
*/
-- Tables involved: HR.Employees
-- =========================================================

with Mchain as
(select empid, mgrid, firstname, lastname
from HR.Employees
where empid = 9

UNION ALL
select E.empid, E.mgrid, E.firstname, E.lastname

from HR.Employees as E
join Mchain as MC
on  MC.mgrid=E.empid)

Select *
from Mchain;
Go

-- =========================================================
-- 5-1
/*
Create a View that obtains, for each salesperson in each year,
the total QTY value.
*/
-- Tables involved: Sales.Orders and Sales.OrderDetails
-- =========================================================

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

Select empid, orderyear, qty
from sales.VEmpOrders
order by empid, orderyear;

-- =========================================================
-- 5-2 (Optional, Advanced)
/*
Write code on Sales.VEmpOrders that computes the QTY value as a
running total per row, for each salesperson and each year.
*/
-- =========================================================

Select empid, orderyear, qty,
(Select sum(V2.qty)
from sales.VEmpOrders as V2
where V1.Empid=V2.empid and V1.orderyear>=V2.orderyear) as runqty
from sales.VEmpOrders as V1
order by empid, orderyear;
Go

-- =========================================================
-- 6-1
/*
Write an Inline function that accepts a supplier id input
value (@supid AS INT) and the number of requested product
records (@n AS INT); this function should return the @n
products with the highest price for the specified Supplier ID.
*/
-- Tables involved: Production.Products
-- =========================================================

Drop Function if exists Production.TopProducts
Go

Create function Production.TopProducts
(@supid as int, @n as int)
Returns Table
with Schemabinding
as
Return
Select Top(@n) productid, productname, unitprice
from Production.Products
where supplierid=@supid
Order by unitprice Desc
Go

Select *
From Production.TopProducts (5,2);

-- =========================================================
-- 6-2
/*
Using Cross Apply and the function created in the previous
exercise, display the two most expensive products for each
supplier.
*/
-- return, for each supplier, the two most expensive products
-- =========================================================

SELECT S.supplierid, S.companyname, T.productid, T.productname, T.unitprice
FROM Production.Suppliers AS S
CROSS APPLY Production.TopProducts(S.supplierid, 2) AS T;

DROP VIEW IF EXISTS Sales.VEmpOrders;
DROP FUNCTION IF EXISTS Production.TopProducts;

-- =========================================================
-- Extra
/* Return each employee's empid, firstname, lastname,
their total number of orders, and their total quantity
sold — but only for employees whose total quantity sold
is abovethe average total quantity sold across all employees.*/
-- =========================================================

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
where ET.totalqty > AQ.avgqty;