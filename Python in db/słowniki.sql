USE [825c2c4a-2c33-4df6-89ee-4cb8dd294a00]
GO

/****** Object:  Table [dbo].[CRS_Accounts]    Script Date: 08.01.2019 16:05:52 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [da].[List](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](256) NOT NULL,
	[Description] [nvarchar](max) NULL,
	[_startDate] [datetime] NOT NULL,
	[_createdBy] [nvarchar](max) NULL,
	[_deleted] [bit] NOT NULL,
 CONSTRAINT [PK_da.List] PRIMARY KEY CLUSTERED 
 (
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [Unique_da.List] UNIQUE NONCLUSTERED ([Name])
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

CREATE TABLE [da].[ListValue](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ListId] [int] NOT NULL,
	[Value] [nvarchar](256) NOT NULL,
	[Description] [nvarchar](max) NULL,
	[_startDate] [datetime] NOT NULL,
	[_createdBy] [nvarchar](max) NULL,
	[_deleted] [bit] NOT NULL,
 CONSTRAINT [PK_da.ListValue] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [Unique_da.ListValue] UNIQUE NONCLUSTERED (ListId,Value)
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [da].[ListValue]  WITH CHECK ADD  CONSTRAINT [FK_da.ListValue_da.List_ListId] FOREIGN KEY([ListId])
REFERENCES [da].[List] ([Id])
GO

ALTER TABLE [da].[ListValue] CHECK CONSTRAINT [FK_da.ListValue_da.List_ListId]
GO

