WITH base AS (
    SELECT
        fhh.LE_Book,
        fhb.Year,
        fhb.Balance_01,
        fhb.Balance_02,
        fhb.Balance_03,
        fhb.Balance_04,
        fhb.Balance_05,
        fhb.Balance_06,
        fhb.Balance_07,
        fhb.Balance_08,
        fhb.Balance_09,
        fhb.Balance_10,
        fhb.Balance_11,
        fhb.Balance_12
    FROM
        VISION.Fin_History_Headers fhh
    JOIN
        VISION.Fin_History_Balances fhb
        ON  fhh.Country      = fhb.Country
        AND fhh.LE_Book      = fhb.LE_Book
        AND fhh.Year         = fhb.Year
        AND fhh.Sequence_FH  = fhb.Sequence_FH
        AND fhh.Record_Type != 9999
    JOIN
        VISION.FRL_Expanded frl
        ON  fhh.FRL_Line_BS  = frl.Source_FRL_Line
        AND fhb.Bal_Type     = frl.Source_Bal_Type
        AND fhh.Record_Type != 9999
    JOIN
        VISION.GL_Codes gc
        ON  fhh.Country      = gc.Country
        AND fhh.LE_Book      = gc.LE_Book
        AND fhh.BS_GL        = gc.Vision_Gl
        AND fhh.Record_Type != 9999
    WHERE
        fhb.Year     >= TO_CHAR(ADD_MONTHS(SYSDATE, -13), 'YYYY')
        AND fhh.LE_Book   BETWEEN '400' AND '999'
        AND fhb.Bal_Type  = '1'
        AND frl.FRL_Line  LIKE 'F1%'
),

unpivoted AS (
    SELECT
        LE_Book,
        Year || Month_Num  AS Year_Month,
        Balance
    FROM base
    UNPIVOT (
        Balance FOR Month_Num IN (
            Balance_01 AS '01',
            Balance_02 AS '02',
            Balance_03 AS '03',
            Balance_04 AS '04',
            Balance_05 AS '05',
            Balance_06 AS '06',
            Balance_07 AS '07',
            Balance_08 AS '08',
            Balance_09 AS '09',
            Balance_10 AS '10',
            Balance_11 AS '11',
            Balance_12 AS '12'
        )
    )
)

SELECT
    LE_Book,
    Year_Month,
    SUM(ABS(Balance))  AS Total_Balance
FROM
    unpivoted
WHERE
    Year_Month >= TO_CHAR(ADD_MONTHS(TRUNC(SYSDATE, 'MM'), -13), 'YYYYMM')
GROUP BY
    LE_Book, Year_Month
ORDER BY
    LE_Book, Year_Month
