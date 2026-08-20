# The Winning Variant — A/B Test Analysis

## Executive Recommendation

### Do not ship Variant B.

The headline result suggests that B wins by **3.3 percentage points**, with B converting at **11.9%** versus **8.7%** for A.

However, the experiment's traffic split was broken after the bucketing-service redeployment. Variant A received approximately **72% web / 28% mobile**, while Variant B received approximately **38% web / 62% mobile**.

This matters because mobile visitors convert much more frequently than web visitors.

When the experiment is segmented by device, B does not outperform A:

- **Web:** A = 4.8%, B = 4.4%
- **Mobile:** A = 18.5%, B = 16.6%

So the overall **+3.3 pp** result is not evidence of a genuine B treatment advantage. The mechanism is the broken device allocation: B received disproportionately more traffic from the higher-converting mobile segment, inflating its blended conversion rate.

After standardising both variants to the same pooled device mix:

- **A = 10.9%**
- **B = 9.8%**
- **B − A = -1.1 pp**

The result reverses.

### Recommendation

**Do not ship B to 100% of traffic.**

Fix the bucketing service, verify that assignment is balanced, and rerun the experiment before making a rollout decision.

The current evidence supports **A, not B**.

---

# 1. Business Question

Cadence tested a new pricing screen and reported that Variant B converted visitors to paid at nearly 12%, compared with approximately 9% for Variant A.

The initial conclusion was a roughly **3 percentage-point lift** for B.

The analysis tests whether that apparent win is real and whether B should be shipped to 100% of traffic.

The key questions are:

1. What is the actual overall conversion difference?
2. Does B still win within mobile?
3. How many unique visitors were assigned to B?
4. Which variant performs better after controlling for device?
5. What is the standardised B minus A conversion difference?

---

# 2. Data

The experiment contains two files.

## `assignments.csv`

Columns:

| Column | Description |
|---|---|
| `visitor_id` | Visitor identifier |
| `variant` | Experiment variant, A or B |
| `assigned_at` | Assignment timestamp in UTC |
| `device` | Web or mobile |
| `channel` | Acquisition channel |
| `country` | Visitor country |

A visitor can have multiple assignment rows.

**Rule used:** each visitor is counted under their **earliest assignment**.

## `conversions.csv`

Columns:

| Column | Description |
|---|---|
| `visitor_id` | Visitor identifier |
| `converted_at` | Subscription start timestamp |
| `plan` | Subscription plan |
| `amount_usd` | Subscription amount |

A conversion is included only when:

```text
converted_at >= visitor's first assignment
AND
converted_at <= 2026-06-30 23:59:59 UTC
```

The experiment window is:

```text
2026-06-01 00:00:00 UTC
to
2026-06-30 23:59:59 UTC
```

---

# 3. Data Preparation

The analysis follows the experiment rules exactly.

### First assignment

Visitors can have multiple assignment events because they may return during the test.

Only the earliest assignment is retained:

```sql
ROW_NUMBER() OVER (
    PARTITION BY visitor_id
    ORDER BY assigned_at
)
```

### Device standardisation

Device values have inconsistent capitalisation, so they are normalised using:

```sql
LOWER(TRIM(device))
```

### Conversion window

Conversions outside the June test window are excluded.

Conversions must also occur on or after the visitor's first assignment.

---

# 4. Verified Answers

| # | Question | Answer |
|---|---|---:|
| 1 | Overall B conversion lift vs A | **3.3 pp** |
| 2 | Mobile B conversion lift vs A | **-1.9 pp** |
| 3 | Unique visitors assigned to B | **28,000** |
| 4 | Better variant after holding device mix constant | **Variant A** |
| 5 | Standardised B conversion lift vs A | **-1.1 pp** |

---

# 5. Overall Conversion

Variant A:

```text
2,603 / 30,000 = 8.7%
```

Variant B:

```text
3,342 / 28,000 = 11.9%
```

Therefore:

```text
11.9% - 8.7% = +3.3 pp
```

### Answer

**3.3 percentage points**

This is the headline result, but it is not sufficient to conclude that B is better.

---

# 6. Mobile Conversion

Among mobile visitors:

Variant A:

```text
1,562 / 8,427 = 18.5%
```

Variant B:

```text
2,879 / 17,366 = 16.6%
```

Therefore:

```text
16.6% - 18.5% = -1.9 pp
```

### Answer

**-1.9 percentage points**

B performs worse than A among mobile visitors.

---

# 7. Unique Variant B Visitors

Visitors are counted once using their earliest assignment.

```text
Variant B unique visitors = 28,000
```

### Answer

**28,000**

---

# 8. The Broken Device Split

The experiment was not balanced by device.

| Device | Variant A | Variant B |
|---|---:|---:|
| Web | 72.0% | 38.0% |
| Mobile | 28.1% | 62.0% |

Variant B received substantially more mobile traffic.

This matters because mobile converts much better than web.

The experiment therefore has a major composition problem.

---

# 9. Conversion by Device

| Device | A Conversion | B Conversion | B − A |
|---|---:|---:|---:|
| Web | 4.8% | 4.4% | **-0.5 pp** |
| Mobile | 18.5% | 16.6% | **-1.9 pp** |

B does not outperform A within either device.

This is the critical evidence.

The overall B win is not coming from better conversion within web or mobile. It is coming from the fact that B received much more traffic from mobile, the higher-converting segment.

---

# 10. Why the Headline Result Reverses

The mechanism is:

```text
Bucketing service redeployed
          ↓
Traffic split became unbalanced
          ↓
A received mostly Web traffic
B received mostly Mobile traffic
          ↓
Mobile has a much higher conversion rate
          ↓
B receives an artificial blended-rate advantage
          ↓
Headline result: B +3.3 pp
          ↓
Control for device mix
          ↓
B actually -1.1 pp
```

Therefore:

> **The +3.3 pp headline is a device-mix effect caused by the broken assignment split, not evidence that Variant B performs better.**

This is the key analytical finding.

---

# 11. Standardised Device Mix

To make a fair comparison, both variants are evaluated using the same pooled web/mobile distribution across all unique visitors.

The standardised conversion rates are:

```text
Standardised A = 10.9%

Standardised B = 9.8%
```

Therefore:

```text
9.8% - 10.9% = -1.1 pp
```

### Answer

**-1.1 percentage points**

After controlling for device mix, **Variant A performs better**.

---

# 12. Final Decision

## Should Variant B be shipped?

### No.

The raw experiment result:

```text
B = 11.9%
A = 8.7%

B appears to lead by +3.3 pp
```

But the experiment has an unbalanced device split.

Within each device:

```text
Web:
A = 4.8%
B = 4.4%

Mobile:
A = 18.5%
B = 16.6%
```

After standardisation:

```text
A = 10.9%
B = 9.8%

B = -1.1 pp vs A
```

Therefore, the evidence does not support shipping B.

---

# 13. Recommended Next Step

1. Fix the bucketing service.
2. Confirm that assignment is balanced across important pre-treatment characteristics.
3. Use the first assignment per visitor.
4. Continue standardising device values.
5. Rerun the experiment.
6. Use the same June conversion-window definition.
7. Evaluate the new experiment before a 100% rollout.

The current experiment should **not** be treated as evidence that Variant B is better.

---

# 14. SQL Analysis

The SQL is separated into reproducible steps:

```text
sql/
├── 00_create_tables_and_load_data.sql
├── 01_data_quality.sql
├── 02_first_assignment.sql
├── 03_conversion_analysis.sql
├── 04_device_analysis.sql
└── 05_standardised_analysis.sql
```

### `00_create_tables_and_load_data.sql`

Creates the MySQL database and tables and loads:

- `assignments.csv`
- `conversions.csv`

It also performs basic row-count checks after loading.

The local file paths in this script should be changed to the user's local dataset location before execution.

### `01_data_quality.sql`

Checks:

- total assignment rows
- unique visitors
- repeated assignment events
- variant distribution
- inconsistent device values
- blank countries
- conversion records
- conversion dates

### `02_first_assignment.sql`

Retains only the earliest assignment for each visitor and verifies the resulting visitor-level experiment population.

### `03_conversion_analysis.sql`

Calculates:

- A visitors
- B visitors
- A conversions
- B conversions
- A conversion rate
- B conversion rate
- overall B minus A lift

### `04_device_analysis.sql`

Calculates:

- device distribution by variant
- web conversion rates
- mobile conversion rates
- device-level B minus A differences

This file establishes the broken device split and the within-device reversal.

### `05_standardised_analysis.sql`

Calculates:

- pooled device distribution
- standardised A conversion rate
- standardised B conversion rate
- standardised B minus A difference

---

# 15. Repository Structure

```text
the-winning-variant/
│
├── README.md
│
├── sql/
│   ├── 00_create_tables_and_load_data.sql
│   ├── 01_data_quality.sql
│   ├── 02_first_assignment.sql
│   ├── 03_conversion_analysis.sql
│   ├── 04_device_analysis.sql
│   └── 05_standardised_analysis.sql
│
├── results/
│   └── five_verified_answers.md
│
└── powerbi/
    └── The_Winning_Variant.pbix
```

The raw challenge CSV files are not required to be committed to the public repository unless the challenge explicitly permits redistribution.

---

# 16. Final Conclusion

The initial result looked like a strong win for Variant B.

After validating the visitor-level assignment logic and checking comparability, the result changes.

The bucketing-service redeployment produced an unbalanced device split:

- A received mostly web traffic.
- B received mostly mobile traffic.
- Mobile converts substantially better than web.
- B therefore received an artificial blended conversion advantage.

Within both devices, A actually converts better.

After standardising the device mix:

```text
A = 10.9%
B = 9.8%

B − A = -1.1 pp
```

### Final recommendation

> **Do not ship Variant B. Fix the bucketing issue and rerun the experiment before rollout.**
