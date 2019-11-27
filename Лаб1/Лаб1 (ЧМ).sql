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
�������� ������ � ����������� ������� ������
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
�������� ������� ������
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
���������� ������
*/

INSERT INTO [KB301_Mustafina].Mustafina.stadium
 (ID_stadium, Name_of_stadium)
 VALUES 
  (1,N'�������')
 ,(2,N'������� �����')
 ,(3,N'��������� �����')
 ,(4,N'������ �����')
 ,(5,N'������������ �����')
 ,(6,N'���� �����')
 ,(7,N'������ �����')
 ,(8,N'������ �����')
GO

INSERT INTO [KB301_Mustafina].Mustafina.team
 (ID_team, Country, Group_)
 VALUES 
  (1,N'������', 'A')
 ,(2,N'�������', 'A')
 ,(3,N'���������� ������', 'A')
 ,(4,N'������', 'A')
 ,(5,N'�������', 'B')
 ,(6,N'����������', 'B')
 ,(7,N'����', 'B')
 ,(8,N'�������', 'B')
 ,(9,N'�������', 'C')
 ,(10,N'�����', 'C')
 ,(11,N'����', 'C')
 ,(12,N'���������', 'C')
 ,(13,N'��������', 'D')
 ,(14,N'���������', 'D')
 ,(15,N'�������', 'D')
 ,(16,N'��������', 'D')
GO

INSERT INTO [KB301_Mustafina].Mustafina.role_of_player
 (ID_role, name_of_role)
 VALUES 
 (11,N'�������')
 ,(22,N'����������')
 ,(33,N'��������')
 ,(44,N'������������')
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
  (8,N'���� ���������', 44, 1, 4, 1, 0, 12)
  ,(6,N'����� �������', 44, 1, 4, 1, 0, 43)
  ,(22,N'���� �����', 22, 1, 4, 1, 0, 71)
  ,(6,N'����� �������', 44, 1, 4, 1, 0, 91)
  ,(17,N'��������� �������', 44, 1, 4, 1, 0, 94)
  ,(2,N'���� �������', 33, 2, 3, 1, 0, 89)
  ,(20,N'���� ��������', 22, 8, 7, 0, 1, 95)
  ,(7,N'��������� �������', 22, 6, 8, 1, 0, 4)
  ,(7,N'��������� �������', 22, 6, 8, 1, 0, 44)
  ,(7,N'��������� �������', 22, 6, 8, 1, 0, 88)
  ,(19,N'����� �����', 22, 5, 8, 1, 0, 24)
  ,(19,N'����� �����', 22, 5, 8, 1, 0, 55)
  ,(4,N'����', 33, 5, 8, 1, 0, 58)
  ,(5,N'������ ��������', 22, 9, 13, 1, 0, 58)
  ,(16,N'���� �����', 33, 12, 13, 0, 1, 81)
  ,(15,N'���� �������', 44, 12, 13, 1, 0, 62)
  ,(23,N'������ ������', 22, 14, 19, 1, 0, 19)
  ,(11,N'������� �����������', 22, 16, 19, 1, 0, 23)
  ,(21,N'����� ��������', 22, 10, 14, 1, 0, 59)
  ,(2,N'��������� �����', 44, 15, 20, 0, 1, 32)
  ,(10,N'���� ������', 44, 13, 20, 1, 0, 71)
  ,(3,N'����� �����', 33, 4, 5, 0, 1, 47)
  ,(22,N'���� �����', 22, 1, 5, 1, 0, 62)
  ,(6,N'����� �������', 44, 1, 5, 1, 0, 59)
  ,(18,N'������� �����', 22, 4, 5, 1, 0, 73)
  ,(7,N'��������� �������', 22, 6, 9, 1, 0, 4)
  ,(9,N'���� ������', 22, 2, 2, 1, 0, 23) 
  ,(19,N'����� �����', 22, 5, 10, 1, 0, 54)
  ,(12,N'�������� �������', 44, 10, 15, 1, 0, 7) 
  ,(15,N'���� �������', 44, 12, 15, 1, 0, 38)
  ,(1,N'������ ������', 22, 9, 16, 1, 0, 34)
  ,(14,N'���� �����', 22, 13, 21, 1, 0, 53)
  ,(10,N'���� ������', 44, 13, 21, 1, 0, 80)
  ,(5,N'���� �������', 44, 13, 21, 1, 0, 91)
  ,(4,N'����� ����', 22, 15, 22, 1, 0, 49)
  ,(4,N'����� ����', 22, 15, 22, 1, 0, 75)
  ,(9,N'���� ������', 22, 2, 1, 1, 0, 10) 
  ,(6,N'����� �������', 44, 1, 1, 0, 1, 23) 
  ,(13,N'������� ������', 22, 2, 1, 1, 0, 90) 
  ,(24,N'������ ���-������', 44, 3, 6, 1, 0, 51) 
  ,(25,N'����� ��-�������', 44, 3, 6, 1, 0, 95) 
  ,(26,N'������� �����', 22, 4, 6, 1, 0, 22) 
  ,(27,N'����', 44, 5, 11, 1, 0, 19) 
  ,(28,N'��� �����', 22, 5, 11, 1, 0, 91) 
  ,(29,N'����� ������', 22, 8, 11, 1, 0, 14) 
  ,(30,N'���� ��-������', 22, 8, 11, 1, 0, 81) 
  ,(31,N'������ �����������', 22, 7, 12, 1, 0, 93) 
  ,(32,N'������� ��������', 22, 6, 12, 1, 0, 45) 
  ,(33,N'����� ��������', 22, 11, 17, 1, 0, 18) 
  ,(34,N'����� �������', 22, 11, 17, 1, 0, 50) 
  ,(35,N'������ �����', 22, 15, 23, 1, 0, 51) 
  ,(36,N'������� �����', 22, 14, 23, 1, 0, 14) 
  ,(37,N'������ ����', 33, 14, 23, 1, 0, 86) 
  ,(38,N'������ �����������', 44, 16, 24, 1, 0, 76) 
  ,(39,N'����� ������', 44, 13, 24, 1, 0, 53) 
  ,(40,N'���� �������', 33, 13, 24, 1, 0, 90) 
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

/*������ ������*/
--������� ������ ������, ������������� �� ������� � ��������.
SELECT Country AS '������'
	  ,Group_ AS '������'
FROM [KB301_Mustafina].Mustafina.team
ORDER BY ������, ������

SELECT Country AS '������'
	  ,Group_ AS '������'
FROM [KB301_Mustafina].Mustafina.team
ORDER BY ������
/*����� ������� �������*/

/*������� ������ ������ � ������������ ������ �������*/
SELECT *
FROM (
	SELECT M.Date_and_time_of_match as '���� � ����� �����', A.Country as '������ �1', B.Country as '������ �2'
	FROM [KB301_Mustafina].Mustafina.match M INNER JOIN   
		 [KB301_Mustafina].Mustafina.team A ON M.ID_first_team = A.ID_team INNER JOIN
		 [KB301_Mustafina].Mustafina.team B ON M.ID_second_team = B.ID_team INNER JOIN
	     [KB301_Mustafina].Mustafina.player PL ON M.ID_match = PL.ID_match
	GROUP BY M.Date_and_time_of_match, M.ID_match, A.Country, B.Country) as F
WHERE CAST([���� � ����� �����] AS date) >= '2018-06-25' and CAST([���� � ����� �����] AS date) <= '2018-06-26'
/*����� �������*/


--IF OBJECT_ID('#T3', 'U') IS NOT NULL
DROP TABLE #T3


/*������ ������*/
--������� ������ ������ � ������������.
SELECT [���� � ����� �����], Name_of_stadium as '�������', [������ �1], [���� ������ �1], [������ �2], [���� ������ �2]
INTO #T3
FROM(
	/*��� ������� �� ����� ����� ������ ����*/
	SELECT ONE.ID_match, ONE.ID_stadium, [���� � ����� �����], 
		   TWO.[������ �1], TWO.[���� ������ �1] + THREE.[�������� ������ �2] as '���� ������ �1', 
		   THREE.[������ �2], THREE.[���� ������ �2] + TWO.[�������� ������ �1] as '���� ������ �2'
	FROM (
		SELECT M.ID_match, M.ID_stadium, M.Date_and_time_of_match as '���� � ����� �����', 
			   A.Country as '������ #1', B.Country as '������ #2'
		FROM [KB301_Mustafina].Mustafina.match M INNER JOIN   
			 [KB301_Mustafina].Mustafina.team A ON M.ID_first_team = A.ID_team INNER JOIN
			 [KB301_Mustafina].Mustafina.team B ON M.ID_second_team = B.ID_team) as ONE INNER JOIN (
		/*������ �����*/
		SELECT SUM(CAST(Goal AS tinyint)) as '���� ������ �1', SUM(CAST(Autogoal AS tinyint)) as '�������� ������ �1', 
			  ID_match, Country as '������ �1'
		FROM [KB301_Mustafina].Mustafina.player PL INNER JOIN   
			 [KB301_Mustafina].Mustafina.team T ON PL.ID_team = T.ID_team
		GROUP BY ID_match, T.Country /**/) AS TWO 
		ON ONE.ID_match =TWO.ID_match and ONE.[������ #1] = TWO.[������ �1] INNER JOIN (
		SELECT SUM(CAST(Goal AS tinyint)) as '���� ������ �2', SUM(CAST(Autogoal AS tinyint)) as '�������� ������ �2', 
			   ID_match as 'id', Country as '������ �2'
		FROM [KB301_Mustafina].Mustafina.player P INNER JOIN   
			 [KB301_Mustafina].Mustafina.team Team ON P.ID_team = Team.ID_team
		GROUP BY ID_match, Team.Country ) as THREE 
		ON ONE.[������ #2] = THREE.[������ �2] and ONE.ID_match =THREE.id
	--ORDER BY [���� � ����� �����]
	UNION 

	/*������� ����, ������� �������� ������ �������, � � ������ ������� 0 ����� �� ����*/
	SELECT ONE.ID_match, ONE.ID_stadium, [���� � ����� �����], 
		   TWO.[������ �1], TWO.[���� ������ �1], ONE.[������ #2], 0 + TWO.[�������� ������ �1] as '���� ������ �2'
	FROM (
		SELECT M.ID_match, M.ID_stadium, M.Date_and_time_of_match as '���� � ����� �����',
			   A.Country as '������ #1', B.Country as '������ #2'
		FROM [KB301_Mustafina].Mustafina.match M INNER JOIN   
			 [KB301_Mustafina].Mustafina.team A ON M.ID_first_team = A.ID_team INNER JOIN
			 [KB301_Mustafina].Mustafina.team B ON M.ID_second_team = B.ID_team) as ONE INNER JOIN (
		SELECT * FROM (
		/*��� ���� �� ������ ���� ��� ������ �������*/
			SELECT SUM(CAST(Goal AS tinyint)) as '���� ������ �1', 
				   SUM(CAST(Autogoal AS tinyint)) as '�������� ������ �1', ID_match, Country as '������ �1'
			FROM [KB301_Mustafina].Mustafina.player PL INNER JOIN   
				 [KB301_Mustafina].Mustafina.team T ON PL.ID_team = T.ID_team
			GROUP BY ID_match, T.Country) AS F  
			WHERE F.ID_match not in (SELECT T.ID_match FROM (
			SELECT ONE.ID_match, ONE.ID_stadium, [���� � ����� �����], 
				   TWO.[������ �1], TWO.[���� ������ �1] + THREE.[�������� ������ �2] as '���� ������ �1', 
				   THREE.[������ �2], THREE.[���� ������ �2] + TWO.[�������� ������ �1] as '���� ������ �2'
			FROM (
				SELECT M.ID_match, M.ID_stadium, M.Date_and_time_of_match as '���� � ����� �����', 
					   A.Country as '������ #1', B.Country as '������ #2'
				FROM [KB301_Mustafina].Mustafina.match M INNER JOIN   
					 [KB301_Mustafina].Mustafina.team A ON M.ID_first_team = A.ID_team INNER JOIN
					 [KB301_Mustafina].Mustafina.team B ON M.ID_second_team = B.ID_team) as ONE INNER JOIN (
				/*������ �����*/
				SELECT SUM(CAST(Goal AS tinyint)) as '���� ������ �1', SUM(CAST(Autogoal AS tinyint)) as '�������� ������ �1', 
					  ID_match, Country as '������ �1'
				FROM [KB301_Mustafina].Mustafina.player PL INNER JOIN   
					 [KB301_Mustafina].Mustafina.team T ON PL.ID_team = T.ID_team
				GROUP BY ID_match, T.Country /**/) AS TWO 
				ON ONE.ID_match =TWO.ID_match and ONE.[������ #1] = TWO.[������ �1] INNER JOIN (
				SELECT SUM(CAST(Goal AS tinyint)) as '���� ������ �2', SUM(CAST(Autogoal AS tinyint)) as '�������� ������ �2', 
					   ID_match as 'id', Country as '������ �2'
				FROM [KB301_Mustafina].Mustafina.player P INNER JOIN   
					 [KB301_Mustafina].Mustafina.team Team ON P.ID_team = Team.ID_team
				GROUP BY ID_match, Team.Country ) as THREE 
				ON ONE.[������ #2] = THREE.[������ �2] and ONE.ID_match =THREE.id) as T)) 
				AS TWO ON ONE.ID_match = TWO.ID_match and ONE.[������ #1]=TWO.[������ �1]

	UNION

	/*������� ����, ������� �������� ������ �������, � � ������ ������� 0 ����� �� ����*/
	SELECT ONE.ID_match, ONE.ID_stadium, [���� � ����� �����], 
		   ONE.[������ #1], 0 + TWO.[�������� ������ �2] as '���� ������ �1', 
		   TWO.[������ �2], TWO.[���� ������ �2]
	FROM (
		SELECT M.ID_match, M.ID_stadium, M.Date_and_time_of_match as '���� � ����� �����', 
			   A.Country as '������ #1', B.Country as '������ #2'
		FROM [KB301_Mustafina].Mustafina.match M INNER JOIN   
			 [KB301_Mustafina].Mustafina.team A ON M.ID_first_team = A.ID_team INNER JOIN
			 [KB301_Mustafina].Mustafina.team B ON M.ID_second_team = B.ID_team) as ONE INNER JOIN (
		SELECT * FROM (
			SELECT SUM(CAST(Goal AS tinyint)) as '���� ������ �2', 
				   SUM(CAST(Autogoal AS tinyint)) as '�������� ������ �2', ID_match, Country as '������ �2'
			FROM [KB301_Mustafina].Mustafina.player PL INNER JOIN   
				 [KB301_Mustafina].Mustafina.team T ON PL.ID_team = T.ID_team
			GROUP BY ID_match, T.Country) AS F  
			WHERE F.ID_match not in (SELECT T.ID_match FROM
			(
			SELECT ONE.ID_match, ONE.ID_stadium, [���� � ����� �����], 
				   TWO.[������ �1], TWO.[���� ������ �1] + THREE.[�������� ������ �2] as '���� ������ �1', 
				   THREE.[������ �2], THREE.[���� ������ �2] + TWO.[�������� ������ �1] as '���� ������ �2'
			FROM (
				SELECT M.ID_match, M.ID_stadium, M.Date_and_time_of_match as '���� � ����� �����', 
					   A.Country as '������ #1', B.Country as '������ #2'
				FROM [KB301_Mustafina].Mustafina.match M INNER JOIN   
					 [KB301_Mustafina].Mustafina.team A ON M.ID_first_team = A.ID_team INNER JOIN
					 [KB301_Mustafina].Mustafina.team B ON M.ID_second_team = B.ID_team) as ONE INNER JOIN (
				/*������ �����*/
				SELECT SUM(CAST(Goal AS tinyint)) as '���� ������ �1', SUM(CAST(Autogoal AS tinyint)) as '�������� ������ �1', 
					  ID_match, Country as '������ �1'
				FROM [KB301_Mustafina].Mustafina.player PL INNER JOIN   
					 [KB301_Mustafina].Mustafina.team T ON PL.ID_team = T.ID_team
				GROUP BY ID_match, T.Country /**/) AS TWO 
				ON ONE.ID_match =TWO.ID_match and ONE.[������ #1] = TWO.[������ �1] INNER JOIN (
				SELECT SUM(CAST(Goal AS tinyint)) as '���� ������ �2', SUM(CAST(Autogoal AS tinyint)) as '�������� ������ �2', 
					   ID_match as 'id', Country as '������ �2'
				FROM [KB301_Mustafina].Mustafina.player P INNER JOIN   
					 [KB301_Mustafina].Mustafina.team Team ON P.ID_team = Team.ID_team
				GROUP BY ID_match, Team.Country ) as THREE 
				ON ONE.[������ #2] = THREE.[������ �2] and ONE.ID_match =THREE.id) as T))  
				AS TWO ON ONE.ID_match = TWO.ID_match and ONE.[������ #2]=TWO.[������ �2]

	UNION 

/*������� ������� 0-0*/
	SELECT ONE.ID_match, ONE.ID_stadium, ONE.[���� � ����� �����], 
		   ONE.[������ #1], 0 as '���� ������ �1', ONE.[������ #2], 0 as '���� ������ �2'
	FROM (
		SELECT M.ID_match, M.ID_stadium, M.Date_and_time_of_match as '���� � ����� �����', A.Country as '������ #1', B.Country as '������ #2'
		FROM [KB301_Mustafina].Mustafina.match M INNER JOIN   
			 [KB301_Mustafina].Mustafina.team A ON M.ID_first_team = A.ID_team INNER JOIN
			 [KB301_Mustafina].Mustafina.team B ON M.ID_second_team = B.ID_team) as ONE
		WHERE ONE.ID_match not in 
		(SELECT TWO.ID_match 
		FROM (
			SELECT SUM(CAST(Goal AS tinyint)) as '����', 
				   SUM(CAST(Autogoal AS tinyint)) as '��������', ID_match, Country as '������'
			FROM [KB301_Mustafina].Mustafina.player PL INNER JOIN   
				 [KB301_Mustafina].Mustafina.team T ON PL.ID_team = T.ID_team
			GROUP BY ID_match, T.Country) as TWO)) as RESULT 
	INNER JOIN [KB301_Mustafina].Mustafina.stadium as ST ON RESULT.ID_stadium = ST.ID_stadium
	/*WHERE CAST(F.[���� � ����� �����] AS date) >= '2018-06-20' and CAST(F.[���� � ����� �����] AS date) <= '2018-06-21'*/
	

SELECT *
FROM #T3
ORDER BY [���� � ����� �����]


SELECT [���� � ����� �����], �������, CONCAT([������ �1], ' - ', [������ �2]) as '�������', CONCAT([���� ������ �1], ':', [���� ������ �2]) as '����'
FROM #T3
ORDER BY [���� � ����� �����]
/*����� ������� �������*/


DROP TABLE #T2

/*������ ������*/
--������� ������ ������ �� ������� (��� ������������ ������) ������������� �� �����.
SELECT team.Group_ as '������', team.Country as '������', ����
INTO #T2
FROM [KB301_Mustafina].Mustafina.team as team LEFT JOIN
/*LEFT JOIN ������ ��� � ������������ ���� �� ���� ��� ��� � �������, ����� � ��� � ������� � ������ ����� ������ NULL.*/
(SELECT ������, SUM(CAST(���� AS tinyint)) as '����'
FROM ([KB301_Mustafina].Mustafina.team as TEAM INNER JOIN(

	/*���������� �� ������ ������� ����*/
	SELECT [������ �1] as '������', SUM(CAST([���� ������ �1] AS tinyint)) as '����'
	FROM(
	/*�������� ������ �������, �� 3 ����*/
		SELECT [���� � ����� �����], [������ �1], 3 as '���� ������ �1', [������ �2], 0 as '���� ������ �2' 
		FROM #T3 as TABL INNER JOIN  [KB301_Mustafina].Mustafina.team as TEAM ON TABL.[������ �1] = TEAM.Country
		WHERE TABL.[���� ������ �1] > TABL.[���� ������ �2]
		UNION
	/*������� ������� � �����, ������ �� 1 ����*/ 
		SELECT [���� � ����� �����], [������ �1], 1 as '���� ������ �1', [������ �2], 1 as '���� ������ �2'
		FROM #T3 as TABL INNER JOIN  [KB301_Mustafina].Mustafina.team as TEAM ON TABL.[������ �1] = TEAM.Country
		WHERE TABL.[���� ������ �1] = TABL.[���� ������ �2]
		UNION
	/*�������� ������ �������, �� 3 ����*/
		SELECT [���� � ����� �����], [������ �1], 0 as '���� ������ �1', [������ �2], 3 as '���� ������ �2'
		FROM #T3 as TABL INNER JOIN  [KB301_Mustafina].Mustafina.team as TEAM ON TABL.[������ �1] = TEAM.Country
		WHERE TABL.[���� ������ �1] < TABL.[���� ������ �2]) as group1
	GROUP BY [������ �1]

UNION
	/*���������� �� ������ ������� ����*/
	SELECT [������ �2] as '������', SUM(CAST([���� ������ �2] AS tinyint)) as '����'
	FROM(
	/*�������� ������ �������, �� 3 ����*/
		SELECT [���� � ����� �����], [������ �1], 3 as '���� ������ �1', [������ �2], 0 as '���� ������ �2' 
		FROM #T3 as TABL INNER JOIN  [KB301_Mustafina].Mustafina.team as TEAM ON TABL.[������ �1] = TEAM.Country
		WHERE TABL.[���� ������ �1] > TABL.[���� ������ �2]
		UNION
	/*������� ������� � �����, ������ �� 1 ����*/
		SELECT [���� � ����� �����], [������ �1], 1 as '���� ������ �1', [������ �2], 1 as '���� ������ �2'
		FROM #T3 TABL INNER JOIN  [KB301_Mustafina].Mustafina.team as TEAM ON TABL.[������ �1] = TEAM.Country
		WHERE TABL.[���� ������ �1] = TABL.[���� ������ �2]
		UNION
	/*�������� ������ �������, �� 3 ����*/
		SELECT [���� � ����� �����], [������ �1], 0 as '���� ������ �1', [������ �2], 3 as '���� ������ �2'
		FROM #T3 as TABL INNER JOIN  [KB301_Mustafina].Mustafina.team as TEAM ON TABL.[������ �1] = TEAM.Country
		WHERE TABL.[���� ������ �1] < TABL.[���� ������ �2]) as group2
	GROUP BY [������ �2]) 
as TABL ON TEAM.Country = TABL.������)
GROUP BY ������) as tabl ON team.Country = tabl.������
/*WHERE team.Group_ = 'B'*/

SELECT *
FROM #T2
/*����� �������� �������*/



/*��������� ������*/
--������� �������� ������� �� ������� � ������, �������� � ������������ ������.
SELECT TEAM.Group_ as '������', TEAM.Country as '������', [������� ����], [����������� ����], ����
FROM [KB301_Mustafina].Mustafina.team as TEAM INNER JOIN(
	SELECT ������, SUM(CAST([������� ����] AS tinyint)) as '������� ����', 
		   SUM(CAST([����������� ����] AS tinyint)) as '����������� ����'
	FROM( 
		SELECT [������ �1] as '������', SUM(CAST([���� ������ �1] AS tinyint)) as '������� ����', 
			   SUM(CAST([���� ������ �2] AS tinyint)) as '����������� ����'
		FROM #T3 as tabl
		GROUP BY tabl.[������ �1]
	UNION
		SELECT [������ �2] as '������', SUM(CAST([���� ������ �2] AS tinyint)) as '������� ����', 
			   SUM(CAST([���� ������ �1] AS tinyint)) as '����������� ����'
		FROM #T3 as tabl
		GROUP BY tabl.[������ �2]) as PromTable 
	GROUP BY ������) as T1 ON TEAM.Country = T1.������ INNER JOIN 
/*������� � ������ �� �������� �������*/
#T2 as T2 ON TEAM.Country = T2.������
/*WHERE team.Group_ = 'B'*/
/*����� ���������� �������*/
