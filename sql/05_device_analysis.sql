USE abtesting;

-- ============================================================
-- THE WINNING VARIANT
-- 04 - DEVICE SEGMENT ANALYSIS
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
-- Device mix by variant
-- ============================================================

SELECT
    variant,
    device,
    COUNT(*) AS visitors,

    ROUND(
        COUNT(*) /
        SUM(COUNT(*)) OVER (PARTITION BY variant) * 100,
        1
    ) AS device_mix_pct

FROM first_assignment
GROUP BY variant, device
ORDER BY variant, device;


-- ============================================================
-- Conversion rate by variant and device
-- ============================================================

SELECT
    fa.variant,
    fa.device,

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

GROUP BY
    fa.variant,
    fa.device

ORDER BY
    fa.device,
    fa.variant;
