# Floor is Lava — Financial Feasibility

An interactive version of the *Floor is Lava* feasibility study: an editable
financial model rather than a spreadsheet redrawn as widgets.

Every figure on screen is derived from assumptions the user can change. Change
the ticket price, the occupancy, the rent or the equipment package and the whole
model — capacity, revenue, expenses, cash flow, payback, ROI and the sensitivity
cases — recalculates from that one input.

## Running it

```bash
flutter pub get
flutter run
flutter test
```

## Architecture

```text
lib/
├── app/                     application frame: theme, shell, composition
├── core/                    shared kernel: errors, formatting, responsive rules, logging
└── features/
    ├── financial_model/
    │   ├── domain/          value objects, entities, calculators, validation  (no Flutter)
    │   ├── application/     use cases and the scenario cubit
    │   ├── data/            JSON mapping, local storage, repository
    │   └── presentation/    screens, widgets, wording for domain identifiers
    └── settings/            display preferences
```

The rules that matter:

- **The calculation engine is the single source of truth.** It lives in
  `features/financial_model/domain/services` and imports nothing from Flutter,
  so it can be — and is — tested on its own.
- **Inputs are stored; results are derived.** A `FinancialScenario` holds only
  assumptions. `FinancialModelCalculator.calculate` turns one into a complete,
  immutable `FinancialProjection`. Nothing derived is ever persisted.
- **No formula lives in a widget.** Screens read the projection; they never
  compute.
- **Money is fixed-precision.** `Money` stores whole micros, so totals do not
  drift and `$4.00` never becomes `3.9999999997`. Rounding happens once, in
  `ValueFormatter`, at display time.
- **One responsive policy.** `ResponsiveLayout` decides navigation style,
  column counts, content width and whether a screen has room for a data table.
  Widgets ask it questions instead of testing `MediaQuery` themselves.
- **Scenario state lives above the layout**, so rotating the device changes the
  layout and nothing else.

## The model

The engine reproduces the source workbook exactly. `test/domain/baseline_regression_test.dart`
is the golden test, asserting on unrounded domain values:

| Figure | Value |
|---|---:|
| Maximum rounds/day | 39 |
| Delivered equipment | $7,219.90 |
| Initial investment | $16,411.89 |
| Stable monthly revenue | $11,878.28928 |
| Year-1 profit | $71,100.08576 |
| Year-1 ROI | 433.22% |
| Payback | month 5 (4.95 interpolated) |

Definitions from the study are preserved as-is, including its ROI definition
(year-1 profit ÷ initial investment) and its treatment of operating profit as
the monthly operating cash flow.

### Points the study leaves open

These were found while implementing the model. None of them changes a number;
each is surfaced in the app or documented in code.

1. **The optimistic sensitivity case (60%) is below the study's own stable
   occupancy (69%).** The values are kept; the app raises a warning about the
   ordering.
2. **The sensitivity cases do not state which cost base they use.** They are
   costed at steady state — final headcount plus the flat monthly base — which
   is what reproduces the study's figures. The screen says so explicitly.
3. **The first month's rent is counted twice** — once inside the start-up
   property cost and again as a month-1 operating expense. This is what the
   workbook does, so it is preserved, and the rent field explains it.
4. **Operating days per week, maximum players per round, contract duration and
   the 24-day setup figure do not enter any formula.** They are kept as
   editable planning inputs (maximum players also bounds the average) and
   labelled as such.
5. **The workbook's staffing phases and weekly hours have no stated
   definition**, so they are shown as reference only and never reach the
   engine.

## Tests

```bash
flutter test
```

Covers the engine (capacity, revenue, expenses, start-up costs, cash flow,
payback, ROI, sensitivity, staffing), value-object precision, validation,
field round-tripping, JSON persistence, the scenario cubit, the responsive
policy, and the app itself across phone and tablet shapes in both orientations.
