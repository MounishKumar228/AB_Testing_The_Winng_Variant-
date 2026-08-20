  USE abtesting;

-- ============================================================
-- THE WINNING VARIANT
-- 05 - STANDARDISED DEVICE MIX
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
-- Pooled device mix
-- ============================================================

DROP TEMPORARY TABLE IF EXISTS pooled_device_mix;

CREATE TEMPORARY TABLE pooled_device_mix AS
SELECT
    device,
    COUNT(*) / SUM(COUNT(*)) OVER () AS pooled_weight
FROM first_assignment
GROUP BY device;


SELECT
    device,
    ROUND(pooled_weight * 100, 2) AS pooled_device_mix_pct
FROM pooled_device_mix;


-- ============================================================
-- Device-level conversion rates
-- ============================================================

DROP TEMPORARY TABLE IF EXISTS device_rates;

CREATE TEMPORARY TABLE device_rates AS
SELECT
    fa.variant,
    fa.device,
    COUNT(*) AS visitors,

    COUNT(DISTINCT CASE
        WHEN c.converted_at >= fa.assigned_at
         AND c.converted_at <= '2026-06-30 23:59:59'
        THEN fa.visitor_id
    END) AS converted_visitors,

    COUNT(DISTINCT CASE
        WHEN c.converted_at >= fa.assigned_at
         AND c.converted_at <= '2026-06-30 23:59:59'
        THEN fa.visitor_id
    END) / COUNT(*) AS conversion_rate

FROM first_assignment fa
LEFT JOIN conversions c
    ON fa.visitor_id = c.visitor_id

GROUP BY
    fa.variant,
    fa.device;


-- ============================================================
-- Standardised conversion rates
-- ============================================================

SELECT
    dr.variant,

    ROUND(
        SUM(dr.conversion_rate * pdm.pooled_weight) * 100,
        2
    ) AS standardised_conversion_rate_pct

FROM device_rates dr
JOIN pooled_device_mix pdm
    ON dr.device = pdm.device

GROUP BY dr.variant;


-- ============================================================
-- Standardised B minus A
-- ============================================================

WITH standardised AS (
    SELECT
        dr.variant,
        SUM(
            dr.conversion_rate * pdm.pooled_weight
        ) AS standardised_rate
    FROM device_rates dr
    JOIN pooled_device_mix pdm
        ON dr.device = pdm.device
    GROUP BY dr.variant
)

SELECT
    ROUND(
        (
            MAX(
                CASE
                    WHEN variant = 'B'
                    THEN standardised_rate
                END
            )
            -
            MAX(
                CASE
                    WHEN variant = 'A'
                    THEN standardised_rate
                END
            )
        ) * 100,
        1
    ) AS standardised_b_minus_a_pp
FROM standardised;
