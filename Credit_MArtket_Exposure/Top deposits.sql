-- Deposit Concentration: Top 5 / 10 / 20 depositors as % of total per LE_Book per month
WITH CustomerDeposits AS (
    -- Layer 1: Sum deposits per customer per LE_Book per month
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
    -- Layer 2: Rank customers by deposit size within each LE_Book/month
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
-- Layer 3: One row per LE_Book/month with top N amounts and percentages
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
