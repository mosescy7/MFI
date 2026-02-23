-- ============================================================================
-- OTHER PRUDENTIAL NORMS - CONSOLIDATED (replaces 6 individual queries)
-- ============================================================================
-- Purpose:   Computes 6 prudential norm metrics per LE_Book per month in a
--            single query. Each metric is a ratio to core capital or total assets.
--
--   PNR  Metric                          Limit           Denominator
--   ---  ------------------------------  --------------  ---------------------
--   13   Investment in fixed assets       Max 50%         Core capital (SACCOs: total equity)
--   14   Land and buildings               Max 5%          Total assets
--   15   Non-earning assets               Max 10%         Total assets
--   16   Borrowing ratio                  Max 25%         Core capital (SACCOs: total equity)
--   17   Placement limits                 Max 25%         Core capital (SACCOs: total equity)
--   18   Investment in equity shares      Max 25%         Core capital (SACCOs: total equity)
--
-- Output:    One row per LE_Book / Year_Month with all 6 metric amounts.
--            Ratios computed in Power BI by joining with CAR data for capital
--            and total assets.
--
-- Sources:   VISION.FIN_HISTORY_HEADERS   (financial history headers)
--            VISION.FIN_HISTORY_BALANCES   (monthly balance columns)
--            VISION.FRL_EXPANDED           (FRL line mapping)
--            VISION.Le_Book                (entity metadata: name, category)
--
-- Filters:   CATEGORY_TYPE IN (MF, SACCO, OSACCO, DSACCO)
--            Rolling 12 months from today
--            Bal_Type = 1 (actual balances)
-- ============================================================================

WITH UnpivotedData AS (
    SELECT
        Year,
        LE_Book,
        CATEGORY_TYPE,
        Stakeholder_Name,
        FRL_Line,
        Month_Number,
        Balance_Value,
        Year || LPAD(TO_CHAR(Month_Number), 2, '0') AS Year_Month
    FROM (
        SELECT
            fhh.Year,
            fhh.LE_Book,
            lb.CATEGORY_TYPE,
            lb.Leb_Description AS Stakeholder_Name,
            frl.FRL_Line,
            fhb.Balance_01, fhb.Balance_02, fhb.Balance_03,
            fhb.Balance_04, fhb.Balance_05, fhb.Balance_06,
            fhb.Balance_07, fhb.Balance_08, fhb.Balance_09,
            fhb.Balance_10, fhb.Balance_11, fhb.Balance_12
        FROM
            VISION.FIN_HISTORY_HEADERS fhh
        JOIN
            VISION.FIN_HISTORY_BALANCES fhb
                ON fhh.Country = fhb.Country
                AND fhh.LE_Book = fhb.LE_Book
                AND fhh.Year = fhb.Year
                AND fhh.SEQUENCE_FH = fhb.SEQUENCE_FH
        JOIN
            VISION.FRL_EXPANDED frl
                ON fhh.FRL_LINE_BS = frl.SOURCE_FRL_LINE
                AND fhb.BAL_TYPE = frl.SOURCE_BAL_TYPE
        JOIN
            VISION.Le_Book lb
                ON lb.Country = fhh.Country
                AND lb.Le_Book = fhh.Le_Book
        WHERE
            fhh.RECORD_TYPE != 9999
            AND fhb.Bal_Type = 1
            -- Include years that may contain data in the last 12 months
            AND fhh.Year >= TO_CHAR(ADD_MONTHS(SYSDATE, -12), 'YYYY')
            AND lb.CATEGORY_TYPE IN ('MF','SACCO','OSACCO','DSACCO')
            -- All FRL codes across all 6 metrics (union of all)
            AND frl.FRL_Line IN (
                'F1700010',  /* Land */
                'F1700015',  /* Properties, Buildings and Offices */
                'F1700016',  /* Accumulated Dep. - Properties, Buildings And Offices */
                'F1700025',  /* Equipments, Furniture and IT */
                'F1700026',  /* Accumulated Dep. - Equipment, Furniture And It */
                'F1700030',  /* Vehicles */
                'F1700031',  /* Accumulated Dep. - Vehicles */
                'F1700035',  /* Refurbishment and Installation */
                'F1700036',  /* Accumulated Dep. - Refurbishment And Installation */
                'F1700040',  /* Other tangible fixed assets */
                'F1700041',  /* Accumulated Dep. - Other Tangible Fixed Assets */
                'F1700050',  /* Property, Plant and Equipment */
                'F1700051',  /* Accumulated Dep. - Property, Plant And Equipment */
                'F1700056',  /* Accumulated Dep. - Investment Property */
                'F1700060',  /* Fixed Assets in progress */
                'F1700065',  /* WIP Buildings */
                'F1700071',  /* Accumulated Dep. - WIP Motor vehicle */
                'F1700080',  /* WIP Softwares */
                'F1700081',  /* Accumulated Dep. - WIP Software */
                'F1700105',  /* WIP Computer Equipment */
                'F1700160',  /* Machines Asset Clearing */
                'F1700320',  /* Building of Placement */
                'F1700410',  /* Depreciation of fixed tangible assets */
                'F1700610',  /* Amortization Software */
                'F1700690',  /* Other Intangible assets */
                'F1120317',  /* Fixed Term Deposits With Banks In Rwanda (LCY) */
                'F1120319',  /* Fixed Term Deposits With Banks In Rwanda (FCY) */
                'F1120365',  /* Accrual receivable interests with the banks & other FI (LCY) */
                'F1200230',  /* Suspended interests (LCY) */
                'F1200250',  /* Accrual receivable interests (LCY) */
                'F1200315',  /* Other debt securities */
                'F1200510',  /* Treasury Bills HTM */
                'F1200511',  /* Government ,Treasury Bonds HTM */
                'F1200520',  /* Accrual receivable interests on financial instruments HTM */
                'F1210010',  /* Equity investment */
                'F1210015',  /* Investment in subsidiaries */
                'F1210440',  /* Accrual receivable interests */
                'F1500010',  /* Overdrawn Accounts (LCY) */
                'F1500011',  /* Provisions on NPL Overdrawn accounts(LCY) */
                'F1500012',  /* Non performing Overdrwawn accounts(LCY) */
                'F1500016',  /* Suspended Interest on Overdrawn A/C (LCY) */
                'F1500017',  /* Suspended Interest on Overdrawn A/C (FCY) */
                'F1500085',  /* Term treasury loans (LCY) */
                'F1500086',  /* Non performing loans Treasury Loans(LCY) */
                'F1500087',  /* Provisions on NPL Treasury Loans(LCY) */
                'F1500088',  /* Suspended Interest on Treasury Loans (LCY) */
                'F1500135',  /* Other Treasury Loans (LCY) */
                'F1500145',  /* Accrual Receivable Interest on Treasury Loans (LCY) */
                'F1500210',  /* Equipment loans (LCY) */
                'F1500211',  /* Non performing loans Equipment Loans(LCY) */
                'F1500212',  /* Provisions on NPL Equipment Loans(LCY) */
                'F1500213',  /* Suspended Interest on Equipment Loans (LCY) */
                'F1500310',  /* Accrual Receivable Interest on Equipment Loans (LCY) */
                'F1500410',  /* Consumer loans (LCY) */
                'F1500411',  /* Non performing loans Consumer Loans(LCY) */
                'F1500412',  /* Provisions on NPL Consumer Loans(LCY) */
                'F1500413',  /* Suspended Interests On Consumer Loans (LCY) */
                'F1500422',  /* Provisions on NPL Consumer Loans(FCY) */
                'F1500480',  /* Accrual Receivable Interests on Consumer Loans (LCY) */
                'F1500510',  /* Mortgage Loans (LCY) */
                'F1500511',  /* Non performing loans Mortgage Loan (LCY) */
                'F1500512',  /* Provisions on NPL Mortgage Loan(LCY) */
                'F1500513',  /* Suspended Interests on Mortgage Loan (LCY) */
                'F1500550',  /* Accrual Receivable Interests on Mortgage Loan (LCY) */
                'F1500612',  /* Provisions on NPL Finance Lease(LCY) */
                'F1500690',  /* Accrual Receivable Interests on Finance Lease (LCY) */
                'F1500815',  /* Loans To The Agriculture Sector And Agro Business Sector */
                'F1500830',  /* Loans And Advances To Staff */
                'F1500860',  /* Salary Advance */
                'F1500980',  /* Other Loans of Clients (LCY) */
                'F1501030',  /* Accrual Receivable Interests on other Loans of Clients (LCY) */
                'F1501040',  /* Other loans and advances */
                'F2110260',  /* Subordinated borrowings (LCY) */
                'F2120010',  /* Central Bank */
                'F2120070',  /* Due to banks In Rwanda */
                'F2120080',  /* Due to other institutions classified as banks and other FI */
                'F2120155',  /* Term treasury borrowings (LCY) */
                'F2120175',  /* Overnight treasury borrowings (LCY) */
                'F2120350',  /* Finance borrowings to banks and other FI (LCY) */
                'F2120355',  /* Finance borrowings to banks and other FI (FCY) */
                'F2120420',  /* Finance borrowings Subsidiaries (LCY) */
                'F2150315'  /* Intergroup Operations With Parents, Subsidiaries And Branches */
            )
    )
    UNPIVOT (
        Balance_Value FOR Month_Number IN (
            Balance_01 AS 1,  Balance_02 AS 2,  Balance_03 AS 3,
            Balance_04 AS 4,  Balance_05 AS 5,  Balance_06 AS 6,
            Balance_07 AS 7,  Balance_08 AS 8,  Balance_09 AS 9,
            Balance_10 AS 10, Balance_11 AS 11, Balance_12 AS 12
        )
    )
    -- Fine-grained filter: only months within the last 12 months
    WHERE
        Year || LPAD(TO_CHAR(Month_Number), 2, '0') >= TO_CHAR(ADD_MONTHS(SYSDATE, -12), 'YYYYMM')
        AND Year || LPAD(TO_CHAR(Month_Number), 2, '0') <= TO_CHAR(SYSDATE, 'YYYYMM')
)
-- Final: One row per LE_Book/month with all 6 metrics as columns
SELECT
    LE_Book,
    Year_Month,
    CATEGORY_TYPE,
    Stakeholder_Name,

    -- PNR13: Investment in fixed assets (Max 50% of core capital)
    SUM(CASE WHEN FRL_Line IN (
        'F1700010',  /* Land */
        'F1700015',  /* Properties, Buildings and Offices */
        'F1700016',  /* Accumulated Dep. - Properties, Buildings And Offices */
        'F1700025',  /* Equipments, Furniture and IT */
        'F1700026',  /* Accumulated Dep. - Equipment, Furniture And It */
        'F1700030',  /* Vehicles */
        'F1700031',  /* Accumulated Dep. - Vehicles */
        'F1700035',  /* Refurbishment and Installation */
        'F1700036',  /* Accumulated Dep. - Refurbishment And Installation */
        'F1700040',  /* Other tangible fixed assets */
        'F1700041',  /* Accumulated Dep. - Other Tangible Fixed Assets */
        'F1700050',  /* Property, Plant and Equipment */
        'F1700051',  /* Accumulated Dep. - Property, Plant And Equipment */
        'F1700056',  /* Accumulated Dep. - Investment Property */
        'F1700060',  /* Fixed Assets in progress */
        'F1700065',  /* WIP Buildings */
        'F1700071',  /* Accumulated Dep. - WIP Motor vehicle */
        'F1700080',  /* WIP Softwares */
        'F1700081',  /* Accumulated Dep. - WIP Software */
        'F1700105',  /* WIP Computer Equipment */
        'F1700160',  /* Machines Asset Clearing */
        'F1700320',  /* Building of Placement */
        'F1700410',  /* Depreciation of fixed tangible assets */
        'F1700610',  /* Amortization Software */
        'F1700690'  /* Other Intangible assets */
    )

    -- PNR14: Land and buildings (Max 5% of total assets)
    SUM(CASE WHEN FRL_Line IN (
        'F1700010',  /* Land */
        'F1700015',  /* Properties, Buildings and Offices */
        'F1700016',  /* Accumulated Dep. - Properties, Buildings And Offices */
        'F1700035',  /* Refurbishment and Installation */
        'F1700036',  /* Accumulated Dep. - Refurbishment And Installation */
        'F1700050',  /* Property, Plant and Equipment */
        'F1700051',  /* Accumulated Dep. - Property, Plant And Equipment */
        'F1700320'  /* Building of Placement */
    )

    -- PNR15: Non-earning assets (Max 10% of total assets)
    SUM(CASE WHEN FRL_Line IN (
        'F1120317',  /* Fixed Term Deposits With Banks In Rwanda (LCY) */
        'F1120319',  /* Fixed Term Deposits With Banks In Rwanda (FCY) */
        'F1120365',  /* Accrual receivable interests with the banks & other FI (LCY) */
        'F1200230',  /* Suspended interests (LCY) */
        'F1200250',  /* Accrual receivable interests (LCY) */
        'F1200315',  /* Other debt securities */
        'F1200510',  /* Treasury Bills HTM */
        'F1200511',  /* Government ,Treasury Bonds HTM */
        'F1200520',  /* Accrual receivable interests on financial instruments HTM */
        'F1210010',  /* Equity investment */
        'F1210015',  /* Investment in subsidiaries */
        'F1210440',  /* Accrual receivable interests */
        'F1500010',  /* Overdrawn Accounts (LCY) */
        'F1500011',  /* Provisions on NPL Overdrawn accounts(LCY) */
        'F1500012',  /* Non performing Overdrwawn accounts(LCY) */
        'F1500016',  /* Suspended Interest on Overdrawn A/C (LCY) */
        'F1500017',  /* Suspended Interest on Overdrawn A/C (FCY) */
        'F1500085',  /* Term treasury loans (LCY) */
        'F1500086',  /* Non performing loans Treasury Loans(LCY) */
        'F1500087',  /* Provisions on NPL Treasury Loans(LCY) */
        'F1500088',  /* Suspended Interest on Treasury Loans (LCY) */
        'F1500135',  /* Other Treasury Loans (LCY) */
        'F1500145',  /* Accrual Receivable Interest on Treasury Loans (LCY) */
        'F1500210',  /* Equipment loans (LCY) */
        'F1500211',  /* Non performing loans Equipment Loans(LCY) */
        'F1500212',  /* Provisions on NPL Equipment Loans(LCY) */
        'F1500213',  /* Suspended Interest on Equipment Loans (LCY) */
        'F1500310',  /* Accrual Receivable Interest on Equipment Loans (LCY) */
        'F1500410',  /* Consumer loans (LCY) */
        'F1500411',  /* Non performing loans Consumer Loans(LCY) */
        'F1500412',  /* Provisions on NPL Consumer Loans(LCY) */
        'F1500413',  /* Suspended Interests On Consumer Loans (LCY) */
        'F1500422',  /* Provisions on NPL Consumer Loans(FCY) */
        'F1500480',  /* Accrual Receivable Interests on Consumer Loans (LCY) */
        'F1500510',  /* Mortgage Loans (LCY) */
        'F1500511',  /* Non performing loans Mortgage Loan (LCY) */
        'F1500512',  /* Provisions on NPL Mortgage Loan(LCY) */
        'F1500513',  /* Suspended Interests on Mortgage Loan (LCY) */
        'F1500550',  /* Accrual Receivable Interests on Mortgage Loan (LCY) */
        'F1500612',  /* Provisions on NPL Finance Lease(LCY) */
        'F1500690',  /* Accrual Receivable Interests on Finance Lease (LCY) */
        'F1500815',  /* Loans To The Agriculture Sector And Agro Business Sector */
        'F1500830',  /* Loans And Advances To Staff */
        'F1500860',  /* Salary Advance */
        'F1500980',  /* Other Loans of Clients (LCY) */
        'F1501030',  /* Accrual Receivable Interests on other Loans of Clients (LCY) */
        'F1501040'  /* Other loans and advances */
    )

    -- PNR16: Borrowing ratio (Max 25% of core capital)
    SUM(CASE WHEN FRL_Line IN (
        'F2110260',  /* Subordinated borrowings (LCY) */
        'F2120010',  /* Central Bank */
        'F2120070',  /* Due to banks In Rwanda */
        'F2120080',  /* Due to other institutions classified as banks and other FI */
        'F2120155',  /* Term treasury borrowings (LCY) */
        'F2120175',  /* Overnight treasury borrowings (LCY) */
        'F2120350',  /* Finance borrowings to banks and other FI (LCY) */
        'F2120355',  /* Finance borrowings to banks and other FI (FCY) */
        'F2120420',  /* Finance borrowings Subsidiaries (LCY) */
        'F2150315'  /* Intergroup Operations With Parents, Subsidiaries And Branches */
    )

    -- PNR17: Placement limits (Max 25% of core capital)
    SUM(CASE WHEN FRL_Line IN (
        'F1120317',  /* Fixed Term Deposits With Banks In Rwanda (LCY) */
        'F1120319'  /* Fixed Term Deposits With Banks In Rwanda (FCY) */
    )

    -- PNR18: Investment in equity shares (Max 25% of core capital)
    SUM(CASE WHEN FRL_Line IN (
        'F1210010',  /* Equity investment */
        'F1210015'  /* Investment in subsidiaries */
    )

FROM UnpivotedData
GROUP BY
    LE_Book,
    Year_Month,
    CATEGORY_TYPE,
    Stakeholder_Name
ORDER BY
    LE_Book,
    Year_Month
