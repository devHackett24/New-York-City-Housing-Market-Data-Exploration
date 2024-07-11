-- Data Cleaning 

CREATE TABLE nyhousingmarket_staging
LIKE nyhousingmarket;

INSERT nyhousingmarket_staging
SELECT *
FROM nyhousingmarket;

-- Removing Duplicates 

SELECT *,
ROW_NUMBER() OVER(
PARTITION BY BROKERTITLE, `TYPE`, PRICE, BEDS, BATH, PROPERTYSQFT, ADDRESS, STATE, MAIN_ADDRESS, ADMINISTRATIVE_AREA_LEVEL_2, LOCALITY, SUBLOCALITY, STREET_NAME, LONG_NAME, FORMATTED_ADDRESS, LATITUDE, LONGITUDE) AS row_num
FROM nyhousingmarket_staging;

WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY BROKERTITLE, `TYPE`, PRICE, BEDS, BATH, PROPERTYSQFT, ADDRESS, STATE, MAIN_ADDRESS, ADMINISTRATIVE_AREA_LEVEL_2, LOCALITY, SUBLOCALITY, STREET_NAME, LONG_NAME, FORMATTED_ADDRESS, LATITUDE, LONGITUDE) AS row_num
FROM nyhousingmarket_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num >  1;

CREATE TABLE `nyhousingmarket_staging2` (
  `BROKERTITLE` text,
  `TYPE` text,
  `PRICE` int DEFAULT NULL,
  `BEDS` int DEFAULT NULL,
  `BATH` double DEFAULT NULL,
  `PROPERTYSQFT` int DEFAULT NULL,
  `ADDRESS` text,
  `STATE` text,
  `MAIN_ADDRESS` text,
  `ADMINISTRATIVE_AREA_LEVEL_2` text,
  `LOCALITY` text,
  `SUBLOCALITY` text,
  `STREET_NAME` text,
  `LONG_NAME` text,
  `FORMATTED_ADDRESS` text,
  `LATITUDE` double DEFAULT NULL,
  `LONGITUDE` double DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


INSERT INTO nyhousingmarket_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY BROKERTITLE, `TYPE`, PRICE, BEDS, BATH, PROPERTYSQFT, ADDRESS, STATE, MAIN_ADDRESS, ADMINISTRATIVE_AREA_LEVEL_2, LOCALITY, 
SUBLOCALITY, STREET_NAME, LONG_NAME, FORMATTED_ADDRESS, LATITUDE, LONGITUDE) AS row_num
FROM nyhousingmarket_staging;

DELETE
FROM nyhousingmarket_staging2
WHERE row_num > 1;

-- Standardizing the Data

UPDATE nyhousingmarket_staging2
SET BROKERTITLE = TRIM(BROKERTITLE);

UPDATE nyhousingmarket_staging2
SET BROKERTITLE = TRIM('Brokered by ' FROM BROKERTITLE);

UPDATE nyhousingmarket_staging2
SET BROKERTITLE = 'Exp Realty'
WHERE BROKERTITLE = 'EXP Realty';

UPDATE nyhousingmarket_staging2
SET BROKERTITLE = 'Douglas Elliman'
WHERE BROKERTITLE LIKE 'Douglas Elliman%';

UPDATE nyhousingmarket_staging2
SET `TYPE` = TRIM('for sale' from `TYPE`);

DELETE
FROM nyhousingmarket_staging2
WHERE `TYPE` = 'for sale';

DELETE
FROM nyhousingmarket_staging2
WHERE `TYPE` = 'Coming Soon' OR `TYPE` = 'Pending';

DELETE
FROM nyhousingmarket_staging2
WHERE `TYPE` = 'Contingent';

UPDATE nyhousingmarket_staging2
SET SUBLOCALITY = 'Bronx County'
WHERE SUBLOCALITY = 'The Bronx';

UPDATE nyhousingmarket_staging2
SET SUBLOCALITY = 'Queens County'
WHERE SUBLOCALITY = 'Queens';

DELETE 
FROM nyhousingmarket_staging2
WHERE SUBLOCALITY = 'New York' or SUBLOCALITY = 'New York County';

UPDATE nyhousingmarket_staging2
SET LOCALITY = 'Bronx County'
WHERE LOCALITY = 'The Bronx';

UPDATE nyhousingmarket_staging2
SET LOCALITY = 'Queens County'
WHERE LOCALITY = 'Queens';

-- East Bronx = Bronx County

UPDATE nyhousingmarket_staging2
SET SUBLOCALITY = 'Bronx County'
WHERE SUBLOCALITY = 'East Bronx';

-- Brooklyn Heights = Brooklyn

UPDATE nyhousingmarket_staging2
SET SUBLOCALITY = 'Brooklyn'
WHERE SUBLOCALITY = 'Brooklyn Heights';

-- Coney Island = Brooklyn

UPDATE nyhousingmarket_staging2
SET SUBLOCALITY = 'Brooklyn'
WHERE SUBLOCALITY = 'Coney Island';

-- Dumbo = Brooklyn

UPDATE nyhousingmarket_staging2
SET SUBLOCALITY = 'Brooklyn'
WHERE SUBLOCALITY = 'Dumbo';

-- Flushing = Queens County

UPDATE nyhousingmarket_staging2
SET SUBLOCALITY = 'Queens County'
WHERE SUBLOCALITY = 'Flushing';

-- Fort Hamilton = Brooklyn

UPDATE nyhousingmarket_staging2
SET SUBLOCALITY = 'Brooklyn'
WHERE SUBLOCALITY = 'Fort Hamilton';

-- Jackson Heights = Queens County

UPDATE nyhousingmarket_staging2
SET SUBLOCALITY = 'Queens County'
WHERE SUBLOCALITY = 'Jackson Heights';

-- Kings County = Brooklyn

UPDATE nyhousingmarket_staging2
SET SUBLOCALITY = 'Brooklyn'
WHERE SUBLOCALITY = 'Kings County';

-- Rego Park = Queens County

UPDATE nyhousingmarket_staging2
SET SUBLOCALITY = 'Queens County'
WHERE SUBLOCALITY = 'Rego Park';

-- Richmond County = Staten Island

UPDATE nyhousingmarket_staging2
SET SUBLOCALITY = 'Staten Island'
WHERE SUBLOCALITY = 'Richmond County';

-- Riverdale = Bronx County

UPDATE nyhousingmarket_staging2
SET SUBLOCALITY = 'Bronx County'
WHERE SUBLOCALITY = 'Riverdale';


SELECT DISTINCT SUBLOCALITY
FROM nyhousingmarket_staging2
ORDER BY 1;

ALTER TABLE nyhousingmarket_staging2
DROP COLUMN row_num;

-- Creating new column for the postal codes for heat map visualization

ALTER TABLE nyhousingmarket_staging2 ADD postal_code VARCHAR(10);

UPDATE nyhousingmarket_staging2 
SET postal_code = TRIM(REGEXP_SUBSTR(MAIN_ADDRESS, '\\d{5}(-\\d{4})?$'));


-- No Null Values or Empty entries were found













