USE abtesting;

-- ============================================================
-- THE WINNING VARIANT
-- 03 - CONVERSION ANALYSIS
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


-- ============================================================
-- Overall conversion
-- ============================================================

SELECT
    fa.variant,
    COUNT(*) AS visitors,
    COUNT(DISTINCT CASE
        WHEN c.converted_at >= fa.assigned_at
         AND c.converted_at <= '2026-06-30 23:59:59'
        THEN fa.visitor_id
    END) AS converted_visitors,

    ROUND(
        COUNT(DISTINCT CASE
            WHEN c.converted_at >= fa.assigned_at
             AND c.converted_at <= '2026-06-30 23:59:59'
            THEN fa.visitor_id
        END) / COUNT(*) * 100,
        2
    ) AS conversion_rate_pct

FROM first_assignment fa
LEFT JOIN conversions c
    ON fa.visitor_id = c.visitor_id
GROUP BY fa.variant
ORDER BY fa.variant;


-- ============================================================
-- Overall B minus A
-- ============================================================

WITH conversion_rates AS (
    SELECT
        fa.variant,
        COUNT(*) AS visitors,
        COUNT(DISTINCT CASE
            WHEN c.converted_at >= fa.assigned_at
             AND c.converted_at <= '2026-06-30 23:59:59'
            THEN fa.visitor_id
        END) AS converted_visitors
    FROM first_assignment fa
    LEFT JOIN conversions c
        ON fa.visitor_id = c.visitor_id
    GROUP BY fa.variant
)

SELECT
    ROUND(
        (
            MAX(
                CASE
                    WHEN variant = 'B'
                    THEN converted_visitors / visitors
                END
            )
            -
            MAX(
                CASE
                    WHEN variant = 'A'
                    THEN converted_visitors / visitors
                END
            )
        ) * 100,
        1
    ) AS b_minus_a_pp
FROM conversion_rates;
