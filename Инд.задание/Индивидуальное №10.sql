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
Создание таблиц и определение первичных ключей
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


--Триггер для проверки того, что есть ли на складе заказанное количество продукта
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
		RAISERROR(N'Заказанного количество продукта нет на складе!', 5, 1)
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
 (N'Хмели-Сунели', N'Екатеринбург, просп. Ленина, 69, корп. 10'),
 (N'Friends', N'Екатеринбург, ул. 8 Марта, 46, очередь 4, ТЦ Гринвич, этаж 1'),
 (N'Buffalo', N'Екатеринбург, ул. Луначарского, 139'),
 (N'Agave', N'Екатеринбург, Центральный рынок, д. 6'),
 (N'Balagan Bar', N'Екатеринбург, Пушкина ул., д. 7'),
 (N'Ben Hall', N'Екатеринбург, Народной воли ул., д. 65'),
 (N'Big Ural Band', N'Екатеринбург, Красноармейская ул., д. 1'),
 (N'Boulevard Bar', N'Екатеринбург, Воеводина ул., д. 1'),
 (N'Come In', N'Екатеринбург, Ленина пр-кт., д. 5'),
 (N'GERTZ/Подруга друга', N'Екатеринбург, Николая Никонова ул., д. 18'),
 (N'Maradona Karaoke Club&Restaurant', N'Екатеринбург, Репина ул., д. 95'),
 (N'Prana bar', N'Екатеринбург, Куйбышева, д. 44'),
 (N'PRO VINO', N'Екатеринбург, Пушкина, д. 16'),
 (N'Red and Black', N'Екатеринбург, Розы Люксембург ул., д. 8, корп. 10'),
 (N'Royal Pub & Restaurant', N'Екатеринбург, Победы ул., д. 51, корп. а')

INSERT INTO [KB301_Mustafina].Mustafina.storage
 (Name_product, Quantity, Price)
 VALUES 
 (N'Пирожное "Картошка"', 120, 53.5),
 (N'Cлойка с карамельной крошкой', 100, 26),
 (N'Бантик со сливочной начинкой', 243, 15),
 (N'Пирожное "Варюша"', 78, 89),
 (N'Профитроли', 500, 35),
 (N'Эклер', 420, 121),
 (N'Трюфель классический', 220, 100),
 (N'Брауни', 360, 150),
 (N'Торт "Швейцарский со сгущёнкой"', 80, 780),
 (N'Торт "Сладкая симфония"', 140, 560),
 (N'Торт "Элегия"', 58, 990),
 (N'Пирожное "Муравейник"', 0, 135),
 (N'Торт "Карамелье"', 90, 1240),
 (N'Торт "Шаганэ"', 75, 800),
 (N'Торт "Красный бархат"', 40, 1000),
 (N'Торт "Белые ночи"', 50, 888),
 (N'Тирамису', 170, 200),
 (N'Торт-суфле "Пломбир"', 98, 650),
 (N'Торт-безе "Графские развалины"', 210, 700),
 (N'Торт "Медовый"', 400, 400),
 (N'Захер фирменный', 230, 860), 
 (N'Торт "Прага"', 300, 910)

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

--Функция возвращает цену за количество товара с учётом скидки
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

--Список поставок клиенту с запросом имени или названия, с вычисляемым полем стоимость и учетом скидки
SELECT Order_number as 'Номер заказа', FORMAT(Order_date, 'D', 'ru-RU') as 'Дата заказа', 
Name_client as 'Наименование клиента', Address_client as 'Адрес клиента', Name_product as 'Наименование продукта', 
Quantity_of_product_ordered as 'Количество', FORMAT(Date_of_delivery, 'D', 'ru-RU') as 'Дата поставки', 
dbo.getPrice(Quantity_of_product_ordered, Price) as 'Цена с учётом скидки'
FROM [KB301_Mustafina].Mustafina.clients as CL INNER JOIN 
[KB301_Mustafina].Mustafina.deliveries as DEL ON DEL.ID_client = CL.ID_client INNER JOIN 
[KB301_Mustafina].Mustafina.storage AS ST ON DEL.ID_product = ST.ID_product
WHERE DEL.ID_client = 1


--Список поставок и адреса клиентов за текущий день
SELECT Order_number as 'Номер заказа', FORMAT(Order_date, 'D', 'ru-RU') as 'Дата заказа', 
Name_client as 'Наименование клиента', Address_client as 'Адрес клиента', Name_product as 'Наименование продукта', 
Quantity_of_product_ordered as 'Количество', FORMAT(Date_of_delivery, 'D', 'ru-RU') as 'Дата поставки', 
dbo.getPrice(Quantity_of_product_ordered, Price) as 'Цена с учётом скидки' FROM [KB301_Mustafina].Mustafina.deliveries as DEL INNER JOIN 
[KB301_Mustafina].Mustafina.clients as CL ON DEL.ID_client = CL.ID_client INNER JOIN 
[KB301_Mustafina].Mustafina.storage AS ST ON DEL.ID_product = ST.ID_product
--WHERE Date_of_delivery = CONVERT(date, GETDATE())
WHERE Date_of_delivery = '30.06.2019'


--Список товаров, количество и стоимость, отправленных за указанный срок
SELECT Name_product as 'Наименование продукта', SUM(Quantity_of_product_ordered) as 'Количество', FORMAT(Date_of_delivery, 'D', 'ru-RU') as 'Дата поставки', 
SUM(dbo.getPrice(Quantity_of_product_ordered, Price)) as 'Цена с учётом скидки' 
FROM [KB301_Mustafina].Mustafina.deliveries as DEL INNER JOIN 
[KB301_Mustafina].Mustafina.clients as CL ON DEL.ID_client = CL.ID_client INNER JOIN 
[KB301_Mustafina].Mustafina.storage AS ST ON DEL.ID_product = ST.ID_product
--WHERE Date_of_delivery BETWEEN '01.07.2019'AND '03.07.2019'
WHERE Date_of_delivery BETWEEN '11.11.2019'AND '14.11.2019'
GROUP BY Name_product, Date_of_delivery
ORDER BY Date_of_delivery

--Список имеющихся на складе товаров
SELECT Name_product as 'Наименование продукта', Quantity as 'Количество', Price as 'Цена' 
FROM [KB301_Mustafina].Mustafina.storage as storage
WHERE storage.Quantity > 0

--Список товаров с ценой выше средней
SELECT STORAGE.Name_product as 'Наименование товара', STORAGE.Price as 'Цена' FROM [KB301_Mustafina].Mustafina.storage as STORAGE
WHERE STORAGE.Price > (SELECT AVG(ST.Price) FROM [KB301_Mustafina].Mustafina.storage as ST)
