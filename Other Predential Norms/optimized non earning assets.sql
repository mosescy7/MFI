SELECT
    Year,
    LE_Book,
    Year || LPAD(TO_CHAR(Month_Number), 2, '0') AS Year_Month,
    SUM(Balance_Value) AS Non_Earning_Assets
FROM (
    SELECT
        fhh.Year,
        fhh.LE_Book,
        fhb.Balance_01, fhb.Balance_02, fhb.Balance_03,
        fhb.Balance_04, fhb.Balance_05, fhb.Balance_06,
        fhb.Balance_07, fhb.Balance_08, fhb.Balance_09,
        fhb.Balance_10, fhb.Balance_11, fhb.Balance_12
    FROM
        VISION.FIN_HISTORY_HEADERS fhh
    JOIN
        VISION.FIN_HISTORY_BALANCES fhb
            ON fhh.Country = fhb.Country
            AND fhh.LE_Book = fhb.LE_Book
            AND fhh.Year = fhb.Year
            AND fhh.SEQUENCE_FH = fhb.SEQUENCE_FH
    JOIN
        VISION.FRL_EXPANDED frl
            ON fhh.FRL_LINE_BS = frl.SOURCE_FRL_LINE
            AND fhb.BAL_TYPE = frl.SOURCE_BAL_TYPE
    JOIN
        VISION.Le_Book lb
            ON lb.Country = fhh.Country
            AND lb.Le_Book = fhh.Le_Book
    WHERE
        fhh.RECORD_TYPE != 9999
        AND fhb.Bal_Type = 1
        AND fhh.Year >= TO_CHAR(ADD_MONTHS(SYSDATE, -13), 'YYYY')
        AND lb.CATEGORY_TYPE IN ('MF','SACCO','OSACCO','DSACCO')
        AND frl.FRL_Line IN (
            'F1120317',  /* Fixed Term Deposits With Banks In Rwanda (LCY) */
            'F1120319',  /* Fixed Term Deposits With Banks In Rwanda (FCY) */
            'F1120365',  /* Accrual receivable interests with the banks & other FI (LCY) */
            'F1200230',  /* Suspended interests (LCY) */
            'F1200250',  /* Accrual receivable interests (LCY) */
            'F1500010',  /* Overdrawn Accounts (LCY) */
            'F1500011',  /* Provisions on NPL Overdrawn accounts(LCY) */
            'F1500012',  /* Non performing Overdrwawn accounts(LCY) */
            'F1500016',  /* Suspended Interest on Overdrawn A/C (LCY) */
            'F1500017',  /* Suspended Interest on Overdrawn A/C (FCY) */
            'F1500085',  /* Term treasury loans (LCY) */
            'F1500086',  /* Non performing loans Treasury Loans(LCY) */
            'F1500087',  /* Provisions on NPL Treasury Loans(LCY) */
            'F1500088',  /* Suspended Interest on Treasury Loans (LCY) */
            'F1500135',  /* Other Treasury Loans (LCY) */
            'F1500145',  /* Accrual Receivable Interest on Treasury Loans (LCY) */
            'F1500210',  /* Equipment loans (LCY) */
            'F1500211',  /* Non performing loans Equipment Loans(LCY) */
            'F1500212',  /* Provisions on NPL Equipment Loans(LCY) */
            'F1500213',  /* Suspended Interest on Equipment Loans (LCY) */
            'F1500310',  /* Accrual Receivable Interest on Equipment Loans (LCY) */
            'F1500410',  /* Consumer loans (LCY) */
            'F1500411',  /* Non performing loans Consumer Loans(LCY) */
            'F1500412',  /* Provisions on NPL Consumer Loans(LCY) */
            'F1500413',  /* Suspended Interests On Consumer Loans (LCY) */
            'F1500422',  /* Provisions on NPL Consumer Loans(FCY) */
            'F1500480',  /* Accrual Receivable Interests on Consumer Loans (LCY) */
            'F1500510',  /* Mortgage Loans (LCY) */
            'F1500511',  /* Non performing loans Mortgage Loan (LCY) */
            'F1500512',  /* Provisions on NPL Mortgage Loan(LCY) */
            'F1500513',  /* Suspended Interests on Mortgage Loan (LCY) */
            'F1500550',  /* Accrual Receivable Interests on Mortgage Loan (LCY) */
            'F1500612',  /* Provisions on NPL Finance Lease(LCY) */
            'F1500690',  /* Accrual Receivable Interests on Finance Lease (LCY) */
            'F1500815',  /* Loans To The Agriculture Sector And Agro Business Sector */
            'F1500830',  /* Loans And Advances To Staff */
            'F1500860',  /* Salary Advance */
            'F1500980',  /* Other Loans of Clients (LCY) */
            'F1501040',  /* Other loans and advances */
            'F1501030',  /* Accrual Receivable Interests on other Loans of Clients (LCY) */
            'F1200511',  /* Government ,Treasury Bonds HTM */
            'F1200315',  /* Other debt securities */
            'F1200510',  /* Treasury Bills HTM */
            'F1210440',  /* Accrual receivable interests */
            'F1210010',  /* Equity investment */
            'F1210015',  /* Investment in subsidiaries */
            'F1200520'  /* Accrual receivable interests on financial instruments HTM */
        )
)
UNPIVOT (
    Balance_Value FOR Month_Number IN (
        Balance_01 AS 1,  Balance_02 AS 2,  Balance_03 AS 3,
        Balance_04 AS 4,  Balance_05 AS 5,  Balance_06 AS 6,
        Balance_07 AS 7,  Balance_08 AS 8,  Balance_09 AS 9,
        Balance_10 AS 10, Balance_11 AS 11, Balance_12 AS 12
    )
)
WHERE
    Year || LPAD(TO_CHAR(Month_Number), 2, '0') >= TO_CHAR(ADD_MONTHS(SYSDATE, -12), 'YYYYMM')
    AND Year || LPAD(TO_CHAR(Month_Number), 2, '0') <= TO_CHAR(SYSDATE, 'YYYYMM')
GROUP BY
    Year, LE_Book, Month_Number
HAVING
    SUM(Balance_Value) != 0
