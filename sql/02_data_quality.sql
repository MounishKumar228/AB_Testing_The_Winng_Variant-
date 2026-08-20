USE abtesting;

-- ============================================================
-- THE WINNING VARIANT
-- 01 - DATA QUALITY CHECKS
-- ============================================================

-- Check total assignment rows
SELECT
    COUNT(*) AS assignment_rows
FROM assignments;


-- Check unique visitors
SELECT
    COUNT(DISTINCT visitor_id) AS unique_visitors
FROM assignments;


-- Check visitors with multiple assignment rows
SELECT
    visitor_id,
    COUNT(*) AS assignment_count
FROM assignments
GROUP BY visitor_id
HAVING COUNT(*) > 1
ORDER BY assignment_count DESC;


-- Check variant distribution at the raw assignment-event level
SELECT
    variant,
    COUNT(*) AS assignment_rows
FROM assignments
GROUP BY variant;


-- Check device values before standardisation
SELECT
    device,
    COUNT(*) AS row_count
FROM assignments
GROUP BY device
ORDER BY row_count DESC;


-- Check device values after standardising case
SELECT
    LOWER(TRIM(device)) AS device,
    COUNT(*) AS row_count
FROM assignments
GROUP BY LOWER(TRIM(device))
ORDER BY row_count DESC;


-- Check blank country values
SELECT
    COUNT(*) AS blank_country_rows
FROM assignments
WHERE country IS NULL
   OR TRIM(country) = '';


-- Check conversion rows
SELECT
    COUNT(*) AS conversion_rows
FROM conversions;


-- Check visitors appearing in conversions
SELECT
    COUNT(DISTINCT visitor_id) AS converting_visitors
FROM conversions;


-- Check conversions outside June
SELECT
    MIN(converted_at) AS first_conversion,
    MAX(converted_at) AS last_conversion
FROM conversions;
