SELECT 
    fm.LE_Book AS LE_Book,
    gc.GL_Type AS GL_Type,
    fm.Year_Month,
    SUM(fm.Amount_Lcy) AS Amount_Lcy
FROM 
    VISION.FINANCIAL_MONTHLY fm
JOIN 
    VISION.GL_Codes gc 
    ON fm.Country = gc.Country 
    AND fm.LE_Book = gc.LE_Book 
    AND fm.Vision_Gl = gc.Vision_Gl
WHERE  
    fm.LE_Book BETWEEN '500' AND '999'  
    AND fm.Year_Month >= '202501'
    AND gc.GL_Type IN ('10', '20', '30')
GROUP BY  
    fm.LE_Book, gc.GL_Type, fm.Year_Month
ORDER BY 
    fm.Year_Month
