SELECT 
                                            Year,
                                            LE_Book,
                                            CATEGORY_TYPE,
                                            Stakeholder_Name,
                                            Month_Number,
                                            SUM(Balance_Value) AS "Investment_in_equity_shares"
                                        FROM (
                                            SELECT 
                                                Fin_History_Headers.Year AS Year,
                                                Fin_History_Headers.LE_Book AS LE_Book,
                                                (
                                                    SELECT Le_Book.CATEGORY_TYPE
                                                    FROM VISION.Le_Book 
                                                    WHERE Le_Book.Country = Fin_History_Headers.Country 
                                                      AND Le_Book.Le_Book = Fin_History_Headers.Le_Book
                                                ) AS CATEGORY_TYPE,
                                                (
                                                    SELECT Leb_Description 
                                                    FROM VISION.Le_Book 
                                                    WHERE Le_Book.Country = Fin_History_Headers.Country 
                                                      AND Le_Book.Le_Book = Fin_History_Headers.Le_Book
                                                ) AS Stakeholder_Name,
                                                Fin_History_Balances.Balance_01,
                                                Fin_History_Balances.Balance_02,
                                                Fin_History_Balances.Balance_03,
                                                Fin_History_Balances.Balance_04,
                                                Fin_History_Balances.Balance_05,
                                                Fin_History_Balances.Balance_06,
                                                Fin_History_Balances.Balance_07,
                                                Fin_History_Balances.Balance_08,
                                                Fin_History_Balances.Balance_09,
                                                Fin_History_Balances.Balance_10,
                                                Fin_History_Balances.Balance_11,
                                                Fin_History_Balances.Balance_12
                                            FROM 
                                                VISION.FIN_HISTORY_HEADERS Fin_History_Headers
                                            JOIN 
                                                VISION.FIN_HISTORY_BALANCES Fin_History_Balances 
                                                ON Fin_History_Headers.Country = Fin_History_Balances.Country 
                                                AND Fin_History_Headers.LE_Book = Fin_History_Balances.LE_Book 
                                                AND Fin_History_Headers.Year = Fin_History_Balances.Year 
                                                AND Fin_History_Headers.SEQUENCE_FH = Fin_History_Balances.SEQUENCE_FH 
                                                AND Fin_History_Headers.RECORD_TYPE != 9999
                                            JOIN 
                                                VISION.FRL_EXPANDED FRL_EXPANDED_BS 
                                                ON Fin_History_Headers.FRL_LINE_BS = FRL_Expanded_BS.SOURCE_FRL_LINE 
                                                AND Fin_History_Balances.BAL_TYPE = FRL_Expanded_BS.SOURCE_BAL_TYPE 
                                                AND Fin_History_Headers.RECORD_TYPE != 9999
                                            WHERE 
                                                Fin_History_Headers.Year = '2025'
                                                AND Fin_History_Balances.Bal_Type = 1
                                                AND (
                                                    SELECT Le_Book.CATEGORY_TYPE
                                                    FROM VISION.Le_Book 
                                                    WHERE Le_Book.Country = Fin_History_Headers.Country 
                                                      AND Le_Book.Le_Book = Fin_History_Headers.Le_Book
                                                ) IN ('MF','SACCO','OSACCO','DSACCO')
                                                AND FRL_Expanded_BS.FRL_Line IN ('F1210010','F1210015')
                                        )
                                        UNPIVOT (
                                            Balance_Value FOR Month_Number IN (
                                                Balance_01 AS 1,
                                                Balance_02 AS 2,
                                                Balance_03 AS 3,
                                                Balance_04 AS 4,
                                                Balance_05 AS 5,
                                                Balance_06 AS 6,
                                                Balance_07 AS 7,
                                                Balance_08 AS 8,
                                                Balance_09 AS 9,
                                                Balance_10 AS 10,
                                                Balance_11 AS 11,
                                                Balance_12 AS 12
                                            )
                                        )
                                        GROUP BY 
                                            Year,
                                            LE_Book,
                                            CATEGORY_TYPE,
                                            Stakeholder_Name,
                                            Month_Number
                                        ORDER BY 
                                            Year,
                                            LE_Book,
                                            Month_Number;