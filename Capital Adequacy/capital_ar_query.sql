SELECT
    ca.LE_BOOK,
    ca.YEAR_MONTH,
    ast.ALPHA_SUBTAB_DESCRIPTION AS CAR_LINE_CODE_DESC,
    SUM(ca.VALUE_LCY) AS VALUE_LCY
FROM vision.CAPITAL_AR ca
LEFT JOIN vision.ALPHA_SUB_TAB ast
    ON ast.ALPHA_TAB = 5005
   AND ast.ALPHA_SUB_TAB = ca.CAR_LINE_CODE
WHERE ast.ALPHA_SUBTAB_DESCRIPTION IN (
    -- 'Core capital',
    -- 'Tier 1 Capital Ratio',
    -- 'Total Capital Adequacy Ratio',
 --   'Total RISK WEIGHTED ASSETS'
   'Total capital (Tier 1 and Tier 2)'
)
  -- OR ast.ALPHA_SUBTAB_DESCRIPTION LIKE 'Total Core capital%Tier 1%'
    OR ast.ALPHA_SUBTAB_DESCRIPTION LIKE 'Total capital%Tier 1 and Tier 2%'
  -- OR ast.ALPHA_SUBTAB_DESCRIPTION LIKE 'Total supple%capital%Tier 2%' 
  AND ca.LE_BOOK = '417'
GROUP BY ca.LE_BOOK, ca.YEAR_MONTH, ast.ALPHA_SUBTAB_DESCRIPTION
ORDER BY ca.LE_BOOK, ca.YEAR_MONTH, ast.ALPHA_SUBTAB_DESCRIPTION
