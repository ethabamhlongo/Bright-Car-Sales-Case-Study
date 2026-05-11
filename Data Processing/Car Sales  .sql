select * from `workspace`.`default`.`car_sales` limit 10000;

---------------------------------------------------------
--EXPLORATORY DATA ANALYSIS
------------------------------------------------------------
-- FINDING MIN YEAR AND MAX YEAR : 1982 AND 2015
SELECT MIN(`year`) , MAX(`year`)
FROM WORKSPACE.DEFAULT.CAR_SALES ;

------------------------------------------------------------
--FINDING DIFFERENT STATES : 38 states
SELECT DISTINCT `state`
FROM WORKSPACE.DEFAULT.CAR_SALES;

----------------------------------------------------------------
--FINDING DIFFERENT SELLERS : 1000 sellers
SELECT DISTINCT `seller`
FROM WORKSPACE.DEFAULT.CAR_SALES ;

---------------------------------------------------------------------
--FINDING DISTINCT BODY AND COLOR  : 
SELECT DISTINCT `BODY` AS BODY,
                `COLOR` AS COLOR
FROM WORKSPACE.DEFAULT.CAR_SALES ;

--------------------------------------------------------------------
---FINDING NULLS
SELECT `MAKE`,`MODEL`,`TRIM`,`BODY`,`TRANSMISSION`
FROM WORKSPACE.DEFAULT.CAR_SALES 
WHERE  `MAKE` IS NULL AND `MODEL` IS NULL AND `TRIM` IS NULL AND `BODY` IS NULL AND `TRANSMISSION` IS NULL ;



SELECT `MAKE`,`MODEL`,`TRIM`,`BODY`,`TRANSMISSION`
FROM WORKSPACE.DEFAULT.CAR_SALES 
WHERE  `MAKE` IS NOT NULL AND `MODEL` IS NOT NULL AND `TRIM` IS NOT NULL AND `BODY` IS NOT NULL AND `TRANSMISSION` IS NOT NULL ;

SELECT  `MAKE`,`MODEL`,`TRIM`,`BODY`,
      IFNULL(`TRANSMISSION`, 'UNKNOWN') AS TRANSMISSION,
      IFNULL (`BODY`,'UNKNOWN') AS BODY,
      IFNULL (`TRIM`,'UNKNOWN')AS TRIM,
      IFNULL(`MODEL`,'UNKNOWN') AS MODEL ,
      IFNULL(`MAKE`, 'UNKNOWN') AS MAKE
FROM WORKSPACE.DEFAULT.CAR_SALES ;

--------------------------------------------------------------------------------------------------------
---ADDING NEW COLUMNS
--------------------------------------------------------------------------------------------------------

WITH car_sales AS (
SELECT
    COALESCE(`year`,0) AS `year`,
    COALESCE(`make`,'Unknown') AS `make`,
    COALESCE(`model`,'Unknown') AS `model`,
    COALESCE(`trim`,'Unknown') AS `trim`,
    COALESCE(`body`,'Unknown') AS `body`,
    COALESCE(`transmission`,'Unknown') AS `transmission`,
    COALESCE(`vin`,'Unknown') AS `vin`,
    COALESCE(`state`,'Unknown') AS `state`,
    COALESCE(`condition`,0) AS `condition`,
    COALESCE(`odometer`,0) AS `odometer`,
    COALESCE(`color`,'Unknown') AS `colour`,
    COALESCE(`interior`,'Unknown') AS `interior`,
    COALESCE(`seller`,'Unknown') AS `seller`,
    COALESCE(`mmr`,0) AS `mmr`,
    COALESCE(`sellingprice`,0) AS `sellingprice`,
    COALESCE(`saledate`,'Unknown') AS `saledate`,


    CASE
        WHEN COALESCE(`odometer`,0) < 30000 THEN 'Low Mileage'
        WHEN COALESCE(`odometer`,0) BETWEEN 30000 AND 80000 THEN 'Medium Mileage'
        ELSE 'High Mileage'
    END AS mileage_band,

    CASE
        WHEN COALESCE(`year`,0) BETWEEN 2010 AND 2015 THEN 'New'
        WHEN COALESCE(`year`,0) BETWEEN 2000 AND 2009 THEN 'Mid Age'
        ELSE 'Old'
    END AS vehicle_age,

    CASE
        WHEN COALESCE(`sellingprice`,0) > COALESCE(`mmr`,0) THEN 'Above MMR'
        WHEN COALESCE(`sellingprice`,0) = COALESCE(`mmr`,0) THEN 'At MMR'
        ELSE 'Below MMR'
    END AS price_vs_mmr,

    CASE
        WHEN COALESCE(`state`,'Unknown') IN ('CA','TX','FL','NY') THEN 'Top Market'
        ELSE 'Other Market'
    END AS market_group,

    CASE
        WHEN COALESCE(`condition`,0) >= 4 THEN 'Excellent'
        WHEN COALESCE(`condition`,0) BETWEEN 2 AND 3.99 THEN 'Average'
        ELSE 'Poor'
    END AS condition_band

FROM WORKSPACE.DEFAULT.CAR_SALES
)

SELECT
    market_group,
    state,
    year,
    make,
    model,
    trim,
    body,
    transmission,
    colour,
    interior,
    seller,
    vin,   
    vehicle_age,
    mileage_band,
    condition_band,
    price_vs_mmr,

    COUNT(*) AS total_sales_volume,
    COUNT(DISTINCT vin) AS unique_cars_sold,
    SUM(sellingprice) AS total_revenue,
    AVG(sellingprice) AS avg_selling_price,
    AVG(mmr) AS avg_mmr,
    SUM(sellingprice - mmr) AS total_profit_gap,
    AVG(odometer) AS avg_mileage,
    AVG(condition) AS avg_condition_score,
    MAX(sellingprice) AS highest_sale,
    MIN(sellingprice) AS lowest_sale

FROM car_sales

GROUP BY
    market_group,
    state,
    year,
    make,
    model,
    trim,
    body,
    transmission,
    colour,
    interior,
    seller,
    vin,
    vehicle_age,
    mileage_band,
    condition_band,
    price_vs_mmr

ORDER BY year ASC, total_revenue DESC;
