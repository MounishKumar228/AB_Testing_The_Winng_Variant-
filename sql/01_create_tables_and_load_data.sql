-- ============================================================
-- THE WINNING VARIANT
-- 00 - CREATE TABLES AND LOAD DATA
-- ============================================================

CREATE DATABASE IF NOT EXISTS abtesting;
USE abtesting;

-- ============================================================
-- 1. DROP EXISTING TABLES
-- ============================================================

DROP TABLE IF EXISTS conversions;
DROP TABLE IF EXISTS assignments;


-- ============================================================
-- 2. CREATE ASSIGNMENTS TABLE
-- ============================================================

CREATE TABLE assignments (
    assignment_row_id BIGINT AUTO_INCREMENT,

    visitor_id VARCHAR(50) NOT NULL,
    variant VARCHAR(10) NOT NULL,
    assigned_at DATETIME NOT NULL,
    device VARCHAR(20),
    channel VARCHAR(50),
    country VARCHAR(10),

    PRIMARY KEY (assignment_row_id),

    INDEX idx_assignment_visitor (visitor_id),
    INDEX idx_assignment_time (assigned_at),
    INDEX idx_assignment_variant (variant),
    INDEX idx_assignment_device (device)
);


-- ============================================================
-- 3. CREATE CONVERSIONS TABLE
-- ============================================================

CREATE TABLE conversions (
    conversion_row_id BIGINT AUTO_INCREMENT,

    visitor_id VARCHAR(50) NOT NULL,
    converted_at DATETIME NOT NULL,
    plan VARCHAR(50),
    amount_usd DECIMAL(10,2),

    PRIMARY KEY (conversion_row_id),

    INDEX idx_conversion_visitor (visitor_id),
    INDEX idx_conversion_time (converted_at)
);


-- ============================================================
-- 4. ENABLE LOCAL FILE LOADING
-- ============================================================

SHOW VARIABLES LIKE 'local_infile';

SET GLOBAL local_infile = 1;


-- ============================================================
-- 5. LOAD ASSIGNMENTS DATA
-- ============================================================

LOAD DATA LOCAL INFILE
'C:assignments.csv'

INTO TABLE assignments

FIELDS TERMINATED BY ','
ENCLOSED BY '"'

LINES TERMINATED BY '\n'

IGNORE 1 ROWS

(
    visitor_id,
    variant,
    assigned_at,
    device,
    channel,
    country
);


-- ============================================================
-- 6. LOAD CONVERSIONS DATA
-- ============================================================

LOAD DATA LOCAL INFILE
'C:conversions.csv'

INTO TABLE conversions

FIELDS TERMINATED BY ','
ENCLOSED BY '"'

LINES TERMINATED BY '\n'

IGNORE 1 ROWS

(
    visitor_id,
    converted_at,
    plan,
    amount_usd
);


-- ============================================================
-- 7. VERIFY DATA LOAD
-- ============================================================

SELECT
    COUNT(*) AS assignment_rows
FROM assignments;


SELECT
    COUNT(DISTINCT visitor_id) AS unique_assignment_visitors
FROM assignments;


SELECT
    COUNT(*) AS conversion_rows
FROM conversions;


SELECT
    COUNT(DISTINCT visitor_id) AS converting_visitors
FROM conversions;


-- ============================================================
-- 8. BASIC DATA PREVIEW
-- ============================================================

SELECT *
FROM assignments
LIMIT 10;


SELECT *
FROM conversions
LIMIT 10;
