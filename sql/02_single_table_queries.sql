/*
Note: All exercises in this file were independently analyzed and solved
by the author. In some cases, the original task descriptions were
translated, reorganized, and grammar-corrected with the assistance
of Claude (Anthropic).
*/

Use TSQLV4

-- =========================================================
-- 1
-- Return sales that fall in June 2015
-- Tables involved: TSQLV4 database, Sales.Orders table
-- =========================================================

SELECT orderId, orderdate, custid, empid
FROM Sales.Orders
WHERE orderdate >= '2015-06-01'
  AND orderdate <  '2015-07-01';

-- =========================================================
-- 2
/*
Return sales that fall on the last day of each month
*/
-- Tables involved: Sales.Orders table
-- =========================================================

select orderId, orderdate, custid, empid
From Sales.Orders
Where orderdate=EOMONTH(orderdate);

-- =========================================================
-- 3
/*
Return customers whose last name contains
the letter e two or more times
*/
-- Tables involved: HR.Employees table
-- =========================================================

select empid, firstname, lastname
From Hr.Employees
where LEN(LastName) - LEN(REPLACE(LastName, 'e', '')) >= 2;

-- =========================================================
-- 4
/*
Return sales with a total value (qty*Unitprice)
greater than 10000,
sorted by total value
*/
-- Tables involved: Sales.OrderDetails table
-- =========================================================

select orderid, sum(qty*unitprice) as TotalValue
From Sales.OrderDetails
group by Orderid
	having sum(qty*unitprice) > 10000
Order By TotalValue desc;

-- =========================================================
-- 5
/*
 On the Hr.Employees table
 write code to return employees whose last name starts with a lowercase letter.
*/
-- =========================================================

select empid, lastname
from HR.Employees
where lastname COLLATE Latin1_General_BIN LIKE '[a-z]%';

-- =========================================================
-- 6
/*
Explain the difference between the two queries below
*/
-- =========================================================

SELECT empid, COUNT(*) AS numorders
FROM Sales.Orders
WHERE orderdate < '20160501'
GROUP BY empid;

/* How many orders did each salesperson have before May 1, 2016?
In this code, rows before the given date are filtered first,
then grouped and counted by employee. */

SELECT empid, COUNT(*) AS numorders
FROM Sales.Orders
GROUP BY empid
HAVING MAX(orderdate) < '20160501';

/* Which salesperson had no orders on or after May 1, 2016,
and what is their total order count?
Here, all orders are grouped by employee first, and then
employees who had sales after the given date are excluded.
*/

-- =========================================================
-- 7
/*
Top three countries by the highest shipping (freight) amount in 2015
*/
-- Table involved: Sales.Orders table
-- =========================================================

Select top (3) shipcountry, avg(freight) as avgfreight
From Sales.Orders
where orderdate >'2014-12-31' and orderdate <= '2015-12-31'
group by shipcountry
Order by avgfreight Desc;

-- =========================================================
-- 8
/*
For each customer, state their gender based on their title of courtesy.
*/
-- Ms., Mrs. - Female, Mr. - Male, Dr. - Unknown
-- Table involved: HR.Employees table
-- =========================================================

Select empid, firstname, lastname, titleofcourtesy,
	CASE 
    When titleofcourtesy IN ('Ms.', 'Mrs.') Then 'Female'
    When titleofcourtesy = 'Mr.' Then 'Male'
    Else 'Unknown'
End as gender
From hr.Employees;

-- =========================================================
-- 9
/*
For each customer, return their customer number and Region.
Sort by Region as well, with Null values
placed at the end of the list.
*/
-- Table involved: Sales.Customers table
-- =========================================================

Select CustID, Region
from Sales.Customers
Order by
    Case 
        When Region IS NULL then 1 
        Else 0 
    END,
    Region;