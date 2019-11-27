USE master
GO

IF  EXISTS (
	SELECT name 
		FROM sys.databases 
		WHERE name = N'KB301_Mustafina'
)
ALTER DATABASE [KB301_Mustafina] set single_user with rollback immediate
GO

IF  EXISTS (
	SELECT name 
		FROM sys.databases 
		WHERE name = N'KB301_Mustafina'
)
DROP DATABASE [KB301_Mustafina]
GO

CREATE DATABASE [KB301_Mustafina]
GO

USE [KB301_Mustafina]
GO

CREATE SCHEMA Mustafina
GO

/*
�������� ������ � ����������� ��������� ������
*/

IF OBJECT_ID(N'clients', 'U') IS NOT NULL
  DROP TABLE [KB301_Mustafina].Mustafina.clients

CREATE TABLE [KB301_Mustafina].Mustafina.clients
(
	ID_client int IDENTITY NOT NULL, 
	Name_client nvarchar(50) NOT NULL,
	Address_client nvarchar(70) NOT NULL, 
    CONSTRAINT PK_ID_client PRIMARY KEY (ID_client)
)
GO


IF OBJECT_ID(N'storage', 'U') IS NOT NULL
  DROP TABLE [KB301_Mustafina].Mustafina.storage

CREATE TABLE [KB301_Mustafina].Mustafina.storage
(
	ID_product int IDENTITY NOT NULL, 
	Name_product nvarchar(50) NOT NULL,
	Quantity int NOT NULL,
	Price money NOT NULL,
    CONSTRAINT PK_ID_product PRIMARY KEY (ID_product)
)
GO

IF OBJECT_ID(N'deliveries', 'U') IS NOT NULL
  DROP TABLE [KB301_Mustafina].Mustafina.deliveries

CREATE TABLE [KB301_Mustafina].Mustafina.deliveries
(
	Order_number int IDENTITY NOT NULL, 
	Order_date date NOT NULL,
	ID_client int NOT NULL, 
	ID_product int NOT NULL,
	Quantity_of_product_ordered int NOT NULL,
	Date_of_delivery date NOT NULL
	CONSTRAINT PK_Order_number PRIMARY KEY (Order_number, ID_product) 
)
GO

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE Name = 'trigger_check_delivery' AND type = 'TR') 
	DROP TRIGGER Mustafina.trigger_check_passage
GO


--������� ��� �������� ����, ��� ���� �� �� ������ ���������� ���������� ��������
CREATE TRIGGER Mustafina.trigger_check_delivery
	ON [KB301_Mustafina].Mustafina.deliveries
	INSTEAD OF INSERT
AS 
DECLARE @count int, @id int, @avail_count int
BEGIN
	SET @count = (SELECT Quantity_of_product_ordered FROM inserted)
	SET @id = (SELECT ID_product FROM inserted)
	SET @avail_count = (SELECT storage.Quantity FROM storage WHERE @id = storage.ID_product)
	if(@count <= @avail_count)
	BEGIN
		INSERT INTO [KB301_Mustafina].Mustafina.deliveries(Order_date, ID_client, ID_product, Quantity_of_product_ordered, Date_of_delivery) SELECT Order_date, ID_client, ID_product, Quantity_of_product_ordered, Date_of_delivery FROM inserted
		UPDATE [KB301_Mustafina].Mustafina.storage SET Quantity = Quantity - @count WHERE ID_product = @id
	END
	ELSE
	BEGIN
	    --SELECT @count as 'count', @id as 'id', @avail_count as 'avail_count'
		--SELECT * from [KB301_Mustafina].Mustafina.deliveries
		RAISERROR(N'����������� ���������� �������� ��� �� ������!', 5, 1)
		ROLLBACK
	END
END
GO

IF OBJECT_ID(N'discounts', 'U') IS NOT NULL
  DROP TABLE [KB301_Mustafina].Mustafina.discounts

CREATE TABLE [KB301_Mustafina].Mustafina.discounts
(
	ID_discount tinyint IDENTITY NOT NULL, 
	Order_price nvarchar(22) NOT NULL,
	Percent_discount tinyint NOT NULL,
	CONSTRAINT PK_ID_discount PRIMARY KEY (ID_discount) 
)
GO

ALTER TABLE [KB301_Mustafina].Mustafina.deliveries ADD 
	CONSTRAINT FK_ID_client FOREIGN KEY (ID_client) 
	REFERENCES [KB301_Mustafina].Mustafina.clients(ID_client)
GO

ALTER TABLE [KB301_Mustafina].Mustafina.deliveries ADD 
	CONSTRAINT FK_ID_product  FOREIGN KEY (ID_product) 
	REFERENCES [KB301_Mustafina].Mustafina.storage(ID_product)
GO

INSERT INTO [KB301_Mustafina].Mustafina.clients
 (Name_client, Address_client)
 VALUES 
 (N'�����-������', N'������������, �����. ������, 69, ����. 10'),
 (N'Friends', N'������������, ��. 8 �����, 46, ������� 4, �� �������, ���� 1'),
 (N'Buffalo', N'������������, ��. ������������, 139'),
 (N'Agave', N'������������, ����������� �����, �. 6'),
 (N'Balagan Bar', N'������������, ������� ��., �. 7'),
 (N'Ben Hall', N'������������, �������� ���� ��., �. 65'),
 (N'Big Ural Band', N'������������, ��������������� ��., �. 1'),
 (N'Boulevard Bar', N'������������, ��������� ��., �. 1'),
 (N'Come In', N'������������, ������ ��-��., �. 5'),
 (N'GERTZ/������� �����', N'������������, ������� �������� ��., �. 18'),
 (N'Maradona Karaoke Club&Restaurant', N'������������, ������ ��., �. 95'),
 (N'Prana bar', N'������������, ���������, �. 44'),
 (N'PRO VINO', N'������������, �������, �. 16'),
 (N'Red and Black', N'������������, ���� ���������� ��., �. 8, ����. 10'),
 (N'Royal Pub & Restaurant', N'������������, ������ ��., �. 51, ����. �')

INSERT INTO [KB301_Mustafina].Mustafina.storage
 (Name_product, Quantity, Price)
 VALUES 
 (N'�������� "��������"', 120, 53.5),
 (N'C����� � ����������� �������', 100, 26),
 (N'������ �� ��������� ��������', 243, 15),
 (N'�������� "������"', 78, 89),
 (N'����������', 500, 35),
 (N'�����', 420, 121),
 (N'������� ������������', 220, 100),
 (N'������', 360, 150),
 (N'���� "����������� �� ���������"', 80, 780),
 (N'���� "������� ��������"', 140, 560),
 (N'���� "������"', 58, 990),
 (N'�������� "����������"', 0, 135),
 (N'���� "���������"', 90, 1240),
 (N'���� "������"', 75, 800),
 (N'���� "������� ������"', 40, 1000),
 (N'���� "����� ����"', 50, 888),
 (N'��������', 170, 200),
 (N'����-����� "�������"', 98, 650),
 (N'����-���� "�������� ���������"', 210, 700),
 (N'���� "�������"', 400, 400),
 (N'����� ���������', 230, 860), 
 (N'���� "�����"', 300, 910)

 --CREATE VIEW storage_view AS
SELECT * FROM [KB301_Mustafina].Mustafina.storage
 --GO 


INSERT INTO [KB301_Mustafina].Mustafina.deliveries VALUES ('25.06.2019', 1, 3, 150, '01.07.2019')
INSERT INTO [KB301_Mustafina].Mustafina.deliveries VALUES ('25.06.2019', 1, 15, 20, '02.07.2019')
INSERT INTO [KB301_Mustafina].Mustafina.deliveries VALUES ('25.06.2019', 2, 3, 70, '01.07.2019')
INSERT INTO [KB301_Mustafina].Mustafina.deliveries VALUES ('03.07.2019', 2, 21, 150, '05.07.2019')
INSERT INTO [KB301_Mustafina].Mustafina.deliveries VALUES ('03.07.2019', 4, 8, 250, '05.07.2019')
INSERT INTO [KB301_Mustafina].Mustafina.deliveries VALUES ('03.07.2019', 4, 2, 20, '05.07.2019')
INSERT INTO [KB301_Mustafina].Mustafina.deliveries VALUES ('30.06.2019', 5, 1, 40, '30.06.2019')
INSERT INTO [KB301_Mustafina].Mustafina.deliveries VALUES ('09.11.2019', 6, 7, 20, '13.11.2019')
INSERT INTO [KB301_Mustafina].Mustafina.deliveries VALUES ('08.11.2019', 7, 7, 200, '13.11.2019')
INSERT INTO [KB301_Mustafina].Mustafina.deliveries VALUES ('01.07.2019', 8, 2, 50, '03.07.2019')
INSERT INTO [KB301_Mustafina].Mustafina.deliveries VALUES ('29.06.2019', 8, 1, 80, '30.06.2019')
INSERT INTO [KB301_Mustafina].Mustafina.deliveries VALUES ('28.06.2019', 9, 9, 60, '02.07.2019')
INSERT INTO [KB301_Mustafina].Mustafina.deliveries VALUES ('30.06.2019', 10, 19, 140, '05.07.2019')
INSERT INTO [KB301_Mustafina].Mustafina.deliveries VALUES ('01.11.2019', 10, 10, 130, '13.11.2019')
INSERT INTO [KB301_Mustafina].Mustafina.deliveries VALUES ('25.06.2019', 11, 4, 50, '30.06.2019')
INSERT INTO [KB301_Mustafina].Mustafina.deliveries VALUES ('10.11.2019', 11, 5, 300, '13.11.2019')
INSERT INTO [KB301_Mustafina].Mustafina.deliveries VALUES ('25.06.2019', 12, 17, 170, '30.06.2019')
INSERT INTO [KB301_Mustafina].Mustafina.deliveries VALUES ('10.11.2019', 13, 20, 300, '13.11.2019')
INSERT INTO [KB301_Mustafina].Mustafina.deliveries VALUES ('10.11.2019', 14, 20, 99, '13.11.2019')
INSERT INTO [KB301_Mustafina].Mustafina.deliveries VALUES ('28.06.2019', 15, 22, 120, '07.07.2019')


/*
INSERT INTO [KB301_Mustafina].Mustafina.deliveries VALUES ('25.06.2019', 15, 17, 1, '30.06.2019')
INSERT INTO [KB301_Mustafina].Mustafina.deliveries VALUES ('25.06.2019', 9, 3, 30, '27.06.2019')
INSERT INTO [KB301_Mustafina].Mustafina.deliveries VALUES ('25.06.2019', 1, 11, 100, '01.07.2019')
INSERT INTO [KB301_Mustafina].Mustafina.deliveries VALUES ('30.06.2019', 10, 18, 100, '05.07.2019')
INSERT INTO [KB301_Mustafina].Mustafina.deliveries VALUES ('03.07.2019', 3, 16, 70, '07.06.2019')
INSERT INTO [KB301_Mustafina].Mustafina.deliveries VALUES ('30.06.2019', 7, 15, 45, '03.07.2019')
*/
INSERT INTO [KB301_Mustafina].Mustafina.discounts
 (Order_price, Percent_discount)
 VALUES 
 (N'0-2499', 5),
 (N'2500-3999', 10), 
 (N'4000-5999', 15),
 (N'6000-', 20)

--SELECT [KB301_Mustafina].Mustafina.storage.Quantity FROM [KB301_Mustafina].Mustafina.deliveries LEFT JOIN [KB301_Mustafina].Mustafina.storage ON deliveries.ID_product = storage.ID_product WHERE deliveries.ID_product = 3

--������� ���������� ���� �� ���������� ������ � ������ ������
CREATE FUNCTION getPrice (@count int, @price money)
RETURNS money
BEGIN 
	DECLARE my_cursor CURSOR
	FOR SELECT DISC.Order_price, DISC.Percent_discount FROM [KB301_Mustafina].Mustafina.discounts AS DISC
	OPEN my_cursor
	DECLARE @order_price nvarchar(22), @percent int, @result money, @from int, @to int, @res_count money
	--SET @counter = 0
	FETCH NEXT FROM my_cursor INTO @order_price, @percent
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @from = CONVERT(INT, SUBSTRING(@order_price, 1, PATINDEX('%-%', @order_price) - 1));
		SET @to = CONVERT(INT, SUBSTRING(@order_price, PATINDEX('%-%', @order_price)+1, LEN(@order_price)-PATINDEX('%-%', @order_price)));
		SET @res_count = @count * @price;
		 
		IF(@from = 6000 AND @res_count >= @from OR @res_count >= @from AND @res_count <= @to)
		BEGIN
			SET @result = @res_count * (100 - @percent) / 100;	
			BREAK;
		END
		ELSE 
		BEGIN
			SET @result = @res_count;
		END
		FETCH NEXT FROM my_cursor INTO @order_price, @percent
	END
	RETURN @result;
END;

--������ �������� ������� � �������� ����� ��� ��������, � ����������� ����� ��������� � ������ ������
SELECT Order_number as '����� ������', FORMAT(Order_date, 'D', 'ru-RU') as '���� ������', 
Name_client as '������������ �������', Address_client as '����� �������', Name_product as '������������ ��������', 
Quantity_of_product_ordered as '����������', FORMAT(Date_of_delivery, 'D', 'ru-RU') as '���� ��������', 
dbo.getPrice(Quantity_of_product_ordered, Price) as '���� � ������ ������'
FROM [KB301_Mustafina].Mustafina.clients as CL INNER JOIN 
[KB301_Mustafina].Mustafina.deliveries as DEL ON DEL.ID_client = CL.ID_client INNER JOIN 
[KB301_Mustafina].Mustafina.storage AS ST ON DEL.ID_product = ST.ID_product
WHERE DEL.ID_client = 1


--������ �������� � ������ �������� �� ������� ����
SELECT Order_number as '����� ������', FORMAT(Order_date, 'D', 'ru-RU') as '���� ������', 
Name_client as '������������ �������', Address_client as '����� �������', Name_product as '������������ ��������', 
Quantity_of_product_ordered as '����������', FORMAT(Date_of_delivery, 'D', 'ru-RU') as '���� ��������', 
dbo.getPrice(Quantity_of_product_ordered, Price) as '���� � ������ ������' FROM [KB301_Mustafina].Mustafina.deliveries as DEL INNER JOIN 
[KB301_Mustafina].Mustafina.clients as CL ON DEL.ID_client = CL.ID_client INNER JOIN 
[KB301_Mustafina].Mustafina.storage AS ST ON DEL.ID_product = ST.ID_product
--WHERE Date_of_delivery = CONVERT(date, GETDATE())
WHERE Date_of_delivery = '30.06.2019'


--������ �������, ���������� � ���������, ������������ �� ��������� ����
SELECT Name_product as '������������ ��������', SUM(Quantity_of_product_ordered) as '����������', FORMAT(Date_of_delivery, 'D', 'ru-RU') as '���� ��������', 
SUM(dbo.getPrice(Quantity_of_product_ordered, Price)) as '���� � ������ ������' 
FROM [KB301_Mustafina].Mustafina.deliveries as DEL INNER JOIN 
[KB301_Mustafina].Mustafina.clients as CL ON DEL.ID_client = CL.ID_client INNER JOIN 
[KB301_Mustafina].Mustafina.storage AS ST ON DEL.ID_product = ST.ID_product
--WHERE Date_of_delivery BETWEEN '01.07.2019'AND '03.07.2019'
WHERE Date_of_delivery BETWEEN '11.11.2019'AND '14.11.2019'
GROUP BY Name_product, Date_of_delivery
ORDER BY Date_of_delivery

--������ ��������� �� ������ �������
SELECT Name_product as '������������ ��������', Quantity as '����������', Price as '����' 
FROM [KB301_Mustafina].Mustafina.storage as storage
WHERE storage.Quantity > 0

--������ ������� � ����� ���� �������
SELECT STORAGE.Name_product as '������������ ������', STORAGE.Price as '����' FROM [KB301_Mustafina].Mustafina.storage as STORAGE
WHERE STORAGE.Price > (SELECT AVG(ST.Price) FROM [KB301_Mustafina].Mustafina.storage as ST)
