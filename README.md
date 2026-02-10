# Financial Health Dashboard – EDW Queries

SQL queries used to extract regulatory and prudential data from the **VISION** Oracle Enterprise Data Warehouse (EDW) for the Financial Health Dashboard.

---

## Repository Structure

```
EDW queries/
├── ALL_EDWH_TABLES.sql              # Schema discovery utility
├── test.sql                         # Scratch/test file
├── Capital Adequacy/
│   └── capital_ar_query.sql         # Capital Adequacy Ratio (CAR) data
├── Credit_MArtket_Exposure/
│   ├── Insider Loans.sql            # Loans to related parties
│   └── Single borrower.sql          # Single borrower credit exposure
├── Liquidity/                        # (reserved – queries pending)
└── Other Predential Norms/
    ├── Borrowings.sql               # Total borrowings by entity
    ├── Investment_in_fixed_assets.sql
    ├── Investment in equity shares.sql
    ├── Landandbuildings.sql
    ├── Non_earning assets.sql
    └── Placements limits.sql
```

---

## Data Source

All queries run against the **VISION** schema on an Oracle database. The core tables used are:

| Table | Description |
|---|---|
| `VISION.FIN_HISTORY_HEADERS` | Financial history record headers (year, LE_Book, FRL line) |
| `VISION.FIN_HISTORY_BALANCES` | Monthly balance columns (Balance_01 … Balance_12) per header |
| `VISION.FRL_EXPANDED` | Financial Reporting Line (FRL) code expansion/mapping |
| `VISION.LE_BOOK` | Legal entity master – category type, description, country |
| `VISION.CAPITAL_AR` | Capital adequacy ratio line-item values |
| `VISION.ALPHA_SUB_TAB` | Alpha lookup table for code descriptions |
| `VISION.CONTRACT_LOANS` | Loan-level data (principal, interest, performance class) |
| `VISION.CONTRACTS_EXPANDED` | Expanded contract master |
| `VISION.CUSTOMERS_EXPANDED` | Customer master (related-party flag, gender) |

**LE_Book range 400–999** represents regulated financial institutions (MFIs, SACCOs, etc.).

**Institution category types** filtered in most queries: `MF`, `SACCO`, `OSACCO`, `DSACCO`.

---

## Queries

### Utility

#### `ALL_EDWH_TABLES.sql`
Lists all tables owned by the VISION schema, useful for schema discovery.

```sql
SELECT table_name, owner
FROM all_tables
WHERE owner = 'VISION'
ORDER BY table_name;
```

---

### Capital Adequacy

#### `Capital Adequacy/capital_ar_query.sql`
Retrieves Capital Adequacy Ratio (CAR) line-item values per legal entity and month, joined to human-readable descriptions from the alpha lookup table.

**Key columns returned:**
- `LE_BOOK` – Legal entity identifier
- `YEAR_MONTH` – Reporting period (YYYYMM)
- `CAR_LINE_CODE_DESC` – Description of the CAR line (from `ALPHA_SUB_TAB`, tab 5005)
- `VALUE_LCY` – Aggregated value in local currency

**Source tables:** `VISION.CAPITAL_AR`, `VISION.ALPHA_SUB_TAB`

---

### Credit & Market Exposure

#### `Credit_MArtket_Exposure/Insider Loans.sql`
Tracks loans extended to **related parties** (staff, directors, management, principals) over the last 12 rolling months.

**Filters:**
- `cu.related_party IN ('STAFF', 'DIR', 'MGT', 'PRN', 'OTH1', 'OTH2', 'OTH3')`
- `LE_BOOK` between 400 and 999
- Last 12 months from current month (`ADD_MONTHS(TRUNC(SYSDATE,'MM'), -12)`)

**Key columns returned:**
- `LE_BOOK`, `YEAR_MONTH` – Entity and period
- `CONTRACT_ID` – Loan contract reference
- `RELATED_PARTY` – Party type (STAFF, DIR, MGT, etc.)
- `CUSTOMER_GENDER` – Gender of the borrower
- `PERFORMANCE_CLASS` – Loan performance class
- `DISBURSED_AMOUNT` – Formatted total disbursed amount
- `INSIDER_LOANS_LCY` – Principal outstanding + interest due in local currency

**Source tables:** `VISION.CONTRACTS_EXPANDED`, `VISION.CONTRACT_LOANS`, `VISION.CUSTOMERS_EXPANDED`

---

#### `Credit_MArtket_Exposure/Single borrower.sql`
Computes **total credit exposure per borrower** over the last 24 rolling months, classifying each borrower as NPL or PL.

**Performance classification logic:**
- `NPL` – performance class in (`SL`, `DL`, `LL`)
- `PL` – performance class in (`NL`, `WL`)
- Excludes written-off loans (`performance_class <> 'WO'`)

**Key columns returned:**
- `LE_BOOK`, `YEAR_MONTH` – Entity and period
- `CUSTOMER_ID`, `CUSTOMER_NAME` – Borrower identity
- `BORROWER_PRINCIPAL_EXPOSURE` – Sum of principal outstanding (LCY)
- `BORROWER_EXPOSURE_INCL_INTEREST` – Principal + interest exposure
- `BORROWER_PERFORMANCE_STATUS` – NPL / PL / OTHER

**Source tables:** `VISION.CONTRACT_LOANS`, `VISION.CONTRACTS_EXPANDED`, `VISION.CUSTOMERS_EXPANDED`

---

### Other Prudential Norms

All queries in this folder share the same pattern:
1. Join `FIN_HISTORY_HEADERS` → `FIN_HISTORY_BALANCES` → `FRL_EXPANDED` for the relevant FRL lines.
2. Filter to **year 2025**, `Bal_Type = 1`, and institution categories `MF / SACCO / OSACCO / DSACCO`.
3. `UNPIVOT` the 12 monthly balance columns (`Balance_01`–`Balance_12`) into a single `(Month_Number, Balance_Value)` pair.
4. `GROUP BY` year, LE_Book, category type, stakeholder name, and month.

---

#### `Other Predential Norms/Investment_in_fixed_assets.sql`
Aggregates investment in **fixed assets** (excluding land & buildings).

**FRL lines covered:** F1700025, F1700026, F1700030, F1700031, F1700040, F1700041, F1700056, F1700060, F1700065, F1700071, F1700080, F1700081, F1700105, F1700160, F1700410, F1700610, F1700690 *(and others)*

**Output column:** `Investment_in_fixed_assets`

---

#### `Other Predential Norms/Landandbuildings.sql`
Aggregates the book value of **land and buildings** held by each institution.

**FRL lines covered:** F1700010, F1700015, F1700016, F1700035, F1700036, F1700050, F1700051, F1700320

**Output column:** `Landandbuildings` *(implied by query context)*

---

#### `Other Predential Norms/Non_earning assets.sql`
Measures **non-earning assets** — assets that do not generate income (e.g. foreclosed property, suspended interest).

**FRL lines covered:** 47 codes including F1120317, F1120319, F1120365, F1200230, F1200250, F1500010–F1501040, F1200511, F1200315, F1200510, F1210010, F1210015, F1200520, F1210440

**Output column:** `Non_earning assets`

---

#### `Other Predential Norms/Borrowings.sql`
Tracks **total borrowings** (external funding) by institution and month.

**FRL lines covered:** F2110260, F2120010, F2120070, F2120080, F2120155, F2120175, F2120350, F2120355, F2120420, F2150315

**Output column:** `Borrowings` *(implied)*

---

#### `Other Predential Norms/Placements limits.sql`
Monitors **interbank/placement balances** against regulatory limits.

**FRL lines covered:** F1120317, F1120319

**Output column:** `Placements` *(implied)*

---

#### `Other Predential Norms/Investment in equity shares.sql`
Tracks **investments in equity shares** held by regulated entities.

**FRL lines covered:** F1210010, F1210015

**Output column:** `Investment_in_equity_shares` *(implied)*

---

## Common Query Pattern (Prudential Norms)

```sql
-- Outer query: aggregate unpivoted monthly balances
SELECT Year, LE_Book, CATEGORY_TYPE, Stakeholder_Name,
       Month_Number, SUM(Balance_Value) AS <metric>
FROM (
    -- Inner query: join headers + balances + FRL, filter by year/category/FRL lines
    SELECT headers.Year, headers.LE_Book,
           (SELECT CATEGORY_TYPE FROM VISION.Le_Book WHERE ...) AS CATEGORY_TYPE,
           (SELECT Leb_Description FROM VISION.Le_Book WHERE ...) AS Stakeholder_Name,
           balances.Balance_01, ..., balances.Balance_12
    FROM VISION.FIN_HISTORY_HEADERS headers
    JOIN VISION.FIN_HISTORY_BALANCES balances ON ...
    JOIN VISION.FRL_EXPANDED frl ON ...
    WHERE headers.Year = '2025'
      AND balances.Bal_Type = 1
      AND CATEGORY_TYPE IN ('MF','SACCO','OSACCO','DSACCO')
      AND frl.FRL_Line IN (...)
)
UNPIVOT (Balance_Value FOR Month_Number IN (Balance_01 AS 1, ..., Balance_12 AS 12))
GROUP BY Year, LE_Book, CATEGORY_TYPE, Stakeholder_Name, Month_Number
ORDER BY Year, LE_Book, Month_Number;
```

---

## Notes

- All monetary values are in **Local Currency (LCY)**.
- Queries are designed to feed an R-based dashboard (see `capital_ar_pivot.Rmd` in `Credit_MArtket_Exposure/`).
- The `Liquidity/` folder is reserved for liquidity-ratio queries not yet implemented.
- `test.sql` duplicates `ALL_EDWH_TABLES.sql` and can be ignored.
