-- ============================================================================
-- PNR16: BORROWING RATIO
-- ============================================================================
-- Purpose:   Total borrowings per LE_Book per month.
--            Ratio = Borrowings / total assets * 100 (Max 25%)
--            For SACCOs: use total equity instead of core capital.
--
-- Output:    One row per LE_Book / Year_Month with borrowings amount.
-- Sources:   VISION.FIN_HISTORY_HEADERS, FIN_HISTORY_BALANCES, FRL_EXPANDED, Le_Book
-- Filters:   CATEGORY_TYPE IN (MF, SACCO, OSACCO, DSACCO), rolling 12 months
-- ============================================================================

SELECT
    Year,
    LE_Book,
    Year || LPAD(TO_CHAR(Month_Number), 2, '0') AS Year_Month,
    SUM(Balance_Value) AS Borrowings
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
        AND fhh.Year >= TO_CHAR(ADD_MONTHS(SYSDATE, -12), 'YYYY')
        AND lb.CATEGORY_TYPE IN ('MF','SACCO','OSACCO','DSACCO')
        AND frl.FRL_Line IN (
            'F2120010','F2120070','F2120080','F2120175','F2120155',
            'F2110260','F2120350','F2120355','F2150315','F2120420'
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
ORDER BY
    LE_Book, Year, Month_Number
