-- Combined Capital Adequacy Ratio (CAR%)
-- Saccos       : CAR% = Equity Amt (GL_Type 30) / Assets Amt (GL_Type 10)  — source: FINANCIAL_MONTHLY
-- Microfinance : CAR% = TOTAL_CAPITAL_ADEQUACY_RATIO already computed       — source: CAPITAL_AR
--
-- Column mapping across institution types:
--   Total_Capital → Sacco: SUM(Amount_Lcy) where GL_Type = '30'
--                   MFI  : TOTAL_CORE_CAPITAL_TIER_1  (equivalent capital measure)
--   Assets_Amt  → Sacco: SUM(ABS(Amount_Lcy)) where GL_Type = '10'
--                 MFI  : NULL (assets not stored in CAPITAL_AR)
--
-- NOTE: MFI CAR_Pct is divided by 100 so both Sacco and MFI are on the same decimal scale (e.g. 0.125 = 12.5%).

WITH sacco_car AS (
    SELECT
        fm.LE_Book                                                                          AS LE_Book,
        fm.Year_Month                                                                       AS Year_Month,
        SUM(CASE WHEN gc.GL_Type = '30' THEN  fm.Amount_Lcy        ELSE 0 END)             AS Total_Capital,
        SUM(CASE WHEN gc.GL_Type = '10' THEN  ABS(fm.Amount_Lcy)   ELSE 0 END)             AS Assets_Amt,
        NULL                                                                                AS Total_Supplementary_Capital_Tier_2,
        CASE
            WHEN SUM(CASE WHEN gc.GL_Type = '10' THEN ABS(fm.Amount_Lcy) ELSE 0 END) <> 0
            THEN SUM(CASE WHEN gc.GL_Type = '30' THEN fm.Amount_Lcy      ELSE 0 END)
               / SUM(CASE WHEN gc.GL_Type = '10' THEN ABS(fm.Amount_Lcy) ELSE 0 END)
            ELSE NULL
        END                                                                                 AS CAR_Pct,
        'SACCO'                                                                             AS Institution_Type
    FROM
        VISION.FINANCIAL_MONTHLY fm
    JOIN
        VISION.GL_Codes gc
        ON  fm.Country   = gc.Country
        AND fm.LE_Book   = gc.LE_Book
        AND fm.Vision_Gl = gc.Vision_Gl
    WHERE
        fm.LE_Book   BETWEEN '500' AND '999'
        AND fm.Year_Month >= TO_CHAR(ADD_MONTHS(TRUNC(SYSDATE, 'MM'), -13), 'YYYYMM')
        AND gc.GL_Type IN ('10', '30')
    GROUP BY
        fm.LE_Book, fm.Year_Month
),

mfi_car AS (
    SELECT
        pvt.LE_BOOK                         AS LE_Book,
        pvt.YEAR_MONTH                      AS Year_Month,
        pvt.TOTAL_CORE_CAPITAL_TIER_1       AS Total_Capital,  -- equivalent to Sacco Total_Capital
        NULL                                        AS Assets_Amt,
        pvt.TOTAL_SUPPLEMENTARY_CAPITAL_TIER_2      AS Total_Supplementary_Capital_Tier_2,
        pvt.TOTAL_CAPITAL_ADEQUACY_RATIO / 100      AS CAR_Pct,  -- divided by 100 to match Sacco decimal ratio
        'MICROFINANCE'                      AS Institution_Type
    FROM (
        SELECT
            ca.LE_BOOK,
            ca.YEAR_MONTH,
            CASE
                WHEN ast.ALPHA_SUBTAB_DESCRIPTION = 'Core capital'                         THEN 'CORE_CAPITAL'
                WHEN ast.ALPHA_SUBTAB_DESCRIPTION = 'Tier 1 Capital Ratio'                 THEN 'TIER_1_CAPITAL_RATIO'
                WHEN ast.ALPHA_SUBTAB_DESCRIPTION = 'Total Capital Adequacy Ratio'         THEN 'TOTAL_CAPITAL_ADEQUACY_RATIO'
                WHEN ast.ALPHA_SUBTAB_DESCRIPTION LIKE 'Total Core capital%Tier 1%'        THEN 'TOTAL_CORE_CAPITAL_TIER_1'
                WHEN ast.ALPHA_SUBTAB_DESCRIPTION LIKE 'Total supple%capital%Tier 2%'      THEN 'TOTAL_SUPPLEMENTARY_CAPITAL_TIER_2'
            END AS CAR_LINE_CODE_DESC,
            ca.VALUE_LCY
        FROM vision.CAPITAL_AR ca
        LEFT JOIN vision.ALPHA_SUB_TAB ast
            ON  ast.ALPHA_TAB     = 5005
            AND ast.ALPHA_SUB_TAB = ca.CAR_LINE_CODE
        WHERE
            ca.YEAR_MONTH >= '202601'
            AND (
                ast.ALPHA_SUBTAB_DESCRIPTION IN (
                    'Core capital',
                    'Tier 1 Capital Ratio',
                    'Total Capital Adequacy Ratio'
                )
                OR ast.ALPHA_SUBTAB_DESCRIPTION LIKE 'Total Core capital%Tier 1%'
                OR ast.ALPHA_SUBTAB_DESCRIPTION LIKE 'Total supple%capital%Tier 2%'
            )
    )
    PIVOT (
        SUM(VALUE_LCY)
        FOR CAR_LINE_CODE_DESC IN (
            'CORE_CAPITAL'                       AS CORE_CAPITAL,
            'TOTAL_CORE_CAPITAL_TIER_1'          AS TOTAL_CORE_CAPITAL_TIER_1,
            'TOTAL_SUPPLEMENTARY_CAPITAL_TIER_2' AS TOTAL_SUPPLEMENTARY_CAPITAL_TIER_2,
            'TIER_1_CAPITAL_RATIO'               AS TIER_1_CAPITAL_RATIO,
            'TOTAL_CAPITAL_ADEQUACY_RATIO'       AS TOTAL_CAPITAL_ADEQUACY_RATIO
        )
    ) pvt
)

SELECT
    LE_Book,
    Year_Month,
    Institution_Type,
    Total_Capital,
    Assets_Amt,
    Total_Supplementary_Capital_Tier_2,
    CAR_Pct
FROM sacco_car

UNION ALL

SELECT
    LE_Book,
    Year_Month,
    Institution_Type,
    Total_Capital,
    Assets_Amt,
    Total_Supplementary_Capital_Tier_2,
    CAR_Pct
FROM mfi_car

ORDER BY
    Institution_Type, LE_Book, Year_Month
