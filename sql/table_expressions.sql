-- 1
/*
کد زیر سعی میکند فروشهایی که در اخرین روز ماه قرار دارد را فیلتر کند. ولی خطای زیر را دریافت میکند. دلیل خطا و راه حل معتبر جهت حل آن بفرمایید
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

/* دلیل خطا تعریف متغیر edofyear در select و استفاده از آن در where است. روند اجرای کد از نظر منطقی
where را قبل از select  بررسی میکند و متغیر endofyear را نمی‌شناسد.*/

with EndofYear as
(select orderid, orderdate, custid, empid, DATEFROMPARTS(YEAR(orderdate), 12, 31) AS endofyear
from sales.orders)

select orderid, orderdate, custid, empid, endofyear
FROM EndofYear
WHERE orderdate <> endofyear;

-- 2-1
 /*
به ازای هر فروشنده آخرین تاریخ سفارش را بدست بیاورید
*/

-- Tables involved: TSQLV4 database, Sales.Orders table

Select empid, max(orderdate) as maxorderdate
from sales.orders
group by empid;

-- 2-2
/*
کد مرحله قبل را به در یک Derived Table نوشته و بواسطه یک جوین با جدول Orders مقادیر مربوط به Orders را برای اخرین تاریخ د ر فروشنده بدست بیاورید
*/
-- Tables involved: Sales.Orders


select O.empid, O.orderdate, O.orderid, O.custid
from sales.orders as O
join (select empid, Max(orderdate) as maxorderdate
from sales.orders
group by empid) as L
on O.empid=L.empid and O.orderdate=L.maxorderdate;

-- 3-1
/*
کدی بنویسید که به ازای هر مشتری براساس تاریخ فروش و شماره فروش یک شماره ردیف یا Row number به آن اختصاص دهد
*/
-- Tables involved: Sales.Orders

Select orderid, orderdate, custid, empid,
	   Row_Number() Over (Order By orderdate, orderid) as rownum
from sales.Orders

with NumedOrders as
(select orderid, orderdate, custid, empid, Row_Number() Over (Order By orderdate, Orderid) as rownum
From Sales.Orders)

Select orderid, orderdate, custid, empid, rownum
From NumedOrders
where rownum between 11 and 20;

-- 4 (Optional, Advanced)
/*
یک کد بازگشتی بنویسید که زنجیره مدیران مربوط به کارمند شماره 9 را بدست بیاورد
*/

-- Tables involved: HR.Employees

select H1.empid, H1.mgrid
from Hr.Employees as H1
join Hr.Employees as H2
on H1.mgrid=H2.empid

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