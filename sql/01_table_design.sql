/*
Note: All exercises in this file were independently analyzed and solved
by the author. In some cases, the original task descriptions were
translated, reorganized, and grammar-corrected with the assistance
of Claude (Anthropic).
*/

/*
Normalize the table below to Third Normal Form (3NF) and design it.
*/
----------------------------2NF 
	--Table Orders (
	--			OrderID int ,
	--			ProductID int ,
	--			OrderDate Datetime,
	--			qty int,
	--			CustomerId int,
	--			CustomerName varchar(100)
	--			) -- OrderId and ProductID is PrimaryKey

	Table Orders(OrderId int, OrderDate Datetime, CustomerId int)
	Table Customers (CustomerId int, CustomerName varchar(100));
	Table OrderDetailes (OrderId int, ProductId int, qty int);