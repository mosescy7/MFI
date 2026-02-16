-- ============================================================================
-- DEPOSIT CONCENTRATION ANALYSIS
-- ============================================================================
-- Purpose:   Measures how much of total deposits are held by the largest
--            depositors (top 5, 10, 20, 50) per LE_Book per month.
--            Used to assess deposit concentration risk for liquidity monitoring.
--
-- Output:    One row per LE_Book / Year_Month with:
--              - Total_Deposits    : sum of all deposit accounts in that LE_Book/month
--              - Top5/10/20/50_Amount : deposit sum held by the top N customers
--              - Top5/10/20/50_Pct   : percentage those top N represent of total
--
-- Usage:     Dashboard line chart over time, with a dropdown to toggle between
--            top 5 / 10 / 20 / 50 concentration views per LE_Book.
--
-- Sources:   VISION.FINANCIAL_MONTHLY  (monthly financial balances)
--            VISION.Accounts_View      (account metadata for type filtering)
--
-- Filters:   LE_Book 400-999 (subsidiary entities)
--            Year_Month >= 202501
--            Account types: CAA, SBA, TDA, SED, TRUSTAC (deposit accounts)
-- ============================================================================

WITH CustomerDeposits AS (
    -- CTE 1: Aggregate deposits per customer per LE_Book per month
    --   Joins to Accounts_View to filter deposit account types only.
    --   The CASE handles records where Account_No = '0', falling back
    --   to Office_Account as the join key.
    SELECT
        fm.LE_Book,
        fm.Year_Month,
        fm.Customer_Id,
        SUM(fm.Amount_Lcy) AS Customer_Amount
    FROM
        VISION.FINANCIAL_MONTHLY fm
    JOIN
        VISION.Accounts_View acc
            ON fm.Country = acc.Country
            AND fm.LE_Book = acc.LE_Book
            AND (
                    CASE
                        WHEN fm.Account_No = '0' THEN fm.Office_Account
                        ELSE fm.Account_No
                    END
                ) = acc.Account_No
    WHERE
        fm.LE_Book BETWEEN '400' AND '999'
        AND fm.Year_Month >= '202501'
        AND acc.Account_Type IN ('CAA','SBA','TDA','SED','TRUSTAC')
    GROUP BY
        fm.LE_Book,
        fm.Year_Month,
        fm.Customer_Id
),
RankedDeposits AS (
    -- CTE 2: Rank customers by deposit size within each LE_Book/month
    --   ROW_NUMBER assigns rank 1 to the largest depositor, 2 to the next, etc.
    --   SUM OVER computes the total deposits for that LE_Book/month across ALL
    --   customers (not just top N), so percentages can be calculated later.
    SELECT
        LE_Book,
        Year_Month,
        Customer_Amount,
        ROW_NUMBER() OVER (
            PARTITION BY LE_Book, Year_Month
            ORDER BY Customer_Amount DESC
        ) AS Rnk,
        SUM(Customer_Amount) OVER (
            PARTITION BY LE_Book, Year_Month
        ) AS Total_Deposits
    FROM CustomerDeposits
)
-- Final: Collapse to one row per LE_Book/month
--   Conditional SUMs accumulate deposit amounts for each tier (top 5, 10, 20, 50).
--   ROUND(...* 100.0 / Total_Deposits) converts each tier into a percentage.
--   WHERE Rnk <= 50 discards all customers beyond rank 50 before aggregation.
SELECT
    LE_Book,
    Year_Month,
    Total_Deposits,
    SUM(CASE WHEN Rnk <= 5  THEN Customer_Amount ELSE 0 END) AS Top5_Amount,
    SUM(CASE WHEN Rnk <= 10 THEN Customer_Amount ELSE 0 END) AS Top10_Amount,
    SUM(CASE WHEN Rnk <= 20 THEN Customer_Amount ELSE 0 END) AS Top20_Amount,
    SUM(CASE WHEN Rnk <= 50 THEN Customer_Amount ELSE 0 END) AS Top50_Amount,
    ROUND(SUM(CASE WHEN Rnk <= 5  THEN Customer_Amount ELSE 0 END) * 100.0 / Total_Deposits, 2) AS Top5_Pct,
    ROUND(SUM(CASE WHEN Rnk <= 10 THEN Customer_Amount ELSE 0 END) * 100.0 / Total_Deposits, 2) AS Top10_Pct,
    ROUND(SUM(CASE WHEN Rnk <= 20 THEN Customer_Amount ELSE 0 END) * 100.0 / Total_Deposits, 2) AS Top20_Pct,
    ROUND(SUM(CASE WHEN Rnk <= 50 THEN Customer_Amount ELSE 0 END) * 100.0 / Total_Deposits, 2) AS Top50_Pct
FROM RankedDeposits
WHERE Rnk <= 50
GROUP BY
    LE_Book,
    Year_Month,
    Total_Deposits
ORDER BY
    LE_Book,
    Year_Month
