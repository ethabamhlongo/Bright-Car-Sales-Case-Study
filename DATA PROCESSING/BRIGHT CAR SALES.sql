SELECT * FROM `WORKSPACE`.`DEFAULT`.`CAR_SALES` limit 1000;
-----------------------------------------------------
--EXPLORATORY DATA ANALYSIS
------------------------------------------------------
-- Checking column names and data types
DESCRIBE TABLE WORKSPACE.DEFAULT.CAR_SALES;

-- Checking unique car makes
SELECT DISTINCT make
FROM WORKSPACE.DEFAULT.CAR_SALES
ORDER BY make;


-- Checking unique body types
SELECT DISTINCT body
FROM WORKSPACE.DEFAULT.CAR_SALES
ORDER BY body;

-- Checking unique transmission types
SELECT DISTINCT transmission
FROM WORKSPACE.DEFAULT.CAR_SALES
ORDER BY transmission;

-- Counting vehicles by model
SELECT
    model,
    COUNT(*) AS total_cars
FROM WORKSPACE.DEFAULT.CAR_SALES
GROUP BY model
ORDER BY total_cars DESC;


-- Checking the basic selling price statistics
SELECT
    MIN(sellingprice) AS minimum_price,
    MAX(sellingprice) AS maximum_price,
    AVG(sellingprice) AS average_price
FROM WORKSPACE.DEFAULT.CAR_SALES ;

----------------------------------------------------
---DATA CLEANING
----------------------------------------------------
-- Checking the missing values in each column
SELECT
    COUNT_IF(year IS NULL) AS year_nulls,
    COUNT_IF(make IS NULL) AS make_nulls,
    COUNT_IF(model IS NULL) AS model_nulls,
    COUNT_IF(trim IS NULL) AS trim_nulls,
    COUNT_IF(body IS NULL) AS body_nulls,
    COUNT_IF(transmission IS NULL) AS transmission_nulls,
    COUNT_IF(vin IS NULL) AS vin_nulls,
    COUNT_IF(state IS NULL) AS state_nulls,
    COUNT_IF(condition IS NULL) AS condition_nulls,
    COUNT_IF(odometer IS NULL) AS odometer_nulls,
    COUNT_IF(color IS NULL) AS color_nulls,
    COUNT_IF(interior IS NULL) AS interior_nulls,
    COUNT_IF(seller IS NULL) AS seller_nulls,
    COUNT_IF(mmr IS NULL) AS mmr_nulls,
    COUNT_IF(sellingprice IS NULL) AS sellingprice_nulls,
    COUNT_IF(saledate IS NULL) AS saledate_nulls
FROM WORKSPACE.DEFAULT.CAR_SALES;

-- Checking for duplicate records
SELECT
    COUNT(*) - COUNT(DISTINCT
        CONCAT_WS('|',
            year,
            make,
            model,
            trim,
            body,
            transmission,
            vin,
            state,
            condition,
            odometer,
            color,
            interior,
            seller,
            mmr,
            sellingprice,
            saledate
        )
    ) AS duplicate_rows
FROM WORKSPACE.DEFAULT.CAR_SALES;

-- Creating a cleaned table with NULLs removed and duplicates removed
CREATE OR REPLACE TABLE WORKSPACE.DEFAULT.CAR_SALES_CLEAN AS

SELECT DISTINCT
    year,
    make,
    model,
    trim,
    body,
    transmission,
    vin,
    state,
    condition,
    odometer,
    color,
    interior,
    seller,
    mmr,
    sellingprice,
    saledate

FROM WORKSPACE.DEFAULT.CAR_SALES

WHERE year IS NOT NULL
  AND make IS NOT NULL
  AND model IS NOT NULL
  AND trim IS NOT NULL
  AND body IS NOT NULL
  AND transmission IS NOT NULL
  AND vin IS NOT NULL
  AND state IS NOT NULL
  AND condition IS NOT NULL
  AND odometer IS NOT NULL
  AND color IS NOT NULL
  AND interior IS NOT NULL
  AND seller IS NOT NULL
  AND mmr IS NOT NULL
  AND sellingprice IS NOT NULL
  AND saledate IS NOT NULL;

  -- Checking the remaining NULL values
SELECT
    COUNT_IF(year IS NULL) AS year_nulls,
    COUNT_IF(make IS NULL) AS make_nulls,
    COUNT_IF(model IS NULL) AS model_nulls,
    COUNT_IF(trim IS NULL) AS trim_nulls,
    COUNT_IF(body IS NULL) AS body_nulls,
    COUNT_IF(transmission IS NULL) AS transmission_nulls,
    COUNT_IF(vin IS NULL) AS vin_nulls,
    COUNT_IF(state IS NULL) AS state_nulls,
    COUNT_IF(condition IS NULL) AS condition_nulls,
    COUNT_IF(odometer IS NULL) AS odometer_nulls,
    COUNT_IF(color IS NULL) AS color_nulls,
    COUNT_IF(interior IS NULL) AS interior_nulls,
    COUNT_IF(seller IS NULL) AS seller_nulls,
    COUNT_IF(mmr IS NULL) AS mmr_nulls,
    COUNT_IF(sellingprice IS NULL) AS sellingprice_nulls,
    COUNT_IF(saledate IS NULL) AS saledate_nulls
FROM WORKSPACE.DEFAULT.CAR_SALES_CLEAN;

-- Viewing the cleaned dataset
SELECT *
FROM WORKSPACE.DEFAULT.CAR_SALES_CLEAN;
-------------------------------------------------------------------------
--FEATURE BUILDING
---------------------------------------------------------------------

SELECT
    saledate,

    to_timestamp(
        regexp_replace(saledate, '^[A-Za-z]{3} ', ''),
        'MMM dd yyyy HH:mm:ss'
    ) AS formatted_saledate

FROM WORKSPACE.DEFAULT.CAR_SALES_CLEAN
LIMIT 20;

-- Creating the date analysis columns

CREATE OR REPLACE TABLE WORKSPACE.DEFAULT.CAR_SALES_DATE AS

SELECT
    *,
    
    -- Proper sale date
    to_timestamp(
        regexp_replace(saledate, '^[A-Za-z]{3} ', ''),
        'MMM dd yyyy HH:mm:ss'
    ) AS formatted_saledate,

    -- Year the car was sold
    YEAR(
        to_timestamp(
            regexp_replace(saledate, '^[A-Za-z]{3} ', ''),
            'MMM dd yyyy HH:mm:ss'
        )
    ) AS sale_year,

    -- Month number
    MONTH(
        to_timestamp(
            regexp_replace(saledate, '^[A-Za-z]{3} ', ''),
            'MMM dd yyyy HH:mm:ss'
        )
    ) AS month_number,

    -- Month name
    date_format(
        to_timestamp(
            regexp_replace(saledate, '^[A-Za-z]{3} ', ''),
            'MMM dd yyyy HH:mm:ss'
        ),
        'MMMM'
    ) AS month_name,

    -- Week number
    weekofyear(
        to_timestamp(
            regexp_replace(saledate, '^[A-Za-z]{3} ', ''),
            'MMM dd yyyy HH:mm:ss'
        )
    ) AS week,

    -- Day of month
    DAY(
        to_timestamp(
            regexp_replace(saledate, '^[A-Za-z]{3} ', ''),
            'MMM dd yyyy HH:mm:ss'
        )
    ) AS day,

    -- Day name
    date_format(
        to_timestamp(
            regexp_replace(saledate, '^[A-Za-z]{3} ', ''),
            'MMM dd yyyy HH:mm:ss'
        ),
        'EEEE'
    ) AS day_name,

    -- Quarter
    QUARTER(
        to_timestamp(
            regexp_replace(saledate, '^[A-Za-z]{3} ', ''),
            'MMM dd yyyy HH:mm:ss'
        )
    ) AS quarter

FROM WORKSPACE.DEFAULT.CAR_SALES_CLEAN;

SELECT
    saledate,
    formatted_saledate,
    sale_year,
    month_number,
    month_name,
    week,
    day,
    day_name,
    quarter
FROM WORKSPACE.DEFAULT.CAR_SALES_DATE
LIMIT 20;

---------------------------------------------------------------------

-- Creating the final Bright Motors analysis table

CREATE OR REPLACE TABLE WORKSPACE.DEFAULT.CAR_SALES_FINAL AS

SELECT
    year,
    make,
    model,
    trim,
    body,
    transmission,
    state,
    condition,
    odometer,
    mmr,
    sellingprice,
    formatted_saledate,
    month_number,
    month_name,
    week,
    day,
    day_name,
    quarter

FROM WORKSPACE.DEFAULT.CAR_SALES_DATE; 

-- Viewing the final dataset

SELECT *
FROM WORKSPACE.DEFAULT.CAR_SALES_FINAL ;
