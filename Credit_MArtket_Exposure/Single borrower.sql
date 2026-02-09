SELECT
    cl.le_book,
    cl.year_month,
    cu.customer_id,
    cu.customer_name,

    SUM(cl.prin_outstanding_amt_lcy) AS borrower_principal_exposure,
    SUM(cl.loan_includ_interest)     AS borrower_exposure_incl_interest,

    MAX(
        CASE
            WHEN cl.performance_class IN ('SL','DL','LL') THEN 'NPL'
            WHEN cl.performance_class IN ('NL','WL') THEN 'PL'
            ELSE 'OTHER'
        END
    ) AS borrower_performance_status

FROM vision.contract_loans  

JOIN vision.contracts_expanded c
    ON c.contract_sequence_number = cl.contract_sequence_number
   AND c.country = cl.country
   AND c.le_book = cl.le_book

JOIN vision.customers_expanded cu
    ON cu.customer_id = c.customer_id
   AND cu.country = c.country
   AND cu.le_book = c.le_book

WHERE
    cl.year_month >= (
        SELECT TO_CHAR(ADD_MONTHS(SYSDATE, -24), 'YYYYMM') FROM dual
    )
    AND cl.le_book BETWEEN '400' AND '999'
    AND cl.performance_class <> 'WO'

GROUP BY
    cl.le_book,
    cl.year_month,
    cu.customer_id,
    cu.customer_name

ORDER BY
    cl.le_book,
    cl.year_month,
    borrower_principal_exposure DESC
