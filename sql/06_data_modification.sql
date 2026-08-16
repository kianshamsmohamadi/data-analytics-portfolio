/*
Note: All exercises in this file were independently analyzed and solved
by the author. In some cases, the original task descriptions were
translated, reorganized, and grammar-corrected with the assistance
of Claude (Anthropic).
*/

use TSQLV4;

-- =========================================================
-- 1
/*
Run the following code.
*/
-- =========================================================

USE TSQLV4;

DROP TABLE IF EXISTS dbo.Customers;

CREATE TABLE dbo.Customers
(
  custid      INT          NOT NULL PRIMARY KEY,
  companyname NVARCHAR(40) NOT NULL,
  country     NVARCHAR(15) NOT NULL,
  region      NVARCHAR(15) NULL,
  city        NVARCHAR(15) NOT NULL  
);

-- =========================================================
-- 1-1
/*
In the dbo.Customers table,
insert one row with the following details:
-- custid:  100
-- companyname: Coho Winery
-- country:     USA
-- region:      WA
-- city:        Redmond
*/
-- =========================================================

select * from dbo.Customers;

insert into dbo.Customers values (100, 'Coho Winery', 'USA', 'WA', 'Redmond');

-- =========================================================
-- 1-2
/*
Add every customer who has sales, from the Sales.Customers
table, into the dbo.Customers table.
*/
-- =========================================================

insert into dbo.Customers
		select distinct c.custid, c.companyname, c.country, c.region, c.city
		from Sales.Customers as c
		join sales.Orders as o
		on c.custid=o.custid;

-- =========================================================
-- 1-3
/*
Using Select Into,
create a table named Dbo.orders
and populate it from the Sales.Orders table, for the date
range 2014 to 2016.
*/
-- =========================================================

drop table if exists dbo.orders;
select *
into dbo.orders
from sales.Orders
where orderdate>='2014-01-01' and orderdate<'2017-01-01';

select *
from dbo.orders;

-- =========================================================
-- 2
/*
From the dbo.Orders table, delete orders placed before
August 2014, and using Output display the Orderid and
Orderdate of the deleted rows.
*/
-- =========================================================

drop table if exists OrderDelete;
create table OrderDelete
(orderid int not null,
orderdate date not null,
shipcountry nvarchar(20) not null);

delete From dbo.orders
output
deleted.orderid,
deleted.orderdate,
deleted.shipcountry
into OrderDelete
where orderdate < '2014-08-01';

select orderid, orderdate from OrderDelete;

-- =========================================================
-- 3
/*
From the dbo.orders table, delete orders that were placed
by customers from Brazil.
*/
-- =========================================================

delete
from  O
output deleted.orderid,
deleted.orderdate,
deleted.shipcountry
into OrderDelete (orderid,orderdate,shipcountry)
from dbo.orders as O
join dbo.Customers as C
on o.custid= c.custid
where c.country='Brazil';

select * from dbo.orders as O join dbo.Customers as C on o.custid=c.custid and c.country='Brazil';

select * from OrderDelete;

-- =========================================================
-- 4
/*
Update the dbo.Customers table and change Region values that
are Null to <None>, and using Output display the
Custid, Old Region, and New Region values.
*/
-- =========================================================

update dbo.Customers
set region='<None>'
Output
inserted.custid,
deleted.region as OldRegion,
inserted.region as NewRegion
where region is null;

select * from dbo.Customers;