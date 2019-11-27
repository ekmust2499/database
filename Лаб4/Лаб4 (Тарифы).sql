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

IF OBJECT_ID(N'tariff', 'U') IS NOT NULL
  DROP TABLE [KB301_Mustafina].Mustafina.tariff

CREATE TABLE [KB301_Mustafina].Mustafina.tariff
(
	ID_tariff tinyint IDENTITY NOT NULL,
	Name_of_tariff nvarchar(40) NOT NULL,
	Subscription_fee money NOT NULL, 
	Number_of_minutes float NOT NULL,
	Cost_per_minute money NOT NULL
    CONSTRAINT PK_ID_tariff PRIMARY KEY (ID_tariff)
)
GO


INSERT INTO [KB301_Mustafina].Mustafina.tariff VALUES
(N'Без абонентской платы', 0, 0, 2),
(N'Безлимитный', 600, 43200, 0),
(N'Смешанный', 200, 14400, 1)
GO


--Функция определяет наиболее выгодный тариф по заданному количеству минут
CREATE FUNCTION determine_best_tariff(@minutes_IN float)
RETURNS nvarchar(70)
AS
BEGIN
DECLARE @name nvarchar(70), @fee money, @minutes float, @cost money
DECLARE @result nvarchar(70), @current float, @last float
DECLARE @cursor CURSOR
	SET @cursor =  CURSOR SCROLL FOR SELECT Name_of_tariff, Subscription_fee, Number_of_minutes, Cost_per_minute FROM [KB301_Mustafina].Mustafina.tariff
	SET @last = 0
	SET @current = 0
	OPEN @cursor
	FETCH NEXT FROM @cursor INTO @name, @fee, @minutes, @cost
	WHILE @@FETCH_STATUS = 0
	BEGIN
		BEGIN
			IF @minutes_IN < 0
			BEGIN
				RETURN N'Введено отрицательное количество минут!'
			END
			IF @minutes_IN > 43200
			BEGIN
				RETURN N'Входное количество минут превышает количества минут в месяце!'
			END
			--Количество минут вмещаются в количество минут абонентской платы
			IF @minutes_IN <= @minutes 
			BEGIN
				SET @current = @fee		
			END
			ELSE
			BEGIN
				SET @current = @fee + (@minutes_IN - @minutes) * @cost
			END

			IF @last = 0 OR @current < @last
			BEGIN 
				SET @last = @current
				SET @result = @name
			END
		END
		FETCH NEXT FROM @cursor INTO @name, @fee, @minutes, @cost
	END
	CLOSE @cursor
	DEALLOCATE @cursor
	RETURN @result
END
GO

PRINT dbo.determine_best_tariff(33)
PRINT dbo.determine_best_tariff(100)
PRINT dbo.determine_best_tariff(101)
PRINT dbo.determine_best_tariff(14799)
PRINT dbo.determine_best_tariff(14800)
PRINT dbo.determine_best_tariff(30000)

PRINT dbo.determine_best_tariff(-22)
PRINT dbo.determine_best_tariff(43201)


CREATE PROCEDURE tariff_for_segment
AS
BEGIN
	DECLARE @max int
	CREATE TABLE #table (Point float)
	INSERT INTO #table VALUES 
	 (0)
	,(43200)
	INSERT INTO #table SELECT MAX(Number_of_minutes) FROM [KB301_Mustafina].Mustafina.tariff
	SET @max = 43200
	--пересечение безлимита с без абонентской платы
	INSERT INTO #table 
				SELECT (A.Subscription_fee-B.Subscription_fee)/B.Cost_per_minute
				FROM [KB301_Mustafina].Mustafina.tariff as A, [KB301_Mustafina].Mustafina.tariff as B
				WHERE A.ID_tariff<>B.ID_tariff AND B.Cost_per_minute <> 0 AND (A.Subscription_fee-B.Subscription_fee)/B.Cost_per_minute > 0
	--пересечение смешанного с остальными
	INSERT INTO #table 
				SELECT (A.Subscription_fee-B.Subscription_fee)/B.Cost_per_minute + B.Number_of_minutes
				FROM [KB301_Mustafina].Mustafina.tariff as A, [KB301_Mustafina].Mustafina.tariff as B
				WHERE A.ID_tariff<>B.ID_tariff AND B.Cost_per_minute <> 0 AND (A.Subscription_fee-B.Subscription_fee)/B.Cost_per_minute > 0
	INSERT INTO #table
				SELECT (B.Subscription_fee - A.Subscription_fee - B.Number_of_minutes*B.Cost_per_minute + A.Number_of_minutes*A.Cost_per_minute)/(A.Cost_per_minute - B.Cost_per_minute)
				FROM [KB301_Mustafina].Mustafina.tariff as A, [KB301_Mustafina].Mustafina.tariff as B
				WHERE A.ID_tariff<>B.ID_tariff AND (B.Number_of_minutes - A.Number_of_minutes) > 0 AND (A.Cost_per_minute - B.Cost_per_minute) <> 0 AND
				(B.Subscription_fee - A.Subscription_fee - B.Number_of_minutes*B.Cost_per_minute + A.Number_of_minutes*A.Cost_per_minute)/(A.Cost_per_minute - B.Cost_per_minute) > 0
	--UPDATE #table SET Point=ROUND(Point,0)
	DELETE FROM #table WHERE
					Point != 0
					AND Point != @max
					AND  dbo.determine_best_tariff(Point-1) = dbo.determine_best_tariff(Point+1) 
					AND  dbo.determine_best_tariff(Point) = dbo.determine_best_tariff(Point+1) 
	CREATE TABLE #result (left_point int, right_point int, tariff nvarchar(40))
	DECLARE @cursor CURSOR, @left int, @right int
	SET @cursor = CURSOR SCROLL FOR
				 SELECT DISTINCT * FROM #table ORDER BY Point ASC
	OPEN @cursor
	FETCH NEXT FROM @cursor INTO @left
	FETCH NEXT FROM @cursor INTO @right
	WHILE @@FETCH_STATUS = 0
	BEGIN
		INSERT INTO #result VALUES (@left, @right, dbo.determine_best_tariff((@left+@right)/2))
		SET @left=@right
		FETCH NEXT FROM @cursor INTO @right
	END
	SELECT CONCAT('[ ', left_point, ' ; ', right_point, ' ]') as Отрезок,		   
		   tariff as [Тариф]
		   FROM #result 
END
GO

EXEC dbo.tariff_for_segment
GO