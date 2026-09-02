# Decoding Customer Value — A SQL-Driven Retention Strategy

A SQL-driven analytics project diagnosing discount dependency and identifying
loyalty drivers for a D2C fashion brand, translating raw purchase behavior
into a concrete, phased retention strategy.

## Business Challenge

Can the brand reduce its dependence on discounts without sacrificing
customer retention and revenue growth? The core tension: a large share of
customers only ever buy on discount, while a separate, sizable segment
already buys at full price and repeats — but promotions are being spent on
both groups indiscriminately, eroding margin on customers who'd likely
purchase anyway.

## Tech Stack

SQL (MySQL) · Python · Power BI · Customer Analytics · Segmentation

## Dataset Snapshot

| Metric | Value |
|---|---|
| Customers Analyzed | 3,900 |
| Variables | 18 |
| Loyal Customers | 42.6% |
| Promo-Dependent Customers | 43.0% |
| Average Customer Spend | $59.76 |
| Satisfaction Rate | 41.9% |

## Key Findings

**Business Risk** — 43% of customers have never purchased without a
discount, and this holds consistently across every customer segment
(41–45%), indicating promotions are influencing even customers who might
buy at full price anyway. Loyal customers, by contrast, spend $5.33 more per
order and show 15% stronger full-price purchasing behavior.

**Business Strength** — The brand has a foundation of 1,660 loyal customers
(42.6%) who consistently buy at full price and repeat. This segment skews
36–57 years old, is subscribed to brand communications, and averages 34
prior purchases.

**Growth Opportunity** — Arizona and Kansas combine high average spend
($55–$67) with relatively low promo dependency (24–34%), flagging them as
underleveraged, high-potential expansion markets.

## Analysis Approach

The SQL analysis (`Customer_Segment_Analysis.sql`) answers five core
business questions using window functions, CTEs, and conditional
aggregation:

1. **Loyal vs. discount-driven customers** — segments customers into
   Genuinely Loyal, Promo Hunter, and Passive/Neutral cohorts, comparing
   spend, purchase frequency, and satisfaction across each
2. **Drivers of customer value** — cross-tabs value tier against payment
   method, subscription status, and purchase frequency to isolate what
   correlates with high-value behavior
3. **Geographic growth opportunities** — a CTE-based opportunity score
   (high spend × low promo dependency) flags underleveraged markets versus
   discount-driven, at-risk ones
4. **Promotion strategy assessment** — quantifies revenue-at-risk if
   discounts were removed, by value tier, season, and category
5. **Ideal Customer Profile** — a composite query isolating the
   Premium + Loyal segment's demographics, preferred payment method,
   season, and category

## Ideal Customer Profile (ICP)

| Attribute | Profile |
|---|---|
| Age | 36–57 |
| Avg Order Value | $72.20 |
| Previous Purchases | 34 |
| Rating | 4.2 / 5 |
| Purchase Frequency | Weekly–Monthly |
| Payment Method | Credit Card |
| Loyalty Status | Full-Price Buyer |
| Geography | AZ, KS, TN, MT |

This customer purchases without relying on discounts, engages across
multiple categories, maintains high satisfaction, and responds to brand
value rather than price incentives — the profile the acquisition strategy is
built to attract more of.

## Retention Strategy — 12-Month Phased Plan

| Phase | Target Segment | Key Action | Success Goal |
|---|---|---|---|
| Month 0–1 | Loyal Customers | Launch Brand Insiders program | Establish loyalty baseline |
| Month 1–3 | High-Value Promo Users | Replace discounts with Brand Credits | Reduce promo reliance |
| Month 3–6 | Mid-Tier Promo Users | Shift to Outerwear-led offers | Drive full-price purchases |
| Month 6–9 | Low-Tier Promo Users | Replace discounts with referrals & bundles | Improve margin quality |
| Month 9–12 | Entire Customer Base | Scale loyalty program & regional growth | Sustain long-term retention |

**Risk control:** pause the current phase if monthly revenue declines more
than 15% year-over-year. Expected trade-offs include short-term revenue
volatility and some promo-dependent churn, with margin improvement expected
to outweigh volume loss over time.

## Success Metrics Dashboard

| KPI | Current | Target |
|---|---|---|
| Promo Dependency | 43% | <25% |
| Loyal Customer Share | 42.6% | 55%+ |
| Full-Price Repurchase Rate | Baseline | +30% |
| Brand Insiders Retention | — | 80%+ |
| Gross Margin / Customer | Baseline | +8% |
| Organic Customers (AZ, KS, TN) | — | 200+ |

## Project Deliverables

- `Customer_Segment_Analysis.sql` — full SQL analysis (schema + 5 core business questions)
- `Executive_Summary_CAC.pdf` — one-page stakeholder summary
- `Retention_Playbook.pdf` — full 12-month strategic roadmap and ICP breakdown
- `Founder_Dashboard.pbix` — Power BI dashboard for ongoing KPI tracking
- `Dataset.csv` — engineered customer dataset used for the analysis
