# The Winning Variant — Five Verified Answers

## Verified Answers

| # | Question | Answer |
|---|---|---:|
| 1 | Overall B conversion lift vs A | **3.3 pp** |
| 2 | Mobile B conversion lift vs A | **-1.9 pp** |
| 3 | Unique visitors assigned to B | **28,000** |
| 4 | Better variant after holding device mix constant | **Variant A** |
| 5 | Standardised B conversion lift vs A | **-1.1 pp** |

---

## 1. Overall B Conversion Lift

### Answer: **3.3 pp**

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

---

## 2. Mobile B Conversion Lift

### Answer: **-1.9 pp**

Mobile Variant A:

```text
1,562 / 8,427 = 18.5%
```

Mobile Variant B:

```text
2,879 / 17,366 = 16.6%
```

Therefore:

```text
16.6% - 18.5% = -1.9 pp
```

B performs worse than A among mobile visitors.

---

## 3. Unique Visitors Assigned to Variant B

### Answer: **28,000**

Each visitor is counted once using their earliest assignment.

```text
Variant B unique visitors = 28,000
```

---

## 4. Better Variant After Holding Device Mix Constant

### Answer: **Variant A**

The traffic split is not balanced:

| Device | Variant A | Variant B |
|---|---:|---:|
| Web | 72.0% | 38.0% |
| Mobile | 28.1% | 62.0% |

Within each device:

| Device | A Conversion | B Conversion | B - A |
|---|---:|---:|---:|
| Web | 4.8% | 4.4% | -0.5 pp |
| Mobile | 18.5% | 16.6% | -1.9 pp |

B does not outperform A within either device.

Therefore:

**Variant A actually converts better.**

---

## 5. Standardised B Conversion Lift

### Answer: **-1.1 pp**

Both variants are evaluated using the same pooled web/mobile device distribution.

```text
Standardised A = 10.9%

Standardised B = 9.8%
```

Therefore:

```text
9.8% - 10.9% = -1.1 pp
```

---

# Final Submission Answers

```text
1. 3.3 pp
2. -1.9 pp
3. 28,000
4. Variant A
5. -1.1 pp
```

## Key Finding

The headline result makes Variant B appear to win:

```text
B = 11.9%
A = 8.7%

Headline lift = +3.3 pp
```

However, the device mix is heavily unbalanced. Variant B received disproportionately more mobile traffic, while Variant A received substantially more web traffic.

Because mobile visitors convert at a much higher rate, this different traffic composition artificially increases B's blended conversion rate.

After controlling for device:

```text
A = 10.9%
B = 9.8%

Adjusted lift = -1.1 pp
```

Therefore, the apparent B win is a **device-mix effect caused by the broken assignment split**, not evidence that B is the better variant.

> **Final decision: Variant A performs better after controlling for device mix, so Variant B should not be shipped based on this experiment.**
