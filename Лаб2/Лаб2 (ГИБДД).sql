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
	CONSTRAINT check_State_number CHECK (State_number NOT LIKE N'[������������������������]000[������������������������][������������������������]' 
	AND State_number LIKE N'[������������������������][0123456789][0123456789][0123456789][������������������������][������������������������]')

)
GO

/*
--�������� �������� ��� ���������� ���.�������

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
					  WHERE  State_number LIKE N'[������������������������]000[������������������������][������������������������]' OR
					  State_number NOT LIKE N'[������������������������][0123456789][0123456789][0123456789][������������������������][������������������������]')
	if (@is_wrong != 0) 
	BEGIN
		RAISERROR(N'�������� ������ ���������������� ��������� �����!', 5, 1)
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


--�������� �������� ��� ������-������

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
		RAISERROR(N'������������ ����������� �������� ����������!', 5, 1)
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
--�������� �������� ��� ������� � ������ ��������

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
		RAISERROR(N'�������� ������ ���� �������!', 5, 1)
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
�������� ������� ������
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
���������� ������
*/
--INSERT INTO [KB301_Mustafina].Mustafina.regions VALUES (101, N'������')

INSERT INTO [KB301_Mustafina].Mustafina.regions
 (ID_region, Name_of_region)
 VALUES 
  (01, N'���������� ������')
 ,(02, N'���������� ������������')
 ,(03, N'���������� �������')
 ,(04, N'���������� �����')
 ,(05, N'���������� ��������')
 ,(06, N'���������� ���������')
 ,(07, N'���������-���������� ����������')
 ,(08, N'���������� ��������')
 ,(09, N'���������� ���������-��������')
 ,(10, N'���������� �������')
 ,(11, N'���������� ����')
 ,(12, N'���������� ����� ��')
 ,(13, N'���������� ��������')
 ,(14, N'���������� ���� (������)')
 ,(15, N'���������� �������� ������ � ������')
 ,(16, N'���������� ���������')
 ,(17, N'���������� ����')
 ,(18, N'���������� ����������')
 ,(19, N'���������� �������')
 ,(21, N'��������� ����������')
 ,(22, N'��������� ����')
 ,(23, N'������������� ����')
 ,(24, N'������������ ����')
 ,(25, N'���������� ����')
 ,(26, N'�������������� ����')
 ,(27, N'����������� ����')
 ,(28, N'�������� �������')
 ,(29, N'������������� �������')
 ,(30, N'������������ �������')
 ,(31, N'������������ �������')
 ,(32, N'�������� �������')
 ,(33, N'������������ �������')
 ,(34, N'������������� �������')
 ,(35, N'����������� �������')
 ,(36, N'����������� �������')
 ,(37, N'���������� �������')
 ,(38, N'��������� �������')
 ,(39, N'��������������� �������')
 ,(40, N'��������� �������')
 ,(41, N'���������� ����')
 ,(42, N'����������� �������')
 ,(43, N'��������� �������')
 ,(44, N'����������� �������')
 ,(45, N'���������� �������')
 ,(46, N'������� �������')
 ,(47, N'������������� �������')
 ,(48, N'�������� �������')
 ,(49, N'����������� �������')
 ,(50, N'���������� �������')
 ,(51, N'���������� �������')
 ,(52, N'������������� �������')
 ,(53, N'������������ �������')
 ,(54, N'������������� �������')
 ,(55, N'������ �������')
 ,(56, N'������������ �������')
 ,(57, N'��������� �������')
 ,(58, N'���������� �������')
 ,(59, N'�������� ����')
 ,(60, N'��������� �������')
 ,(61, N'���������� �������')
 ,(62, N'��������� �������')
 ,(63, N'��������� �������')
 ,(64, N'����������� �������')
 ,(65, N'����������� �������')
 ,(66, N'������������ �������')
 ,(67, N'���������� �������')
 ,(68, N'���������� �������')
 ,(69, N'�������� �������')
 ,(70, N'������� �������')
 ,(71, N'�������� �������')
 ,(72, N'��������� �������')
 ,(73, N'����������� �������')
 ,(74, N'����������� �������')
 ,(75, N'������������� ����')
 ,(76, N'����������� �������')
 ,(77, N'������')
 ,(78, N'�����-���������')
 ,(79, N'��������� ���������� �������')
 ,(82, N'����')
 ,(83, N'�������� ���������� �����')
 ,(86, N'�����-���������� ���������� ����� ����')
 ,(87, N'��������� ���������� �����')
 ,(89, N'�����-�������� ���������� �����')
 ,(92, N'�����������')
 ,(94, N'��������')
 ,(95, N'��������� ����������')
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
  (N'Ferrari', N'Monza SP', '�����', 2012, N'�658��', 48, N'��������� �.�.') 
INSERT INTO [KB301_Mustafina].Mustafina.cars VALUES 
 (N'Audi', N'Coupe', N'������', 2015,  N'�185��', 178, N'����� �.�.')
INSERT INTO [KB301_Mustafina].Mustafina.cars VALUES 
 (N'Lada', N'Granta', N'�������', 2014,  N'�001��', 72, N'��������� �.�.')
INSERT INTO [KB301_Mustafina].Mustafina.cars VALUES 
 (N'Daewoo', N'Matiz', N'�������', 2013,  N'�823��', 89, N'������ �.�.')
INSERT INTO [KB301_Mustafina].Mustafina.cars VALUES 
 (N'KIA', N'Cerato', N'�������', 2011,  N'�579��', 74, N'������� �.�.')
INSERT INTO [KB301_Mustafina].Mustafina.cars VALUES 
 (N'Mazda', N'Bongo Brawny', N'�����', 2018,  N'�369��', 96, N'������� �.�.')
INSERT INTO [KB301_Mustafina].Mustafina.cars VALUES 
 (N'Lexus', N'RC', N'������', 2017,  N'�461��', 174, N'������� �.�.')
INSERT INTO [KB301_Mustafina].Mustafina.cars VALUES 
 (N'Daewoo', N'Nexia', N'�����������', 2014,  N'�258��', 55, N'������� �.�.')
INSERT INTO [KB301_Mustafina].Mustafina.cars VALUES 
 (N'Nissan', N'Terrano', N'�������', 2012,  N'�346��', 154, N'��������� �.�.')
INSERT INTO [KB301_Mustafina].Mustafina.cars VALUES 
 (N'Mazda', N'Bongo Brawny', N'Ƹ����', 2008,  N'�421��', 138, N'������ �.�.')
INSERT INTO [KB301_Mustafina].Mustafina.cars VALUES 
 (N'Renault', N'Logan', N'���������', 2008,  N'�713��', 47, N'������ �.�.')
INSERT INTO [KB301_Mustafina].Mustafina.cars VALUES 
 (N'Renault', N'Sandero', N'�����', 2017,  N'�115��', 88, N'������� �.�.')
INSERT INTO [KB301_Mustafina].Mustafina.cars VALUES 
 (N'Subaru', N'Crosstrek', N'�����', 2014,  N'�156��', 66, N'������ �.�.')
INSERT INTO [KB301_Mustafina].Mustafina.cars VALUES 
 (N'Toyota', N'Highlander', N'�����', 2016,  N'�598��', 48, N'�������� �.�.')
INSERT INTO [KB301_Mustafina].Mustafina.cars VALUES 
 (N'Lexus', N'RC', N'�������', 2014,  N'�687��', 196, N'������� �.�.')
INSERT INTO [KB301_Mustafina].Mustafina.cars VALUES 
 (N'Volkswagen', N'Golf Country', N'�������', 2016,  N'�482��', 27, N'������� �.�.')
INSERT INTO [KB301_Mustafina].Mustafina.cars VALUES 
 (N'Toyota', N'Camry', N'׸����', 2017,  N'�273��', 123, N'���������� �.�.')
INSERT INTO [KB301_Mustafina].Mustafina.cars VALUES 
 (N'Skoda', N'Scala', N'���������', 2015,  N'�448��', 178, N'����� �.�.')
INSERT INTO [KB301_Mustafina].Mustafina.cars VALUES 
 (N'Lada', N'Granta', N'�������', 2012,  N'�942��', 62, N'������� �.�.')
INSERT INTO [KB301_Mustafina].Mustafina.cars VALUES 
 (N'Porsche', N'Taycan', N'��������', 2013,  N'�767��', 51, N'������ �.�.')
INSERT INTO [KB301_Mustafina].Mustafina.cars VALUES 
 (N'Lada', N'Xray Cross', N'���������', 2011,  N'�219��', 74, N'�������� �.�.')
INSERT INTO [KB301_Mustafina].Mustafina.cars VALUES 
 (N'Suzuki', N'Fun', N'�����', 2009,  N'�108��', 174, N'�������� �.�.')
INSERT INTO [KB301_Mustafina].Mustafina.cars VALUES 
 (N'Infinity', N'Q60', N'�����������', 2011,  N'�634��', 55, N'��������� �.�.')
INSERT INTO [KB301_Mustafina].Mustafina.cars VALUES 
 (N'Chery', N'J11', N'��������', 2010,  N'�841��', 81, N'���������� �.�.')
INSERT INTO [KB301_Mustafina].Mustafina.cars VALUES 
 (N'Bentley', N'R-Type', N'׸����', 2018,  N'�995��', 48, N'��������� �.�.')
INSERT INTO [KB301_Mustafina].Mustafina.cars VALUES 
 (N'�����', N'6520', N'�����', 2015,  N'�470��', 55, N'������� �.�.')
INSERT INTO [KB301_Mustafina].Mustafina.cars VALUES 
 (N'Lada', N'Vesta', N'�������', 2019,  N'�540��', 48, N'������� �.�.')
INSERT INTO [KB301_Mustafina].Mustafina.cars VALUES 
 (N'Lada', N'2106', N'������', 2016,  N'�456��', 89, N'��������� �.�.')
INSERT INTO [KB301_Mustafina].Mustafina.cars VALUES 
 (N'Lada', N'2107', N'�����������', 2007,  N'�666��', 32, N'�������� �.�.')
INSERT INTO [KB301_Mustafina].Mustafina.cars VALUES  
 (N'Toyota', N'Highlander', N'�����', 2015,  N'�810��', 74, N'�������� �.�.')
INSERT INTO [KB301_Mustafina].Mustafina.cars VALUES  
 (N'�����', N'65115', N'�����', 2013,  N'�349��', 66, N'��������� �.�.')
GO
/*
INSERT INTO [KB301_Mustafina].Mustafina.cars VALUES  
 (N'Suzuki', N'Liana', N'������', 2013,  N'�609��', 51, N'�������� �.�.')
INSERT INTO [KB301_Mustafina].Mustafina.cars VALUES  
 (N'Suzuki', N'Liana', N'Ƹ����', 2008,  N'�999��', 51, N'�������� �.�.')
INSERT INTO [KB301_Mustafina].Mustafina.cars VALUES  
 (N'Suzuki', N'Liana', N'������', 2007,  N'4609��', 51, N'�������� �.�.')
INSERT INTO [KB301_Mustafina].Mustafina.cars VALUES 
 (N'Skoda', N'Scala', N'�����', 2017,  N'�000��', 74, N'������� �.�.')
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
--1, 2, 24 - ���������� ������
--6, 13, 15 - ������� ������
--5, 10, 18, 31 - ����������� ������
--7, 8, 9, 20, 21, 14 - ������

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


--��� ������� ����� - �������� �������

SELECT POST.ID_post as '����� �����', 
IIF(LEN(CAST(Region as int))=1, '0' + CAST(Region as nvarchar(5)), CAST(Region as nvarchar(5))) as '��� ������� �����',
IIF(LEN(CAST(REGION.ID_region as int))=1, '0' + CAST(REGION.ID_region as nvarchar(5)), CAST(REGION.ID_region as nvarchar(5))) as '������� ��� �������',
REGION.Name_of_region as '������ �����' FROM 
[KB301_Mustafina].Mustafina.posts as POST INNER JOIN 
[KB301_Mustafina].Mustafina.region_codes as CODE ON POST.Region = CODE.Code INNER JOIN 
[KB301_Mustafina].Mustafina.regions as REGION ON CODE.ID_region = REGION.ID_region

--���������� �����������, ��������� �� ������ � ��������������� �� ��������

SELECT  REGION_CAR.ID_region as '��� �������',
REGION_CAR.Name_of_region as '������',  COUNT(REGION_CAR.Name_of_region) as '���������� �����������'
FROM [KB301_Mustafina].Mustafina.passages AS PASS LEFT JOIN
[KB301_Mustafina].Mustafina.cars as CAR ON PASS.ID_car = CAR.ID_car INNER JOIN
[KB301_Mustafina].Mustafina.region_codes as CODE_CAR ON CAR.Region_code = CODE_CAR.Code INNER JOIN 
[KB301_Mustafina].Mustafina.regions as REGION_CAR ON CODE_CAR.ID_region = REGION_CAR.ID_region
WHERE PASS.Entry_or_exit=0
GROUP BY REGION_CAR.Name_of_region, REGION_CAR.ID_region

--����� ������� �������� �� ����� ������������������ �������

SELECT CAR.Make as '�������������', CAR.Model as '�����', CAR.Color as '����', CAR.Year_of_issue as '��� ������������', CAR.Driver_name as '��������', 
CAR.State_number + IIF(LEN(CAST(CAR.Region_code as int))=1, '0' + CAST(CAR.Region_code as nvarchar(5)), CAST(CAR.Region_code as nvarchar(5))) as '���.�����',  
REGION_CAR.Name_of_region AS '������ ����������',
IIF(PASS.Entry_or_exit=1, '�����', '�����') as '�����/�����', POST.ID_post as '���� ������/������', 
IIF(LEN(CAST(POST.Region as int))=1, '0' + CAST(POST.Region as nvarchar(5)), CAST(CODE.ID_region as nvarchar(5))) as '��� ������� �����',
REGION.Name_of_region as '������ ������/������',
FORMAT(CAST(PASS.Passage_time as time), N'hh\:mm') as '����� ������/������' 
FROM
[KB301_Mustafina].Mustafina.passages AS PASS LEFT JOIN
[KB301_Mustafina].Mustafina.cars as CAR ON PASS.ID_car = CAR.ID_car INNER JOIN
[KB301_Mustafina].Mustafina.region_codes as CODE_CAR ON CAR.Region_code = CODE_CAR.Code INNER JOIN 
[KB301_Mustafina].Mustafina.regions as REGION_CAR ON CODE_CAR.ID_region = REGION_CAR.ID_region INNER JOIN

[KB301_Mustafina].Mustafina.posts as POST ON PASS.ID_post = POST.ID_post INNER JOIN 
[KB301_Mustafina].Mustafina.region_codes as CODE ON POST.Region = CODE.Code INNER JOIN 
[KB301_Mustafina].Mustafina.regions as REGION ON CODE.ID_region = REGION.ID_region 
ORDER BY PASS.Passage_time, POST.ID_post

--���������� ����������

CREATE VIEW transit_cars AS

SELECT CAR.Make as '�������������', CAR.Model as '�����', CAR.Color as '����', CAR.Year_of_issue as '��� ������������',
CAR.Driver_name as '��������', 
CAR.State_number + IIF(LEN(CAST(CAR.Region_code as int))=1, '0' + CAST(CAR.Region_code as nvarchar(5)), CAST(CAR.Region_code as nvarchar(5))) as '���.�����', 
REGION_CAR.Name_of_region as '������ ����������', POST_IN.ID_post as '���� ������', 
POST_OUT.ID_post as '���� ������', 
IIF(LEN(CAST(POST_OUT.Region as int))=1, '0' + CAST(POST_OUT.Region as nvarchar(5)), CAST(REGION_OUT.ID_region as nvarchar(5))) as '��� ������� ������', 
REGION_OUT.Name_of_region as '������ ������-������',
FORMAT(CAST(IN_CITY.Passage_time as time), N'hh\:mm') + ' - ' + FORMAT(cast(OUT_CITY.Passage_time as time), N'hh\:mm') as '����� ������-������'
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

--����������� ����������

CREATE VIEW nonresident_cars AS

SELECT CAR.Make as '�������������', CAR.Model as '�����', CAR.Color as '����', CAR.Year_of_issue as '��� ������������', 
CAR.Driver_name as '��������', 
CAR.State_number + IIF(LEN(CAST(CAR.Region_code as int))=1, '0' + CAST(CAR.Region_code as nvarchar(5)), CAST(CAR.Region_code as nvarchar(5))) as '���.�����', 
REGION_CAR.Name_of_region as '������ ����������', POST_IN.ID_post as '���� ������', 
POST_OUT.ID_post as '���� ������', 
IIF(LEN(CAST(POST_OUT.Region as int))=1, '0' + CAST(POST_OUT.Region as nvarchar(5)), CAST(REGION_OUT.ID_region as nvarchar(5))) as '��� ������� ������',
REGION_OUT.Name_of_region as '������ ������-������',
FORMAT(CAST(IN_CITY.Passage_time as time), N'hh\:mm') + ' - ' + FORMAT(cast(OUT_CITY.Passage_time as time), N'hh\:mm') as '����� ������-������'
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

--������� ����������

CREATE VIEW local_cars AS

SELECT CAR.Make as '�������������', CAR.Model as '�����', CAR.Color as '����', CAR.Year_of_issue as '��� ������������', 
CAR.Driver_name as '��������',
CAR.State_number + IIF(LEN(CAST(CAR.Region_code as int))=1, '0' + CAST(CAR.Region_code as nvarchar(5)), CAST(CAR.Region_code as nvarchar(5))) as '���.�����',  
REGION_CAR.Name_of_region as '������ ����������', POST_OUT.ID_post as '���� ������', POST_IN.ID_post as '���� ������', 
IIF(LEN(CAST(POST_OUT.Region as int))=1, '0' + CAST(POST_OUT.Region as nvarchar(5)), CAST(REGION_OUT.ID_region as nvarchar(5))) as '��� ������� ������',
REGION_OUT.Name_of_region as '������ ������-������',
FORMAT(CAST(OUT_CITY.Passage_time as time), N'hh\:mm') + ' - ' + FORMAT(cast(IN_CITY.Passage_time as time), N'hh\:mm') as '����� ������-������'
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


--������ ����������

CREATE VIEW other_cars AS

SELECT CAR.Make as '�������������', CAR.Model as '�����', CAR.Color as '����', CAR.Year_of_issue as '��� ������������', CAR.Driver_name as '��������', 
CAR.State_number + IIF(LEN(CAST(CAR.Region_code as int))=1, '0' + CAST(CAR.Region_code as nvarchar(5)), CAST(CAR.Region_code as nvarchar(5))) as '���.�����',  
REGION_CAR.Name_of_region as '������ ����������', 
IIF(PASS.Entry_or_exit=1, '�����', '�����') as '�����/�����', POST.ID_post as '���� ������/������', 
IIF(LEN(CAST(POST.Region as int))=1, '0' + CAST(POST.Region as nvarchar(5)), CAST(REGION.ID_region  as nvarchar(5))) as '��� ������� �����',
REGION.Name_of_region as '������ ������/������',
FORMAT(CAST(PASS.Passage_time as time), N'hh\:mm') as '����� ������/������' 

FROM [KB301_Mustafina].Mustafina.passages AS PASS LEFT JOIN
dbo.local_cars AS LOC ON PASS.ID_post = LOC.[���� ������] AND PASS.Passage_time = SUBSTRING(LOC.[����� ������-������], 1, 5) 
OR PASS.ID_post = LOC.[���� ������]  AND PASS.Passage_time = SUBSTRING(LOC.[����� ������-������], 9, 5) LEFT JOIN
dbo.nonresident_cars AS NON ON PASS.ID_post = NON.[���� ������] AND PASS.Passage_time = SUBSTRING(NON.[����� ������-������], 1, 5) 
OR PASS.ID_post = NON.[���� ������]  AND PASS.Passage_time = SUBSTRING(NON.[����� ������-������], 9, 5) LEFT JOIN
dbo.transit_cars AS TR ON PASS.ID_post = TR.[���� ������] AND PASS.Passage_time = SUBSTRING(TR.[����� ������-������], 1, 5) 
OR PASS.ID_post = TR.[���� ������]  AND PASS.Passage_time = SUBSTRING(TR.[����� ������-������], 9, 5) INNER JOIN

[KB301_Mustafina].Mustafina.cars as CAR ON PASS.ID_car = CAR.ID_car INNER JOIN
[KB301_Mustafina].Mustafina.region_codes as CODE_CAR ON CAR.Region_code = CODE_CAR.Code INNER JOIN 
[KB301_Mustafina].Mustafina.regions as REGION_CAR ON CODE_CAR.ID_region = REGION_CAR.ID_region INNER JOIN

[KB301_Mustafina].Mustafina.posts as POST ON PASS.ID_post = POST.ID_post INNER JOIN 
[KB301_Mustafina].Mustafina.region_codes as CODE ON POST.Region = CODE.Code INNER JOIN 
[KB301_Mustafina].Mustafina.regions as REGION ON CODE.ID_region = REGION.ID_region 
WHERE LOC.[���.�����] IS NULL AND NON.[���.�����] IS NULL AND TR.[���.�����] IS NULL
GO

SELECT * FROM dbo.other_cars

