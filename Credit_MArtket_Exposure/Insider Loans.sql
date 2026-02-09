SELECT 
    cl.le_book,
    cl.year_month,
    ce.contract_id,
    cu.related_party,
    cu.customer_gender,
    cl.performance_class,
    TRIM(
        TO_CHAR(
            SUM(cl.disbursed_amount),
            '999,999,999,999,999,990.00000'
        )
    ) AS disbursed_amount,
    SUM(cl.prin_outstanding_amt_lcy) 
        + SUM(cl.interest_due_lcy) AS insider_loans_lcy
FROM 
    vision.contracts_expanded ce
JOIN 
    vision.contract_loans cl
        ON ce.contract_sequence_number = cl.contract_sequence_number
       AND ce.country = cl.country
       AND ce.le_book = cl.le_book
JOIN 
    vision.customers_expanded cu
        ON ce.country = cu.country
       AND ce.le_book = cu.le_book
       AND ce.customer_id = cu.customer_id
WHERE
    cu.related_party IN ('STAFF', 'DIR', 'MGT', 'PRN', 'OTH1', 'OTH2', 'OTH3')
AND
    TO_NUMBER(cl.le_book) BETWEEN 400 AND 999
AND
    cl.year_month >= TO_CHAR(
        ADD_MONTHS(TRUNC(SYSDATE, 'MM'), -12),
        'YYYYMM'
    )
GROUP BY
    cl.le_book,
    cl.year_month,
    ce.contract_id,
    cu.related_party,
    cu.customer_gender,
    cl.performance_class
ORDER BY
    cl.le_book,
    cl.year_month,
    ce.contract_id
