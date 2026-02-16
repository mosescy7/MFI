-- ============================================================================
-- SINGLE BORROWER / TOP 20 BORROWER CONCENTRATION
-- ============================================================================
-- Purpose:   Returns the top 20 borrowers per LE_Book per month, ranked by
--            total exposure (principal + interest). Used to assess:
--              - Single borrower to capital  = (rnk=1 exposure / Total Capital) * 100
--              - Single borrower to deposits = (rnk=1 exposure / Total Deposits) * 100
--            Applies to: MF, DSACCO, USACCO, OSACCO entities (LE_Book 400-999)
--
-- Output:    Top 20 rows per LE_Book / Year_Month, each with:
--              - customer_id, customer_name
--              - borrower_exposure   : SUM(principal + interest)
--              - performance_status  : NPL or PL
--              - rnk                 : 1 = largest borrower, 2 = second, etc.
--
-- Ratios:    Computed in Power BI by joining with:
--              - Capital data   (capital_ar_query)  for "single borrower to capital"
--              - Deposit totals (top deposits query) for "single borrower to deposits"
--
-- Sources:   vision.contract_loans       (loan balances)
--            vision.contracts_expanded   (links loans to customers)
--            vision.customers_expanded   (customer names)
--
-- Filters:   LE_Book 400-999, last 12 months, excludes write-offs (WO)
-- ============================================================================

WITH BorrowerExposure AS (
    -- CTE 1: Total exposure per borrower per LE_Book per month
    SELECT
        cl.le_book,
        cl.year_month,
        cu.customer_id,
        cu.customer_name,
        SUM(cl.prin_outstanding_amt_lcy + cl.interest_due_lcy) AS borrower_exposure,
        MAX(
            CASE
                WHEN cl.performance_class IN ('SL','DL','LL') THEN 'NPL'
                WHEN cl.performance_class IN ('NL','WL') THEN 'PL'
                ELSE 'OTHER'
            END
        ) AS performance_status
    FROM vision.contract_loans cl
    JOIN vision.contracts_expanded c
        ON c.contract_sequence_number = cl.contract_sequence_number
       AND c.country = cl.country
       AND c.le_book = cl.le_book
    JOIN vision.customers_expanded cu
        ON cu.customer_id = c.customer_id
       AND cu.country = c.country
       AND cu.le_book = c.le_book
    WHERE
        cl.year_month >= (
            SELECT TO_CHAR(ADD_MONTHS(SYSDATE, -12), 'YYYYMM') FROM dual
        )
        AND cl.le_book BETWEEN '400' AND '999'
        AND cl.performance_class <> 'WO'
    GROUP BY
        cl.le_book,
        cl.year_month,
        cu.customer_id,
        cu.customer_name
),
RankedBorrowers AS (
    -- CTE 2: Rank borrowers largest to smallest within each LE_Book/month
    SELECT
        le_book,
        year_month,
        customer_id,
        customer_name,
        borrower_exposure,
        performance_status,
        ROW_NUMBER() OVER (
            PARTITION BY le_book, year_month
            ORDER BY borrower_exposure DESC
        ) AS rnk
    FROM BorrowerExposure
)
-- Final: Keep only top 20 borrowers per LE_Book/month
SELECT
    le_book,
    year_month,
    customer_id,
    customer_name,
    borrower_exposure,
    performance_status,
    rnk
FROM RankedBorrowers
WHERE rnk <= 20
ORDER BY
    le_book,
    year_month,
    rnk
