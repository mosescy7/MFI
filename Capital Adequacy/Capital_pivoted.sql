SELECT
    LE_BOOK,
    YEAR_MONTH,
    CORE_CAPITAL,
    TOTAL_CORE_CAPITAL_TIER_1,
    TOTAL_SUPPLEMENTARY_CAPITAL_TIER_2,
    TIER_1_CAPITAL_RATIO,
    TOTAL_CAPITAL_ADEQUACY_RATIO
FROM (
    SELECT
        ca.LE_BOOK,
        ca.YEAR_MONTH,
        CASE
            WHEN ast.ALPHA_SUBTAB_DESCRIPTION = 'Core capital'
                THEN 'CORE_CAPITAL'
            WHEN ast.ALPHA_SUBTAB_DESCRIPTION = 'Tier 1 Capital Ratio'
                THEN 'TIER_1_CAPITAL_RATIO'
            WHEN ast.ALPHA_SUBTAB_DESCRIPTION = 'Total Capital Adequacy Ratio'
                THEN 'TOTAL_CAPITAL_ADEQUACY_RATIO'
            WHEN ast.ALPHA_SUBTAB_DESCRIPTION LIKE 'Total Core capital%Tier 1%'
                THEN 'TOTAL_CORE_CAPITAL_TIER_1'
            WHEN ast.ALPHA_SUBTAB_DESCRIPTION LIKE 'Total supple%capital%Tier 2%'
                THEN 'TOTAL_SUPPLEMENTARY_CAPITAL_TIER_2'
        END AS CAR_LINE_CODE_DESC,
        ca.VALUE_LCY
    FROM vision.CAPITAL_AR ca
    LEFT JOIN vision.ALPHA_SUB_TAB ast
        ON ast.ALPHA_TAB = 5005
       AND ast.ALPHA_SUB_TAB = ca.CAR_LINE_CODE
    WHERE ast.ALPHA_SUBTAB_DESCRIPTION IN (
        'Core capital',
        'Tier 1 Capital Ratio',
        'Total Capital Adequacy Ratio'
    )
       OR ast.ALPHA_SUBTAB_DESCRIPTION LIKE 'Total Core capital%Tier 1%'
       OR ast.ALPHA_SUBTAB_DESCRIPTION LIKE 'Total supple%capital%Tier 2%'
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
)
ORDER BY LE_BOOK, YEAR_MONTH
