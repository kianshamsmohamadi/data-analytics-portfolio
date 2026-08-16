/*
Note: All exercises in this file were independently analyzed and solved
by the author. In some cases, the original task descriptions were
translated, reorganized, and grammar-corrected with the assistance
of Claude (Anthropic).
*/

Use TSQLV4

-- =========================================================
-- 1
/*
Write code that returns all sales belonging to the most recent
activity date in the sales table.
*/
-- Tables involved: TSQLV4 database, Orders table
-- =========================================================

select orderid, orderdate, custid, empid
from sales.Orders
where orderdate=
	(select max(orderdate)
	from sales.Orders);

-- =========================================================
-- 2 (Optional, Advanced)
/*
	All sales belonging to the customer with the highest number of sales.
	There may be more than one customer tied for the same number of sales.
*/
-- Tables involved: TSQLV4 database, Orders table
-- =========================================================

select custid, orderid, orderdate, empid
From sales.Orders
where custid in
	(SELECT Top 1 with ties
			o.custid
	from sales.OrderDetails as D
		inner join Sales.orders as O
		on D.orderid=O.orderid
	group by o.custid
	order by sum(d.qty) desc);

--Another metod that is more efficiant

	WITH CustomerQty AS
(
    SELECT
        o.custid,
        SUM(d.qty) AS totqty
    FROM sales.OrderDetails AS d
    INNER JOIN sales.Orders AS o
        ON d.orderid = o.orderid
    GROUP BY o.custid
),
TopCustomers AS
(
    SELECT custid
    FROM CustomerQty
    WHERE totqty = (SELECT MAX(totqty) FROM CustomerQty)
)
SELECT o.custid, o.orderid, o.orderdate, o.empid
FROM sales.Orders AS o
JOIN TopCustomers AS t
    ON t.custid = o.custid;

-- =========================================================
-- 3
/*
List of salespeople who had no sales on or after
May 1st, 2016.
*/
-- Tables involved: TSQLV4 database, Employees and Orders tables
-- =========================================================

select empid, firstname, lastname
from hr.Employees
where empid not in
	(select empid
	from sales.Orders
	where orderdate >= '2016-05-01'
	group by empid);

--Another metod that is recomended
SELECT e.empid, e.firstname, e.lastname
FROM hr.Employees AS e
WHERE NOT EXISTS
	(SELECT 1
    FROM sales.Orders AS o
    WHERE o.empid = e.empid
      AND o.orderdate >= '2016-05-01');

-- =========================================================
-- 4
/*
List of countries where we have customers but no employees.
*/
-- Tables involved: TSQLV4 database, Customers and Employees tables
-- =========================================================

Select Distinct C.country
From sales.Customers as C
	where not exists
		(select 1
		from hr.Employees as E
		where C.country = E.country);

-- =========================================================
-- 5
/*
For each customer, all sales belonging to that customer
on the last day they made a purchase.
*/
-- Tables involved: TSQLV4 database, Orders table
-- =========================================================

select O1.custid, O1.orderid, O1.orderdate, empid
From Sales.Orders as O1
		where O1.orderdate =
			(select max(O2.orderdate)
			from sales.Orders as O2
			where O2.custid=O1.custid)
Order By O1.custid;

--more Optimized version:

WITH LastOrderDate AS
(SELECT custid, MAX(orderdate) AS maxorderdate
    FROM Sales.Orders
    GROUP BY custid)
SELECT o.custid, o.orderid, o.orderdate, o.empid
FROM Sales.Orders AS o
JOIN LastOrderDate AS l
    ON l.custid = o.custid
   AND l.maxorderdate = o.orderdate
Order By o.custid;

-- =========================================================
-- 6
/*
List of customers who purchased in 2015 but not in 2016.
*/
-- Tables involved: TSQLV4 database, Customers and Orders tables
-- =========================================================

with fifhcust as
	(Select custid
	from Sales.orders
	where Orderdate>='2015-01-01' and orderdate < '2016-01-01'
	Group by custid),

sixtcust as
	(Select custid
	from Sales.orders
	where Orderdate>='2016-01-01' and orderdate < '2017-01-01'
	Group by custid),

snotfcust as
(select fifhcust.custid from fifhcust
Except
select sixtcust.custid from sixtcust)

select c.custid, c.companyname
from sales.Customers as C
inner join snotfcust as snfc
on c.custid=snfc.custid;

--above is my first code that works but is a little too much and also wont give me room 
--to do more queries based on it, the following code uses EXISTS and is more efficiant
--with the code below I can also modify is to do more analysis

SELECT DISTINCT c.custid, c.companyname
FROM Sales.Customers AS c
WHERE EXISTS
(
    SELECT 1
    FROM Sales.Orders AS o
    WHERE o.custid = c.custid
      AND o.orderdate >= '2015-01-01'
      AND o.orderdate <  '2016-01-01'
)
AND NOT EXISTS
(
    SELECT 1
    FROM Sales.Orders AS o
    WHERE o.custid = c.custid
      AND o.orderdate >= '2016-01-01'
      AND o.orderdate <  '2017-01-01'
);

-- =========================================================
-- 7 (Optional, Advanced)
/*
List of customers who purchased product number 12.
*/
-- Tables involved: TSQLV4 database,
-- Customers, Orders and OrderDetails tables
-- =========================================================

select Distinct O.custid, c.companyname
from sales.OrderDetails as D
join sales.Orders as O
on d.orderid=O.orderid
join sales.Customers as C
on C.custid=O.custid
where D.productid=12
Order by custid;

--above is the fist code I wrote wich is fine but using EXISTS is more efficiant
--my code is better if i want to show more details about each sale
--below is the efficiant version with EXISTS

SELECT c.custid, c.companyname
FROM Sales.Customers AS c
WHERE EXISTS
(
    SELECT 1
    FROM Sales.Orders AS o
    JOIN Sales.OrderDetails AS d
        ON d.orderid = o.orderid
    WHERE o.custid = c.custid
      AND d.productid = 12
)
ORDER BY c.custid;


-- =========================================================
-- 8 (Optional, Advanced)
/*
Compute the qty field as a running total, per row, for each
customer and each month, using a Subquery.
*/
-- Tables involved: TSQLV4 database, Sales.CustOrders view
-- =========================================================

select CO1.custid, CO1.ordermonth, CO1.qty,
	(select Sum(co2.qty)
	from sales.CustOrders as CO2
	where CO1.custid=co2.custid
	and co2.ordermonth <= co1.ordermonth)
	as runqty

	from sales.CustOrders as CO1
order by custid, ordermonth;

-- =========================================================
-- 9
/*
Explain the difference between IN and EXISTS.
*/
-- =========================================================

--in using "IN" function if there is a Null field in the results we get an empty result
--but by using "Exists" there is not such problem

-- =========================================================
-- 10 (Optional, Advanced)
/*
For each order, compute the number of days between it and that
customer's previous purchase.
*/
-- use orderdate as the primary sort element and orderid as the tiebreaker.
-- Tables involved: TSQLV4 database, Sales.Orders table
-- =========================================================

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