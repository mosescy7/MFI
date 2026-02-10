SELECT  
    fm.Country AS Country,
    fm.LE_Book AS LE_Book,
    fm.Year_Month AS Year_Month,
    fm.Customer_Id AS Customer_Id,
    SUM(fm.Amount_Lcy) AS Amount_Lcy
FROM  
    VISION.FINANCIAL_MONTHLY fm
JOIN 
    VISION.Accounts_View acc
        ON fm.Country = acc.Country
        AND fm.LE_Book = acc.LE_Book
        AND (
                CASE 
                    WHEN fm.Account_No = '0' THEN fm.Office_Account
                    ELSE fm.Account_No 
                END
            ) = acc.Account_No
WHERE  
    fm.LE_Book BETWEEN '400' AND '999'
    AND fm.Year_Month >= '202301'
    AND acc.Account_Type IN ('CAA','SBA','TDA','SED','TRUSTAC')
GROUP BY  
    fm.Country,
    fm.LE_Book,
    fm.Year_Month,
    fm.Customer_Id
