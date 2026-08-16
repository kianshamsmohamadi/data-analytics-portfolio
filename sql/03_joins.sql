/*
Note: All exercises in this file were independently analyzed and solved
by the author. In some cases, the original task descriptions were
translated, reorganized, and grammar-corrected with the assistance
of Claude (Anthropic).
*/

-- =========================================================
-- 1
-- 1-1
/*
Write code that produces 5 copies of each employee.
*/
-- Tables involved: TSQLV4 database, Employees and Nums tables
-- =========================================================

Select E.empid, E.firstname, E.lastname, N.n
from hr.Employees as E
cross join Nums as N
Where n.n BETWEEN 1 AND 5;

-- =========================================================
-- 1-2 (Optional, Advanced)
/*
Write code that returns one row for each employee and each day,
where the day falls between
June 12, 2016 - June 16, 2016.
*/
-- Tables involved: TSQLV4 database, Employees and Nums tables
-- =========================================================

Select e.empid, Cast(Dateadd (day, n.n-1, '2016-06-12') as Date) as dt
From hr.Employees as E
cross join Nums as N
where n.n Between 1 and 5
Order by empid, dt;

-- =========================================================
-- 2
/*
What error exists in the code below? Fix it.
*/
-- =========================================================

Select C.custid, C.companyname, O.orderid, O.orderdate
from Sales.Customers AS C
  Inner Join Sales.Orders AS O
    ON C.custid = O.custid;

-- =========================================================
-- 3
/*
Return US customers, and for each customer show
the maximum number of orders and the total quantity ordered.
*/
-- Tables involved: TSQLV4 database, Customers, Orders and OrderDetails tables
-- =========================================================

Select c.custid, count(Distinct o.orderid) as NumOrders, sum(D.qty) as totlaQty
From Sales.Customers as C
	Join Sales.Orders as O
		On O.custid = c.custid
	Join Sales.OrderDetails as D
		On O.orderid = D.orderid
	Where c.country='USA'
	Group by c.custid;

-- =========================================================
-- 4
/*
Return every customer and all of their sales -- also include
customers who have no sales at all.
*/
-- Tables involved: TSQLV4 database, Customers and Orders tables
-- =========================================================

select c.custid, c.companyname, o.orderid, o.orderdate
from sales.Customers as C
	Left Join sales.Orders as O
		on c.custid = o.custid;

-- =========================================================
-- 5
/*
Return customers who have no sales at all.
*/
-- Tables involved: TSQLV4 database, Customers and Orders tables
-- =========================================================

select c.custid, c.companyname
from sales.Customers as C
	Left join sales.orders as O
		on c.custid = o.custid
where o.orderid is null;

-- =========================================================
-- 6
/*
 Customers along with their sales that occurred on
 Feb 12, 2016.
*/
-- Tables involved: TSQLV4 database, Customers and Orders tables
-- =========================================================

select c.custid, c.companyname, o.orderid, o.orderdate
from sales.Customers as C
	inner join sales.Orders as O
		on c.custid = o.custid
where o.orderdate = '2016-02-12';

-- =========================================================
-- 7 (Optional, Advanced)
/*
Write code that returns all customers, but only shows the
sale and its date for sales that occurred on February 12, 2016.
*/
-- Tables involved: TSQLV4 database, Customers and Orders tables
-- =========================================================

select c.custid, o.orderid, o.orderdate
from sales.Customers as C
	left join sales.orders as O
		on c.custid = o. custid and o.orderdate = '2016-02-12';

-- =========================================================
-- 8
/*
Explain why the code below is not a suitable solution for Exercise 7.
*/
-- =========================================================

SELECT C.custid, C.companyname, O.orderid, O.orderdate
FROM Sales.Customers AS C
  LEFT OUTER JOIN Sales.Orders AS O
    ON O.custid = C.custid
WHERE O.orderdate = '20160212'
   OR O.orderid IS NULL;

/*
The filtering happens after the JOIN executes, so the result
excludes customers who had no orders at all.
The presence of the IS NULL condition also causes two sale
records with an unknown orderid to be included in the results.
*/