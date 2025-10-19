# Business Concepts Reference

### Financial Metrics

#### Gross Sales

```
Gross Sales = Unit Price × Quantity Sold
```

- Raw revenue before any deductions
- Starting point for P&L analysis

#### Pre-Invoice Deductions

```
Net Invoice Sales = Gross Sales × (1 - Pre-Invoice Discount %)
```

- Customer-level discounts
- Negotiated rates based on volume/relationship

#### Post-Invoice Deductions

```
Net Sales = Net Invoice Sales × (1 - Post-Invoice Discount %)
```

- Product-level promotions
- Additional deductions (freight, marketing support)

#### Gross Margin

```
Gross Margin = Net Sales - COGS (Cost of Goods Sold)
Gross Margin % = (Gross Margin / Net Sales) × 100
```

### Supply Chain Metrics

#### Forecast Accuracy

```
Forecast Accuracy = 100% - Absolute Error %

Where:
Absolute Error % = (|Forecast - Actual| / Forecast) × 100
```

**Interpretation**:

- 90-100%: Excellent forecasting
- 70-90%: Good forecasting
- 50-70%: Needs improvement
- <50%: Poor forecasting (significant action required)

#### Net Error Analysis

```
Net Error = Forecast - Actual

Positive Net Error → Over-forecasting (excess inventory risk)
Negative Net Error → Under-forecasting (stockout risk)
```

### Fiscal Calendar

**Company Fiscal Year**: September to August

- Q1: Sep, Oct, Nov
- Q2: Dec, Jan, Feb
- Q3: Mar, Apr, May
- Q4: Jun, Jul, Aug

**Conversion Formula**:

```
Fiscal Year = Calendar Year + (0 if month < September else 0)
            = YEAR(Date + INTERVAL 4 MONTH)
```
