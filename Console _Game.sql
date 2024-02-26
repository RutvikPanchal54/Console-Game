CREATE DATABASE CONSOLE_GAME;
USE CONSOLE_GAME;

CREATE TABLE P9_ConsoleDates (
   Platform VARCHAR(4) NOT NULL, 
   FirstRetailAvailability DATE NOT NULL, 
   Discontinued DATE, 
   UnitsSoldMillions DECIMAL(38, 2) NOT NULL, 
   Comment VARCHAR(37)
);

LOAD DATA INFILE 
'F:/Console Game/P9-ConsoleDates.csv'
INTO TABLE P9_ConsoleDates
FIELDS TERMINATED BY ','  
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(@Platform, @FirstRetailAvailability, @Discontinued, @UnitsSoldMillions, @Comment)
SET
   Platform = @Platform,
   FirstRetailAvailability = @FirstRetailAvailability,
   Discontinued = NULLIF(@Discontinued, ''),
   UnitsSoldMillions = @UnitsSoldMillions,
   Comment = @Comment;

SELECT * FROM P9_ConsoleDates;
SELECT COUNT(*) FROM P9_ConsoleDates;

CREATE TABLE P9_ConsoleGames(
	`Rank` DECIMAL(38, 0) NOT NULL, 
	Name VARCHAR(132), 
	Platform VARCHAR(4), 
	Year DECIMAL(38, 0), 
	Genre VARCHAR(12) NOT NULL, 
	Publisher VARCHAR(38), 
	NA_Sales DECIMAL(38, 2) NOT NULL, 
	EU_Sales DECIMAL(38, 2) NOT NULL, 
	JP_Sales DECIMAL(38, 2), 
	Other_Sales DECIMAL(38, 2) NOT NULL
);

LOAD DATA INFILE 'F:/Console Game/P9-ConsoleGames.csv'
INTO TABLE P9_ConsoleGames
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(@Rank, @Name, @Platform, @Year, @Genre, @Publisher, @NA_Sales, @EU_Sales, @JP_Sales, @Other_Sales)
SET
    `Rank` = @Rank,
    Name = @Name,
    Platform = @Platform,
    Year = NULLIF(@Year, ''),
    Genre = @Genre,
    Publisher = @Publisher,
    NA_Sales = @NA_Sales,
    EU_Sales = @EU_Sales,
    JP_Sales = NULLIF(@JP_Sales, ''),
    Other_Sales = @Other_Sales;

SELECT * FROM P9_ConsoleGames;
SELECT COUNT(*) FROM P9_ConsoleGames;

/*--------------------------QUERIES--------------------------*/

/* 1. Calculate what % of Global Sales were made in North America*/

SELECT (SUM(NA_Sales) / 
	(SUM(NA_Sales) + SUM(EU_Sales) + SUM(JP_Sales) + SUM(Other_Sales))) * 100 AS Percentage
FROM P9_ConsoleGames;

/* 2. Extract view of the console game titles orderes by platform 
name in ascending order and Year of release in descending order*/

CREATE VIEW ConsoleGamesView AS
SELECT `Rank`, Name, Platform, Year, Genre, Publisher, NA_Sales, EU_Sales, JP_Sales, Other_Sales
FROM P9_ConsoleGames
ORDER BY Platform ASC, Year DESC;

SELECT * FROM ConsoleGamesView;

/* 3. For each game title extacrt the first four letters of the publisher's name */

CREATE VIEW ConsoleGamesView12 AS
SELECT `Rank`, Name, Platform, Year, LEFT(Publisher, 4) AS PublisherShort
FROM P9_ConsoleGames
ORDER BY Platform ASC, Year DESC;

SELECT * FROM ConsoleGamesView12;

/* 4. Display all console platforms which were released either just before 
Black Friday or Just before Christmas(in any Year)*/

SELECT DISTINCT Platform
FROM P9_ConsoleDates
WHERE 
	(MONTH(FirstRetailAvailability) = 11 AND DAY(FirstRetailAvailability) = 23)
    OR
    (MONTH(FirstRetailAvailability) = 12 AND DAY(FirstRetailAvailability) = 24); 

/* 5. Order the Platforms by theor longevity in ascending order
(i.e. the platform which was available for the longest at the bottom)*/

SELECT Platform, FirstRetailAvailability, Discontinued,
DATEDIFF( IFNULL(Discontinued, CURDATE()), FirstRetailAvailability) AS Longevity
FROM P9_ConsoleDates
ORDER BY Longevity ASC;

/* 6. Demonstrate how to deal with the Game_Year column if the client wants to convert it to a different data type*/

SELECT * FROM P9_ConsoleGames WHERE `Year` NOT REGEXP '^[0-9]+$';

ALTER TABLE P9_ConsoleGames
MODIFY COLUMN `Year` YEAR;

/* 7. Provide recommendations on how to deal with missing data in the file*/
/*
SET Column1 = IFNULL(@Column1, 'default_value');

----OR----

LOAD DATA INFILE 'your_file.csv'
INTO TABLE your_table
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(@Column1, @Column2)
SET Column1 = NULLIF(@Column1, ''),
    Column2 = NULLIF(@Column2, ''); */
    
