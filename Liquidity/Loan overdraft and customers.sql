SELECT
    le_book,
    year,
    frl_attribute_07,
    SUM(balance_01) AS balance_01,
    SUM(balance_02) AS balance_02,
    SUM(balance_03) AS balance_03,
    SUM(balance_04) AS balance_04,
    SUM(balance_05) AS balance_05,
    SUM(balance_06) AS balance_06,
    SUM(balance_07) AS balance_07,
    SUM(balance_08) AS balance_08,
    SUM(balance_09) AS balance_09,
    SUM(balance_10) AS balance_10,
    SUM(balance_11) AS balance_11,
    SUM(balance_12) AS balance_12
FROM vision.fin_history_balances
LEFT JOIN (
    SELECT
        country,
        le_book,
        year,
        sequence_fh,
        frl_line_bs,
        frl_line_pl
    FROM vision.fin_history_headers
) t1 USING (country, le_book, year, sequence_fh)
LEFT JOIN (
    SELECT
        source_frl_line AS frl_line_bs,
        CAST(bal_type AS VARCHAR2(10)) AS bal_type,
        frl_attribute_07
    FROM vision.frl_expanded
    WHERE bal_type = 1
) t2 USING (frl_line_bs, bal_type)
LEFT JOIN (
    SELECT
        source_frl_line AS frl_line_pl,
        CAST(bal_type AS VARCHAR2(10)) AS bal_type,
        frl_attribute_08
    FROM vision.frl_expanded
    WHERE bal_type = 3
) t3 USING (frl_line_pl, bal_type)
WHERE year BETWEEN 2023 AND EXTRACT(YEAR FROM SYSDATE)
  AND le_book BETWEEN '400' AND '999'
  AND frl_attribute_07 IN ('FA071050','FA071055','FA071060','FA071065','FA072025')
GROUP BY
    le_book,
    year,
    frl_attribute_07
ORDER BY 
    le_book, year, frl_attribute_07
