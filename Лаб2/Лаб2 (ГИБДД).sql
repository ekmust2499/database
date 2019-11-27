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

IF OBJECT_ID(N'cars', 'U') IS NOT NULL
  DROP TABLE [KB301_Mustafina].Mustafina.cars

CREATE TABLE [KB301_Mustafina].Mustafina.cars
(
	ID_car tinyint IDENTITY NOT NULL, 
	Make nvarchar(20) NOT NULL,
	Model nvarchar(50) NOT NULL, 
	Color nvarchar(20) NOT NULL, 
	Year_of_issue int NOT NULL,
	State_number nvarchar(9) NOT NULL, 
	Region_code int NOT NULL, 
	Driver_name nvarchar(50) NOT NULL,
    CONSTRAINT PK_ID_car PRIMARY KEY (ID_car),
	CONSTRAINT check_Region_code CHECK (0<Region_code AND Region_code<200 OR 699<Region_code AND Region_code<800),
	CONSTRAINT check_State_number CHECK (State_number NOT LIKE N'[АВЕКМНОРСТУХавекмнорстух]000[АВЕКМНОРСТУХавекмнорстух][АВЕКМНОРСТУХавекмнорстух]' 
	AND State_number LIKE N'[АВЕКМНОРСТУХавекмнорстух][0123456789][0123456789][0123456789][АВЕКМНОРСТУХавекмнорстух][АВЕКМНОРСТУХавекмнорстух]')

)
GO

/*
--Создание триггера для валидности гос.номеров

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE Name = 'trigger_check_state_number' AND type = 'TR') 
	DROP TRIGGER Mustafina.trigger_check_state_number
GO

CREATE TRIGGER Mustafina.trigger_check_state_number 
	ON [KB301_Mustafina].Mustafina.cars
	INSTEAD OF INSERT
AS 
DECLARE @is_wrong int
BEGIN
	SET @is_wrong = (SELECT COUNT(1) FROM inserted
					  WHERE  State_number LIKE N'[АВЕКМНОРСТУХавекмнорстух]000[АВЕКМНОРСТУХавекмнорстух][АВЕКМНОРСТУХавекмнорстух]' OR
					  State_number NOT LIKE N'[АВЕКМНОРСТУХавекмнорстух][0123456789][0123456789][0123456789][АВЕКМНОРСТУХавекмнорстух][АВЕКМНОРСТУХавекмнорстух]')
	if (@is_wrong != 0) 
	BEGIN
		RAISERROR(N'Неверный формат регистрационного номерного знака!', 5, 1)
		ROLLBACK
	END
	ELSE
	BEGIN
		INSERT INTO [KB301_Mustafina].Mustafina.cars (Make, Model, Color, Year_of_issue, State_number, Region_code, Driver_name) SELECT Make, Model, Color, Year_of_issue, State_number, Region_code, Driver_name FROM inserted
	END
END
GO
*/


IF OBJECT_ID(N'posts', 'U') IS NOT NULL
  DROP TABLE [KB301_Mustafina].Mustafina.posts

CREATE TABLE [KB301_Mustafina].Mustafina.posts
(
	ID_post tinyint IDENTITY NOT NULL, 
	Region int NOT NULL, 
    CONSTRAINT PK_ID_post PRIMARY KEY (ID_post),
	CONSTRAINT check_Region CHECK (0<Region AND Region<200 OR 699<Region AND Region<800),
)
GO

IF OBJECT_ID(N'passages', 'U') IS NOT NULL
  DROP TABLE [KB301_Mustafina].Mustafina.passages

--entry 1, exit 0
CREATE TABLE [KB301_Mustafina].Mustafina.passages
(
	ID_post tinyint NOT NULL, 
	ID_car tinyint NOT NULL,
	Passage_time time NOT NULL,
	Entry_or_exit bit NOT NULL	
	CONSTRAINT PK_ID_passage PRIMARY KEY (ID_car, Passage_time) 
)
GO


--Создание триггера для въезда-выезда

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE Name = 'trigger_check_passage' AND type = 'TR') 
	DROP TRIGGER Mustafina.trigger_check_passage
GO

CREATE TRIGGER Mustafina.trigger_check_passage
	ON [KB301_Mustafina].Mustafina.passages
	INSTEAD OF INSERT
AS 
DECLARE @count int, @sum int, @bit int, @insert int, @passage int, @insert_time time, @passage_time time
BEGIN
	SET @insert = (SELECT Entry_or_exit FROM inserted)
	SET @passage = (SELECT TOP 1 passages.Entry_or_exit FROM passages, inserted WHERE inserted.ID_car = passages.ID_car ORDER BY passages.Passage_time DESC)
	SET @insert_time = (SELECT Passage_time FROM inserted)
	SET @passage_time = (SELECT TOP 1 passages.Passage_time FROM passages, inserted WHERE inserted.ID_car = passages.ID_car ORDER BY passages.Passage_time DESC)
	if(ISNULL(@passage, 2) = 2 OR @insert != @passage AND DATEADD(minute, 5, @insert_time)>= ISNULL(@passage_time, '00:00'))
	BEGIN
		INSERT INTO [KB301_Mustafina].Mustafina.passages(ID_post, ID_car, Passage_time, Entry_or_exit) SELECT ID_post, ID_car, Passage_time, Entry_or_exit FROM inserted
	END
	ELSE
	BEGIN
	    SELECT @passage as 'passage', @insert as 'insert', @insert_time as 'ins_time', @passage_time as 'pass_time'
		SELECT * from [KB301_Mustafina].Mustafina.passages
		RAISERROR(N'Неправильное направление движение автомобиля!', 5, 1)
		ROLLBACK
	END
END
GO


IF OBJECT_ID(N'regions', 'U') IS NOT NULL
  DROP TABLE [KB301_Mustafina].Mustafina.regions

CREATE TABLE [KB301_Mustafina].Mustafina.regions
(
	ID_region tinyint NOT NULL, 
	Name_of_region nvarchar(50) NOT NULL, 
    CONSTRAINT PK_ID_region PRIMARY KEY (ID_region),
	CONSTRAINT check_code_region CHECK (0<ID_region AND ID_region<100)
)
GO

IF OBJECT_ID(N'region_codes', 'U') IS NOT NULL
  DROP TABLE [KB301_Mustafina].Mustafina.region_codes

CREATE TABLE [KB301_Mustafina].Mustafina.region_codes
(
	Code int NOT NULL, 
	ID_region tinyint NOT NULL, 
    CONSTRAINT PK_ID_region_code PRIMARY KEY (Code),
	CONSTRAINT check_code CHECK (0<Code AND Code<200 OR 699<Code AND Code<800),
	CONSTRAINT check_ID_region CHECK (0<ID_region AND ID_region<100)
)
GO

/*
--Создание триггера для таблицы с кодами регионов

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE Name = 'trigger_check_region_code' AND type = 'TR') 
	DROP TRIGGER Mustafina.trigger_check_region_code
GO

CREATE TRIGGER Mustafina.trigger_check_region_code
	ON [KB301_Mustafina].Mustafina.region_codes
	INSTEAD OF INSERT
AS
DECLARE @is_wrong int
BEGIN
	SET @is_wrong = (SELECT COUNT(1) FROM inserted
					  WHERE NOT(0<Code AND Code<200 OR 699<Code AND Code<800))
	if (@is_wrong != 0) 
	BEGIN
		RAISERROR(N'Неверный формат кода региона!', 5, 1)
		ROLLBACK
	END
	ELSE
	BEGIN
		INSERT INTO [KB301_Mustafina].Mustafina.region_codes (Code, ID_region) SELECT * FROM inserted
	END
END
GO
*/

/*
Создание внешних ключей
*/

ALTER TABLE [KB301_Mustafina].Mustafina.cars ADD 
	CONSTRAINT FK_ID_region_code FOREIGN KEY (Region_code) 
	REFERENCES [KB301_Mustafina].Mustafina.region_codes(Code)
GO

ALTER TABLE [KB301_Mustafina].Mustafina.posts ADD 
	CONSTRAINT FK_ID_region_for_post FOREIGN KEY (Region) 
	REFERENCES [KB301_Mustafina].Mustafina.region_codes(Code)
GO	

ALTER TABLE [KB301_Mustafina].Mustafina.passages ADD 
	CONSTRAINT FK_ID_post FOREIGN KEY (ID_post) 
	REFERENCES [KB301_Mustafina].Mustafina.posts(ID_post), 
	CONSTRAINT FK_ID_car FOREIGN KEY (ID_car) 
	REFERENCES [KB301_Mustafina].Mustafina.cars(ID_car)
GO	

ALTER TABLE [KB301_Mustafina].Mustafina.region_codes ADD 
	CONSTRAINT FK_ID_region FOREIGN KEY (ID_region) 
	REFERENCES [KB301_Mustafina].Mustafina.regions(ID_region)
GO	

/*
Заполнение таблиц
*/
--INSERT INTO [KB301_Mustafina].Mustafina.regions VALUES (101, N'Россия')

INSERT INTO [KB301_Mustafina].Mustafina.regions
 (ID_region, Name_of_region)
 VALUES 
  (01, N'Республика Адыгея')
 ,(02, N'Республика Башкортостан')
 ,(03, N'Республика Бурятия')
 ,(04, N'Республика Алтай')
 ,(05, N'Республика Дагестан')
 ,(06, N'Республика Ингушетия')
 ,(07, N'Кабардино-Балкарская Республика')
 ,(08, N'Республика Калмыкия')
 ,(09, N'Республика Карачаево-Черкесия')
 ,(10, N'Республика Карелия')
 ,(11, N'Республика Коми')
 ,(12, N'Республика Марий Эл')
 ,(13, N'Республика Мордовия')
 ,(14, N'Республика Саха (Якутия)')
 ,(15, N'Республика Северная Осетия — Алания')
 ,(16, N'Республика Татарстан')
 ,(17, N'Республика Тыва')
 ,(18, N'Удмуртская Республика')
 ,(19, N'Республика Хакасия')
 ,(21, N'Чувашская Республика')
 ,(22, N'Алтайский край')
 ,(23, N'Краснодарский край')
 ,(24, N'Красноярский край')
 ,(25, N'Приморский край')
 ,(26, N'Ставропольский край')
 ,(27, N'Хабаровский край')
 ,(28, N'Амурская область')
 ,(29, N'Архангельская область')
 ,(30, N'Астраханская область')
 ,(31, N'Белгородская область')
 ,(32, N'Брянская область')
 ,(33, N'Владимирская область')
 ,(34, N'Волгоградская область')
 ,(35, N'Вологодская область')
 ,(36, N'Воронежская область')
 ,(37, N'Ивановская область')
 ,(38, N'Иркутская область')
 ,(39, N'Калининградская область')
 ,(40, N'Калужская область')
 ,(41, N'Камчатский край')
 ,(42, N'Кемеровская область')
 ,(43, N'Кировская область')
 ,(44, N'Костромская область')
 ,(45, N'Курганская область')
 ,(46, N'Курская область')
 ,(47, N'Ленинградская область')
 ,(48, N'Липецкая область')
 ,(49, N'Магаданская область')
 ,(50, N'Московская область')
 ,(51, N'Мурманская область')
 ,(52, N'Нижегородская область')
 ,(53, N'Новгородская область')
 ,(54, N'Новосибирская область')
 ,(55, N'Омская область')
 ,(56, N'Оренбургская область')
 ,(57, N'Орловская область')
 ,(58, N'Пензенская область')
 ,(59, N'Пермский край')
 ,(60, N'Псковская область')
 ,(61, N'Ростовская область')
 ,(62, N'Рязанская область')
 ,(63, N'Самарская область')
 ,(64, N'Саратовская область')
 ,(65, N'Сахалинская область')
 ,(66, N'Свердловская область')
 ,(67, N'Смоленская область')
 ,(68, N'Тамбовская область')
 ,(69, N'Тверская область')
 ,(70, N'Томская область')
 ,(71, N'Тульская область')
 ,(72, N'Тюменская область')
 ,(73, N'Ульяновская область')
 ,(74, N'Челябинская область')
 ,(75, N'Забайкальский край')
 ,(76, N'Ярославская область')
 ,(77, N'Москва')
 ,(78, N'Санкт-Петербург')
 ,(79, N'Еврейская автономная область')
 ,(82, N'Крым')
 ,(83, N'Ненецкий автономный округ')
 ,(86, N'Ханты-Мансийский автономный округ Югра')
 ,(87, N'Чукотский автономный округ')
 ,(89, N'Ямало-Ненецкий автономный округ')
 ,(92, N'Севастополь')
 ,(94, N'Байконур')
 ,(95, N'Чеченская республика')
GO

--INSERT INTO [KB301_Mustafina].Mustafina.region_codes VALUES (400, 85)
--INSERT INTO [KB301_Mustafina].Mustafina.region_codes VALUES (186, 150)
INSERT INTO [KB301_Mustafina].Mustafina.region_codes
 (Code,ID_region)
 VALUES 
  (01, 01)
 ,(02, 02)
 ,(03, 03)
 ,(04, 04)
 ,(05, 05)
 ,(06, 06)
 ,(07, 07)
 ,(08, 08)
 ,(09, 09)
 ,(10, 10)
 ,(11, 11)
 ,(12, 12)
 ,(13, 13)
 ,(14, 14)
 ,(15, 15)
 ,(16, 16)
 ,(17, 17)
 ,(18, 18)
 ,(19, 19)
 ,(21, 21)
 ,(22, 22)
 ,(23, 23)
 ,(24, 24)
 ,(25, 25)
 ,(26, 26)
 ,(27, 27)
 ,(28, 28)
 ,(29, 29)
 ,(30, 30)
 ,(31, 31)
 ,(32, 32)
 ,(33, 33)
 ,(34, 34)
 ,(35, 35)
 ,(36, 36)
 ,(37, 37)
 ,(38, 38)
 ,(39, 39)
 ,(40, 40)
 ,(41, 41)
 ,(42, 42)
 ,(43, 43)
 ,(44, 44)
 ,(45, 45)
 ,(46, 46)
 ,(47, 47)
 ,(48, 48)
 ,(49, 49)
 ,(50, 50)
 ,(51, 51)
 ,(52, 52)
 ,(53, 53)
 ,(54, 54)
 ,(55, 55)
 ,(56, 56)
 ,(57, 57)
 ,(58, 58)
 ,(59, 59)
 ,(60, 60)
 ,(61, 61)
 ,(62, 62)
 ,(63, 63)
 ,(64, 64)
 ,(65, 65)
 ,(66, 66)
 ,(67, 67)
 ,(68, 68)
 ,(69, 69)
 ,(70, 70)
 ,(71, 71)
 ,(72, 72)
 ,(73, 73)
 ,(74, 74)
 ,(75, 75)
 ,(76, 76)
 ,(77, 77)
 ,(78, 78)
 ,(79, 79)
 ,(82, 82)
 ,(83, 83)
 ,(86, 86)
 ,(87, 87)
 ,(89, 89)
 ,(92, 92)
 ,(94, 94)
 ,(95, 95)
 ,(102, 02)
 ,(113, 13)
 ,(116, 16)
 ,(716, 16)
 ,(121, 21)
 ,(93, 23)
 ,(123, 23)
 ,(84, 24)
 ,(88, 24)
 ,(124, 24)
 ,(125, 25)
 ,(126, 26)
 ,(134, 34)
 ,(136, 36)
 ,(85, 38)
 ,(138, 38)
 ,(91, 39)
 ,(142, 42)
 ,(90, 50)
 ,(150, 50)
 ,(190, 50)
 ,(750, 50)
 ,(152, 52)
 ,(154, 54)
 ,(159, 59)
 ,(81, 59)
 ,(161, 61)
 ,(163, 63)
 ,(164, 64)
 ,(96, 66)
 ,(196, 66)
 ,(173, 73)
 ,(174, 74)
 ,(80, 75)
 ,(97, 77)
 ,(99, 77)
 ,(177, 77)
 ,(197, 77)
 ,(199, 77)
 ,(777, 77)
 ,(799, 77)
 ,(98, 78)
 ,(178, 78)
 ,(186, 86)
GO


INSERT INTO [KB301_Mustafina].Mustafina.cars
 (Make, Model, Color, Year_of_issue, State_number, Region_code, Driver_name) VALUES 
  (N'Ferrari', N'Monza SP', 'Синий', 2012, N'В658НМ', 48, N'Корастылёв С.В.') 
INSERT INTO [KB301_Mustafina].Mustafina.cars VALUES 
 (N'Audi', N'Coupe', N'Черный', 2015,  N'С185ОН', 178, N'Чудов М.А.')
INSERT INTO [KB301_Mustafina].Mustafina.cars VALUES 
 (N'Lada', N'Granta', N'Красный', 2014,  N'Н001ЕР', 72, N'Гараничев Е.Т.')
INSERT INTO [KB301_Mustafina].Mustafina.cars VALUES 
 (N'Daewoo', N'Matiz', N'Голубой', 2013,  N'Х823ТА', 89, N'Юрлова Е.А.')
INSERT INTO [KB301_Mustafina].Mustafina.cars VALUES 
 (N'KIA', N'Cerato', N'Золотой', 2011,  N'К579УМ', 74, N'Логинов А.С.')
INSERT INTO [KB301_Mustafina].Mustafina.cars VALUES 
 (N'Mazda', N'Bongo Brawny', N'Белый', 2018,  N'О369ЕВ', 96, N'Шипулин А.В.')
INSERT INTO [KB301_Mustafina].Mustafina.cars VALUES 
 (N'Lexus', N'RC', N'Черный', 2017,  N'К461АН', 174, N'Логинов А.С.')
INSERT INTO [KB301_Mustafina].Mustafina.cars VALUES 
 (N'Daewoo', N'Nexia', N'Серебристый', 2014,  N'М258ТА', 55, N'Пащенко Н.Т.')
INSERT INTO [KB301_Mustafina].Mustafina.cars VALUES 
 (N'Nissan', N'Terrano', N'Красный', 2012,  N'А346ВС', 154, N'Губерниев Д.С.')
INSERT INTO [KB301_Mustafina].Mustafina.cars VALUES 
 (N'Mazda', N'Bongo Brawny', N'Жёлтый', 2008,  N'Р421НТ', 138, N'Юрьева Е.В.')
INSERT INTO [KB301_Mustafina].Mustafina.cars VALUES 
 (N'Renault', N'Logan', N'Сиреневый', 2008,  N'Е713ХУ', 47, N'Волков А.В.')
INSERT INTO [KB301_Mustafina].Mustafina.cars VALUES 
 (N'Renault', N'Sandero', N'Белый', 2017,  N'К115АР', 88, N'Устюгов Е.А.')
INSERT INTO [KB301_Mustafina].Mustafina.cars VALUES 
 (N'Subaru', N'Crosstrek', N'Синий', 2014,  N'У156СТ', 66, N'Жирный Е.В.')
INSERT INTO [KB301_Mustafina].Mustafina.cars VALUES 
 (N'Toyota', N'Highlander', N'Белый', 2016,  N'О598ВМ', 48, N'Романова Я.Г.')
INSERT INTO [KB301_Mustafina].Mustafina.cars VALUES 
 (N'Lexus', N'RC', N'Голубой', 2014,  N'А687ОР', 196, N'Шипулин А.В.')
INSERT INTO [KB301_Mustafina].Mustafina.cars VALUES 
 (N'Volkswagen', N'Golf Country', N'Золотой', 2016,  N'Т482ОК', 27, N'Зайцева О.А.')
INSERT INTO [KB301_Mustafina].Mustafina.cars VALUES 
 (N'Toyota', N'Camry', N'Чёрный', 2017,  N'С273МН', 123, N'Медведцева О.Р.')
INSERT INTO [KB301_Mustafina].Mustafina.cars VALUES 
 (N'Skoda', N'Scala', N'Оранжевый', 2015,  N'Х448ЕО', 178, N'Чудов М.А.')
INSERT INTO [KB301_Mustafina].Mustafina.cars VALUES 
 (N'Lada', N'Granta', N'Красный', 2012,  N'А942ВУ', 62, N'Ахатова А.А.')
INSERT INTO [KB301_Mustafina].Mustafina.cars VALUES 
 (N'Porsche', N'Taycan', N'Бордовый', 2013,  N'Т767МС', 51, N'Белова Н.А.')
INSERT INTO [KB301_Mustafina].Mustafina.cars VALUES 
 (N'Lada', N'Xray Cross', N'Бирюзовый', 2011,  N'К219ОА', 74, N'Боярских М.В.')
INSERT INTO [KB301_Mustafina].Mustafina.cars VALUES 
 (N'Suzuki', N'Fun', N'Белый', 2009,  N'О108РТ', 174, N'Вилухина О.Г.')
INSERT INTO [KB301_Mustafina].Mustafina.cars VALUES 
 (N'Infinity', N'Q60', N'Серебристый', 2011,  N'С634ТО', 55, N'Васильева М.С.')
INSERT INTO [KB301_Mustafina].Mustafina.cars VALUES 
 (N'Chery', N'J11', N'Бордовый', 2010,  N'С841ЕТ', 81, N'Виролайнен Д.Л.')
INSERT INTO [KB301_Mustafina].Mustafina.cars VALUES 
 (N'Bentley', N'R-Type', N'Чёрный', 2018,  N'Н995ЕТ', 48, N'Глазырина Е.И.')
INSERT INTO [KB301_Mustafina].Mustafina.cars VALUES 
 (N'КамАЗ', N'6520', N'Белый', 2015,  N'Р470УТ', 55, N'Дедюхин А.Р.')
INSERT INTO [KB301_Mustafina].Mustafina.cars VALUES 
 (N'Lada', N'Vesta', N'Красный', 2019,  N'Т540УР', 48, N'Елисеев М.П.')
INSERT INTO [KB301_Mustafina].Mustafina.cars VALUES 
 (N'Lada', N'2106', N'Зелёный', 2016,  N'М456ТС', 89, N'Загоруйко А.Г.')
INSERT INTO [KB301_Mustafina].Mustafina.cars VALUES 
 (N'Lada', N'2107', N'Серебристый', 2007,  N'К666АХ', 32, N'Ильченко К.С.')
INSERT INTO [KB301_Mustafina].Mustafina.cars VALUES  
 (N'Toyota', N'Highlander', N'Белый', 2015,  N'Е810ЕТ', 74, N'Майгуров В.В.')
INSERT INTO [KB301_Mustafina].Mustafina.cars VALUES  
 (N'КамАЗ', N'65115', N'Синий', 2013,  N'М349ОН', 66, N'Меркушина А.О.')
GO
/*
INSERT INTO [KB301_Mustafina].Mustafina.cars VALUES  
 (N'Suzuki', N'Liana', N'Зелёный', 2013,  N'Ш609ТС', 51, N'Морозова А.И.')
INSERT INTO [KB301_Mustafina].Mustafina.cars VALUES  
 (N'Suzuki', N'Liana', N'Жёлтый', 2008,  N'Н999ТЗ', 51, N'Морозова А.И.')
INSERT INTO [KB301_Mustafina].Mustafina.cars VALUES  
 (N'Suzuki', N'Liana', N'Зелёный', 2007,  N'4609ТС', 51, N'Морозова А.И.')
INSERT INTO [KB301_Mustafina].Mustafina.cars VALUES 
 (N'Skoda', N'Scala', N'Белый', 2017,  N'Н000ТВ', 74, N'Логинов А.С.')
*/

INSERT INTO [KB301_Mustafina].Mustafina.posts
 (Region)
 VALUES 
  (196)
 ,(196)
 ,(196)
 ,(196)
 ,(196)
GO
--1, 2, 24 - транзитные машины
--6, 13, 15 - местные машины
--5, 10, 18, 31 - иногородние машины
--7, 8, 9, 20, 21, 14 - прочие

INSERT INTO [KB301_Mustafina].Mustafina.passages
 (ID_post, ID_car, Passage_time, Entry_or_exit)
 VALUES (1, 14, '09:52', 0)
INSERT INTO [KB301_Mustafina].Mustafina.passages VALUES (2, 14, '11:11', 1)

INSERT INTO [KB301_Mustafina].Mustafina.passages VALUES (2, 7, '07:02', 1)

INSERT INTO [KB301_Mustafina].Mustafina.passages VALUES (3, 5, '08:14', 1)
INSERT INTO [KB301_Mustafina].Mustafina.passages VALUES (3, 5, '10:00', 0)
INSERT INTO [KB301_Mustafina].Mustafina.passages VALUES (3, 1, '09:33', 1)
INSERT INTO [KB301_Mustafina].Mustafina.passages VALUES (1, 1, '12:00', 0)
INSERT INTO [KB301_Mustafina].Mustafina.passages VALUES (5, 2, '09:40', 1)
INSERT INTO [KB301_Mustafina].Mustafina.passages VALUES (2, 2, '13:17', 0)
INSERT INTO [KB301_Mustafina].Mustafina.passages VALUES (2, 6, '15:08', 0)
INSERT INTO [KB301_Mustafina].Mustafina.passages VALUES (4, 6, '19:31', 1)

INSERT INTO [KB301_Mustafina].Mustafina.passages VALUES (5, 13, '17:59', 0)
INSERT INTO [KB301_Mustafina].Mustafina.passages VALUES (1, 13, '22:22', 1)
INSERT INTO [KB301_Mustafina].Mustafina.passages VALUES (5, 31, '05:06', 1)
INSERT INTO [KB301_Mustafina].Mustafina.passages VALUES (5, 31, '21:15', 0)

INSERT INTO [KB301_Mustafina].Mustafina.passages VALUES (1, 9, '12:53', 0)

INSERT INTO [KB301_Mustafina].Mustafina.passages VALUES (5, 24, '11:42', 1)
INSERT INTO [KB301_Mustafina].Mustafina.passages VALUES (4, 24, '20:04', 0)
INSERT INTO [KB301_Mustafina].Mustafina.passages VALUES (2, 18, '14:36', 1)
INSERT INTO [KB301_Mustafina].Mustafina.passages VALUES (2, 18, '16:58', 0)

INSERT INTO [KB301_Mustafina].Mustafina.passages VALUES (3, 8, '15:50', 1)
INSERT INTO [KB301_Mustafina].Mustafina.passages VALUES (5, 21, '16:37', 1)

INSERT INTO [KB301_Mustafina].Mustafina.passages VALUES (5, 15, '09:24', 0)
INSERT INTO [KB301_Mustafina].Mustafina.passages VALUES (3, 15, '17:42', 1)
INSERT INTO [KB301_Mustafina].Mustafina.passages VALUES (1, 10, '10:01', 1)
INSERT INTO [KB301_Mustafina].Mustafina.passages VALUES (1, 10, '13:23', 0)

INSERT INTO [KB301_Mustafina].Mustafina.passages VALUES (1, 20, '06:08', 0)

GO

/*
INSERT INTO [KB301_Mustafina].Mustafina.passages VALUES (1, 22, '12:22', 1)
INSERT INTO [KB301_Mustafina].Mustafina.passages VALUES (1, 22, '13:23', 0)
INSERT INTO [KB301_Mustafina].Mustafina.passages VALUES (1, 22, '20:04', 0)
GO

INSERT INTO [KB301_Mustafina].Mustafina.passages VALUES (1, 11, '12:22', 1)
INSERT INTO [KB301_Mustafina].Mustafina.passages VALUES (1, 11, '13:23', 1)
INSERT INTO [KB301_Mustafina].Mustafina.passages VALUES (4, 11, '20:04', 0)
GO

INSERT INTO [KB301_Mustafina].Mustafina.passages VALUES (2, 9, '12:22', 1)
INSERT INTO [KB301_Mustafina].Mustafina.passages VALUES (4, 9, '10:23', 0)
GO

INSERT INTO [KB301_Mustafina].Mustafina.passages VALUES (5, 16, '21:28', 0)
INSERT INTO [KB301_Mustafina].Mustafina.passages VALUES (3, 16, '18:44', 1)
GO

INSERT INTO [KB301_Mustafina].Mustafina.passages VALUES (1, 4, '16:58', 0)
GO
*/

SELECT *
FROM [KB301_Mustafina].Mustafina.regions

SELECT *
FROM [KB301_Mustafina].Mustafina.region_codes

SELECT *
FROM [KB301_Mustafina].Mustafina.cars

SELECT *
FROM [KB301_Mustafina].Mustafina.posts

SELECT *
FROM [KB301_Mustafina].Mustafina.passages


--Код региона поста - название региона

SELECT POST.ID_post as 'Номер поста', 
IIF(LEN(CAST(Region as int))=1, '0' + CAST(Region as nvarchar(5)), CAST(Region as nvarchar(5))) as 'Код региона поста',
IIF(LEN(CAST(REGION.ID_region as int))=1, '0' + CAST(REGION.ID_region as nvarchar(5)), CAST(REGION.ID_region as nvarchar(5))) as 'Главный код региона',
REGION.Name_of_region as 'Регион поста' FROM 
[KB301_Mustafina].Mustafina.posts as POST INNER JOIN 
[KB301_Mustafina].Mustafina.region_codes as CODE ON POST.Region = CODE.Code INNER JOIN 
[KB301_Mustafina].Mustafina.regions as REGION ON CODE.ID_region = REGION.ID_region

--Количество автомобилей, выехавшие из города и сгруппированные по регионам

SELECT  REGION_CAR.ID_region as 'Код региона',
REGION_CAR.Name_of_region as 'Регион',  COUNT(REGION_CAR.Name_of_region) as 'Количество автомобилей'
FROM [KB301_Mustafina].Mustafina.passages AS PASS LEFT JOIN
[KB301_Mustafina].Mustafina.cars as CAR ON PASS.ID_car = CAR.ID_car INNER JOIN
[KB301_Mustafina].Mustafina.region_codes as CODE_CAR ON CAR.Region_code = CODE_CAR.Code INNER JOIN 
[KB301_Mustafina].Mustafina.regions as REGION_CAR ON CODE_CAR.ID_region = REGION_CAR.ID_region
WHERE PASS.Entry_or_exit=0
GROUP BY REGION_CAR.Name_of_region, REGION_CAR.ID_region

--Вывод таблицы движения со всеми отформатированными данными

SELECT CAR.Make as 'Производитель', CAR.Model as 'Марка', CAR.Color as 'Цвет', CAR.Year_of_issue as 'Год производства', CAR.Driver_name as 'Водитель', 
CAR.State_number + IIF(LEN(CAST(CAR.Region_code as int))=1, '0' + CAST(CAR.Region_code as nvarchar(5)), CAST(CAR.Region_code as nvarchar(5))) as 'Гос.номер',  
REGION_CAR.Name_of_region AS 'Регион автомобиля',
IIF(PASS.Entry_or_exit=1, 'Въезд', 'Выезд') as 'Въезд/Выезд', POST.ID_post as 'Пост въезда/выезда', 
IIF(LEN(CAST(POST.Region as int))=1, '0' + CAST(POST.Region as nvarchar(5)), CAST(CODE.ID_region as nvarchar(5))) as 'Код региона поста',
REGION.Name_of_region as 'Регион въезда/выезда',
FORMAT(CAST(PASS.Passage_time as time), N'hh\:mm') as 'Время въезда/выезда' 
FROM
[KB301_Mustafina].Mustafina.passages AS PASS LEFT JOIN
[KB301_Mustafina].Mustafina.cars as CAR ON PASS.ID_car = CAR.ID_car INNER JOIN
[KB301_Mustafina].Mustafina.region_codes as CODE_CAR ON CAR.Region_code = CODE_CAR.Code INNER JOIN 
[KB301_Mustafina].Mustafina.regions as REGION_CAR ON CODE_CAR.ID_region = REGION_CAR.ID_region INNER JOIN

[KB301_Mustafina].Mustafina.posts as POST ON PASS.ID_post = POST.ID_post INNER JOIN 
[KB301_Mustafina].Mustafina.region_codes as CODE ON POST.Region = CODE.Code INNER JOIN 
[KB301_Mustafina].Mustafina.regions as REGION ON CODE.ID_region = REGION.ID_region 
ORDER BY PASS.Passage_time, POST.ID_post

--Транзитные автомобили

CREATE VIEW transit_cars AS

SELECT CAR.Make as 'Производитель', CAR.Model as 'Марка', CAR.Color as 'Цвет', CAR.Year_of_issue as 'Год производства',
CAR.Driver_name as 'Водитель', 
CAR.State_number + IIF(LEN(CAST(CAR.Region_code as int))=1, '0' + CAST(CAR.Region_code as nvarchar(5)), CAST(CAR.Region_code as nvarchar(5))) as 'Гос.номер', 
REGION_CAR.Name_of_region as 'Регион автомобиля', POST_IN.ID_post as 'Пост въезда', 
POST_OUT.ID_post as 'Пост выезда', 
IIF(LEN(CAST(POST_OUT.Region as int))=1, '0' + CAST(POST_OUT.Region as nvarchar(5)), CAST(REGION_OUT.ID_region as nvarchar(5))) as 'Код региона постов', 
REGION_OUT.Name_of_region as 'Регион въезда-выезда',
FORMAT(CAST(IN_CITY.Passage_time as time), N'hh\:mm') + ' - ' + FORMAT(cast(OUT_CITY.Passage_time as time), N'hh\:mm') as 'Время въезда-выезда'
FROM 
[KB301_Mustafina].Mustafina.passages as IN_CITY FULL JOIN
[KB301_Mustafina].Mustafina.passages as OUT_CITY ON IN_CITY.ID_car = OUT_CITY.ID_car INNER JOIN

[KB301_Mustafina].Mustafina.cars as CAR ON IN_CITY.ID_car = CAR.ID_car INNER JOIN
[KB301_Mustafina].Mustafina.region_codes as CODE_CAR ON CAR.Region_code = CODE_CAR.Code INNER JOIN 
[KB301_Mustafina].Mustafina.regions as REGION_CAR ON CODE_CAR.ID_region = REGION_CAR.ID_region INNER JOIN

[KB301_Mustafina].Mustafina.posts as POST_IN ON IN_CITY.ID_post = POST_IN.ID_post INNER JOIN 
[KB301_Mustafina].Mustafina.region_codes as CODE_IN ON POST_IN.Region = CODE_IN.Code INNER JOIN 
[KB301_Mustafina].Mustafina.regions as REGION_IN ON CODE_IN.ID_region = REGION_IN.ID_region INNER JOIN

[KB301_Mustafina].Mustafina.posts as POST_OUT ON OUT_CITY.ID_post = POST_OUT.ID_post INNER JOIN 
[KB301_Mustafina].Mustafina.region_codes as CODE_OUT ON POST_OUT.Region = CODE_OUT.Code INNER JOIN 
[KB301_Mustafina].Mustafina.regions as REGION_OUT ON CODE_OUT.ID_region = REGION_OUT.ID_region

WHERE IN_CITY.Entry_or_exit = 1 AND OUT_CITY.Entry_or_exit = 0 AND
      IN_CITY.Passage_time <= OUT_CITY.Passage_time AND
	  POST_IN.ID_post != POST_OUT.ID_post AND
	  REGION_CAR.ID_region != REGION_IN.ID_region AND
	  REGION_CAR.ID_region != REGION_OUT.ID_region
--ORDER BY IN_CITY.Passage_time
GO

SELECT * FROM dbo.transit_cars

--Иногородние автомобили

CREATE VIEW nonresident_cars AS

SELECT CAR.Make as 'Производитель', CAR.Model as 'Марка', CAR.Color as 'Цвет', CAR.Year_of_issue as 'Год производства', 
CAR.Driver_name as 'Водитель', 
CAR.State_number + IIF(LEN(CAST(CAR.Region_code as int))=1, '0' + CAST(CAR.Region_code as nvarchar(5)), CAST(CAR.Region_code as nvarchar(5))) as 'Гос.номер', 
REGION_CAR.Name_of_region as 'Регион автомобиля', POST_IN.ID_post as 'Пост въезда', 
POST_OUT.ID_post as 'Пост выезда', 
IIF(LEN(CAST(POST_OUT.Region as int))=1, '0' + CAST(POST_OUT.Region as nvarchar(5)), CAST(REGION_OUT.ID_region as nvarchar(5))) as 'Код региона постов',
REGION_OUT.Name_of_region as 'Регион въезда-выезда',
FORMAT(CAST(IN_CITY.Passage_time as time), N'hh\:mm') + ' - ' + FORMAT(cast(OUT_CITY.Passage_time as time), N'hh\:mm') as 'Время въезда-выезда'
FROM 
[KB301_Mustafina].Mustafina.passages as IN_CITY FULL JOIN
[KB301_Mustafina].Mustafina.passages as OUT_CITY ON IN_CITY.ID_car = OUT_CITY.ID_car INNER JOIN

[KB301_Mustafina].Mustafina.cars as CAR ON IN_CITY.ID_car = CAR.ID_car INNER JOIN
[KB301_Mustafina].Mustafina.region_codes as CODE_CAR ON CAR.Region_code = CODE_CAR.Code INNER JOIN 
[KB301_Mustafina].Mustafina.regions as REGION_CAR ON CODE_CAR.ID_region = REGION_CAR.ID_region INNER JOIN

[KB301_Mustafina].Mustafina.posts as POST_IN ON IN_CITY.ID_post = POST_IN.ID_post INNER JOIN 
[KB301_Mustafina].Mustafina.region_codes as CODE_IN ON POST_IN.Region = CODE_IN.Code INNER JOIN 
[KB301_Mustafina].Mustafina.regions as REGION_IN ON CODE_IN.ID_region = REGION_IN.ID_region INNER JOIN

[KB301_Mustafina].Mustafina.posts as POST_OUT ON OUT_CITY.ID_post = POST_OUT.ID_post INNER JOIN 
[KB301_Mustafina].Mustafina.region_codes as CODE_OUT ON POST_OUT.Region = CODE_OUT.Code INNER JOIN 
[KB301_Mustafina].Mustafina.regions as REGION_OUT ON CODE_OUT.ID_region = REGION_OUT.ID_region

WHERE IN_CITY.Entry_or_exit = 1 AND OUT_CITY.Entry_or_exit = 0 AND
      IN_CITY.Passage_time <= OUT_CITY.Passage_time AND
	  POST_IN.ID_post = POST_OUT.ID_post AND
	  IN_CITY.Passage_time <= OUT_CITY.Passage_time
--ORDER BY IN_CITY.Passage_time
GO 

SELECT * FROM dbo.nonresident_cars

--Местные автомобили

CREATE VIEW local_cars AS

SELECT CAR.Make as 'Производитель', CAR.Model as 'Марка', CAR.Color as 'Цвет', CAR.Year_of_issue as 'Год производства', 
CAR.Driver_name as 'Водитель',
CAR.State_number + IIF(LEN(CAST(CAR.Region_code as int))=1, '0' + CAST(CAR.Region_code as nvarchar(5)), CAST(CAR.Region_code as nvarchar(5))) as 'Гос.номер',  
REGION_CAR.Name_of_region as 'Регион автомобиля', POST_OUT.ID_post as 'Пост выезда', POST_IN.ID_post as 'Пост въезда', 
IIF(LEN(CAST(POST_OUT.Region as int))=1, '0' + CAST(POST_OUT.Region as nvarchar(5)), CAST(REGION_OUT.ID_region as nvarchar(5))) as 'Код региона постов',
REGION_OUT.Name_of_region as 'Регион въезда-выезда',
FORMAT(CAST(OUT_CITY.Passage_time as time), N'hh\:mm') + ' - ' + FORMAT(cast(IN_CITY.Passage_time as time), N'hh\:mm') as 'Время выезда-въезда'
FROM 
[KB301_Mustafina].Mustafina.passages as IN_CITY FULL JOIN
[KB301_Mustafina].Mustafina.passages as OUT_CITY ON IN_CITY.ID_car = OUT_CITY.ID_car INNER JOIN

[KB301_Mustafina].Mustafina.cars as CAR ON IN_CITY.ID_car = CAR.ID_car INNER JOIN
[KB301_Mustafina].Mustafina.region_codes as CODE_CAR ON CAR.Region_code = CODE_CAR.Code INNER JOIN 
[KB301_Mustafina].Mustafina.regions as REGION_CAR ON CODE_CAR.ID_region = REGION_CAR.ID_region INNER JOIN

[KB301_Mustafina].Mustafina.posts as POST_IN ON IN_CITY.ID_post = POST_IN.ID_post INNER JOIN 
[KB301_Mustafina].Mustafina.region_codes as CODE_IN ON POST_IN.Region = CODE_IN.Code INNER JOIN 
[KB301_Mustafina].Mustafina.regions as REGION_IN ON CODE_IN.ID_region = REGION_IN.ID_region INNER JOIN

[KB301_Mustafina].Mustafina.posts as POST_OUT ON OUT_CITY.ID_post = POST_OUT.ID_post INNER JOIN 
[KB301_Mustafina].Mustafina.region_codes as CODE_OUT ON POST_OUT.Region = CODE_OUT.Code INNER JOIN 
[KB301_Mustafina].Mustafina.regions as REGION_OUT ON CODE_OUT.ID_region = REGION_OUT.ID_region

WHERE IN_CITY.Entry_or_exit = 1 AND OUT_CITY.Entry_or_exit = 0 AND
	  IN_CITY.Passage_time >= OUT_CITY.Passage_time AND
	  REGION_CAR.ID_region = REGION_IN.ID_region AND
	  REGION_CAR.ID_region = REGION_OUT.ID_region
--ORDER BY IN_CITY.Passage_time
GO

SELECT * FROM dbo.local_cars


--Прочие автомобили

CREATE VIEW other_cars AS

SELECT CAR.Make as 'Производитель', CAR.Model as 'Марка', CAR.Color as 'Цвет', CAR.Year_of_issue as 'Год производства', CAR.Driver_name as 'Водитель', 
CAR.State_number + IIF(LEN(CAST(CAR.Region_code as int))=1, '0' + CAST(CAR.Region_code as nvarchar(5)), CAST(CAR.Region_code as nvarchar(5))) as 'Гос.номер',  
REGION_CAR.Name_of_region as 'Регион автомобиля', 
IIF(PASS.Entry_or_exit=1, 'Въезд', 'Выезд') as 'Въезд/Выезд', POST.ID_post as 'Пост въезда/выезда', 
IIF(LEN(CAST(POST.Region as int))=1, '0' + CAST(POST.Region as nvarchar(5)), CAST(REGION.ID_region  as nvarchar(5))) as 'Код региона поста',
REGION.Name_of_region as 'Регион въезда/выезда',
FORMAT(CAST(PASS.Passage_time as time), N'hh\:mm') as 'Время въезда/выезда' 

FROM [KB301_Mustafina].Mustafina.passages AS PASS LEFT JOIN
dbo.local_cars AS LOC ON PASS.ID_post = LOC.[Пост выезда] AND PASS.Passage_time = SUBSTRING(LOC.[Время выезда-въезда], 1, 5) 
OR PASS.ID_post = LOC.[Пост въезда]  AND PASS.Passage_time = SUBSTRING(LOC.[Время выезда-въезда], 9, 5) LEFT JOIN
dbo.nonresident_cars AS NON ON PASS.ID_post = NON.[Пост въезда] AND PASS.Passage_time = SUBSTRING(NON.[Время въезда-выезда], 1, 5) 
OR PASS.ID_post = NON.[Пост выезда]  AND PASS.Passage_time = SUBSTRING(NON.[Время въезда-выезда], 9, 5) LEFT JOIN
dbo.transit_cars AS TR ON PASS.ID_post = TR.[Пост въезда] AND PASS.Passage_time = SUBSTRING(TR.[Время въезда-выезда], 1, 5) 
OR PASS.ID_post = TR.[Пост выезда]  AND PASS.Passage_time = SUBSTRING(TR.[Время въезда-выезда], 9, 5) INNER JOIN

[KB301_Mustafina].Mustafina.cars as CAR ON PASS.ID_car = CAR.ID_car INNER JOIN
[KB301_Mustafina].Mustafina.region_codes as CODE_CAR ON CAR.Region_code = CODE_CAR.Code INNER JOIN 
[KB301_Mustafina].Mustafina.regions as REGION_CAR ON CODE_CAR.ID_region = REGION_CAR.ID_region INNER JOIN

[KB301_Mustafina].Mustafina.posts as POST ON PASS.ID_post = POST.ID_post INNER JOIN 
[KB301_Mustafina].Mustafina.region_codes as CODE ON POST.Region = CODE.Code INNER JOIN 
[KB301_Mustafina].Mustafina.regions as REGION ON CODE.ID_region = REGION.ID_region 
WHERE LOC.[Гос.номер] IS NULL AND NON.[Гос.номер] IS NULL AND TR.[Гос.номер] IS NULL
GO

SELECT * FROM dbo.other_cars

