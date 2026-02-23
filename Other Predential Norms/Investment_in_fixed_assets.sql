-- ============================================================================
-- PNR13: INVESTMENT IN FIXED ASSETS
-- ============================================================================
-- Purpose:   Total investment in fixed assets per LE_Book per month.
--            Ratio = Fixed Assets / Core Capital * 100 (Max 50%)
--            For SACCOs: use total equity instead of core capital.
--
-- Output:    One row per LE_Book / Year_Month with fixed assets amount.
-- Sources:   VISION.FIN_HISTORY_HEADERS, FIN_HISTORY_BALANCES, FRL_EXPANDED, Le_Book
-- Filters:   CATEGORY_TYPE IN (MF, SACCO, OSACCO, DSACCO), rolling 12 months
-- ============================================================================

SELECT
    Year,
    LE_Book,
    Year || LPAD(TO_CHAR(Month_Number), 2, '0') AS Year_Month,
    SUM(Balance_Value) AS Investment_In_Fixed_Assets
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
            'F1700080',  /* WIP Softwares */
            'F1700081',  /* Accumulated Dep. - WIP Software */
            'F1700105',  /* WIP Computer Equipment */
            'F1700160',  /* Machines Asset Clearing */
            'F1700610',  /* Amortization Software */
            'F1700690',  /* Other Intangible assets */
            'F1700010',  /* Land */
            'F1700015',  /* Properties, Buildings and Offices */
            'F1700016',  /* Accumulated Dep. - Properties, Buildings And Offices */
            'F1700025',  /* Equipments, Furniture and IT */
            'F1700026',  /* Accumulated Dep. - Equipment, Furniture And It */
            'F1700030',  /* Vehicles */
            'F1700031',  /* Accumulated Dep. - Vehicles */
            'F1700035',  /* Refurbishment and Installation */
            'F1700036',  /* Accumulated Dep. - Refurbishment And Installation */
            'F1700040',  /* Other tangible fixed assets */
            'F1700041',  /* Accumulated Dep. - Other Tangible Fixed Assets */
            'F1700050',  /* Property, Plant and Equipment */
            'F1700051',  /* Accumulated Dep. - Property, Plant And Equipment */
            'F1700060',  /* Fixed Assets in progress */
            'F1700065',  /* WIP Buildings */
            'F1700071',  /* Accumulated Dep. - WIP Motor vehicle */
            'F1700320',  /* Building of Placement */
            'F1700410',  /* Depreciation of fixed tangible assets */
            'F1700056'  /* Accumulated Dep. - Investment Property */
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
