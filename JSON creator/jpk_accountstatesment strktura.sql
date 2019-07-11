USE [0d6304d3-75bd-4194-9221-9eea81c8c497]
GO

/****** Object:  Table [dbo].[JPK_AccountStatements]    Script Date: 2017-09-04 16:33:10 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[JPK_AccountStatements](
	[Id] [uniqueidentifier] NOT NULL,
	[TransactionDate] [datetime] NOT NULL,
	[TransactionNumber] [nvarchar](max) NULL,
	[TransactionId] [nvarchar](max) NULL,
	[EntityName] [nvarchar](max) NULL,
	[Description] [nvarchar](max) NULL,
	[Amount] [decimal](18, 2) NOT NULL,
	[AccountBalance] [decimal](18, 2) NOT NULL,
	[AccountNumber] [nvarchar](max) NULL,
	[DataSource] [nvarchar](max) NULL,
	[_startDate] [datetime] NOT NULL,
	[_createdBy] [nvarchar](max) NULL,
	[_deleted] [bit] NOT NULL,
 CONSTRAINT [PK_dbo.JPK_AccountStatements] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

ALTER TABLE [dbo].[JPK_AccountStatements] ADD  DEFAULT (newsequentialid()) FOR [Id]
GO

ALTER TABLE [dbo].[JPK_AccountStatements] ADD  DEFAULT ('1900-01-01T00:00:00.000') FOR [_startDate]
GO

ALTER TABLE [dbo].[JPK_AccountStatements] ADD  DEFAULT ((0)) FOR [_deleted]
GO


