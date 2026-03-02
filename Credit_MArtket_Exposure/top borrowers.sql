WITH borrower_exposure AS (
    SELECT
        cl.LE_BOOK                                   AS LE_BOOK,
        cl.Year_Month                                AS Year_Month,
        c.Customer_ID                                AS Customer_ID,
        cu.Customer_Name                             AS Borrower_Name,
        cl.Performance_Class                         AS Performance_Class,
        SUM(
            cl.prin_outstanding_amt_lcy
          + cl.interest_due_lcy
        )                                            AS Amount
    FROM vision.Contracts_Expanded c
    JOIN vision.Contract_Loans cl
        ON c.Contract_Sequence_Number = cl.Contract_Sequence_Number
       AND c.Country = cl.Country
       AND c.LE_BOOK = cl.LE_BOOK
    JOIN vision.Customers_Expanded cu
        ON c.Country = cu.Country
       AND c.LE_BOOK = cu.LE_BOOK
       AND c.Customer_ID = cu.Customer_ID
    WHERE cl.LE_BOOK BETWEEN '400' AND '999'
      AND cl.Year_Month >= TO_CHAR(ADD_MONTHS(SYSDATE, -10), 'YYYYMM')
    GROUP BY
        cl.LE_BOOK,
        cl.Year_Month,
        c.Customer_ID,
        cu.Customer_Name,
        cl.Performance_Class
),
top20_per_lebook AS (
    SELECT
        LE_BOOK,
        Customer_ID,
        Borrower_Name,
        Performance_Class,
        Year_Month,
        TRIM(
            TO_CHAR(
                Amount,
                '999,999,999,999,999,990'
            )
        ) AS Amount
    FROM (
        SELECT
            be.*,
            ROW_NUMBER() OVER (
                PARTITION BY LE_BOOK
                ORDER BY Amount DESC
            ) AS rn
        FROM borrower_exposure be
    ) x
    WHERE rn <= 20
)
SELECT *
FROM top20_per_lebook
ORDER BY LE_BOOK, Amount DESC
