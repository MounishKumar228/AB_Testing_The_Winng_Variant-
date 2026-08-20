USE abtesting;

-- ============================================================
-- THE WINNING VARIANT
-- 02 - FIRST ASSIGNMENT PER VISITOR
-- ============================================================

DROP TEMPORARY TABLE IF EXISTS first_assignment;

CREATE TEMPORARY TABLE first_assignment AS
SELECT
    visitor_id,
    variant,
    assigned_at,
    LOWER(TRIM(device)) AS device,
    channel,
    country
FROM (
    SELECT
        visitor_id,
        variant,
        assigned_at,
        device,
        channel,
        country,
        ROW_NUMBER() OVER (
            PARTITION BY visitor_id
            ORDER BY assigned_at
        ) AS rn
    FROM assignments
) a
WHERE rn = 1;


-- Verify one row per visitor
SELECT
    COUNT(*) AS rows_after_deduplication,
    COUNT(DISTINCT visitor_id) AS unique_visitors
FROM first_assignment;


-- Verify first assignment variant distribution
SELECT
    variant,
    COUNT(*) AS visitors
FROM first_assignment
GROUP BY variant
ORDER BY variant;


-- Verify device distribution by variant
SELECT
    variant,
    device,
    COUNT(*) AS visitors
FROM first_assignment
GROUP BY variant, device
ORDER BY variant, device;
