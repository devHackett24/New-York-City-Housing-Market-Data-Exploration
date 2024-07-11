-- Analyzing the most prominent brokers in each borough

-- Brooklyn, Manhattan, Queens, Bronx, Staten Island

CREATE TEMPORARY TABLE prominent_brokers AS 
SELECT SUBLOCALITY, BROKERTITLE, COUNT(DISTINCT ADDRESS) AS property_count
FROM nyhousingmarket_staging2
GROUP BY SUBLOCALITY, BROKERTITLE
ORDER BY SUBLOCALITY, property_count DESC;

CREATE TEMPORARY TABLE top_brokers AS
SELECT SUBLOCALITY, BROKERTITLE
FROM (
	SELECT SUBLOCALITY, BROKERTITLE, ROW_NUMBER() OVER (PARTITION BY SUBLOCALITY ORDER BY property_count DESC) AS row_num
	FROM prominent_brokers
) ranked_brokers
WHERE row_num = 1;

CREATE TABLE top_broker_property_counts (
	Broker VARCHAR(255),
    Borough VARCHAR(255),
	Single_Family_Home INT,
    Multi_Family_Home INT,
    Condo INT,
    Co_op INT,
    Condop INT,
    Townhouse INT,
    Mobile_Home INT,
    Land INT,
    Foreclosure INT
);

INSERT INTO top_broker_property_counts (Broker, Borough, Single_Family_Home, Multi_Family_Home, Condo, Co_op, Condop, Townhouse, Mobile_Home, Land, Foreclosure)
SELECT 
    top_brokers.BROKERTITLE,
    top_brokers.SUBLOCALITY,
    SUM(CASE WHEN nyhousingmarket_staging2.`TYPE` LIKE 'House%' THEN 1 ELSE 0 END) AS Single_Family_Home,
    SUM(CASE WHEN nyhousingmarket_staging2.`TYPE` LIKE 'Multi-family home%' THEN 1 ELSE 0 END) AS Multi_Family_Home,
    SUM(CASE WHEN nyhousingmarket_staging2.`TYPE` LIKE 'Condo%' THEN 1 ELSE 0 END) AS Condo,
    SUM(CASE WHEN nyhousingmarket_staging2.`TYPE` LIKE 'Co-op%' THEN 1 ELSE 0 END) AS Co_op,
    SUM(CASE WHEN nyhousingmarket_staging2.`TYPE` LIKE 'Condop%' THEN 1 ELSE 0 END) AS Condop,
    SUM(CASE WHEN nyhousingmarket_staging2.`TYPE` LIKE 'Townhouse%' THEN 1 ELSE 0 END) AS Townhouse,
    SUM(CASE WHEN nyhousingmarket_staging2.`TYPE` LIKE 'Mobile house%' THEN 1 ELSE 0 END) AS Mobile_Home,
    SUM(CASE WHEN nyhousingmarket_staging2.`TYPE` LIKE 'Land%' THEN 1 ELSE 0 END) AS Land,
    SUM(CASE WHEN nyhousingmarket_staging2.`TYPE` LIKE 'Foreclosure%' THEN 1 ELSE 0 END) AS Foreclosure
FROM 
    top_brokers
JOIN 
    nyhousingmarket_staging2
ON 
    top_brokers.SUBLOCALITY = nyhousingmarket_staging2.SUBLOCALITY AND top_brokers.BROKERTITLE = nyhousingmarket_staging2.BROKERTITLE
GROUP BY 
    top_brokers.SUBLOCALITY, top_brokers.BROKERTITLE;

SELECT *
FROM top_broker_property_counts;

-- Find which borough has the most foreclosures and which broker has the most foreclosures in each borough

CREATE TEMPORARY TABLE foreclosures_temp AS
SELECT SUBLOCALITY, BROKERTITLE, SUM(CASE WHEN nyhousingmarket_staging2.`TYPE` LIKE 'foreclosure%' THEN 1 ELSE 0 END) AS foreclosure_counts
FROM nyhousingmarket_staging2
GROUP BY BROKERTITLE, SUBLOCALITY
ORDER BY SUBLOCALITY, foreclosure_counts DESC;

-- Total forecloures in each borough

CREATE TABLE foreclosures AS
SELECT SUBLOCALITY,SUM(CASE WHEN nyhousingmarket_staging2.`TYPE` LIKE 'foreclosure%' THEN 1 ELSE 0 END) AS foreclosures
FROM nyhousingmarket_staging2
GROUP BY SUBLOCALITY
ORDER BY foreclosures DESC;

SELECT * FROM foreclosures;

-- Average property size by borough and property type

CREATE TEMPORARY TABLE avg_property_size AS
SELECT SUBLOCALITY, `TYPE`, ROUND(AVG(PROPERTYSQFT), 2) AS average_size
FROM nyhousingmarket_staging2
GROUP BY SUBLOCALITY,`TYPE`
ORDER BY SUBLOCALITY, `TYPE`;

-- Average Price Per Square Foot

CREATE TEMPORARY TABLE avg_price_squarefoot AS
SELECT SUBLOCALITY, `TYPE`, ROUND(AVG(PRICE/PROPERTYSQFT), 2) AS average_price_per_sqaurefoot
FROM nyhousingmarket_staging2
WHERE PROPERTYSQFT > 0
GROUP BY SUBLOCALITY, `TYPE`
ORDER BY SUBLOCALITY, `TYPE`;


-- Combining Tables

CREATE TABLE average_housing_rates AS
SELECT pSize.SUBLOCALITY AS borough, pSize.`TYPE` AS type_of_housing, pSize.average_size, pPrice.average_price_per_sqaurefoot
FROM avg_property_size pSize
JOIN avg_price_squarefoot pPrice
ON pSize.SUBLOCALITY = pPrice.SUBLOCALITY AND pSize.`TYPE` = pPRice.`TYPE`
ORDER BY pSize.SUBLOCALITY, pSize.`TYPE`;


-- Borough property counts

SELECT SUBLOCALITY, COUNT(*) AS property_count
FROM nyhousingmarket_staging2
GROUP BY SUBLOCALITY
ORDER BY property_count DESC;
