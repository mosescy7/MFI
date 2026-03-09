-- NOP (Net Open Position) Data Query
-- Calculates foreign currency net open position and ratio to Tier 1 capital
-- FRL_ATTRIBUTE_07 codes classify FC assets and liabilities per MFSD prudential norms
--
-- Output columns:
--   LE_BOOK          - Legal entity / book code
--   YEAR_MONTH       - Period in YYYYMM format
--   FRL_ATTRIBUTE_07 - FRL position code
--   Values           - Balance amount in LCY
--   AMOUNT_CAR       - Tier 1 core capital for the period
--   NOP_POSITION_NET - Net open position (FC assets - FC liabilities)
--   NOP_RATIO        - ABS(NOP_POSITION_NET) / AMOUNT_CAR

WITH nop_raw AS (
    SELECT
        fhh.LE_BOOK,
        fhh.Year || LPAD(TO_CHAR(fhh.Month_Number), 2, '0') AS YEAR_MONTH,
        frl.FRL_ATTRIBUTE_07,
        col.Balance_Value                                     AS "Values"
    FROM VISION.FIN_HISTORY_HEADERS fhh
    JOIN VISION.FIN_HISTORY_BALANCES fhb
        ON fhh.Header_ID = fhb.Header_ID
    JOIN VISION.FRL_EXPANDED frl
        ON fhb.FRL_Code = frl.FRL_Code
    -- Inline UNPIVOT: return one row for the current month column
    CROSS JOIN LATERAL (
        SELECT fhb.Balance_1  AS Balance_Value FROM DUAL WHERE fhh.Month_Number = 1  UNION ALL
        SELECT fhb.Balance_2  FROM DUAL WHERE fhh.Month_Number = 2  UNION ALL
        SELECT fhb.Balance_3  FROM DUAL WHERE fhh.Month_Number = 3  UNION ALL
        SELECT fhb.Balance_4  FROM DUAL WHERE fhh.Month_Number = 4  UNION ALL
        SELECT fhb.Balance_5  FROM DUAL WHERE fhh.Month_Number = 5  UNION ALL
        SELECT fhb.Balance_6  FROM DUAL WHERE fhh.Month_Number = 6  UNION ALL
        SELECT fhb.Balance_7  FROM DUAL WHERE fhh.Month_Number = 7  UNION ALL
        SELECT fhb.Balance_8  FROM DUAL WHERE fhh.Month_Number = 8  UNION ALL
        SELECT fhb.Balance_9  FROM DUAL WHERE fhh.Month_Number = 9  UNION ALL
        SELECT fhb.Balance_10 FROM DUAL WHERE fhh.Month_Number = 10 UNION ALL
        SELECT fhb.Balance_11 FROM DUAL WHERE fhh.Month_Number = 11 UNION ALL
        SELECT fhb.Balance_12 FROM DUAL WHERE fhh.Month_Number = 12
    ) col
    WHERE frl.FRL_ATTRIBUTE_07 IN (
        -- FC Asset positions
        'FA071010',  -- FC Cash & balances with central bank
        'FA071015',  -- FC Placements with banks (assets)
        'FA071020',  -- FC Loans & advances
        'FA071025',  -- FC Investment securities
        'FA071040',  -- FC Other assets
        'FA071055',  -- FC Fixed assets
        'FA071080',  -- FC Other FC assets
        -- FC Liability positions
        'FA078010',  -- FC Deposits from customers
        'FA078015',  -- FC Borrowings & placements (liabilities)
        -- Off-balance / other FC positions
        'FA072025',  -- FC Off-balance sheet assets
        'FA072070',  -- FC Off-balance sheet liabilities
        'FA079035'   -- FC Other liabilities
    )
),

-- Aggregate to LE_BOOK / YEAR_MONTH / FRL_ATTRIBUTE_07
nop_agg AS (
    SELECT
        LE_BOOK,
        YEAR_MONTH,
        FRL_ATTRIBUTE_07,
        SUM("Values") AS "Values"
    FROM nop_raw
    GROUP BY LE_BOOK, YEAR_MONTH, FRL_ATTRIBUTE_07
),

-- Compute net open position per LE_BOOK / YEAR_MONTH
nop_net AS (
    SELECT
        LE_BOOK,
        YEAR_MONTH,
        SUM(CASE WHEN FRL_ATTRIBUTE_07 IN (
                'FA071010','FA071015','FA071020','FA071025',
                'FA071040','FA071055','FA071080','FA072025'
            ) THEN "Values" ELSE 0 END)                         AS FC_ASSETS,
        SUM(CASE WHEN FRL_ATTRIBUTE_07 IN (
                'FA078010','FA078015','FA072070','FA079035'
            ) THEN "Values" ELSE 0 END)                         AS FC_LIABILITIES,
        SUM(CASE WHEN FRL_ATTRIBUTE_07 IN (
                'FA071010','FA071015','FA071020','FA071025',
                'FA071040','FA071055','FA071080','FA072025'
            ) THEN "Values" ELSE 0 END)
      - SUM(CASE WHEN FRL_ATTRIBUTE_07 IN (
                'FA078010','FA078015','FA072070','FA079035'
            ) THEN "Values" ELSE 0 END)                         AS NOP_POSITION_NET
    FROM nop_agg
    GROUP BY LE_BOOK, YEAR_MONTH
),

-- Tier 1 / Core capital (GL_Type = '30')
capital AS (
    SELECT
        fm.LE_BOOK,
        fm.YEAR_MONTH,
        SUM(fm.Amount_Lcy) AS AMOUNT_CAR
    FROM VISION.FINANCIAL_MONTHLY fm
    JOIN VISION.GL_Codes gc
        ON fm.GL_Code = gc.GL_Code
    WHERE gc.GL_Type = '30'
    GROUP BY fm.LE_BOOK, fm.YEAR_MONTH
)

-- Final: detail rows per FRL code enriched with capital and NOP ratio
SELECT
    n.LE_BOOK,
    n.YEAR_MONTH,
    n.FRL_ATTRIBUTE_07,
    n."Values",
    c.AMOUNT_CAR,
    nn.NOP_POSITION_NET,
    CASE
        WHEN c.AMOUNT_CAR IS NULL OR c.AMOUNT_CAR = 0 THEN NULL
        ELSE ABS(nn.NOP_POSITION_NET) / c.AMOUNT_CAR
    END AS NOP_RATIO
FROM nop_agg n
LEFT JOIN capital  c  ON n.LE_BOOK = c.LE_BOOK  AND n.YEAR_MONTH = c.YEAR_MONTH
LEFT JOIN nop_net  nn ON n.LE_BOOK = nn.LE_BOOK AND n.YEAR_MONTH = nn.YEAR_MONTH
ORDER BY
    n.LE_BOOK,
    n.YEAR_MONTH,
    n.FRL_ATTRIBUTE_07
