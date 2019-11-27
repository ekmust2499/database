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

IF OBJECT_ID(N'wallet', 'U') IS NOT NULL
  DROP TABLE [KB301_Mustafina].Mustafina.wallet

CREATE TABLE [KB301_Mustafina].Mustafina.wallet
(
	ID_wallet tinyint NOT NULL,
    CONSTRAINT PK_ID_wallet PRIMARY KEY (ID_wallet)
)
GO


IF OBJECT_ID(N'currency', 'U') IS NOT NULL
  DROP TABLE [KB301_Mustafina].Mustafina.currency

CREATE TABLE [KB301_Mustafina].Mustafina.currency
(
	ID_currency tinyint NOT NULL,
	Currency nvarchar(3) NOT NULL,
    CONSTRAINT PK_ID_currency PRIMARY KEY (ID_currency)
)
GO

IF OBJECT_ID(N'content', 'U') IS NOT NULL
  DROP TABLE [KB301_Mustafina].Mustafina.content

CREATE TABLE [KB301_Mustafina].Mustafina.content
(
	ID int IDENTITY NOT NULL,
	ID_wallet tinyint NOT NULL,
	ID_currency tinyint NOT NULL,
	Quantity float NOT NULL,
    CONSTRAINT PK_ID_content PRIMARY KEY (ID), 
	CONSTRAINT FK_ID_wallet FOREIGN KEY(ID_wallet) REFERENCES [KB301_Mustafina].Mustafina.wallet(ID_wallet),
	CONSTRAINT FK_ID_currency FOREIGN KEY(ID_currency) REFERENCES [KB301_Mustafina].Mustafina.currency(ID_currency)
)
GO

IF OBJECT_ID(N'exchange_rates', 'U') IS NOT NULL
  DROP TABLE [KB301_Mustafina].Mustafina.exchange_rates

CREATE TABLE [KB301_Mustafina].Mustafina.exchange_rates
(
	ID tinyint IDENTITY NOT NULL, 
	Sale tinyint NOT NULL, 
	Purchase tinyint NOT NULL,
	Course float NOT NULL,
    CONSTRAINT PK_ID_post PRIMARY KEY (ID),
	CONSTRAINT FK_sale FOREIGN KEY(Sale) REFERENCES [KB301_Mustafina].Mustafina.currency(ID_currency),
	CONSTRAINT FK_purchase FOREIGN KEY(Purchase) REFERENCES [KB301_Mustafina].Mustafina.currency(ID_currency),
	CONSTRAINT currencies UNIQUE (Sale, Purchase)
)
GO

INSERT INTO [KB301_Mustafina].Mustafina.wallet 
 (ID_wallet) VALUES 
  (1)
 ,(2)
 ,(3)
GO

INSERT INTO [KB301_Mustafina].Mustafina.currency
 (ID_currency, Currency) VALUES 
  (1, N'USD')
 ,(2, N'GBP')
 --,(3, N'JPY')
 ,(4, N'CHF')
 ,(5, N'CAD')
 ,(6, N'DKK')
 ,(7, N'SEC')
 ,(8, N'EUR')
 ,(9, N'AUD')
 ,(10, N'NZD')	
GO

INSERT INTO [KB301_Mustafina].Mustafina.content 
 (ID_wallet, ID_currency, Quantity) VALUES
 (1, 1, 150),
 --(1, 3, 270),
 (1, 10, 87.5),
 (2, 4, 140),
 (2, 1, 46.35),
 (2, 2, 222.22),
 --(2, 3, 568.1),
 (3, 1, 139.9),
 (3, 7, 85),
 (3, 4, 980),
 (3, 5, 601.7),
 --(3, 3, 333.33),
 (1, 2, 1212.12)


INSERT INTO [KB301_Mustafina].Mustafina.exchange_rates
 (Sale, Purchase, Course) VALUES
  (1, 1, 1)		
 ,(1, 2, 0.623)
 --,(1, 3, 78.065)
 ,(1, 4, 0.9011)
 ,(1, 5, 1.0134)
 ,(1, 6, 5.4064)
 ,(1, 7, 6.562)
 ,(1, 8, 0.7263)
 ,(1, 9, 0.9639)
 ,(1, 10, 1.2549)
 ,(2, 1, 1.6052)		
 ,(2, 2, 1)
 --,(2, 3, 125.31)
 ,(2, 4, 1.4467)
 ,(2, 5, 1.6268)
 ,(2, 6, 8.6788)
 ,(2, 7, 10.5285)
 ,(2, 8, 1.1658)
 ,(2, 9, 1.5473)
 ,(2, 10, 2.0144)
 --,(3, 1, 0.0128)		
 --,(3, 2, 0.008)
 --,(3, 3, 1)
 --,(3, 4, 0.0115)
 --,(3, 5, 0.013)
 --,(3, 6, 0.0692)
 --,(3, 7, 8.4)
 --,(3, 8, 0.0093)
 --,(3, 9, 0.0123)
 --,(3, 10, 0.0161)
 ,(4, 1, 1.1098)		
 ,(4, 2, 0.6912)
 --,(4, 3, 86.6275)
 ,(4, 4, 1)
 ,(4, 5, 1.1246)
 ,(4, 6, 0.06)
 ,(4, 7, 7.2825)
 ,(4, 8, 0.8059)
 ,(4, 9, 1.0696)
 ,(4, 10, 1.3924)
 ,(5, 1, 0.9868)		
 ,(5, 2, 0.6147)
 --,(5, 3, 77.0345)
 ,(5, 4, 0.8892)
 ,(5, 5, 1)
 ,(5, 6, 5.335)
 ,(5, 7, 6.4754)
 ,(5, 8, 0.7166)
 ,(5, 9, 0.9512)
 ,(5, 10, 1.2383)
 ,(6, 1, 0.185)		
 ,(6, 2, 0.1152)
 --,(6, 3, 14.442)
 ,(6, 4, 16.6)
 ,(6, 5, 0.1874)
 ,(6, 6, 1)
 ,(6, 7, 1.2137)
 ,(6, 8, 0.1343)
 ,(6, 9, 0.1783)
 ,(6, 10, 0.2322)
 ,(7, 1, 0.1524)		
 ,(7, 2, 0.095)
 --,(7, 3, 0.119)
 ,(7, 4, 0.1373)
 ,(7, 5, 0.1544)
 ,(7, 6, 0.8239)
 ,(7, 7, 1)
 ,(7, 8, 0.1107)
 ,(7, 9, 0.1469)
 ,(7, 10, 0.1912)
 ,(8, 1, 1.3769)		
 ,(8, 2, 0.8578)
 --,(8, 3, 107.495)
 ,(8, 4, 1.2409)
 ,(8, 5, 1.3954)
 ,(8, 6, 7.4443)
 ,(8, 7, 9.0357)
 ,(8, 8, 1)
 ,(8, 9, 1.3273)
 ,(8, 10, 1.7279)
 ,(9, 1, 1.0374)		
 ,(9, 2, 0.6463)
 --,(9, 3, 80.979)
 ,(9, 4, 0.9349)
 ,(9, 5, 1.0513)
 ,(9, 6, 5.6086)
 ,(9, 7, 6.8074)
 ,(9, 8, 0.7534)
 ,(9, 9, 1)
 ,(9, 10, 1.3018)
 ,(10, 1, 0.7969)		
 ,(10, 2, 0.4964)
 --,(10, 3, 62.1118)
 ,(10, 4, 0.7182)
 ,(10, 5, 0.8076)
 ,(10, 6, 4.3066)
 ,(10, 7, 5.2293)
 ,(10, 8, 0.5787)
 ,(10, 9, 0.7682)
 ,(10, 10, 1)
GO
--Ошибка: такой уникальный ключ уже существует в таблице
/*
INSERT INTO [KB301_Mustafina].Mustafina.exchange_rates VALUES (1, 1, 2) 
GO
*/


--Процедура добавления денег в кошелёк к такой же валюте
CREATE PROCEDURE add_money
		@wallet tinyint,
		@currency tinyint,
		@quantity float
AS
DECLARE @count int
BEGIN
	SET @count = (SELECT COUNT(*) FROM [KB301_Mustafina].Mustafina.content WHERE ID_wallet = @wallet AND ID_currency = @currency)
	IF (@count = 0)
	BEGIN
		INSERT INTO [KB301_Mustafina].Mustafina.content(ID_wallet, ID_currency, Quantity) VALUES(@wallet, @currency, 0)
	END
	UPDATE [KB301_Mustafina].Mustafina.content 
	SET Quantity = Quantity + @quantity WHERE ID_wallet = @wallet AND ID_currency = @currency
	SELECT * from dbo.wallet_view as W 
	ORDER BY Кошелёк, Валюта
END
GO


--Процедура выемки валюты из кошелька (точно такой же)
CREATE PROCEDURE take_money
		@wallet tinyint,
		@currency tinyint,
		@quantity float
AS
DECLARE @count int
DECLARE @quantity_in_wallet float
BEGIN

	IF NOT EXISTS (SELECT * FROM [KB301_Mustafina].Mustafina.content WHERE ID_wallet = @wallet)
	BEGIN
		RAISERROR('Нет такого кошелька!', 5, 1)
		RETURN
	END
	IF NOT EXISTS (SELECT * FROM [KB301_Mustafina].Mustafina.content WHERE ID_currency = @currency)
	BEGIN
		RAISERROR('Нет такой валюты в кошельке!', 5, 1)
		RETURN
	END
	SET @quantity_in_wallet = (SELECT Quantity FROM [KB301_Mustafina].Mustafina.content WHERE ID_wallet = @wallet AND ID_currency = @currency)
	IF (@quantity_in_wallet >= @quantity)
	BEGIN
		UPDATE [KB301_Mustafina].Mustafina.content 
		SET Quantity = @quantity_in_wallet - @quantity WHERE ID_wallet = @wallet AND ID_currency = @currency
	END
	ELSE
	BEGIN
		RAISERROR('В кошельке недостаточно средств для выемки!', 5, 1)
		RETURN
	END
	SELECT * from dbo.wallet_view as W 
	ORDER BY Кошелёк, Валюта
END
GO


--Процедура выемки денег в кошельке валют всех видов. На вход подается валюта и количество, от всех валют в кошельке отнимается переданная валюта с учётом курса
CREATE PROCEDURE take_money_in_each_currency
		@wallet tinyint,
		@currency tinyint,
		@quantity float
AS
BEGIN
DECLARE @result float, @current_currency tinyint, @current_quantity float, @course float, @multiplicity int
DECLARE @cursor CURSOR
	SET @result=0
	SET @multiplicity = 100
	IF NOT EXISTS (SELECT * FROM [KB301_Mustafina].Mustafina.content WHERE ID_wallet = @wallet)
	BEGIN
		RAISERROR('Нет такого кошелька!', 5, 1)
		RETURN
	END
	SET @cursor =  CURSOR SCROLL FOR SELECT ID_currency, Quantity FROM [KB301_Mustafina].Mustafina.content WHERE ID_wallet=@wallet
	OPEN @cursor
	FETCH NEXT FROM @cursor INTO @current_currency, @current_quantity
	WHILE @@FETCH_STATUS = 0
	BEGIN
		BEGIN
			IF NOT EXISTS (SELECT Course FROM [KB301_Mustafina].Mustafina.exchange_rates WHERE Sale=@currency AND Purchase=@current_currency)
			BEGIN
				RETURN
			END
			SET @course = (SELECT Course FROM [KB301_Mustafina].Mustafina.exchange_rates WHERE Sale=@currency AND Purchase=@current_currency)
		END
		SET @result = (@course*@quantity) 
		IF (@current_quantity >= @result)
		BEGIN
			UPDATE [KB301_Mustafina].Mustafina.content SET Quantity = @current_quantity - @result WHERE ID_wallet = @wallet AND ID_currency = @current_currency
		END
		ELSE
		BEGIN
			RAISERROR('В кошельке недостаточно средств для выемки!', 5, 1)
			RETURN
		END
		FETCH NEXT FROM @cursor INTO @current_currency, @current_quantity
	END
	CLOSE @cursor
	DEALLOCATE @cursor
	SELECT * from dbo.wallet_view as W 
	WHERE Кошелёк = @wallet
	ORDER BY Валюта
	RETURN
END
GO

--Показать таблицу с валютами
CREATE PROCEDURE show_table
AS
BEGIN
DECLARE @one_currency nvarchar(3)
DECLARE @two_currency nvarchar(3)
DECLARE @course float
DECLARE @one_cursor CURSOR
DECLARE @two_cursor CURSOR
DECLARE @sql nvarchar(400)
	SET NOCOUNT ON
	CREATE TABLE #result_table(Валюта nvarchar(20) PRIMARY KEY)
	SET @one_cursor = CURSOR SCROLL FOR SELECT Currency FROM [KB301_Mustafina].Mustafina.currency ORDER BY Currency
	OPEN @one_cursor
	FETCH NEXT FROM @one_cursor INTO @one_currency
	WHILE @@FETCH_STATUS = 0
	BEGIN
		EXEC ('ALTER TABLE #result_table ADD ['+@one_currency+'] float NULL')
		INSERT INTO #result_table(Валюта) VALUES(@one_currency)
		FETCH NEXT FROM @one_cursor INTO @one_currency
	END
	CLOSE @one_cursor
	SET @two_cursor = CURSOR SCROLL FOR SELECT Currency FROM [KB301_Mustafina].Mustafina.currency
	OPEN @one_cursor
	FETCH NEXT FROM @one_cursor INTO @one_currency
	WHILE @@FETCH_STATUS = 0
	BEGIN
		OPEN @two_cursor
		FETCH NEXT FROM @two_cursor INTO @two_currency
		WHILE @@FETCH_STATUS = 0
		BEGIN
			SET @course = (SELECT Course FROM [KB301_Mustafina].Mustafina.exchange_rates LEFT JOIN
			[KB301_Mustafina].Mustafina.currency AS ONE ON Sale = ONE.ID_currency LEFT JOIN
			[KB301_Mustafina].Mustafina.currency AS TWO ON Purchase = TWO.ID_currency
									 WHERE ONE.Currency=@one_currency AND TWO.Currency=@two_currency)
			SET @sql = ('UPDATE #result_table SET '+@two_currency+'='+CAST(CAST(@course AS float) AS varchar(10))+' WHERE Валюта='''+@one_currency+'''')
			EXEC (@sql)
			FETCH NEXT FROM @two_cursor INTO @two_currency
		END
		CLOSE @two_cursor
		FETCH NEXT FROM @one_cursor INTO @one_currency
	END
	SELECT * FROM #result_table
	CLOSE @one_cursor
	DEALLOCATE @one_cursor
	SET NOCOUNT OFF
	RETURN
END
GO


--Получить сумму всех денег в одной валюте в кошельке
CREATE FUNCTION get_money_in_wallet(@wallet tinyint, @currency tinyint)
RETURNS float
AS
BEGIN
DECLARE @result float, @current_currency tinyint, @current_quantity float, @course float
DECLARE @cursor CURSOR
	SET @result=0
	IF NOT EXISTS (SELECT * FROM [KB301_Mustafina].Mustafina.content WHERE ID_wallet = @wallet)
	BEGIN
		RETURN 0
		
	END
	SET @cursor =  CURSOR SCROLL FOR SELECT ID_currency, Quantity FROM [KB301_Mustafina].Mustafina.content WHERE ID_wallet=@wallet
	OPEN @cursor
	FETCH NEXT FROM @cursor INTO @current_currency, @current_quantity
	WHILE @@FETCH_STATUS = 0
	BEGIN
		BEGIN
			IF NOT EXISTS (SELECT Course FROM [KB301_Mustafina].Mustafina.exchange_rates WHERE Sale=@currency AND Purchase=@current_currency)
			BEGIN
				RETURN 0
			END
			SET @course = (SELECT Course FROM [KB301_Mustafina].Mustafina.exchange_rates WHERE Sale=@currency AND Purchase=@current_currency)
		END
		SET @result = @result + (@course*@current_quantity) 
		FETCH NEXT FROM @cursor INTO @current_currency, @current_quantity
	END
	CLOSE @cursor
	DEALLOCATE @cursor
	RETURN @result
END
GO


--Представление. Сколько и какой валюты находится в кошельках
CREATE VIEW wallet_view AS
SELECT ID_wallet as 'Кошелёк', CUR.Currency as 'Валюта', Quantity as 'Количество' FROM [KB301_Mustafina].Mustafina.content AS CONT 
LEFT JOIN [KB301_Mustafina].Mustafina.currency as CUR
ON CONT.ID_currency = CUR.ID_currency
GO

SELECT * FROM dbo.wallet_view
WHERE Кошелёк=1

--Добавление валюты в кошелек
EXEC add_money 1, 1, 10
EXEC add_money 2, 1, 85
EXEC add_money 1, 5, 76.8


--Выемка валюты из кошелька
EXEC take_money 1, 1, 200
EXEC take_money 4, 9, 2
EXEC take_money 3, 8, 70
EXEC take_money 3, 7, 100

EXEC take_money_in_each_currency 1, 1, 1
EXEC take_money_in_each_currency 2, 1, 2


--Определение суммы всех денег в кошельке, выраженной в определенной валюте
SELECT DISTINCT ID_wallet as 'Кошелёк', CUR.Currency as 'Валюта', dbo.get_money_in_wallet(ID_wallet, CUR.ID_currency) as 'Сумма' FROM
[KB301_Mustafina].Mustafina.content AS CONT 
LEFT JOIN [KB301_Mustafina].Mustafina.currency as CUR
ON CONT.ID_currency = CUR.ID_currency
WHERE ID_wallet = 1 AND CUR.ID_currency = 2

--Таблица валют
EXEC show_table
