# Financial Health Dashboard – EDW Queries

SQL queries and R scripts used to extract regulatory and prudential data from the **VISION** Oracle Enterprise Data Warehouse (EDW) for the **Microfinance Supervision Department (MFSD)** Financial Health Dashboard.

> **Regulatory reference:** Regulation No 60/2023 of 27/03/2023 determining prudential norms for deposit-taking microfinance institutions.

---

## Background

This repository supports the automation of MFSD frequently used output reports and dashboards sourced from EDWH data. The initiative transitions manual computation of key soundness indicators into automated, reproducible queries that feed a Power BI / R-based dashboard for monitoring Deposit-Taking Microfinance Institutions (DTMFIs).

### Objectives

- Monitor and visualize financial soundness metrics reported by DTMFIs through EDWH
- Boost compliance with prudential norms monitoring
- Increase EDWH data reliability
- Improve efficiency in data extraction and reporting

---

## Repository Structure

```
EDW queries/
├── ALL_EDWH_TABLES.sql                          # Schema discovery utility
├── README.md
├── Capital Adequacy/
│   ├── capital_ar_query.sql                     # CAR line-item breakdown (companies)
│   └── Sacco Capital(equity to assets.sql       # CAR equity-to-assets ratio (SACCOs)
├── Credit_MArtket_Exposure/
│   ├── capital_ar_pivot.Rmd                     # R notebook: CAR data pivot & analysis
│   ├── Insider Loans.sql                        # Loans to related parties / insiders
│   └── Single borrower.sql                      # Single borrower credit exposure
├── Liquidity/
│   ├── Loan overdraft and customers.sql         # Loan & overdraft balances by FRL attribute
│   └── top depositors for companies and saccos.sql  # Top depositors by customer
└── Other Predential Norms/
    ├── Borrowings.sql                           # Total borrowings by entity
    ├── Investment_in_fixed_assets.sql           # Fixed assets (excl. land & buildings)
    ├── Investment in equity shares.sql          # Equity share investments
    ├── Landandbuildings.sql                     # Land and buildings book value
    ├── Non_earning assets.sql                   # Non-earning / non-income assets
    └── Placements limits.sql                    # Interbank/placement balances
```

---

## Dashboard Coverage

The queries in this repository map to the following prudential norms and reporting categories, as defined in the MFSD requirements specification.

### Batch 1 – Prudential Norms

| # | Indicator | Applies To | Threshold | Regulation | Data Source | Query Status |
|---|-----------|-----------|-----------|------------|-------------|:---:|
| PNR01 | Liquidity Ratio | MF, DSACCO, USACCO, OSACCO | Min 20% (Companies), Min 30% (SACCOs) | Article 3 | Liquidity data | Implemented |
| PNR02 | Core (Tier 1) Capital Ratio | MF | Min 10% | Article 6 | CAR data | Implemented |
| PNR03 | Total Capital Adequacy Ratio | MF | Min 12.5% | Article 6 | CAR data | Implemented |
| PNR04 | CAR (Equity to Assets) | MF, DSACCO, USACCO, OSACCO | Min 15% (SACCOs) | Article 6 | FINMTH View | Implemented |
| PNR05 | NPL Ratio | MF, DSACCO, USACCO, OSACCO | Max 5%, warning >10% | Article 21 | CONTLOAN | Partial |
| PNR06 | Written-off Loans Ratio | MF, DSACCO, USACCO, OSACCO | Max 5%, warning >20% | Article 21 | CONTLOAN | Partial |
| PNR07 | Single Borrower to Capital | MF, DSACCO, USACCO, OSACCO | Max 5% of core capital | Article 12 | CONTLOAN, CAR | Implemented |
| PNR08 | Single Borrower to Deposits | MF, DSACCO, USACCO, OSACCO | Max 2.5% of total deposits | Article 12 | CONTLOAN, FINMTH | Planned |
| PNR09 | Related Party Loans Ratio | MF, DSACCO, USACCO, OSACCO | Max 5% of core capital | Article 13 | CONTLOAN, CUST, CAR | Implemented |
| PNR10 | Insider Loans Ratio | MF, DSACCO, USACCO, OSACCO | Max 2% of core capital | Article 13 | CONTLOAN, CUST, CAR | Implemented |
| PNR11 | Aggregated Related Party Loans | MF | Max 20% of core capital | Article 13 | CONTLOAN, CAR | Planned |
| PNR12 | Loans to Total Resources | MF, DSACCO, USACCO, OSACCO | Max 80% | Article 14 | FINMTH View | Planned |
| PNR13 | Investment in Fixed Assets | MF, DSACCO, USACCO, OSACCO | Max 50% of core capital | Article 16 | FINMTH View | Implemented |
| PNR14 | Land & Buildings to Total Assets | MF, DSACCO, USACCO, OSACCO | Max 5% of total assets | Article 16 | FINMTH View | Implemented |
| PNR15 | Non-Earning Assets | MF, DSACCO, USACCO, OSACCO | Max 10% of total assets | Article 16 | FINMTH View | Implemented |

#### Capital Adequacy Warning Signals

| Level | Tier 1 | Total CAR | CAR (SACCOs) | Regulation |
|-------|--------|-----------|--------------|------------|
| Adequately capitalized | >= 10% | >= 12.5% | >= 15% | Article 7 |
| Undercapitalized | >= 8% and < 10% | >= 10% and < 12.5% | >= 12% and < 15% | Article 8 |
| Significantly undercapitalized | >= 6% and < 8% | >= 8% and < 10% | >= 10% and < 12% | Article 9 |
| Critically undercapitalized | < 6% | < 8% | < 10% | Article 10 |

### Batch 2 – Credit Risk Monitoring

| Report | Data Source | Status |
|--------|-------------|:---:|
| Trend of gross loans by performance class | ContLoan | Planned |
| NPL ratio trend (excl. OBS commitments) | ContLoan + ContInfo | Planned |
| NPL coverage ratio (total provisions) | ContLoan | Planned |
| NPL coverage ratio (specific provisions) | ContLoan | Planned |
| Watch category to Gross Loans | ContLoan | Planned |
| Restructured Loans to Gross Loans | ContLoan + LoanApp | Planned |
| Written-off loans to Gross Loans | ContLoan | Planned |
| Single person & connected parties (SOL) | ContLoan | Implemented |
| Big borrowers concentration | ContLoan | Planned |
| Related party concentration | ContLoan + Cust | Implemented |
| Sectoral concentration | ContLoan + LoanApp | Planned |
| Lending by institutional sector | ContLoan + Acc | Planned |
| Geographic lending (by district) | ContLoan + Cust | Planned |
| Loan by Economic Activity (ISIC) | ContLoan + Acc | Planned |
| Customer segment & gender concentration | ContLoan | Planned |
| New loans by sector and gender | ACC + CUST + LOANAPP + CONTDISB | Planned |
| Insider lending report | EDWH Report Suite | Implemented |
| Sector-wise borrowers | ContLoan | Planned |
| Loan classification & provisioning monitoring | ContLoan | Planned |

### Batch 3 – Other Frequently Used Data

| Report | Data Source | Status |
|--------|-------------|:---:|
| Total Assets trend | FINMTH View | Planned |
| Asset Mix (% of each component) | FINMTH View | Planned |
| DTMFIs by size (Assets, Loans, Deposits, Equity, Net Profit) | FINMTH View | Planned |
| Market share (% of total assets, loans, deposits, equity) | FINMTH View | Planned |
| Earnings: ROA, ROE, Cost-to-Income, Staff Cost-to-Income | FINMTH View | Planned |
| Income from loans to total incomes | FINMTH View | Planned |
| FX Exposure to Core Capital (NOP report) | FINMTH + CAR | Planned |
| FX Loans to FX Deposits | FINMTH View | Planned |
| Geographical location of Branches | BRANCHINFO | Planned |
| Gender in Management of DTMFIs | BRANCHINFO, MGTINFO2, STAFFINFO | Planned |

### Batch 4 – Summarized Financial Statements

| Report | Details | Status |
|--------|---------|:---:|
| Balance Sheet | Consolidated by sector, subsector, institution | Planned |
| Income Statement | Trend analysis, common-size for consecutive periods | Planned |

### Deposits & Loans Reports

| Report | Data Source | Status |
|--------|-------------|:---:|
| Top 20 depositors / total customer deposits | Related FRLs | Implemented |
| Deposits to total assets | FINMTH View | Planned |
| Loans to Customer deposits ratio | FINMTH View | Planned |
| Deposits (Number & Amount) by account type, gender, segment, age | FINMTH, CUST, ACCT | Planned |
| Borrowers (Number & Amount) by account type, gender, segment | FINMTH, CUST, ACCT | Planned |
| Dormancy in demand deposits | FINMTH, CUST, ACCT | Planned |

---

## Query Details

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
Retrieves Capital Adequacy Ratio (CAR) line-item values per legal entity and month, joined to human-readable descriptions from the alpha lookup table. Used for **PNR02** (Tier 1) and **PNR03** (Total CAR) for microfinance companies.

**Key columns:** `LE_BOOK`, `YEAR_MONTH`, `CAR_LINE_CODE_DESC`, `VALUE_LCY`
**Source tables:** `VISION.CAPITAL_AR`, `VISION.ALPHA_SUB_TAB`

#### `Capital Adequacy/Sacco Capital(equity to assets.sql`
Computes equity-to-assets ratio components for SACCOs (LE_Book 500–999). Aggregates GL types 10, 20, 30 from `FINANCIAL_MONTHLY` to derive total equity relative to total assets. Supports **PNR04**.

**Key columns:** `LE_Book`, `GL_Type`, `Year_Month`, `Amount_Lcy`
**Source tables:** `VISION.FINANCIAL_MONTHLY`, `VISION.GL_Codes`

---

### Credit & Market Exposure

#### `Credit_MArtket_Exposure/Insider Loans.sql`
Tracks loans extended to **related parties** (staff, directors, management, principals) over the last 12 rolling months. Supports **PNR09** and **PNR10**.

**Filters:** Related party types (`STAFF`, `DIR`, `MGT`, `PRN`, `OTH1–OTH3`), LE_BOOK 400–999
**Key columns:** `LE_BOOK`, `YEAR_MONTH`, `CONTRACT_ID`, `RELATED_PARTY`, `CUSTOMER_GENDER`, `PERFORMANCE_CLASS`, `DISBURSED_AMOUNT`, `INSIDER_LOANS_LCY`
**Source tables:** `VISION.CONTRACTS_EXPANDED`, `VISION.CONTRACT_LOANS`, `VISION.CUSTOMERS_EXPANDED`

#### `Credit_MArtket_Exposure/Single borrower.sql`
Computes **total credit exposure per borrower** over the last 24 rolling months, classifying each as NPL or PL. Supports **PNR07**.

**Performance classification:** NPL = (`SL`, `DL`, `LL`), PL = (`NL`, `WL`), excludes written-off (`WO`)
**Key columns:** `LE_BOOK`, `YEAR_MONTH`, `CUSTOMER_ID`, `CUSTOMER_NAME`, `BORROWER_PRINCIPAL_EXPOSURE`, `BORROWER_EXPOSURE_INCL_INTEREST`, `BORROWER_PERFORMANCE_STATUS`
**Source tables:** `VISION.CONTRACT_LOANS`, `VISION.CONTRACTS_EXPANDED`, `VISION.CUSTOMERS_EXPANDED`

#### `Credit_MArtket_Exposure/capital_ar_pivot.Rmd`
R Markdown notebook that connects to EDWH via ODBC, runs the CAR query, and pivots the data so each `CAR_LINE_CODE_DESC` becomes a column. Useful for wide-format analysis and export.

**R packages required:** `DBI`, `odbc`, `dplyr`, `tidyr`

---

### Liquidity

#### `Liquidity/top depositors for companies and saccos.sql`
Aggregates deposit amounts by customer for institutions (LE_Book 400–999) from January 2023 onward. Filters to deposit account types (`CAA`, `SBA`, `TDA`, `SED`, `TRUSTAC`). Supports **top depositor concentration** analysis and **PNR01** liquidity monitoring.

**Key columns:** `Country`, `LE_Book`, `Year_Month`, `Customer_Id`, `Amount_Lcy`
**Source tables:** `VISION.FINANCIAL_MONTHLY`, `VISION.Accounts_View`

#### `Liquidity/Loan overdraft and customers.sql`
Extracts monthly loan and overdraft balances by FRL attribute code from financial history. Covers FRL attributes `FA071050`, `FA071055`, `FA071060`, `FA071065`, `FA072025` for years 2023 onward, LE_Book 400–999.

**Key columns:** `le_book`, `year`, `frl_attribute_07`, `balance_01`–`balance_12`
**Source tables:** `VISION.FIN_HISTORY_BALANCES`, `VISION.FIN_HISTORY_HEADERS`, `VISION.FRL_EXPANDED`

---

### Other Prudential Norms

All queries in this folder share the same pattern:
1. Join `FIN_HISTORY_HEADERS` -> `FIN_HISTORY_BALANCES` -> `FRL_EXPANDED` for the relevant FRL lines
2. Filter to **year 2025**, `Bal_Type = 1`, and institution categories `MF / SACCO / OSACCO / DSACCO`
3. `UNPIVOT` the 12 monthly balance columns (`Balance_01`–`Balance_12`) into a single `(Month_Number, Balance_Value)` pair
4. `GROUP BY` year, LE_Book, category type, stakeholder name, and month

#### `Other Predential Norms/Investment_in_fixed_assets.sql`
Aggregates investment in **fixed assets** (excluding land & buildings). Supports **PNR13**.
**FRL lines:** F1700025, F1700026, F1700030, F1700031, F1700040, F1700041, F1700056, F1700060, F1700065, F1700071, F1700080, F1700081, F1700105, F1700160, F1700410, F1700610, F1700690 *(and others)*

#### `Other Predential Norms/Landandbuildings.sql`
Aggregates book value of **land and buildings**. Supports **PNR14**.
**FRL lines:** F1700010, F1700015, F1700016, F1700035, F1700036, F1700050, F1700051, F1700320

#### `Other Predential Norms/Non_earning assets.sql`
Measures **non-earning assets** (foreclosed property, suspended interest, etc.). Supports **PNR15**.
**FRL lines:** 47 codes including F1120317, F1120319, F1120365, F1200230, F1200250, F1500010–F1501040, and others.

#### `Other Predential Norms/Borrowings.sql`
Tracks **total borrowings** (external funding) by institution and month.
**FRL lines:** F2110260, F2120010, F2120070, F2120080, F2120155, F2120175, F2120350, F2120355, F2120420, F2150315

#### `Other Predential Norms/Placements limits.sql`
Monitors **interbank/placement balances** against regulatory limits.
**FRL lines:** F1120317, F1120319

#### `Other Predential Norms/Investment in equity shares.sql`
Tracks **investments in equity shares** held by regulated entities.
**FRL lines:** F1210010, F1210015

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

## Data Source

All queries run against the **VISION** schema on an Oracle database. The core tables used are:

| Table | Description |
|---|---|
| `VISION.FIN_HISTORY_HEADERS` | Financial history record headers (year, LE_Book, FRL line) |
| `VISION.FIN_HISTORY_BALANCES` | Monthly balance columns (Balance_01 – Balance_12) per header |
| `VISION.FINANCIAL_MONTHLY` | Monthly financial data by account (Amount_Lcy) |
| `VISION.FRL_EXPANDED` | Financial Reporting Line (FRL) code expansion/mapping |
| `VISION.GL_Codes` | General Ledger code mapping (GL_Type) |
| `VISION.LE_BOOK` | Legal entity master – category type, description, country |
| `VISION.CAPITAL_AR` | Capital adequacy ratio line-item values |
| `VISION.ALPHA_SUB_TAB` | Alpha lookup table for code descriptions |
| `VISION.CONTRACT_LOANS` | Loan-level data (principal, interest, performance class) |
| `VISION.CONTRACTS_EXPANDED` | Expanded contract master |
| `VISION.CUSTOMERS_EXPANDED` | Customer master (related-party flag, gender) |
| `VISION.Accounts_View` | Account details (Account_Type, Account_No) |

**LE_Book ranges:**
- **400–999**: All regulated financial institutions (MFIs, SACCOs)
- **500–999**: SACCOs specifically

**Institution category types:** `MF`, `SACCO`, `OSACCO`, `DSACCO`

---

## Notes

- All monetary values are in **Local Currency (LCY)**
- Queries are designed to feed a Power BI dashboard and/or R-based analysis (see `capital_ar_pivot.Rmd`)
- "Implemented" status means the SQL query exists in this repo; further integration with Power BI may still be needed
- "Planned" items are documented in the requirements but queries have not yet been written
- The expected output should be filterable by microfinance sector, sub-sectors, and institution-wise, with trend tables and graphs showing actual vs threshold values
