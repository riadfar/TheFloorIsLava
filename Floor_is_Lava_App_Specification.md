# Floor is Lava — Financial Feasibility Application Specification

**Document type:** Product + Technical Specification  
**Source:** Financial feasibility workbook for *The Floor is Lava*  
**Target:** Flutter Android application, designed to remain extensible beyond this specific financial study  
**Architecture target:** Clean Architecture + Clean Code + feature-first modularity  
**Responsive target:** Phones and large tablets, portrait and landscape  
**Project work-start timestamp:** 2026-09-08 12:17 (UTC+03:00)

---

## 1. Purpose

This document converts the original financial feasibility study from a spreadsheet model into the functional and technical specification of a small Flutter application.

The application must reproduce the study's calculations faithfully while replacing spreadsheet-cell dependencies with a proper domain model, calculation engine, editable inputs, validation, and responsive UI.

The application is **not** intended to hard-code the current study. The current values are the initial scenario. Every important assumption must be editable, and every dependent result must recalculate automatically.

The architecture must therefore support future evolution into a general-purpose business/financial planning application rather than a one-off "Floor is Lava" calculator.

---

# 2. Core Product Concept

The application is an interactive financial model.

Users enter or modify assumptions such as:

- Round duration
- Turnaround/setup time
- Ticket price
- Average players per round
- Maximum capacity
- Operating hours
- Operating days
- Occupancy by month
- Employee count and expansion timing
- Salaries and incentives
- Electricity
- Maintenance/consumables
- Marketing
- Mall service fees
- Rent
- Mall deposit/key money
- Contract duration
- Equipment package
- Shipping percentage
- Customs/clearance percentage
- Fit-out costs
- Licensing
- Opening campaign
- Contingency percentage

The application calculates:

- Daily capacity
- Actual daily rounds
- Daily revenue
- Monthly revenue
- Cumulative revenue
- Monthly operating expenses
- Monthly operating profit
- Profit margin
- Initial investment
- Monthly net cash flow
- Cumulative cash flow
- Payback period
- Year-one profit
- Year-two profit
- Year-one ROI
- Sensitivity scenarios
- Staffing schedule

No result should be manually entered if it can be derived from another value.

---

# 3. Current Study Baseline

These are the values currently present in the source workbook. They are **defaults only**, not constants.

## 3.1 Session and pricing

| Parameter | Current value |
|---|---:|
| Round duration | 15 minutes |
| Turnaround time | 5 minutes |
| Ticket price/person/round | $4.00 |
| Average players/round | 3.63 |
| Maximum players/round | 6 |
| Operating hours/day | 13 |
| Operating days/week | 7 |
| Operating days/month | 30.4 |

Current operating window is described as approximately **1 PM–2 AM**.

## 3.2 Occupancy

| Period | Occupancy |
|---|---:|
| Month 1 | 8% |
| Month 2 | 23% |
| Month 3 | 46% |
| Month 4 onward | 69% |

Occupancy is the most influential revenue assumption and must remain editable.

## 3.3 Staffing

| Parameter | Current value |
|---|---:|
| Initial employees | 2 |
| Expanded employees | 3 |
| Expansion begins | Month 3 |
| Monthly salary/employee | $160 |
| Monthly incentive/employee | $30 |

## 3.4 Monthly operating costs

| Cost | Current value |
|---|---:|
| Electricity | $250 |
| Maintenance/consumables | $100 |
| Continuous marketing | $150 |
| Mall shared services | $50 |
| Rent | $3,000 |

## 3.5 Property

| Parameter | Current value |
|---|---:|
| Mall deposit/key money | $0 |
| Contract duration | 1 year |

## 3.6 Equipment

Two supplier options exist:

| Option | Equipment cost |
|---|---:|
| Package 1 — complete Grid Room | $10,285 |
| Package 2 — individual components | $5,270 |

Current study selects **Option 2**.

Additional assumptions:

- Sea freight = 12% of equipment value
- Customs/clearance = 25% of equipment value

## 3.7 Fit-out

| Item | Current value |
|---|---:|
| Reception/cashier furniture | $300 |
| Painting/illuminated wall graphics | $200 |
| Signage | $100 |
| HVAC | $800 |
| Electrician/carpenter/painter labor | $1,000 |

## 3.8 Pre-opening costs

| Item | Current value |
|---|---:|
| Registration/licensing | $300 |
| Opening marketing campaign | $2,000 |
| Contingency | 10% |
| Maximum full setup days after goods arrive | 24 days |

The 24-day setup figure is planning information and does not currently enter the financial formulas.

---

# 4. Financial Calculation Engine

The calculation engine is the most important part of the application.

It must be implemented independently from Flutter widgets.

UI code must never contain business formulas.

Recommended structure:

```text
Presentation
    ↓
Application / Use Cases
    ↓
Domain Calculation Engine
    ↓
Input/Output Models
```

The engine should receive a complete scenario and return a complete calculated financial model.

---

# 5. Revenue Calculations

## 5.1 Round duration

A round consists of:

```text
Round Duration
+
Turnaround Time
=
Total Time Consumed Per Round
```

Current:

```text
15 + 5 = 20 minutes
```

## 5.2 Maximum rounds per day

```text
Maximum Rounds/Day
=
floor((Operating Hours × 60) / (Round Duration + Turnaround Time))
```

Current:

```text
floor((13 × 60) / (15 + 5))
= floor(780 / 20)
= 39 rounds/day
```

The application must use integer flooring because a partial round cannot be sold.

## 5.3 Actual rounds per day

Occupancy converts theoretical capacity into expected utilization.

```text
Actual Rounds/Day
=
Maximum Rounds/Day × Occupancy
```

Example at 69% occupancy:

```text
39 × 0.69
= 26.91 rounds/day
```

Whether the UI displays 26.91 or rounds a presentation value is a UX decision; calculations should retain sufficient precision.

## 5.4 Daily revenue

```text
Daily Revenue
=
Actual Rounds/Day
×
Average Players/Round
×
Ticket Price
```

At the baseline:

```text
26.91 × 3.63 × $4
= approximately $390.72/day
```

## 5.5 Monthly revenue

```text
Monthly Revenue
=
Daily Revenue
×
Operating Days/Month
```

At 30.4 operating days:

```text
$390.72 × 30.4
≈ $11,878/month
```

The exact application result should be calculated from the underlying values rather than hard-coded examples.

## 5.6 Monthly occupancy rule

The model uses:

```text
Month 1 → Occupancy Month 1
Month 2 → Occupancy Month 2
Month 3 → Occupancy Month 3
Month 4+ → Stable Occupancy
```

This rule must be represented explicitly in the domain model.

A future version should support a general occupancy schedule rather than limiting the model to four hard-coded values.

---

# 6. Operating Expense Calculations

## 6.1 Employee count

Current staffing rule:

```text
If month >= Expansion Month:
    Employees = Expanded Employee Count
Else:
    Employees = Initial Employee Count
```

With current values:

```text
Months 1–2 → 2 employees
Month 3 onward → 3 employees
```

This should be generalized into a staffing schedule in the future.

## 6.2 Employee monthly cost

```text
Cost Per Employee
=
Monthly Salary
+
Monthly Incentive
```

Current:

```text
$160 + $30 = $190
```

## 6.3 Total payroll

```text
Total Payroll
=
Employee Count
×
(Salary + Incentive)
```

## 6.4 Total monthly operating expenses

```text
Operating Expenses
=
Payroll
+
Rent
+
Mall Shared Services
+
Electricity
+
Maintenance/Consumables
+
Continuous Marketing
```

All expense categories must remain independently editable.

Do not merge categories in the domain model simply because they are currently six lines in the spreadsheet.

---

# 7. Initial Investment / Setup Cost

## 7.1 Equipment selection

```text
Equipment Cost =
    Package 1 if selected package = 1
    Package 2 if selected package = 2
```

The UI should present equipment packages as selectable options, not require the user to type the selected equipment cost manually.

However, future versions should support arbitrary equipment packages.

## 7.2 Shipping

```text
Shipping
=
Equipment Cost × Shipping Rate
```

Current:

```text
$5,270 × 12%
= $632.40
```

## 7.3 Customs and clearance

```text
Customs
=
Equipment Cost × Customs Rate
```

Current:

```text
$5,270 × 25%
= $1,317.50
```

## 7.4 Delivered equipment cost

```text
Delivered Equipment
=
Equipment
+
Shipping
+
Customs
```

Current:

```text
≈ $7,219.90
```

The spreadsheet displays rounded dollar values, but the application should retain decimal precision internally.

## 7.5 Fit-out total

```text
Fit-out
=
Furniture
+
Painting
+
Signage
+
HVAC
+
Installation Labor
```

Current:

```text
300 + 200 + 100 + 800 + 1000
= $2,400
```

## 7.6 Property total

```text
Property Cost
=
Mall Deposit
+
First Month Rent
```

Current:

```text
0 + 3,000
= $3,000
```

## 7.7 Other pre-opening costs

```text
Other Pre-opening
=
Licensing
+
Opening Marketing
```

Current:

```text
300 + 2,000
= $2,300
```

## 7.8 Subtotal before contingency

```text
Subtotal
=
Delivered Equipment
+
Fit-out
+
Property Cost
+
Other Pre-opening
```

## 7.9 Contingency

```text
Contingency
=
Subtotal × Contingency Rate
```

Current rate:

```text
10%
```

## 7.10 Total initial investment

```text
Initial Investment
=
Subtotal + Contingency
```

Current study result:

```text
$16,412 approximately
```

---

# 8. Cash Flow Model

The model contains a special **Month 0**.

## Month 0

Month 0 represents the initial investment:

```text
Revenue = 0
Operating Expenses = 0
Operating Profit = 0
Initial Investment = Initial Investment Cost
Net Cash Flow = -Initial Investment
```

## Months 1–24

For each month:

```text
Operating Profit
=
Monthly Revenue
-
Monthly Operating Expenses
```

The current model treats operating profit as the monthly net operating cash flow.

```text
Net Cash Flow
=
Operating Profit
```

because the initial investment is only applied at Month 0.

## Cumulative cash flow

```text
Cumulative Cash Flow(month 0)
=
Month 0 Net Cash Flow
```

For every later month:

```text
Cumulative Cash Flow(n)
=
Cumulative Cash Flow(n-1)
+
Net Cash Flow(n)
```

---

# 9. Profit Margin

For every month:

```text
Profit Margin
=
Operating Profit / Revenue
```

If revenue is zero:

```text
Profit Margin = 0
```

The implementation must safely handle division by zero.

---

# 10. Payback Period

The original spreadsheet calculates an approximate payback month by identifying when cumulative cash flow stops being negative.

The application should improve this concept slightly.

### Required display

- Last month with negative cumulative cash flow
- First month with zero/positive cumulative cash flow
- Payback month
- Optional interpolated payback period

Example:

```text
Investment recovered during Month 5.
```

For higher precision, the application may calculate:

```text
Fractional Month
=
Absolute Previous Negative Cumulative Cash Flow
/
Current Month Net Cash Flow
```

Then:

```text
Payback
=
Previous Month
+
Fractional Month
```

This should be a separate precision metric so the original workbook-compatible month result remains available.

---

# 11. Yearly Profit

## Year 1

```text
Year 1 Profit
=
SUM(Month 1 ... Month 12 Operating Profit)
```

## Year 2

```text
Year 2 Profit
=
SUM(Month 13 ... Month 24 Operating Profit)
```

Month 0 investment is not included in operating profit.

---

# 12. ROI

The original model defines Year-1 ROI as:

```text
ROI
=
Year 1 Net Profit
/
Initial Investment
```

Display as a percentage:

```text
ROI%
=
ROI × 100
```

Current study:

```text
approximately 433.2%
```

The application should clearly label this as:

> Year-1 ROI based on the study's definition.

Do not silently replace this definition with a different accounting/finance convention.

---

# 13. Sensitivity Analysis

The original model contains three scenarios:

| Scenario | Occupancy |
|---|---:|
| Conservative | 20% |
| Base | Stable/base occupancy |
| Optimistic | 60% |

For each scenario:

```text
Daily Rounds
=
Maximum Rounds/Day × Scenario Occupancy
```

```text
Monthly Revenue
=
Daily Rounds
×
Average Players/Round
×
Ticket Price
×
Operating Days/Month
```

```text
Monthly Estimated Profit
=
Scenario Monthly Revenue
-
Scenario Monthly Operating Expenses
```

```text
Approximate Payback
=
Initial Investment
/
Monthly Estimated Profit
```

If monthly estimated profit is zero or negative:

```text
Payback = Not Recoverable Under This Scenario
```

Never display a negative or meaningless payback number.

---

# 14. Staffing Schedule

The workbook includes a separate employee schedule.

Current data describes staffing phases such as:

```text
Phase 1 → emp1
Phase 2 → emp1 + emp2
Phase 3 → emp2
```

and recorded work-hour information:

```text
emp1 H → 54 H
emp2 H → 42 H
Founders → 13 H
```

These figures should **not be mixed into the financial engine unless their meaning is formally defined**.

In the application they should be represented as a separate staffing/operations module.

Future versions should support:

- Employee records
- Role
- Hourly/monthly compensation
- Working days
- Shift start/end
- Breaks
- Weekly hours
- Staffing phases
- Temporary employees
- Overtime
- Multiple locations

---

# 15. Data Dependency Model

The most important architectural rule is:

> Every derived value must depend on source inputs, not on duplicated numbers.

Example:

```text
Ticket Price
       ↓
Revenue
       ↓
Profit
       ↓
Cash Flow
       ↓
Payback
       ↓
ROI-related analysis
```

Another chain:

```text
Round Duration
        +
Turnaround Time
        ↓
Total Round Time
        ↓
Maximum Rounds/Day
        ↓
Actual Rounds/Day
        ↓
Daily Revenue
        ↓
Monthly Revenue
        ↓
Monthly Profit
        ↓
Cumulative Cash Flow
```

Another:

```text
Equipment Selection
        ↓
Equipment Cost
        ↓
Shipping
        ↓
Customs
        ↓
Delivered Equipment
        ↓
Initial Investment
        ↓
Payback
```

Another:

```text
Employee Count
        +
Salary
        +
Incentive
        ↓
Payroll
        ↓
Operating Expenses
        ↓
Operating Profit
        ↓
Cash Flow
```

Changing one input must propagate through every dependent result automatically.

---

# 16. Generalized Input Model

Do not create a giant flat `FloorIsLavaSettings` class.

Use concepts that can survive future projects.

Suggested domain model:

```text
FinancialScenario
├── ScenarioMetadata
├── RevenueModel
│   ├── PricingModel
│   ├── CapacityModel
│   ├── OperatingSchedule
│   └── OccupancySchedule
├── StaffingModel
├── OperatingExpenseModel
├── StartupCostModel
├── ProjectionSettings
└── SensitivitySettings
```

Example conceptual entities:

```text
Money
Percentage
Duration
OperatingSchedule
OccupancySchedule
StaffingPlan
ExpenseCategory
StartupCostItem
RevenueStream
FinancialScenario
MonthlyProjection
SensitivityScenario
FinancialSummary
```

The application should avoid passing raw `double` values everywhere when the domain meaning matters.

For example, `Money`, `Percentage`, and `DurationMinutes` can prevent accidental misuse.

---

# 17. Application Screens

## 17.1 Dashboard

The first screen should immediately communicate the business state.

Suggested cards:

- Initial Investment
- Monthly Revenue
- Monthly Operating Expenses
- Monthly Profit
- Payback
- Year-1 Profit
- Year-1 ROI

Also show:

- Revenue trend chart
- Cumulative cash-flow chart
- Occupancy
- Current scenario

The dashboard should remain useful on both phone and tablet.

---

# 18. Inputs / Assumptions Screen

Group inputs into sections:

### Session & Pricing
- Round duration
- Turnaround
- Ticket price
- Average players
- Maximum capacity
- Operating hours
- Operating days

### Occupancy
- Month 1
- Month 2
- Month 3
- Stable occupancy
- Future monthly schedule

### Staffing
- Initial headcount
- Expansion rules
- Salary
- Incentive

### Operating Expenses
- Rent
- Electricity
- Maintenance
- Marketing
- Mall services
- Custom expenses

### Property
- Deposit
- Contract duration

### Equipment
- Equipment packages
- Selected package
- Shipping
- Customs

### Fit-out
- Furniture
- Painting
- Signage
- HVAC
- Labor
- Additional items

### Pre-opening
- Licensing
- Opening campaign
- Contingency

Every editable input should display:

- Current value
- Unit
- Validation rules
- Optional description/help
- Whether it is an assumption or verified value

---

# 19. Calculation Results Screen

Show the complete monthly projection.

Columns:

```text
Month
Occupancy
Maximum Rounds
Actual Rounds
Daily Revenue
Monthly Revenue
Employees
Payroll
Other Expenses
Total Expenses
Operating Profit
Profit Margin
Net Cash Flow
Cumulative Cash Flow
```

On small screens, do not force a giant horizontal table.

Use:

- Month cards
- Expandable monthly rows
- Horizontal scrolling only when appropriate

On tablets, use a real data table/grid.

---

# 20. Startup Cost Screen

Show:

```text
Equipment
Shipping
Customs
Delivered Equipment

Fit-out
Property
Pre-opening

Subtotal
Contingency
TOTAL INITIAL INVESTMENT
```

Every subtotal should be tappable/expandable to reveal its components.

---

# 21. Sensitivity Screen

Show:

- Conservative
- Base
- Optimistic

For each:

- Occupancy
- Monthly revenue
- Monthly expenses
- Monthly profit
- Approximate payback

Future version:

Allow the user to create arbitrary scenarios such as:

```text
Pessimistic
Expected
Optimistic
Custom
```

---

# 22. Settings

Settings should include:

- Currency
- Number formatting
- Decimal precision
- Theme
- Language
- First day of week
- Default scenario
- Data backup/export
- Reset scenario
- About
- Calculation/model version

The application should support localization from the beginning, even if the first UI language is English.

---

# 23. Visual Design Direction

The UI should be simple, modern, professional, and financial rather than visually overloaded.

Suggested visual language:

- Clean cards
- Clear hierarchy
- Large key metrics
- Subtle elevation
- Rounded corners used consistently
- Strong typography
- Minimal decorative elements
- Clear positive/negative states
- Consistent spacing
- Accessible contrast
- No unnecessary gradients or animations

The product should feel like:

> A lightweight professional financial dashboard.

Not:

> A complicated accounting system.

---

# 24. Color Semantics

Use semantic colors rather than hard-coded widget colors.

Examples:

```text
Primary
Surface
Background
Text
Muted Text
Success
Warning
Error
Border
Positive Financial Value
Negative Financial Value
Input / Editable
Verified
Unverified Assumption
```

The exact color palette can be changed later without touching business logic.

---

# 25. Input UX

Financial inputs must be easy to edit.

Requirements:

- Numeric keyboards where appropriate
- Currency formatting
- Percentage formatting
- Duration formatting
- Validation before saving
- Clear min/max constraints
- Prevent invalid negative values where inappropriate
- Preserve decimal values such as 3.63 players
- Show calculated values separately from editable values
- Indicate which values are assumptions
- Confirm destructive resets

Avoid forcing users to understand formulas.

For example, instead of asking the user to calculate shipping:

```text
Shipping rate: 12%
```

and display:

```text
Calculated shipping: $632.40
```

---

# 26. Continuous Recalculation

The calculation engine must be deterministic.

Given:

```text
Scenario A
```

it should always produce:

```text
FinancialModel A
```

No UI state should be required.

Recommended flow:

```text
User edits input
      ↓
Validate
      ↓
Update Scenario
      ↓
Run Calculation Engine
      ↓
Produce immutable Financial Results
      ↓
Update UI
```

Avoid scattered calculations such as:

```dart
setState(() {
  revenue = ...
  profit = ...
});
```

Instead:

```dart
final result = calculator.calculate(updatedScenario);
```

and render the returned result.

---

# 27. Clean Architecture

Recommended structure:

```text
lib/
├── app/
│   ├── app.dart
│   ├── router/
│   └── theme/
│
├── core/
│   ├── error/
│   ├── formatting/
│   ├── validation/
│   ├── responsive/
│   └── utils/
│
├── features/
│   └── financial_model/
│       ├── domain/
│       │   ├── entities/
│       │   ├── value_objects/
│       │   ├── repositories/
│       │   └── services/
│       │
│       ├── application/
│       │   ├── use_cases/
│       │   └── state/
│       │
│       ├── data/
│       │   ├── models/
│       │   ├── datasources/
│       │   └── repositories/
│       │
│       └── presentation/
│           ├── screens/
│           ├── widgets/
│           └── controllers/
│
└── main.dart
```

The financial calculation engine belongs in the **domain** layer.

---

# 28. State Management

A lightweight state-management solution such as Cubit/BLoC is appropriate.

Recommended separation:

```text
ScenarioCubit
    → editable scenario state

FinancialCalculationService
    → deterministic calculations

FinancialResultsState
    → calculated output

Dashboard
    → presentation only
```

Avoid putting calculation rules inside Cubits.

The Cubit orchestrates state changes; the domain calculates business results.

---

# 29. Persistence

The initial version should persist the current scenario locally.

Requirements:

- Save scenario
- Load scenario
- Update individual inputs
- Reset to defaults
- Store calculation/model version
- Optional autosave

Future:

- Multiple scenarios
- Scenario duplication
- Export/import
- Cloud synchronization
- User accounts
- Multi-location businesses

A repository abstraction should exist even if the first implementation uses local storage.

---

# 30. Scenario Support

Do not assume there is only one financial model.

The application should eventually support:

```text
Scenario
├── Name
├── Description
├── Created At
├── Updated At
├── Currency
├── Inputs
└── Model Version
```

Examples:

```text
Floor is Lava — Base
Floor is Lava — Conservative
Floor is Lava — Optimistic
Floor is Lava — Mall A
Floor is Lava — Mall B
```

This makes the application immediately more useful than the original spreadsheet.

---

# 31. Tablet and Responsive Design

Tablet support is a first-class requirement.

The application must work in:

- Small phones
- Large phones
- 7–8 inch tablets
- 10–11 inch tablets
- Large Android tablets
- Portrait
- Landscape

Do not design a phone UI and merely stretch it.

## Phone

Use:

```text
Single-column layout
```

with collapsible sections.

## Tablet portrait

Use:

```text
Two-column adaptive layout
```

where appropriate.

## Tablet landscape

Use:

```text
Navigation rail/sidebar
+
Main content
```

Example:

```text
┌──────────────┬─────────────────────────────────────────────┐
│ Navigation   │ Dashboard                                  │
│              │                                             │
│ Dashboard    │ KPI   KPI   KPI   KPI                       │
│ Assumptions  │                                             │
│ Projection   │ Revenue Chart      Cash Flow Chart           │
│ Startup      │                                             │
│ Sensitivity  │ Monthly projection / insights               │
│ Settings     │                                             │
└──────────────┴─────────────────────────────────────────────┘
```

Use Flutter's responsive constraints and layout primitives rather than hard-coded screen dimensions.

Recommended concepts:

- `LayoutBuilder`
- `MediaQuery`
- adaptive navigation
- constrained content width
- flexible grids
- reusable responsive breakpoints

Avoid excessive breakpoint logic scattered across widgets.

Create a central responsive policy.

---

# 32. Orientation Changes

Changing:

```text
Portrait → Landscape
```

must not:

- lose input
- reset calculations
- recreate the scenario incorrectly
- duplicate state
- break scroll position unnecessarily

Financial state belongs above the presentation layout.

---

# 33. Accessibility

The application should support:

- Adequate contrast
- Large touch targets
- Screen readers
- Semantic labels
- Dynamic text where practical
- Clear error messages
- No meaning communicated by color alone

For financial values, use explicit labels:

```text
Profit: +$2,450
```

rather than only a green color.

---

# 34. Number and Currency Handling

Avoid floating-point mistakes in money calculations where practical.

Prefer a money representation based on fixed precision, such as integer minor units or a dedicated money type.

Example:

```text
$4.00
```

should not become:

```text
3.9999999997
```

Display precision and calculation precision must be separated.

Percentages should be represented consistently.

Example:

```text
0.69 internally
69% in UI
```

---

# 35. Validation Rules

Examples:

### Round duration

```text
> 0
```

### Turnaround

```text
>= 0
```

### Ticket price

```text
>= 0
```

### Average players

```text
> 0
<= Maximum capacity
```

### Maximum capacity

```text
>= 1
```

### Operating hours

```text
> 0
<= 24
```

### Occupancy

```text
0% to 100%
```

### Employees

```text
>= 0
```

### Salary/incentive

```text
>= 0
```

### Contingency

```text
>= 0%
```

and normally:

```text
<= 100%
```

Validation must exist in the domain/application layer, not only in text fields.

---

# 36. Calculation Integrity

The application must protect against impossible states.

Examples:

```text
Average players > maximum capacity
```

must be rejected.

```text
Round duration + turnaround <= 0
```

must be rejected.

```text
Operating hours <= 0
```

must be rejected.

```text
Negative initial investment
```

must never be produced.

If monthly profit is negative:

```text
Payback = Not Recovered
```

If revenue is zero:

```text
Margin = 0%
```

or explicitly:

```text
N/A
```

depending on presentation rules.

---

# 37. Testing Strategy

The calculation engine requires extensive unit tests.

At minimum test:

### Capacity

- Normal values
- Zero duration rejection
- Fractional result flooring
- Very large turnaround
- 24-hour operation

### Revenue

- 0% occupancy
- 100% occupancy
- Decimal average players
- Zero price
- Monthly day count changes

### Expenses

- Zero employees
- Staffing expansion
- Zero salary
- Additional expenses

### Startup costs

- Package 1
- Package 2
- Shipping changes
- Customs changes
- Deposit changes
- Contingency changes

### Cash flow

- Profitable project
- Loss-making project
- Break-even project
- Payback never reached

### Sensitivity

- Positive profit
- Zero profit
- Negative profit

### Regression

Create a fixed baseline scenario and compare calculated results against the source workbook.

The current baseline should become a golden test case.

---

# 38. Example Regression Assertions

The baseline should approximately reproduce:

```text
Equipment selected: Option 2
Equipment cost: $5,270
Shipping: ≈ $632.40
Customs: ≈ $1,317.50
Delivered equipment: ≈ $7,219.90

Fit-out: $2,400
Property: $3,000
Other pre-opening: $2,300

Subtotal: ≈ $14,919.90
Contingency: ≈ $1,491.99
Initial investment: ≈ $16,411.89
```

The UI may display:

```text
$16,412
```

while internal calculations retain cents.

The regression test must compare unrounded domain values.

---

# 39. Calculation Versioning

Because the application may evolve, store:

```text
calculationModelVersion
```

with each saved scenario.

Example:

```text
financial_model_v1
```

Future formula changes can become:

```text
financial_model_v2
```

This prevents old scenarios from silently changing meaning.

---

# 40. Auditability

Every calculated result should be explainable.

A user should be able to tap a metric and see:

```text
Monthly Revenue
= Daily Revenue × Operating Days
= (Actual Rounds × Players × Ticket Price) × Days
= ...
```

This is extremely valuable for a financial-study application.

Do not merely show the final number.

Provide a compact:

> How is this calculated?

panel.

---

# 41. Assumption Status

Inputs should support a status:

```text
Estimated
Verified
Confirmed
User-defined
Imported
```

The current study contains several explicitly uncertain assumptions, especially:

- Rent
- Mall deposit/key money
- Shipping
- Customs
- Occupancy

The UI should make this distinction visible.

Example:

```text
Rent
$3,000 / month
⚠ Estimated — verify with mall management
```

This is preferable to pretending every number is equally reliable.

---

# 42. Importing the Original Study

The first implementation may use the workbook values as seed/default data.

However, the spreadsheet itself must not become the application's runtime dependency.

The application should own:

```text
Scenario → Calculation Engine → Results
```

not:

```text
Flutter → Excel formulas
```

The workbook is the source/reference model, not the application architecture.

---

# 43. Export

Future export should support:

### PDF

Executive report containing:

- Assumptions
- Startup costs
- Revenue projection
- Expense projection
- Cash flow
- Payback
- ROI
- Sensitivity

### CSV

Detailed monthly projection.

### JSON

Full scenario backup.

Example:

```json
{
  "modelVersion": "financial_model_v1",
  "scenarioName": "Floor is Lava - Base",
  "currency": "USD",
  "inputs": {}
}
```

---

# 44. Future Generalization Beyond This Project

The architecture should allow the specific business to become a generic financial planning system.

Future revenue streams:

```text
Tickets
Subscriptions
Food & Beverage
Merchandise
Events
Memberships
Advertising
Services
```

Future expense categories:

```text
Payroll
Rent
Utilities
Marketing
Maintenance
Insurance
Taxes
Supplies
Software
Transportation
Other
```

Future financial features:

- Multiple revenue streams
- Multiple locations
- Variable pricing
- Seasonal demand
- Inflation
- Tax
- VAT
- Depreciation
- Financing/loans
- Interest
- NPV
- IRR
- Break-even analysis
- Scenario comparison
- Monte Carlo analysis
- Budget vs actual
- Actual financial tracking
- Monthly accounting
- Cash runway
- Forecasting

These must be future extensions, not unnecessarily implemented in the first version.

---

# 45. Separation Between Forecast and Actuals

A future-proof design should distinguish:

```text
Forecast
```

from:

```text
Actual
```

Example:

```text
Forecast revenue for Month 4: $11,500
Actual revenue for Month 4: $10,920
Variance: -$580
```

This turns the application from a feasibility calculator into a business-management tool.

---

# 46. Business Rules That Must Not Be Hidden in UI

Never implement these inside widgets:

```text
maximum rounds formula
revenue formula
payroll formula
startup cost formula
contingency formula
payback formula
ROI formula
occupancy progression
staffing expansion
```

These belong to domain/application services and must be testable without Flutter.

---

# 47. Recommended Domain Services

A possible design:

```text
CapacityCalculator
RevenueCalculator
OperatingExpenseCalculator
StartupCostCalculator
CashFlowCalculator
PaybackCalculator
RoiCalculator
SensitivityCalculator
FinancialProjectionCalculator
```

A top-level orchestrator can coordinate them:

```text
FinancialModelCalculator
```

The orchestrator should produce a complete immutable result.

---

# 48. Result Model

Conceptually:

```text
FinancialProjection
├── monthlyResults[]
├── startupCosts
├── annualResults
├── payback
├── roi
└── sensitivityResults[]
```

Each monthly result:

```text
MonthlyFinancialResult
├── monthNumber
├── occupancy
├── maximumRoundsPerDay
├── actualRoundsPerDay
├── dailyRevenue
├── monthlyRevenue
├── employeeCount
├── payroll
├── otherOperatingExpenses
├── totalOperatingExpenses
├── operatingProfit
├── profitMargin
├── netCashFlow
└── cumulativeCashFlow
```

This structure makes charts, tables, exports, and reports easy to implement.

---

# 49. UI Component Reuse

Build reusable components:

```text
FinancialMetricCard
CurrencyInput
PercentageInput
DurationInput
AssumptionField
SectionCard
CalculationExplanation
MonthlyResultCard
FinancialDataTable
ScenarioCard
ExpenseItemEditor
StartupCostItemEditor
ResponsiveGrid
EmptyState
ValidationMessage
```

Avoid duplicating custom financial widgets across screens.

---

# 50. Performance

The model is computationally small.

Do not over-engineer performance.

However:

- Calculations should remain synchronous if trivial
- Avoid unnecessary widget rebuilds
- Keep domain objects immutable
- Recalculate only when relevant inputs change
- Avoid rebuilding the entire application for one text-field keystroke if unnecessary

If the model becomes significantly larger later, the calculation engine can be moved to an isolate.

---

# 51. Security and Data Safety

Even though the first version is local and simple:

- Never store secrets in source code
- Do not include API keys
- Avoid unnecessary permissions
- Protect exported data where appropriate
- Validate imported JSON
- Version persisted data
- Gracefully recover from corrupted local data

---

# 52. Logging and Diagnostics

The application should include controlled diagnostic logging.

Log:

- Application startup
- Scenario load
- Scenario save
- Calculation failures
- Validation failures
- Import/export failures
- Model version
- Major navigation/action events where useful

Do not log sensitive user data unnecessarily.

Development logs should be more verbose than production logs.

---

# 53. Analytics

Do not add third-party analytics merely for the study version.

If analytics are introduced later, make them:

- Opt-in/appropriate
- Privacy-conscious
- Abstracted behind an interface
- Removable without changing business logic

---

# 54. Error Handling

Use typed failures where possible.

Examples:

```text
InvalidScenario
InvalidOccupancy
InvalidCapacity
InvalidMoneyValue
CalculationError
PersistenceError
ImportError
ExportError
```

UI should translate these into user-friendly messages.

Never expose raw exceptions to the user.

---

# 55. Development Phases

## Phase 1 — Foundation

- Flutter project
- Clean Architecture
- Theme
- Routing
- Responsive framework
- Domain primitives
- Scenario model

## Phase 2 — Calculation Engine

Implement and test:

- Capacity
- Revenue
- Expenses
- Startup costs
- Cash flow
- Payback
- ROI
- Sensitivity

## Phase 3 — Input UI

- Assumptions
- Startup costs
- Staffing
- Occupancy
- Validation

## Phase 4 — Results

- Dashboard
- Monthly projection
- Charts
- Calculation explanations

## Phase 5 — Persistence

- Local repository
- Autosave
- Reset
- Scenario metadata

## Phase 6 — Tablet

- Portrait
- Landscape
- Adaptive navigation
- Data table
- Large-screen optimization

## Phase 7 — Quality

- Unit tests
- Widget tests
- Golden tests where useful
- Regression against workbook
- Accessibility review
- Error-state testing

## Phase 8 — Future Extensions

Only after the first stable version:

- Multiple scenarios
- Export
- Actual-vs-forecast
- Additional financial metrics
- Multiple businesses/locations

---

# 56. Definition of Done

The application is ready for the first stable release when:

- All workbook formulas are represented in the calculation engine.
- No business calculation lives in a widget.
- Every major assumption is editable.
- Changing an input recalculates every dependent value.
- The baseline scenario matches the workbook within defined rounding tolerance.
- Invalid inputs are rejected.
- Payback handles non-recovery correctly.
- Zero revenue does not cause division errors.
- Phone portrait works.
- Phone landscape works.
- Tablet portrait works.
- Tablet landscape works.
- No state is lost during orientation changes.
- Financial values are displayed consistently.
- Startup costs reconcile.
- Monthly projections reconcile.
- Cumulative cash flow reconciles.
- Yearly totals reconcile.
- ROI reconciles with the original study definition.
- Sensitivity scenarios work.
- Local persistence works.
- Calculation model is versioned.
- Core calculation tests pass.
- UI is accessible and visually consistent.
- Code follows Clean Architecture and Clean Code principles.

---

# 57. Important Modeling Decisions

The following rules are intentional:

1. **The spreadsheet is a reference, not the application.**
2. **The calculation engine is the single source of truth.**
3. **Inputs are editable; results are derived.**
4. **The current values are defaults, not constants.**
5. **Business logic must remain independent of Flutter UI.**
6. **The application must support future scenarios.**
7. **Tablet support is designed from the beginning.**
8. **Money precision is preserved internally.**
9. **Financial assumptions have an explicit verification status.**
10. **The original financial definitions must not be silently changed.**
11. **Future generalization must be possible without rewriting the domain layer.**
12. **No unnecessary complexity should be introduced in the study version.**

---

# 58. Initial Baseline Summary

The current study indicates approximately:

```text
Initial Investment:     $16,412
Ticket Price:           $4/person/round
Base Occupancy:         69% from Month 4
Year-1 Profit:          $71,100
Year-1 ROI:             433.2%
Payback:                approximately Month 5
```

These are baseline reference outputs from the original workbook and must be verified by the application's regression tests rather than hard-coded into the UI.

---

# 59. Final Implementation Principle

The application should be small in scope but strong in architecture.

The correct target is:

```text
Simple UI
   +
Strong Domain Model
   +
Deterministic Calculation Engine
   +
Editable Scenario
   +
Responsive Layout
   +
Reliable Persistence
   +
Tests
```

Not:

```text
Excel recreated as Flutter widgets.
```

The first release should solve the current financial study elegantly while establishing a foundation that can later become a broader business planning and financial forecasting application.

---

# Appendix A — Formula Reference

## Capacity

```text
Total Round Time
= Round Duration + Turnaround Time
```

```text
Maximum Rounds/Day
= floor((Operating Hours × 60) / Total Round Time)
```

```text
Actual Rounds/Day
= Maximum Rounds/Day × Occupancy
```

## Revenue

```text
Daily Revenue
= Actual Rounds/Day × Average Players/Round × Ticket Price
```

```text
Monthly Revenue
= Daily Revenue × Operating Days/Month
```

```text
Cumulative Revenue(n)
= Cumulative Revenue(n-1) + Monthly Revenue(n)
```

## Staffing

```text
Employee Cost
= Salary + Incentive
```

```text
Payroll
= Employee Count × Employee Cost
```

## Operating expenses

```text
Total Operating Expenses
= Payroll
+ Rent
+ Mall Services
+ Electricity
+ Maintenance
+ Continuous Marketing
+ Future Custom Expenses
```

## Profit

```text
Operating Profit
= Monthly Revenue - Total Operating Expenses
```

```text
Profit Margin
= Operating Profit / Monthly Revenue
```

## Startup

```text
Equipment
= Selected Equipment Package
```

```text
Shipping
= Equipment × Shipping Rate
```

```text
Customs
= Equipment × Customs Rate
```

```text
Delivered Equipment
= Equipment + Shipping + Customs
```

```text
Fit-out
= Furniture + Painting + Signage + HVAC + Labor + Future Fit-out Items
```

```text
Property
= Deposit + First Month Rent
```

```text
Other Pre-opening
= Licensing + Opening Marketing + Future Pre-opening Items
```

```text
Subtotal
= Delivered Equipment + Fit-out + Property + Other Pre-opening
```

```text
Contingency
= Subtotal × Contingency Rate
```

```text
Initial Investment
= Subtotal + Contingency
```

## Cash flow

```text
Month 0 Net Cash Flow
= -Initial Investment
```

```text
Month n Net Cash Flow
= Operating Profit(n)
```

```text
Cumulative Cash Flow(n)
= Cumulative Cash Flow(n-1) + Net Cash Flow(n)
```

## Annual

```text
Year 1 Profit
= SUM(Month 1 ... Month 12 Profit)
```

```text
Year 2 Profit
= SUM(Month 13 ... Month 24 Profit)
```

## ROI

```text
Year-1 ROI
= Year-1 Profit / Initial Investment
```

## Sensitivity

```text
Scenario Monthly Revenue
= Maximum Rounds/Day
× Scenario Occupancy
× Average Players/Round
× Ticket Price
× Operating Days/Month
```

```text
Scenario Monthly Profit
= Scenario Monthly Revenue - Scenario Monthly Operating Expenses
```

```text
Approximate Payback
= Initial Investment / Scenario Monthly Profit
```

Only calculate payback when scenario monthly profit is positive.

---

# Appendix B — Recommended First Questions Before Coding

The specification is implementation-ready, but the following decisions would improve the first release:

1. **Currency:** Should the application support USD only initially, or USD + Syrian Lira from day one?
2. **Scope:** Should the first version be a single-business calculator, or should the UI already expose "projects/scenarios" as first-class objects?
3. **Persistence:** Is local-only storage sufficient for V1, or is export/import required from the beginning?
4. **Visual direction:** Should the UI remain strictly professional/minimal, or should it retain a subtle "Floor is Lava" visual identity?
5. **Charts:** Should V1 include charts, or should the first milestone focus on inputs + calculations + monthly tables?
6. **Actual tracking:** Should V1 remain forecast-only, leaving actual revenue/expenses for a later phase?

Recommended default for a fast first implementation:

```text
USD
+
Local persistence
+
Scenario-based architecture
+
Professional minimal UI
+
Dashboard + charts
+
24-month projection
+
No actual accounting yet
```
