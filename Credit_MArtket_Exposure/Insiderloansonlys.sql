/* Insider loans only */
SELECT 

    /* Institution identifier (Microfinance LE_BOOK code) */
    cl.le_book,

    /* Reporting period in YYYYMM format */
    cl.year_month,

    /* Unique contract identifier (contract-level granularity) */
  --  ce.contract_id,

    /* Description of insider relationship
       (e.g., Director, Management, Principal Shareholder) */
    cu.relationship_type_desc,

    /* Related party category code
    cu.related_party,

    /* Gender of borrower for gender-based concentration analysis */
    cu.customer_gender,

    /* Loan classification status
       (e.g., Performing, Substandard, Doubtful, Loss) */
    cl.performance_class,

    /* Total disbursed amount per contract
       Note: SUM used in case of multiple disbursement records
       Formatting applied for reporting purposes */
    TRIM(
        TO_CHAR(
            SUM(cl.disbursed_amount),
            '999,999,999,999,999,990.00000'
        )
    ) AS disbursed_amount,

    /* Insider exposure definition:
       Outstanding principal + accrued interest (LCY) */
    SUM(cl.prin_outstanding_amt_lcy) 
        + SUM(cl.interest_due_lcy) AS insider_loans_lcy

FROM 

    /* Contract master data */
    vision.contracts_expanded ce

JOIN 

    /* Loan financial balances */
    vision.contract_loans cl
        ON ce.contract_sequence_number = cl.contract_sequence_number
       AND ce.country = cl.country
       AND ce.le_book = cl.le_book

JOIN 

    /* Customer and insider classification details */
    vision.customers_expanded cu
        ON ce.country = cu.country
       AND ce.le_book = cu.le_book
       AND ce.customer_id = cu.customer_id

WHERE

    /* Restrict to insider-related categories only */
    cu.related_party IN (
        'DIR',      
        'MGT',    
        'PRN',       
        'STAFF'      

    )
AND
    /*RELATIONSHIP TYPE THAT ARE INSIDER LOAN*/
    cu.relationship_type_desc IN (
        'Spouse',
        'Husband',
        'Wife',
        'Self'
    )

AND

    /* Restrict to Microfinance Institutions (DTMFIs)
       LE_BOOK codes between 400 and 999 */
    TO_NUMBER(cl.le_book) BETWEEN 400 AND 999

AND

    /* Rolling 12-month reporting window
       Improves performance and focuses on recent monitoring */
    cl.year_month >= TO_CHAR(
        ADD_MONTHS(TRUNC(SYSDATE, 'MM'), -12),
        'YYYYMM'
    )

GROUP BY

    /* Ensures correct aggregation at contract level */
    cl.le_book,
    cl.year_month,
    --ce.contract_id,
    cu.relationship_type_desc,
    cu.related_party,
    cu.customer_gender,
    cl.performance_class

ORDER BY

    /* Sorted for reporting consistency and easier validation */
    cl.le_book,
    cl.year_month;