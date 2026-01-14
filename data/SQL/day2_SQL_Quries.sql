
-- -----------------------------------------------------------------------------
-- 1. Database & Table Setup
-- -----------------------------------------------------------------------------

CREATE DATABASE IF NOT EXISTS Customer_Segmentation;
USE Customer_Segmentation;

DROP TABLE IF EXISTS retail;

CREATE TABLE retail (
  InvoiceNo      VARCHAR(20),
  StockCode      VARCHAR(20),
  Description    TEXT,
  Quantity       INT,
  InvoiceDate    DATETIME,
  UnitPrice      DECIMAL(10,2),
  CustomerID     INT,
  Country        VARCHAR(50)
);

-- -----------------------------------------------------------------------------
-- 2. Data Import
-- -----------------------------------------------------------------------------
-- Note: Update the path below to match your local file location.
-- On Mac, you may need to ensure the file needs is in a directory allowed by 'secure_file_priv'.

SET global local_infile=1; -- Enable local data loading if needed

LOAD DATA LOCAL INFILE '/Users/smitpatel/Documents/project/New-projects/Customer_Segmentation_Churn_Prediction/Customer_Segmentation_Churn_Prediction/data/data/Retail.csv'
INTO TABLE retail
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

-- -----------------------------------------------------------------------------
-- 3. Data Cleaning
-- -----------------------------------------------------------------------------

SET SQL_SAFE_UPDATES = 0;

-- Remove cancelled transactions (InvoiceNo starting with 'C')
DELETE FROM retail 
WHERE InvoiceNo LIKE 'C%';

-- Remove invalid transactions (Negative/Zero Quantity or Price)
DELETE FROM retail 
WHERE Quantity <= 0;

DELETE FROM retail 
WHERE UnitPrice <= 0;

-- -----------------------------------------------------------------------------
-- 4. Exploratory Data Analysis (EDA)
-- -----------------------------------------------------------------------------

-- A. Total Sales (Gross Merchandise Value)
SELECT 
    FORMAT(SUM(Quantity * UnitPrice), 2) AS Total_Sales 
FROM retail;

-- B. Top Customers by Frequency (Total Invoices)
SELECT 
    CustomerID, 
    COUNT(DISTINCT InvoiceNo) AS Total_Invoices
FROM retail
WHERE CustomerID IS NOT NULL
GROUP BY CustomerID
ORDER BY Total_Invoices DESC
LIMIT 10;

-- C. Top Customers by Revenue (Monetary Value)
SELECT 
    CustomerID, 
    ROUND(SUM(Quantity * UnitPrice), 2) AS Revenue
FROM retail
WHERE CustomerID IS NOT NULL
GROUP BY CustomerID
ORDER BY Revenue DESC
LIMIT 10;

-- D. Revenue by Country
SELECT 
    Country, 
    ROUND(SUM(Quantity * UnitPrice), 2) AS Revenue
FROM retail
GROUP BY Country
ORDER BY Revenue DESC;

-- E. Monthly Sales Trends
SELECT 
    YEAR(InvoiceDate) AS Year,
    MONTH(InvoiceDate) AS Month, 
    ROUND(SUM(Quantity * UnitPrice), 2) AS Revenue
FROM retail
GROUP BY Year, Month
ORDER BY Year, Month;

-- -----------------------------------------------------------------------------
-- 5. Data Export
-- -----------------------------------------------------------------------------
-- Exporting cleaned data for further analysis (e.g., Python/PowerBI)

SELECT 'InvoiceNo', 'StockCode', 'Description', 'Quantity', 'InvoiceDate', 'UnitPrice', 'CustomerID', 'Country'
UNION ALL
SELECT InvoiceNo, StockCode, Description, Quantity, InvoiceDate, UnitPrice, CustomerID, Country
FROM retail
INTO OUTFILE '/Users/smitpatel/Documents/project/New-projects/Customer_Segmentation_Churn_Prediction/Customer_Segmentation_Churn_Prediction/data/data/cleaned_online_retail.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n';

SET SQL_SAFE_UPDATES = 1;

/* End of Script */
