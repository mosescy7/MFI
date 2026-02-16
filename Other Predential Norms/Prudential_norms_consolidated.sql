-- ============================================================================
-- OTHER PRUDENTIAL NORMS - CONSOLIDATED (replaces 6 individual queries)
-- ============================================================================
-- Purpose:   Computes 6 prudential norm metrics per LE_Book per month in a
--            single query. Each metric is a ratio to core capital or total assets.
--
--   PNR  Metric                          Limit           Denominator
--   ---  ------------------------------  --------------  ---------------------
--   13   Investment in fixed assets       Max 50%         Core capital (SACCOs: total equity)
--   14   Land and buildings               Max 5%          Total assets
--   15   Non-earning assets               Max 10%         Total assets
--   16   Borrowing ratio                  Max 25%         Core capital (SACCOs: total equity)
--   17   Placement limits                 Max 25%         Core capital (SACCOs: total equity)
--   18   Investment in equity shares      Max 25%         Core capital (SACCOs: total equity)
--
-- Output:    One row per LE_Book / Year_Month with all 6 metric amounts.
--            Ratios computed in Power BI by joining with CAR data for capital
--            and total assets.
--
-- Sources:   VISION.FIN_HISTORY_HEADERS   (financial history headers)
--            VISION.FIN_HISTORY_BALANCES   (monthly balance columns)
--            VISION.FRL_EXPANDED           (FRL line mapping)
--            VISION.Le_Book                (entity metadata: name, category)
--
-- Filters:   CATEGORY_TYPE IN (MF, SACCO, OSACCO, DSACCO)
--            Rolling 12 months from today
--            Bal_Type = 1 (actual balances)
-- ============================================================================

WITH UnpivotedData AS (
    SELECT
        Year,
        LE_Book,
        CATEGORY_TYPE,
        Stakeholder_Name,
        FRL_Line,
        Month_Number,
        Balance_Value,
        Year || LPAD(TO_CHAR(Month_Number), 2, '0') AS Year_Month
    FROM (
        SELECT
            fhh.Year,
            fhh.LE_Book,
            lb.CATEGORY_TYPE,
            lb.Leb_Description AS Stakeholder_Name,
            frl.FRL_Line,
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
            -- Include years that may contain data in the last 12 months
            AND fhh.Year >= TO_CHAR(ADD_MONTHS(SYSDATE, -12), 'YYYY')
            AND lb.CATEGORY_TYPE IN ('MF','SACCO','OSACCO','DSACCO')
            -- All FRL codes across all 6 metrics (union of all)
            AND frl.FRL_Line IN (
                -- PNR13: Investment in fixed assets
                'F1700010','F1700015','F1700016','F1700025','F1700026',
                'F1700030','F1700031','F1700035','F1700036','F1700040',
                'F1700041','F1700050','F1700051','F1700056','F1700060',
                'F1700065','F1700071','F1700080','F1700081','F1700105',
                'F1700160','F1700320','F1700410','F1700610','F1700690',
                -- PNR15: Non-earning assets (codes not already listed above)
                'F1120317','F1120319','F1120365',
                'F1200230','F1200250','F1200315','F1200510','F1200511','F1200520',
                'F1210010','F1210015','F1210440',
                'F1500010','F1500011','F1500012','F1500016','F1500017',
                'F1500085','F1500086','F1500087','F1500088','F1500135',
                'F1500145','F1500210','F1500211','F1500212','F1500213',
                'F1500310','F1500410','F1500411','F1500412','F1500413',
                'F1500422','F1500480','F1500510','F1500511','F1500512',
                'F1500513','F1500550','F1500612','F1500690','F1500815',
                'F1500830','F1500860','F1500980','F1501030','F1501040',
                -- PNR16: Borrowings
                'F2110260','F2120010','F2120070','F2120080','F2120155',
                'F2120175','F2120350','F2120355','F2120420','F2150315'
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
    -- Fine-grained filter: only months within the last 12 months
    WHERE
        Year || LPAD(TO_CHAR(Month_Number), 2, '0') >= TO_CHAR(ADD_MONTHS(SYSDATE, -12), 'YYYYMM')
        AND Year || LPAD(TO_CHAR(Month_Number), 2, '0') <= TO_CHAR(SYSDATE, 'YYYYMM')
)
-- Final: One row per LE_Book/month with all 6 metrics as columns
SELECT
    LE_Book,
    Year_Month,
    CATEGORY_TYPE,
    Stakeholder_Name,

    -- PNR13: Investment in fixed assets (Max 50% of core capital)
    SUM(CASE WHEN FRL_Line IN (
        'F1700010','F1700015','F1700016','F1700025','F1700026',
        'F1700030','F1700031','F1700035','F1700036','F1700040',
        'F1700041','F1700050','F1700051','F1700056','F1700060',
        'F1700065','F1700071','F1700080','F1700081','F1700105',
        'F1700160','F1700320','F1700410','F1700610','F1700690'
    ) THEN Balance_Value ELSE 0 END) AS Investment_In_Fixed_Assets,

    -- PNR14: Land and buildings (Max 5% of total assets)
    SUM(CASE WHEN FRL_Line IN (
        'F1700010','F1700015','F1700016','F1700035','F1700036',
        'F1700050','F1700051','F1700320'
    ) THEN Balance_Value ELSE 0 END) AS Land_And_Buildings,

    -- PNR15: Non-earning assets (Max 10% of total assets)
    SUM(CASE WHEN FRL_Line IN (
        'F1120317','F1120319','F1120365','F1200230','F1200250',
        'F1200315','F1200510','F1200511','F1200520',
        'F1210010','F1210015','F1210440',
        'F1500010','F1500011','F1500012','F1500016','F1500017',
        'F1500085','F1500086','F1500087','F1500088','F1500135',
        'F1500145','F1500210','F1500211','F1500212','F1500213',
        'F1500310','F1500410','F1500411','F1500412','F1500413',
        'F1500422','F1500480','F1500510','F1500511','F1500512',
        'F1500513','F1500550','F1500612','F1500690','F1500815',
        'F1500830','F1500860','F1500980','F1501030','F1501040'
    ) THEN Balance_Value ELSE 0 END) AS Non_Earning_Assets,

    -- PNR16: Borrowing ratio (Max 25% of core capital)
    SUM(CASE WHEN FRL_Line IN (
        'F2110260','F2120010','F2120070','F2120080','F2120155',
        'F2120175','F2120350','F2120355','F2120420','F2150315'
    ) THEN Balance_Value ELSE 0 END) AS Borrowings,

    -- PNR17: Placement limits (Max 25% of core capital)
    SUM(CASE WHEN FRL_Line IN (
        'F1120317','F1120319'
    ) THEN Balance_Value ELSE 0 END) AS Placement_Limits,

    -- PNR18: Investment in equity shares (Max 25% of core capital)
    SUM(CASE WHEN FRL_Line IN (
        'F1210010','F1210015'
    ) THEN Balance_Value ELSE 0 END) AS Investment_In_Equity_Shares

FROM UnpivotedData
GROUP BY
    LE_Book,
    Year_Month,
    CATEGORY_TYPE,
    Stakeholder_Name
ORDER BY
    LE_Book,
    Year_Month
