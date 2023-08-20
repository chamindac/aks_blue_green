SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[Order]', N'U') IS null
BEGIN
	CREATE TABLE [dbo].[Order] (
		[Id]          BIGINT       NOT NULL IDENTITY(1,1) PRIMARY KEY,
		[Number] VARCHAR (30) NOT NULL,
		[Status] VARCHAR (30) NOT NULL,
		[InitiatedByApp] VARCHAR (15) NOT NULL,
		[InitiatedByCluster] VARCHAR (30) NOT NULL,
		[IntiatedAt] DATETIME NULL,
		[CreatedByApp] VARCHAR (15) NULL,
		[CreatedByCluster] VARCHAR (30) NULL,
		[CreatedAt] DATETIME NULL
	);
END
GO

IF OBJECT_ID(N'[dbo].[Invoice]', N'U') IS null
BEGIN
	CREATE TABLE [dbo].[Invoice] (
		[Id]          BIGINT       NOT NULL IDENTITY(1,1) PRIMARY KEY,
		[Number] VARCHAR (30) NOT NULL,
		[Status] VARCHAR (30) NOT NULL,
		[InitiatedByApp] VARCHAR (15) NOT NULL,
		[InitiatedByCluster] VARCHAR (30) NOT NULL,
		[IntiatedAt] DATETIME NULL,
		[CreatedByApp] VARCHAR (15) NULL,
		[CreatedByCluster] VARCHAR (30) NULL,
		[CreatedAt] DATETIME NULL
	);
END
GO

IF OBJECT_ID(N'[dbo].[CustomerOrder]', N'U') IS null
BEGIN
	CREATE TABLE [dbo].[CustomerOrder] (
		[Id]          BIGINT       NOT NULL IDENTITY(1,1) PRIMARY KEY,
		[Number] VARCHAR (30) NOT NULL,
		[ByApp] VARCHAR (15) NOT NULL,
		[ByCluster] VARCHAR (30) NOT NULL,
		[At] DATETIME NOT NULL
	);
END
GO

IF OBJECT_ID(N'[dbo].[CustomerInvoice]', N'U') IS null
BEGIN
	CREATE TABLE [dbo].[CustomerInvoice] (
		[Id]          BIGINT       NOT NULL IDENTITY(1,1) PRIMARY KEY,
		[Number] VARCHAR (30) NOT NULL,
		[ByApp] VARCHAR (15) NOT NULL,
		[ByCluster] VARCHAR (30) NOT NULL,
		[At] DATETIME NOT NULL
	);
END
GO

IF OBJECT_ID('[dbo].[View_OrdersWithoutCustomerOrder_ShouldRetrunNoRecords]', 'V') IS NOT NULL
BEGIN
	DROP VIEW [dbo].[View_OrdersWithoutCustomerOrder_ShouldRetrunNoRecords];
END
GO
CREATE VIEW [dbo].[View_OrdersWithoutCustomerOrder_ShouldRetrunNoRecords] 
AS 
    select o.* from [Order] o 
        left outer join [CustomerOrder] c on o.Number = c.Number 
        where c.Number IS NULL
GO

IF OBJECT_ID('[dbo].[View_OrdersNotCreated_ShouldRetrunNoRecords]', 'V') IS NOT NULL
BEGIN
	DROP VIEW [dbo].[View_OrdersNotCreated_ShouldRetrunNoRecords];
END
GO
CREATE VIEW [dbo].[View_OrdersNotCreated_ShouldRetrunNoRecords] 
AS 
    select o.* from [Order] o 
		where o.CreatedAt is NULL 
			or o.CreatedByApp IS NULL
			or o.CreatedByCluster IS NULL
			or o.[Status] <> 'Created'
GO

IF OBJECT_ID('[dbo].[View_OrdersIntiatedByAndCreatedByDifferentClusters_ShouldRetrunNoRecords]', 'V') IS NOT NULL
BEGIN
	DROP VIEW [dbo].[View_OrdersIntiatedByAndCreatedByDifferentClusters_ShouldRetrunNoRecords];
END
GO
CREATE VIEW [dbo].[View_OrdersIntiatedByAndCreatedByDifferentClusters_ShouldRetrunNoRecords] 
AS 
    select o.* from [Order] o
    	where o.InitiatedByCluster <> o.CreatedByCluster 
GO

IF OBJECT_ID('[dbo].[View_OrdersIntiatedByAndCustomerOrderByDifferentClusters_ShouldRetrunNoRecords]', 'V') IS NOT NULL
BEGIN
	DROP VIEW [dbo].[View_OrdersIntiatedByAndCustomerOrderByDifferentClusters_ShouldRetrunNoRecords];
END
GO
CREATE VIEW [dbo].[View_OrdersIntiatedByAndCustomerOrderByDifferentClusters_ShouldRetrunNoRecords] 
AS 
    SELECT o.Number, 
		o.InitiatedByCluster,
		c.ByCluster AS CustomerOrderByCluster
	from [Order] o INNER JOIN [CustomerOrder] c
		on o.Number = c.Number
    where o.InitiatedByCluster <> c.ByCluster
GO

IF OBJECT_ID('[dbo].[View_OrderCreateTime_Highest]', 'V') IS NOT NULL
BEGIN
	DROP VIEW [dbo].[View_OrderCreateTime_Highest];
END
GO
CREATE VIEW [dbo].[View_OrderCreateTime_Highest] 
AS 
    select TOP 1000 o.*,
		DATEDIFF(MILLISECOND,o.IntiatedAt,o.CreatedAt) AS TimeToUpdateMS,
		(DATEDIFF(MILLISECOND,o.IntiatedAt,o.CreatedAt)/1000) AS TimeToUpdateS
	from [Order] o
	order by TimeToUpdateMS DESC
GO

IF OBJECT_ID('[dbo].[View_CustomerOrderCreateTime_Highest]', 'V') IS NOT NULL
BEGIN
	DROP VIEW [dbo].[View_CustomerOrderCreateTime_Highest];
END
GO
CREATE VIEW [dbo].[View_CustomerOrderCreateTime_Highest] 
AS 
    SELECT TOP 1000 o.Number, 
		o.IntiatedAt,
		c.At AS CustomerOrderAt,
		DATEDIFF(MILLISECOND,o.IntiatedAt,c.At) AS TimeToUpdateMS,
		(DATEDIFF(MILLISECOND,o.IntiatedAt,c.At)/1000) AS TimeToUpdateS
	from [Order] o INNER JOIN [CustomerOrder] c
		on o.Number = c.Number
	order by TimeToUpdateMS DESC
GO

IF OBJECT_ID('[dbo].[View_InvoicesWithoutCustomerInvoice_ShouldRetrunNoRecords]', 'V') IS NOT NULL
BEGIN
	DROP VIEW [dbo].[View_InvoicesWithoutCustomerInvoice_ShouldRetrunNoRecords];
END
GO
CREATE VIEW [dbo].[View_InvoicesWithoutCustomerInvoice_ShouldRetrunNoRecords] 
AS 
    select i.* from [Invoice] i 
        left outer join [CustomerInvoice] c on i.Number = c.Number 
        where c.Number IS NULL
GO

IF OBJECT_ID('[dbo].[View_InvoicesNotCreated_ShouldRetrunNoRecords]', 'V') IS NOT NULL
BEGIN
	DROP VIEW [dbo].[View_InvoicesNotCreated_ShouldRetrunNoRecords];
END
GO
CREATE VIEW [dbo].[View_InvoicesNotCreated_ShouldRetrunNoRecords] 
AS 
    select i.* from [Invoice] i 
		where i.CreatedAt is NULL 
			or i.CreatedByApp IS NULL
			or i.CreatedByCluster IS NULL
			or i.[Status] <> 'Created'
GO

IF OBJECT_ID('[dbo].[View_InvoicesIntiatedByAndCreatedByDifferentClusters_ShouldRetrunNoRecords]', 'V') IS NOT NULL
BEGIN
	DROP VIEW [dbo].[View_InvoicesIntiatedByAndCreatedByDifferentClusters_ShouldRetrunNoRecords];
END
GO
CREATE VIEW [dbo].[View_InvoicesIntiatedByAndCreatedByDifferentClusters_ShouldRetrunNoRecords] 
AS 
    select i.* from [Invoice] i
    	where i.InitiatedByCluster <> i.CreatedByCluster
GO

IF OBJECT_ID('[dbo].[View_InvoicesIntiatedByAndCustomerInvoiceByDifferentClusters_ShouldRetrunNoRecords]', 'V') IS NOT NULL
BEGIN
	DROP VIEW [dbo].[View_InvoicesIntiatedByAndCustomerInvoiceByDifferentClusters_ShouldRetrunNoRecords];
END
GO
CREATE VIEW [dbo].[View_InvoicesIntiatedByAndCustomerInvoiceByDifferentClusters_ShouldRetrunNoRecords] 
AS 
    SELECT i.Number, 
		i.InitiatedByCluster,
		c.ByCluster AS CustomerInvoiceByCluster
	from [Invoice] i INNER JOIN [CustomerInvoice] c
		on i.Number = c.Number
    where i.InitiatedByCluster <> c.ByCluster
GO

IF OBJECT_ID('[dbo].[View_InvoiceCreateTime_Highest]', 'V') IS NOT NULL
BEGIN
	DROP VIEW [dbo].[View_InvoiceCreateTime_Highest];
END
GO
CREATE VIEW [dbo].[View_InvoiceCreateTime_Highest] 
AS 
    select TOP 1000 i.*,
		DATEDIFF(MILLISECOND,i.IntiatedAt,i.CreatedAt) AS TimeToUpdateMS,
		(DATEDIFF(MILLISECOND,i.IntiatedAt,i.CreatedAt)/1000) AS TimeToUpdateS
	from [Invoice] i
	order by TimeToUpdateMS DESC
GO

IF OBJECT_ID('[dbo].[View_CustomerInvoiceCreateTime_Highest]', 'V') IS NOT NULL
BEGIN
	DROP VIEW [dbo].[View_CustomerInvoiceCreateTime_Highest];
END
GO
CREATE VIEW [dbo].[View_CustomerInvoiceCreateTime_Highest] 
AS 
    SELECT TOP 1000 i.Number, 
		i.IntiatedAt,
		c.At AS CustomerInvoiceAt,
		DATEDIFF(MILLISECOND,i.IntiatedAt,c.At) AS TimeToUpdateMS,
		(DATEDIFF(MILLISECOND,i.IntiatedAt,c.At)/1000) AS TimeToUpdateS
	from [Invoice] i INNER JOIN [CustomerInvoice] c
		on i.Number = c.Number
	order by TimeToUpdateMS DESC
GO