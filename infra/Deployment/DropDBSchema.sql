SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('[dbo].[View_OrdersWithoutCustomerOrder_ShouldRetrunNoRecords]', 'V') IS NOT NULL
BEGIN
	DROP VIEW [dbo].[View_OrdersWithoutCustomerOrder_ShouldRetrunNoRecords];
END
GO

IF OBJECT_ID('[dbo].[View_OrdersNotCreated_ShouldRetrunNoRecords]', 'V') IS NOT NULL
BEGIN
	DROP VIEW [dbo].[View_OrdersNotCreated_ShouldRetrunNoRecords];
END
GO

IF OBJECT_ID('[dbo].[View_OrdersIntiatedByAndCreatedByDifferentClusters_ShouldRetrunNoRecords]', 'V') IS NOT NULL
BEGIN
	DROP VIEW [dbo].[View_OrdersIntiatedByAndCreatedByDifferentClusters_ShouldRetrunNoRecords];
END
GO

IF OBJECT_ID('[dbo].[View_OrdersIntiatedByAndCustomerOrderByDifferentClusters_ShouldRetrunNoRecords]', 'V') IS NOT NULL
BEGIN
	DROP VIEW [dbo].[View_OrdersIntiatedByAndCustomerOrderByDifferentClusters_ShouldRetrunNoRecords];
END
GO

IF OBJECT_ID('[dbo].[View_OrderCreateTime_Highest]', 'V') IS NOT NULL
BEGIN
	DROP VIEW [dbo].[View_OrderCreateTime_Highest];
END
GO

IF OBJECT_ID('[dbo].[View_CustomerOrderCreateTime_Highest]', 'V') IS NOT NULL
BEGIN
	DROP VIEW [dbo].[View_CustomerOrderCreateTime_Highest];
END
GO

IF OBJECT_ID('[dbo].[View_InvoicesWithoutCustomerInvoice_ShouldRetrunNoRecords]', 'V') IS NOT NULL
BEGIN
	DROP VIEW [dbo].[View_InvoicesWithoutCustomerInvoice_ShouldRetrunNoRecords];
END
GO

IF OBJECT_ID('[dbo].[View_InvoicesNotCreated_ShouldRetrunNoRecords]', 'V') IS NOT NULL
BEGIN
	DROP VIEW [dbo].[View_InvoicesNotCreated_ShouldRetrunNoRecords];
END
GO

IF OBJECT_ID('[dbo].[View_InvoicesIntiatedByAndCreatedByDifferentClusters_ShouldRetrunNoRecords]', 'V') IS NOT NULL
BEGIN
	DROP VIEW [dbo].[View_InvoicesIntiatedByAndCreatedByDifferentClusters_ShouldRetrunNoRecords];
END
GO

F OBJECT_ID('[dbo].[View_InvoicesIntiatedByAndCustomerInvoiceByDifferentClusters_ShouldRetrunNoRecords]', 'V') IS NOT NULL
BEGIN
	DROP VIEW [dbo].[View_InvoicesIntiatedByAndCustomerInvoiceByDifferentClusters_ShouldRetrunNoRecords];
END
GO

IF OBJECT_ID('[dbo].[View_InvoiceCreateTime_Highest]', 'V') IS NOT NULL
BEGIN
	DROP VIEW [dbo].[View_InvoiceCreateTime_Highest];
END
GO

IF OBJECT_ID('[dbo].[View_CustomerInvoiceCreateTime_Highest]', 'V') IS NOT NULL
BEGIN
	DROP VIEW [dbo].[View_CustomerInvoiceCreateTime_Highest];
END
GO

IF OBJECT_ID(N'[dbo].[Order]', N'U') IS NOT null
BEGIN
DROP TABLE [dbo].[Order];
END
GO

IF OBJECT_ID(N'[dbo].[Invoice]', N'U') IS NOT null
BEGIN
	DROP TABLE [dbo].[Invoice];
END
GO

IF OBJECT_ID(N'[dbo].[CustomerOrder]', N'U') IS NOT null
BEGIN
DROP TABLE [dbo].[CustomerOrder];
END
GO

IF OBJECT_ID(N'[dbo].[CustomerInvoice]', N'U') IS NOT null
BEGIN
DROP TABLE [dbo].[CustomerInvoice];
END
GO