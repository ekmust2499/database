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
Создание таблиц и определение внешних ключей
*/

CREATE TABLE [KB301_Mustafina].Mustafina.team
(
	ID_team tinyint NOT NULL, 
	Country nvarchar(50) NOT NULL, 
	Group_ char(1) NOT NULL, 
    CONSTRAINT PK_ID_team PRIMARY KEY (ID_team) 
)
GO

CREATE TABLE [KB301_Mustafina].Mustafina.role_of_player
(
	ID_role tinyint NOT NULL, 
	name_of_role nvarchar(20) NOT NULL, 
    CONSTRAINT PK_ID_role PRIMARY KEY (ID_role) 
)
GO


CREATE TABLE [KB301_Mustafina].Mustafina.match
(
	ID_match tinyint NOT NULL,
	ID_stadium tinyint NOT NULL, 	
	ID_first_team tinyint NOT NULL, 
	ID_second_team tinyint NOT NULL,
	Date_and_time_of_match smalldatetime NOT NULL, 
    CONSTRAINT PK_ID_match PRIMARY KEY (ID_match) 
)
GO

CREATE TABLE [KB301_Mustafina].Mustafina.stadium
(
	ID_stadium tinyint NOT NULL, 
	Name_of_stadium nvarchar(50) NOT NULL, 
    CONSTRAINT PK_ID_stadium PRIMARY KEY (ID_stadium) 
)
GO

CREATE TABLE [KB301_Mustafina].Mustafina.player
(
    ID_player tinyint NOT NULL, 
	Name_of_player nvarchar(50) NOT NULL, 
	ID_role tinyint NOT NULL, 
	ID_team tinyint NOT NULL,
	ID_match tinyint NOT NULL,
	Goal bit NULL, 
	Autogoal bit NULL,
	Time_of_goal tinyint NOT NULL,
    CONSTRAINT PK_ID_player PRIMARY KEY (ID_player, ID_match, Time_of_goal)
)
GO
/*
Создание внешних ключей
*/

ALTER TABLE [KB301_Mustafina].Mustafina.match ADD 
	CONSTRAINT FK_ID_stadium FOREIGN KEY (ID_stadium) 
	REFERENCES [KB301_Mustafina].Mustafina.stadium(ID_stadium)
GO	

ALTER TABLE [KB301_Mustafina].Mustafina.match ADD 
	CONSTRAINT FK_ID_first_team FOREIGN KEY (ID_first_team) 
	REFERENCES [KB301_Mustafina].Mustafina.team(ID_team)
GO	

ALTER TABLE [KB301_Mustafina].Mustafina.match ADD 
	CONSTRAINT FK_ID_second_team FOREIGN KEY (ID_second_team) 
	REFERENCES [KB301_Mustafina].Mustafina.team(ID_team)
GO	

ALTER TABLE [KB301_Mustafina].Mustafina.player ADD 
	CONSTRAINT FK_ID_role_of_player FOREIGN KEY (ID_role) 
	REFERENCES [KB301_Mustafina].Mustafina.role_of_player(ID_role)
GO


ALTER TABLE [KB301_Mustafina].Mustafina.player ADD 
	CONSTRAINT FK_ID_team_of_player FOREIGN KEY (ID_team) 
	REFERENCES [KB301_Mustafina].Mustafina.team(ID_team)
GO

ALTER TABLE [KB301_Mustafina].Mustafina.player ADD 
	CONSTRAINT FK_ID_match_of_player FOREIGN KEY (ID_match) 
	REFERENCES [KB301_Mustafina].Mustafina.match(ID_match)
GO

/*
Заполнение таблиц
*/

INSERT INTO [KB301_Mustafina].Mustafina.stadium
 (ID_stadium, Name_of_stadium)
 VALUES 
  (1,N'Лужники')
 ,(2,N'Газпром Арена')
 ,(3,N'Волгоград Арена')
 ,(4,N'Казань Арена')
 ,(5,N'Екатеринбург Арена')
 ,(6,N'Сочи Арена')
 ,(7,N'Ростов Арена')
 ,(8,N'Самара Арена')
GO

INSERT INTO [KB301_Mustafina].Mustafina.team
 (ID_team, Country, Group_)
 VALUES 
  (1,N'Россия', 'A')
 ,(2,N'Уругвай', 'A')
 ,(3,N'Саудовская Аравия', 'A')
 ,(4,N'Египет', 'A')
 ,(5,N'Испания', 'B')
 ,(6,N'Португалия', 'B')
 ,(7,N'Иран', 'B')
 ,(8,N'Марокко', 'B')
 ,(9,N'Франция', 'C')
 ,(10,N'Дания', 'C')
 ,(11,N'Перу', 'C')
 ,(12,N'Австралия', 'C')
 ,(13,N'Хорватия', 'D')
 ,(14,N'Аргентина', 'D')
 ,(15,N'Нигерия', 'D')
 ,(16,N'Исландия', 'D')
GO

INSERT INTO [KB301_Mustafina].Mustafina.role_of_player
 (ID_role, name_of_role)
 VALUES 
 (11,N'Вратарь')
 ,(22,N'Нападающий')
 ,(33,N'Защитник')
 ,(44,N'Полузащитник')
GO


INSERT INTO [KB301_Mustafina].Mustafina.match
 (ID_match, ID_stadium, ID_first_team, ID_second_team, Date_and_time_of_match)
 VALUES 
 (1, 8, 1, 2, '25.06.2018 17:00:00.000')
 ,(2, 7, 2, 3, '20.06.2018 18:00:00.000')
 ,(3, 5, 2, 4, '15.06.2018 15:00:00.000')
 ,(4, 1, 1, 3, '14.06.2018 18:00:00.000')
 ,(5, 2, 1, 4, '19.06.2018 21:00:00.000')
 ,(6, 3, 3, 4, '25.06.2018 17:00:00.000')
 ,(7, 2, 7, 8, '15.06.2018 18:00:00.000')
 ,(8, 6, 5, 6, '15.06.2018 21:00:00.000')
 ,(9, 1, 6, 8, '20.06.2018 15:00:00.000')
 ,(10, 4, 5, 7, '20.06.2018 21:00:00.000')
 ,(11, 5, 5, 8, '25.06.2018 21:00:00.000')
 ,(12, 7, 6, 7, '25.06.2018 21:00:00.000')
 ,(13, 4, 9, 12, '16.06.2018 13:00:00.000')
 ,(14, 3, 10, 11, '16.06.2018 19:00:00.000')
 ,(15, 8, 10, 12, '21.06.2018 15:00:00.000')
 ,(16, 5, 9, 11, '21.06.2018 18:00:00.000')
 ,(17, 6, 11, 12, '26.06.2018 17:00:00.000')
 ,(18, 1, 9, 10, '26.06.2018 17:00:00.000')
 ,(19, 1, 14, 16, '16.06.2018 16:00:00.000')
 ,(20, 6, 13, 15, '16.06.2018 22:00:00.000')
 ,(21, 4, 13, 14, '21.06.2018 21:00:00.000')
 ,(22, 3, 15, 16, '22.06.2018 18:00:00.000')
 ,(23, 2, 14, 15, '26.06.2018 21:00:00.000')
 ,(24, 7, 13, 16, '26.06.2018 21:00:00.000')
GO

INSERT INTO [KB301_Mustafina].Mustafina.player
 (ID_player, Name_of_player, ID_role, ID_team,
	ID_match, Goal,	Autogoal, Time_of_goal)
 VALUES 
  (8,N'Юрий Газинский', 44, 1, 4, 1, 0, 12)
  ,(6,N'Денис Черышев', 44, 1, 4, 1, 0, 43)
  ,(22,N'Артём Дзюба', 22, 1, 4, 1, 0, 71)
  ,(6,N'Денис Черышев', 44, 1, 4, 1, 0, 91)
  ,(17,N'Александр Головин', 44, 1, 4, 1, 0, 94)
  ,(2,N'Хосе Химинес', 33, 2, 3, 1, 0, 89)
  ,(20,N'Азиз Бухаддуз', 22, 8, 7, 0, 1, 95)
  ,(7,N'Криштиану Роналду', 22, 6, 8, 1, 0, 4)
  ,(7,N'Криштиану Роналду', 22, 6, 8, 1, 0, 44)
  ,(7,N'Криштиану Роналду', 22, 6, 8, 1, 0, 88)
  ,(19,N'Диего Коста', 22, 5, 8, 1, 0, 24)
  ,(19,N'Диего Коста', 22, 5, 8, 1, 0, 55)
  ,(4,N'Начо', 33, 5, 8, 1, 0, 58)
  ,(5,N'Антуан Гризманн', 22, 9, 13, 1, 0, 58)
  ,(16,N'Азиз Бехич', 33, 12, 13, 0, 1, 81)
  ,(15,N'Миле Йединак', 44, 12, 13, 1, 0, 62)
  ,(23,N'Серхио Агуэро', 22, 14, 19, 1, 0, 19)
  ,(11,N'Альфред Финнбогасон', 22, 16, 19, 1, 0, 23)
  ,(21,N'Юссуф Поульсен', 22, 10, 14, 1, 0, 59)
  ,(2,N'Огенекаро Этебо', 44, 15, 20, 0, 1, 32)
  ,(10,N'Лука Модрич', 44, 13, 20, 1, 0, 71)
  ,(3,N'Ахмед Фатхи', 33, 4, 5, 0, 1, 47)
  ,(22,N'Артём Дзюба', 22, 1, 5, 1, 0, 62)
  ,(6,N'Денис Черышев', 44, 1, 5, 1, 0, 59)
  ,(18,N'Мохамед Салах', 22, 4, 5, 1, 0, 73)
  ,(7,N'Криштиану Роналду', 22, 6, 9, 1, 0, 4)
  ,(9,N'Луис Суарес', 22, 2, 2, 1, 0, 23) 
  ,(19,N'Диего Коста', 22, 5, 10, 1, 0, 54)
  ,(12,N'Кристиан Эриксен', 44, 10, 15, 1, 0, 7) 
  ,(15,N'Миле Йединак', 44, 12, 15, 1, 0, 38)
  ,(1,N'Килиан Мбаппе', 22, 9, 16, 1, 0, 34)
  ,(14,N'Анте Ребич', 22, 13, 21, 1, 0, 53)
  ,(10,N'Лука Модрич', 44, 13, 21, 1, 0, 80)
  ,(5,N'Иван Ракитич', 44, 13, 21, 1, 0, 91)
  ,(4,N'Ахмед Муса', 22, 15, 22, 1, 0, 49)
  ,(4,N'Ахмед Муса', 22, 15, 22, 1, 0, 75)
  ,(9,N'Луис Суарес', 22, 2, 1, 1, 0, 10) 
  ,(6,N'Денис Черышев', 44, 1, 1, 0, 1, 23) 
  ,(13,N'Эдинсон Кавани', 22, 2, 1, 1, 0, 90) 
  ,(24,N'Салман аль-Фарадж', 44, 3, 6, 1, 0, 51) 
  ,(25,N'Салим ад-Давсари', 44, 3, 6, 1, 0, 95) 
  ,(26,N'Мохамед Салах', 22, 4, 6, 1, 0, 22) 
  ,(27,N'Иско', 44, 5, 11, 1, 0, 19) 
  ,(28,N'Яго Аспас', 22, 5, 11, 1, 0, 91) 
  ,(29,N'Халид Бутаиб', 22, 8, 11, 1, 0, 14) 
  ,(30,N'Юсиф ан-Несири', 22, 8, 11, 1, 0, 81) 
  ,(31,N'Кариму Ансарифарду', 22, 7, 12, 1, 0, 93) 
  ,(32,N'Рикарду Каурежма', 22, 6, 12, 1, 0, 45) 
  ,(33,N'Андре Каррильо', 22, 11, 17, 1, 0, 18) 
  ,(34,N'Паоло Герреро', 22, 11, 17, 1, 0, 50) 
  ,(35,N'Виктор Мозес', 22, 15, 23, 1, 0, 51) 
  ,(36,N'Лионель Месси', 22, 14, 23, 1, 0, 14) 
  ,(37,N'Маркос Рохо', 33, 14, 23, 1, 0, 86) 
  ,(38,N'Гильфи Сигурдссона', 44, 16, 24, 1, 0, 76) 
  ,(39,N'Милан Бадель', 44, 13, 24, 1, 0, 53) 
  ,(40,N'Иван Перишич', 33, 13, 24, 1, 0, 90) 
GO

SELECT *
FROM [KB301_Mustafina].Mustafina.stadium

SELECT *
FROM [KB301_Mustafina].Mustafina.team

SELECT *
FROM [KB301_Mustafina].Mustafina.role_of_player

SELECT *
FROM [KB301_Mustafina].Mustafina.match

SELECT *
FROM [KB301_Mustafina].Mustafina.player

/*ПЕРВЫЙ ЗАПРОС*/
--Вывести список команд, упорядоченный по группам и алфавиту.
SELECT Country AS 'Страна'
	  ,Group_ AS 'Группа'
FROM [KB301_Mustafina].Mustafina.team
ORDER BY Группа, Страна

SELECT Country AS 'Страна'
	  ,Group_ AS 'Группа'
FROM [KB301_Mustafina].Mustafina.team
ORDER BY Страна
/*КОНЕЦ ПЕРВОГО ЗАПРОСА*/

/*ВЫВЕСТИ СПИСОК МАТЧЕЙ В ОПРЕДЕЛЕННЫЙ ПЕРИОД ВРЕМЕНИ*/
SELECT *
FROM (
	SELECT M.Date_and_time_of_match as 'Дата и время матча', A.Country as 'Страна №1', B.Country as 'Страна №2'
	FROM [KB301_Mustafina].Mustafina.match M INNER JOIN   
		 [KB301_Mustafina].Mustafina.team A ON M.ID_first_team = A.ID_team INNER JOIN
		 [KB301_Mustafina].Mustafina.team B ON M.ID_second_team = B.ID_team INNER JOIN
	     [KB301_Mustafina].Mustafina.player PL ON M.ID_match = PL.ID_match
	GROUP BY M.Date_and_time_of_match, M.ID_match, A.Country, B.Country) as F
WHERE CAST([Дата и время матча] AS date) >= '2018-06-25' and CAST([Дата и время матча] AS date) <= '2018-06-26'
/*КОНЕЦ ЗАПРОСА*/


--IF OBJECT_ID('#T3', 'U') IS NOT NULL
DROP TABLE #T3


/*ВТОРОЙ ЗАПРОС*/
--Вывести список матчей с результатами.
SELECT [Дата и время матча], Name_of_stadium as 'Стадион', [Страна №1], [Голы страны №1], [Страна №2], [Голы страны №2]
INTO #T3
FROM(
	/*Обе команды за время матча забили голы*/
	SELECT ONE.ID_match, ONE.ID_stadium, [Дата и время матча], 
		   TWO.[Страна №1], TWO.[Голы страны №1] + THREE.[Автоголы страны №2] as 'Голы страны №1', 
		   THREE.[Страна №2], THREE.[Голы страны №2] + TWO.[Автоголы страны №1] as 'Голы страны №2'
	FROM (
		SELECT M.ID_match, M.ID_stadium, M.Date_and_time_of_match as 'Дата и время матча', 
			   A.Country as 'Страна #1', B.Country as 'Страна #2'
		FROM [KB301_Mustafina].Mustafina.match M INNER JOIN   
			 [KB301_Mustafina].Mustafina.team A ON M.ID_first_team = A.ID_team INNER JOIN
			 [KB301_Mustafina].Mustafina.team B ON M.ID_second_team = B.ID_team) as ONE INNER JOIN (
		/*СПИСОК ГОЛОВ*/
		SELECT SUM(CAST(Goal AS tinyint)) as 'Голы страны №1', SUM(CAST(Autogoal AS tinyint)) as 'Автоголы страны №1', 
			  ID_match, Country as 'Страна №1'
		FROM [KB301_Mustafina].Mustafina.player PL INNER JOIN   
			 [KB301_Mustafina].Mustafina.team T ON PL.ID_team = T.ID_team
		GROUP BY ID_match, T.Country /**/) AS TWO 
		ON ONE.ID_match =TWO.ID_match and ONE.[Страна #1] = TWO.[Страна №1] INNER JOIN (
		SELECT SUM(CAST(Goal AS tinyint)) as 'Голы страны №2', SUM(CAST(Autogoal AS tinyint)) as 'Автоголы страны №2', 
			   ID_match as 'id', Country as 'Страна №2'
		FROM [KB301_Mustafina].Mustafina.player P INNER JOIN   
			 [KB301_Mustafina].Mustafina.team Team ON P.ID_team = Team.ID_team
		GROUP BY ID_match, Team.Country ) as THREE 
		ON ONE.[Страна #2] = THREE.[Страна №2] and ONE.ID_match =THREE.id
	--ORDER BY [Дата и время матча]
	UNION 

	/*Заносим голы, которые забивала первая команда, а у второй команды 0 голов за матч*/
	SELECT ONE.ID_match, ONE.ID_stadium, [Дата и время матча], 
		   TWO.[Страна №1], TWO.[Голы страны №1], ONE.[Страна #2], 0 + TWO.[Автоголы страны №1] as 'Голы страны №2'
	FROM (
		SELECT M.ID_match, M.ID_stadium, M.Date_and_time_of_match as 'Дата и время матча',
			   A.Country as 'Страна #1', B.Country as 'Страна #2'
		FROM [KB301_Mustafina].Mustafina.match M INNER JOIN   
			 [KB301_Mustafina].Mustafina.team A ON M.ID_first_team = A.ID_team INNER JOIN
			 [KB301_Mustafina].Mustafina.team B ON M.ID_second_team = B.ID_team) as ONE INNER JOIN (
		SELECT * FROM (
		/*Все голы за каждый матч для каждой команды*/
			SELECT SUM(CAST(Goal AS tinyint)) as 'Голы страны №1', 
				   SUM(CAST(Autogoal AS tinyint)) as 'Автоголы страны №1', ID_match, Country as 'Страна №1'
			FROM [KB301_Mustafina].Mustafina.player PL INNER JOIN   
				 [KB301_Mustafina].Mustafina.team T ON PL.ID_team = T.ID_team
			GROUP BY ID_match, T.Country) AS F  
			WHERE F.ID_match not in (SELECT T.ID_match FROM (
			SELECT ONE.ID_match, ONE.ID_stadium, [Дата и время матча], 
				   TWO.[Страна №1], TWO.[Голы страны №1] + THREE.[Автоголы страны №2] as 'Голы страны №1', 
				   THREE.[Страна №2], THREE.[Голы страны №2] + TWO.[Автоголы страны №1] as 'Голы страны №2'
			FROM (
				SELECT M.ID_match, M.ID_stadium, M.Date_and_time_of_match as 'Дата и время матча', 
					   A.Country as 'Страна #1', B.Country as 'Страна #2'
				FROM [KB301_Mustafina].Mustafina.match M INNER JOIN   
					 [KB301_Mustafina].Mustafina.team A ON M.ID_first_team = A.ID_team INNER JOIN
					 [KB301_Mustafina].Mustafina.team B ON M.ID_second_team = B.ID_team) as ONE INNER JOIN (
				/*СПИСОК ГОЛОВ*/
				SELECT SUM(CAST(Goal AS tinyint)) as 'Голы страны №1', SUM(CAST(Autogoal AS tinyint)) as 'Автоголы страны №1', 
					  ID_match, Country as 'Страна №1'
				FROM [KB301_Mustafina].Mustafina.player PL INNER JOIN   
					 [KB301_Mustafina].Mustafina.team T ON PL.ID_team = T.ID_team
				GROUP BY ID_match, T.Country /**/) AS TWO 
				ON ONE.ID_match =TWO.ID_match and ONE.[Страна #1] = TWO.[Страна №1] INNER JOIN (
				SELECT SUM(CAST(Goal AS tinyint)) as 'Голы страны №2', SUM(CAST(Autogoal AS tinyint)) as 'Автоголы страны №2', 
					   ID_match as 'id', Country as 'Страна №2'
				FROM [KB301_Mustafina].Mustafina.player P INNER JOIN   
					 [KB301_Mustafina].Mustafina.team Team ON P.ID_team = Team.ID_team
				GROUP BY ID_match, Team.Country ) as THREE 
				ON ONE.[Страна #2] = THREE.[Страна №2] and ONE.ID_match =THREE.id) as T)) 
				AS TWO ON ONE.ID_match = TWO.ID_match and ONE.[Страна #1]=TWO.[Страна №1]

	UNION

	/*Заносим голы, которые забивала вторая команда, а у первой команды 0 голов за матч*/
	SELECT ONE.ID_match, ONE.ID_stadium, [Дата и время матча], 
		   ONE.[Страна #1], 0 + TWO.[Автоголы страны №2] as 'Голы страны №1', 
		   TWO.[Страна №2], TWO.[Голы страны №2]
	FROM (
		SELECT M.ID_match, M.ID_stadium, M.Date_and_time_of_match as 'Дата и время матча', 
			   A.Country as 'Страна #1', B.Country as 'Страна #2'
		FROM [KB301_Mustafina].Mustafina.match M INNER JOIN   
			 [KB301_Mustafina].Mustafina.team A ON M.ID_first_team = A.ID_team INNER JOIN
			 [KB301_Mustafina].Mustafina.team B ON M.ID_second_team = B.ID_team) as ONE INNER JOIN (
		SELECT * FROM (
			SELECT SUM(CAST(Goal AS tinyint)) as 'Голы страны №2', 
				   SUM(CAST(Autogoal AS tinyint)) as 'Автоголы страны №2', ID_match, Country as 'Страна №2'
			FROM [KB301_Mustafina].Mustafina.player PL INNER JOIN   
				 [KB301_Mustafina].Mustafina.team T ON PL.ID_team = T.ID_team
			GROUP BY ID_match, T.Country) AS F  
			WHERE F.ID_match not in (SELECT T.ID_match FROM
			(
			SELECT ONE.ID_match, ONE.ID_stadium, [Дата и время матча], 
				   TWO.[Страна №1], TWO.[Голы страны №1] + THREE.[Автоголы страны №2] as 'Голы страны №1', 
				   THREE.[Страна №2], THREE.[Голы страны №2] + TWO.[Автоголы страны №1] as 'Голы страны №2'
			FROM (
				SELECT M.ID_match, M.ID_stadium, M.Date_and_time_of_match as 'Дата и время матча', 
					   A.Country as 'Страна #1', B.Country as 'Страна #2'
				FROM [KB301_Mustafina].Mustafina.match M INNER JOIN   
					 [KB301_Mustafina].Mustafina.team A ON M.ID_first_team = A.ID_team INNER JOIN
					 [KB301_Mustafina].Mustafina.team B ON M.ID_second_team = B.ID_team) as ONE INNER JOIN (
				/*СПИСОК ГОЛОВ*/
				SELECT SUM(CAST(Goal AS tinyint)) as 'Голы страны №1', SUM(CAST(Autogoal AS tinyint)) as 'Автоголы страны №1', 
					  ID_match, Country as 'Страна №1'
				FROM [KB301_Mustafina].Mustafina.player PL INNER JOIN   
					 [KB301_Mustafina].Mustafina.team T ON PL.ID_team = T.ID_team
				GROUP BY ID_match, T.Country /**/) AS TWO 
				ON ONE.ID_match =TWO.ID_match and ONE.[Страна #1] = TWO.[Страна №1] INNER JOIN (
				SELECT SUM(CAST(Goal AS tinyint)) as 'Голы страны №2', SUM(CAST(Autogoal AS tinyint)) as 'Автоголы страны №2', 
					   ID_match as 'id', Country as 'Страна №2'
				FROM [KB301_Mustafina].Mustafina.player P INNER JOIN   
					 [KB301_Mustafina].Mustafina.team Team ON P.ID_team = Team.ID_team
				GROUP BY ID_match, Team.Country ) as THREE 
				ON ONE.[Страна #2] = THREE.[Страна №2] and ONE.ID_match =THREE.id) as T))  
				AS TWO ON ONE.ID_match = TWO.ID_match and ONE.[Страна #2]=TWO.[Страна №2]

	UNION 

/*Команды сыграли 0-0*/
	SELECT ONE.ID_match, ONE.ID_stadium, ONE.[Дата и время матча], 
		   ONE.[Страна #1], 0 as 'Голы страны №1', ONE.[Страна #2], 0 as 'Голы страны №2'
	FROM (
		SELECT M.ID_match, M.ID_stadium, M.Date_and_time_of_match as 'Дата и время матча', A.Country as 'Страна #1', B.Country as 'Страна #2'
		FROM [KB301_Mustafina].Mustafina.match M INNER JOIN   
			 [KB301_Mustafina].Mustafina.team A ON M.ID_first_team = A.ID_team INNER JOIN
			 [KB301_Mustafina].Mustafina.team B ON M.ID_second_team = B.ID_team) as ONE
		WHERE ONE.ID_match not in 
		(SELECT TWO.ID_match 
		FROM (
			SELECT SUM(CAST(Goal AS tinyint)) as 'Голы', 
				   SUM(CAST(Autogoal AS tinyint)) as 'Автоголы', ID_match, Country as 'Страна'
			FROM [KB301_Mustafina].Mustafina.player PL INNER JOIN   
				 [KB301_Mustafina].Mustafina.team T ON PL.ID_team = T.ID_team
			GROUP BY ID_match, T.Country) as TWO)) as RESULT 
	INNER JOIN [KB301_Mustafina].Mustafina.stadium as ST ON RESULT.ID_stadium = ST.ID_stadium
	/*WHERE CAST(F.[Дата и время матча] AS date) >= '2018-06-20' and CAST(F.[Дата и время матча] AS date) <= '2018-06-21'*/
	

SELECT *
FROM #T3
ORDER BY [Дата и время матча]


SELECT [Дата и время матча], Стадион, CONCAT([Страна №1], ' - ', [Страна №2]) as 'Команды', CONCAT([Голы страны №1], ':', [Голы страны №2]) as 'Счёт'
FROM #T3
ORDER BY [Дата и время матча]
/*КОНЕЦ ВТОРОГО ЗАПРОСА*/


DROP TABLE #T2

/*ТРЕТИЙ ЗАПРОС*/
--Вывести список команд по группам (для определенной группы) упорядоченный по очкам.
SELECT team.Group_ as 'Группа', team.Country as 'Страна', Очки
INTO #T2
FROM [KB301_Mustafina].Mustafina.team as team LEFT JOIN
/*LEFT JOIN потому что к определенной дате не было еще игр у команды, тогда у них в колонке с очками будет стоять NULL.*/
(SELECT Страна, SUM(CAST(Очки AS tinyint)) as 'Очки'
FROM ([KB301_Mustafina].Mustafina.team as TEAM INNER JOIN(

	/*ГРУППИРУЕМ ПО ПЕРВОЙ КОМАНДЕ ОЧКИ*/
	SELECT [Страна №1] as 'Страна', SUM(CAST([Очки страны №1] AS tinyint)) as 'Очки'
	FROM(
	/*ВЫИГРАЛА ПЕРВАЯ КОМАНДА, ЕЙ 3 ОЧКА*/
		SELECT [Дата и время матча], [Страна №1], 3 as 'Очки страны №1', [Страна №2], 0 as 'Очки страны №2' 
		FROM #T3 as TABL INNER JOIN  [KB301_Mustafina].Mustafina.team as TEAM ON TABL.[Страна №1] = TEAM.Country
		WHERE TABL.[Голы страны №1] > TABL.[Голы страны №2]
		UNION
	/*КОМАНДЫ СЫГРАЛИ В НИЧЬЮ, КАЖДОЙ ПО 1 ОЧКУ*/ 
		SELECT [Дата и время матча], [Страна №1], 1 as 'Очки страны №1', [Страна №2], 1 as 'Очки страны №2'
		FROM #T3 as TABL INNER JOIN  [KB301_Mustafina].Mustafina.team as TEAM ON TABL.[Страна №1] = TEAM.Country
		WHERE TABL.[Голы страны №1] = TABL.[Голы страны №2]
		UNION
	/*ВЫИГРАЛА ВТОРАЯ КОМАНДА, ЕЙ 3 ОЧКА*/
		SELECT [Дата и время матча], [Страна №1], 0 as 'Очки страны №1', [Страна №2], 3 as 'Очки страны №2'
		FROM #T3 as TABL INNER JOIN  [KB301_Mustafina].Mustafina.team as TEAM ON TABL.[Страна №1] = TEAM.Country
		WHERE TABL.[Голы страны №1] < TABL.[Голы страны №2]) as group1
	GROUP BY [Страна №1]

UNION
	/*ГРУППИРУЕМ ПО ВТОРОЙ КОМАНДЕ ОЧКИ*/
	SELECT [Страна №2] as 'Страна', SUM(CAST([Очки страны №2] AS tinyint)) as 'Очки'
	FROM(
	/*ВЫИГРАЛА ПЕРВАЯ КОМАНДА, ЕЙ 3 ОЧКА*/
		SELECT [Дата и время матча], [Страна №1], 3 as 'Очки страны №1', [Страна №2], 0 as 'Очки страны №2' 
		FROM #T3 as TABL INNER JOIN  [KB301_Mustafina].Mustafina.team as TEAM ON TABL.[Страна №1] = TEAM.Country
		WHERE TABL.[Голы страны №1] > TABL.[Голы страны №2]
		UNION
	/*КОМАНДЫ СЫГРАЛИ В НИЧЬЮ, КАЖДОЙ ПО 1 ОЧКУ*/
		SELECT [Дата и время матча], [Страна №1], 1 as 'Очки страны №1', [Страна №2], 1 as 'Очки страны №2'
		FROM #T3 TABL INNER JOIN  [KB301_Mustafina].Mustafina.team as TEAM ON TABL.[Страна №1] = TEAM.Country
		WHERE TABL.[Голы страны №1] = TABL.[Голы страны №2]
		UNION
	/*ВЫИГРАЛА ВТОРАЯ КОМАНДА, ЕЙ 3 ОЧКА*/
		SELECT [Дата и время матча], [Страна №1], 0 as 'Очки страны №1', [Страна №2], 3 as 'Очки страны №2'
		FROM #T3 as TABL INNER JOIN  [KB301_Mustafina].Mustafina.team as TEAM ON TABL.[Страна №1] = TEAM.Country
		WHERE TABL.[Голы страны №1] < TABL.[Голы страны №2]) as group2
	GROUP BY [Страна №2]) 
as TABL ON TEAM.Country = TABL.Страна)
GROUP BY Страна) as tabl ON team.Country = tabl.Страна
/*WHERE team.Group_ = 'B'*/

SELECT *
FROM #T2
/*КОНЕЦ ТРЕТЬЕГО ЗАПРОСА*/



/*ЧЕТВЕРТЫЙ ЗАПРОС*/
--Вывести итоговую таблицу по группам с очками, забитыми и пропущенными мячами.
SELECT TEAM.Group_ as 'Группа', TEAM.Country as 'Страна', [Забитые голы], [Пропущенные голы], Очки
FROM [KB301_Mustafina].Mustafina.team as TEAM INNER JOIN(
	SELECT Страна, SUM(CAST([Забитые голы] AS tinyint)) as 'Забитые голы', 
		   SUM(CAST([Пропущенные голы] AS tinyint)) as 'Пропущенные голы'
	FROM( 
		SELECT [Страна №1] as 'Страна', SUM(CAST([Голы страны №1] AS tinyint)) as 'Забитые голы', 
			   SUM(CAST([Голы страны №2] AS tinyint)) as 'Пропущенные голы'
		FROM #T3 as tabl
		GROUP BY tabl.[Страна №1]
	UNION
		SELECT [Страна №2] as 'Страна', SUM(CAST([Голы страны №2] AS tinyint)) as 'Забитые голы', 
			   SUM(CAST([Голы страны №1] AS tinyint)) as 'Пропущенные голы'
		FROM #T3 as tabl
		GROUP BY tabl.[Страна №2]) as PromTable 
	GROUP BY Страна) as T1 ON TEAM.Country = T1.Страна INNER JOIN 
/*ТАБЛИЦА С ОЧКАМИ ИЗ ТРЕТЬЕГО ЗАПРОСА*/
#T2 as T2 ON TEAM.Country = T2.Страна
/*WHERE team.Group_ = 'B'*/
/*КОНЕЦ ЧЕТВЕРТОГО ЗАПРОСА*/
