-- ============================================================================
-- TOTAL ASSETS
-- ============================================================================
-- Purpose:   Total assets per LE_Book per month (sum of all asset FRL lines).
-- Sources:   VISION.FIN_HISTORY_HEADERS, FIN_HISTORY_BALANCES, FRL_EXPANDED, Le_Book
-- Filters:   CATEGORY_TYPE IN (MF, SACCO, OSACCO, DSACCO), rolling 12 months
-- Note:      F1999999 returns no data for MFIs, so all individual asset
--            FRL lines are used instead.
-- ============================================================================

SELECT
    Year,
    LE_Book,
    Year || LPAD(TO_CHAR(Month_Number), 2, '0') AS Year_Month,
    SUM(Balance_Value) AS Total_Assets
FROM (
    SELECT
        fhh.Year,
        fhh.LE_Book,
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
        AND fhh.Year >= TO_CHAR(ADD_MONTHS(SYSDATE, -12), 'YYYY')
        AND lb.CATEGORY_TYPE IN ('MF','SACCO','OSACCO','DSACCO')
        AND frl.FRL_Line IN (

            /* ======== Cash Balances ======== */
            'F1110010',  /* Cash In Hand (LCY) */
            'F1110020',  /* Cash In Hand (FCY) */
            'F1110030',  /* Cash In Vault (LCY) */
            'F1110040',  /* Cash In Vault (FCY) */
            'F1110050',  /* Cash In ATM (LCY) */
            'F1110060',  /* Cash In ATM (FCY) */
            'F1110070',  /* Cash In Transit (LCY) */
            'F1110080',  /* Cash In Transit (FCY) */
            'F1110090',  /* Cash and cash equivalents */
            'F1110100',  /* Cash items in process of collection LCY */
            'F1110110',  /* Cash items in process of collection FCY */
            'F1110120',  /* Precious Metal */

            /* ======== Balances with Central Bank ======== */
            'F1120210',  /* Balances with Central Bank (LCY) */
            'F1120220',  /* Balances with Central Bank (FCY) */
            'F1120230',  /* Regulatory Reserve with Central Bank */
            'F1120290',  /* Other demand deposits with BNR */

            /* ======== Balances with Banks and Other FIs ======== */
            'F1120310',  /* Balances with Banks in Rwanda (LCY) */
            'F1120315',  /* Balances with Banks in Rwanda (FCY) */
            'F1120317',  /* Fixed Term Deposits With Banks In Rwanda (LCY) */
            'F1120319',  /* Fixed Term Deposits With Banks In Rwanda (FCY) */
            'F1120320',  /* Balances with Other FI (LCY) */
            'F1120325',  /* Balances with Other FI (FCY) */
            'F1120330',  /* Balances with assimilated banks in Rwanda (LCY) */
            'F1120335',  /* Balances with assimilated banks in Rwanda (FCY) */
            'F1120340',  /* Postal Accounts (LCY) */
            'F1120345',  /* Postal Accounts (FCY) */
            'F1120350',  /* Due from Central Banks, banks & FI abroad (LCY) */
            'F1120355',  /* Due from Central Banks, banks & FI abroad (FCY) */
            'F1120360',  /* Other demand deposits abroad */
            'F1120365',  /* Accrual receivable interests with banks (LCY) */
            'F1120370',  /* Accrual receivable interests with banks (FCY) */

            /* ======== Nostro Accounts ======== */
            'F1120410',  /* Nostro USD */
            'F1120415',  /* Nostro GBP */
            'F1120420',  /* Nostro EUR */
            'F1120425',  /* Nostro JPY */
            'F1120430',  /* Nostro ZAR */
            'F1120435',  /* Nostro CHF */
            'F1120440',  /* Nostro CNY */
            'F1120445',  /* Nostro Other Currencies */
            'F1120450',  /* Nostro Local Banks */

            /* ======== Fixed Term Deposits Abroad ======== */
            'F1120510',  /* Fixed Term Deposits Abroad USD */
            'F1120515',  /* Fixed Term Deposits Abroad GBP */
            'F1120520',  /* Fixed Term Deposits Abroad EUR */
            'F1120525',  /* Fixed Term Deposits Abroad JPY */
            'F1120530',  /* Fixed Term Deposits Abroad ZAR */
            'F1120535',  /* Fixed Term Deposits Abroad CHF */
            'F1120540',  /* Fixed Term Deposits Abroad CNY */
            'F1120545',  /* Fixed Term Deposits Abroad Other Currencies */

            /* ======== IMF and Govt Debts ======== */
            'F1120610',  /* IMF Quota */
            'F1120615',  /* Due from Government of Rwanda */
            'F1120620',  /* Consolidated Debt to Government */
            'F1120625',  /* Interest on Government Overdraft */

            /* ======== Reverse Repo, Loans & OD ======== */
            'F1150010',  /* Overnight reverse repo BNR */
            'F1150015',  /* Overnight reverse repo Other Banks */
            'F1150020',  /* Term reverse repo BNR */
            'F1150025',  /* Term reverse repo Other Banks */
            'F1150030',  /* Clients reverse repo (LCY) */
            'F1150035',  /* Clients reverse repo (FCY) */
            'F1150040',  /* Finance loans to banks (LCY) */
            'F1150045',  /* Finance loans to banks (FCY) */
            'F1150050',  /* Subordinated loans to banks (LCY) */
            'F1150055',  /* Subordinated loans to banks (FCY) */
            'F1150060',  /* Other overdrawn accounts (LCY) */
            'F1150065',  /* Other overdrawn accounts (FCY) */
            'F1150070',  /* Accrual receivable interest on REPO (LCY) */
            'F1150075',  /* Accrual receivable interest on REPO (FCY) */

            /* ======== Financial Assets at Fair Value ======== */
            'F1150110',  /* Sovereigns and Central Banks */
            'F1150115',  /* Non Central Govt PSEs */
            'F1150120',  /* MDBs */
            'F1150125',  /* Group Bank */
            'F1150130',  /* Group non-bank entities */
            'F1150135',  /* Other banks */
            'F1150140',  /* Non-Financial Corp Industrial */
            'F1150145',  /* Non-Financial Corp Financial Intermediaries */
            'F1150150',  /* Non-Financial Corp Securities Firms */

            /* ======== Assets in Union Credit Group ======== */
            'F1150210',  /* Assets in Union Credit Group (LCY) */
            'F1150220',  /* Assets in Union Credit Group (FCY) */

            /* ======== Inter-group Operations ======== */
            'F1200010',  /* Due from inter-group (LCY) */
            'F1200020',  /* Due from inter-group (FCY) */
            'F1200030',  /* Finances with Subsidiaries Abroad (LCY) */
            'F1200040',  /* Finances with Subsidiaries Abroad (FCY) */
            'F1200050',  /* Loans and receivables Insurers */
            'F1200060',  /* Loans and receivables RDB */

            /* ======== Receivables in Transit ======== */
            'F1200110',  /* Receivables in transit Travellers Cheque */
            'F1200120',  /* Receivables in transit unpaid cheques */
            'F1200130',  /* Other receivables in transit payment */
            'F1200140',  /* Other receivables in transit */

            /* ======== Non Performing Debts ======== */
            'F1200210',  /* Substandard/doubtful/loss loans (LCY) */
            'F1200220',  /* Substandard/doubtful/loss loans (FCY) */
            'F1200230',  /* Suspended interests (LCY) */
            'F1200240',  /* Suspended interests (FCY) */
            'F1200250',  /* Accrual receivable interests (LCY) */
            'F1200260',  /* Accrual receivable interests (FCY) */

            /* ======== Financial Instruments AFS ======== */
            'F1200310',  /* Treasury Bills AFS */
            'F1200311',  /* Debt Securities HTM Unquoted */
            'F1200312',  /* Debt Securities HTM quoted */
            'F1200313',  /* Debt Securities */
            'F1200314',  /* Accr interests on HTM */
            'F1200315',  /* Other debt securities */
            'F1200320',  /* Securities of portfolio activity */
            'F1200325',  /* Other registered securities AFS */
            'F1200330',  /* Accrual receivable interests AFS */
            'F1200335',  /* Sovereigns and Central Banks */
            'F1200340',  /* Non Central Govt PSEs */
            'F1200345',  /* MDBs */
            'F1200350',  /* Group Bank */
            'F1200355',  /* Group Non-Bank Entities */
            'F1200360',  /* Other Banks */
            'F1200365',  /* Non-Financial Corp Industrial */
            'F1200370',  /* Non-Financial Corp Financial Intermediaries */
            'F1200375',  /* Non-Financial Corp Securities Firms */

            /* ======== Financial Instruments HFT ======== */
            'F1200410',  /* Treasury Bills HFT */
            'F1200411',  /* Equities HFT */
            'F1200412',  /* Government Treasury Bonds HFT */
            'F1200420',  /* Other Debt Securities */
            'F1200430',  /* Registered securities */
            'F1200440',  /* Borrowed securities */
            'F1200450',  /* Accrual receivable interests HFT */

            /* ======== Financial Instruments HTM ======== */
            'F1200510',  /* Treasury Bills HTM */
            'F1200511',  /* Government Treasury Bonds HTM */
            'F1200515',  /* Other Debt Securities HTM */
            'F1200520',  /* Accrual receivable interests HTM */
            'F1200525',  /* Central Banks */
            'F1200530',  /* Non Central Govt PSEs */
            'F1200535',  /* MDBs */
            'F1200540',  /* Group Bank */
            'F1200545',  /* Group Non-Bank Entities */
            'F1200550',  /* Other Banks */
            'F1200555',  /* Non-Financial Corp Industrial */
            'F1200560',  /* Non-Financial Corp Financial Intermediaries */

            /* ======== Financial Assets HFT / FVTPL / AFS ======== */
            'F1200610',  /* Government Treasury Bonds HFT */
            'F1200615',  /* Derivatives HTF */
            'F1200620',  /* Equity instruments HFT Quoted */
            'F1200625',  /* Debt securities HTF Quoted */
            'F1200630',  /* Equity instruments HFT Unquoted */
            'F1200635',  /* Debt securities HTF Unquoted */
            'F1200640',  /* Derivatives Pledged as collateral */
            'F1200645',  /* Equity instruments Pledged as collateral */
            'F1200650',  /* Debt securities Pledged as collateral */
            'F1200655',  /* Derivatives FVTPL */
            'F1200660',  /* Equity instruments FVTPL */
            'F1200665',  /* Debt securities FVTPL */
            'F1200670',  /* Government Treasury Bonds AFS */
            'F1200675',  /* Equity instruments AFS Quoted */
            'F1200680',  /* Debt securities AFS Quoted */
            'F1200685',  /* Equity instruments AFS Unquoted */
            'F1200690',  /* Debt securities AFS Unquoted */
            'F1200695',  /* Accrual receivable interests AFS */
            'F1200700',  /* Equity instruments AFS Pledged */
            'F1200705',  /* Debt securities AFS Pledged */

            /* ======== Other Investments ======== */
            'F1210010',  /* Equity investment */
            'F1210015',  /* Investment in subsidiaries */
            'F1210020',  /* Investment in securities/equities */
            'F1210025',  /* Investments in affiliates */
            'F1210030',  /* Investments in properties */
            'F1210035',  /* Allowance to abroad branches */
            'F1210040',  /* Sovereigns And Central Banks */
            'F1210045',  /* Non Central Govt PSEs */
            'F1210050',  /* MDBs */
            'F1210055',  /* Group Bank */
            'F1210060',  /* Group Non-Bank Entities */
            'F1210065',  /* Other Banks */
            'F1210070',  /* Non-Financial Corp Industrial */
            'F1210075',  /* Non-Financial Corp Financial Intermediaries */
            'F1210080',  /* Non-Financial Corp Securities Firms */

            /* ======== Foreign Investments ======== */
            'F1210110',  /* Foreign Investment USD */
            'F1210115',  /* Foreign Investment EUR */
            'F1210120',  /* Foreign Investment GBP */
            'F1210125',  /* Foreign Investment JPY */
            'F1210130',  /* Foreign Investment CNY */
            'F1210135',  /* Foreign Investment CHF */
            'F1210140',  /* Foreign Investment ZAR */
            'F1210190',  /* Foreign Investment Other Ccy */

            /* ======== Covers Receivable ======== */
            'F1210210',  /* Covers Receivable USD */
            'F1210215',  /* Covers Receivable GBP */
            'F1210220',  /* Covers Receivable EUR */
            'F1210225',  /* Covers Receivable JPY */
            'F1210230',  /* Covers Receivable CHF */
            'F1210235',  /* Covers Receivable CNY */
            'F1210240',  /* Covers Receivable ZAR */
            'F1210290',  /* Covers Receivable Other Currencies */

            /* ======== Accrued Interest & Foreign Assets ======== */
            'F1210310',  /* Accrued Interest USD */
            'F1210315',  /* Accrued Interest USD */
            'F1210320',  /* Accrued Interest GBP */
            'F1210325',  /* Accrued Interest EUR */
            'F1210330',  /* Accrued Interest JPY */
            'F1210335',  /* Accrued Interest CHF */
            'F1210340',  /* Accrued Interest CNY */
            'F1210345',  /* Accrued Interest ZAR */
            'F1210350',  /* Accrued Interest Other Currencies */
            'F1210355',  /* Traveller Cheque American Express USD */
            'F1210360',  /* Traveller Cheque American Express EUR */
            'F1210365',  /* Other Foreign Assets */
            'F1210370',  /* Local Assets in Foreign currencies */
            'F1210375',  /* REPSS recovery Accounts */
            'F1210380',  /* Unpaid in DTS */
            'F1210395',  /* Other Local Assets in Foreign Currencies */

            /* ======== Investment NPD & Debt Securities ======== */
            'F1210410',  /* Substandard/doubtful/loss loans */
            'F1210420',  /* Suspended interests */
            'F1210430',  /* Depreciation */
            'F1210440',  /* Accrual receivable interests */
            'F1210510',  /* Deposit receipts */
            'F1210520',  /* Issued deposit certificates */
            'F1210530',  /* Issued Bonds */
            'F1210540',  /* Other issued debt securities */
            'F1210550',  /* Accrual payable interests */

            /* ======== Overdrawn Accounts ======== */
            'F1500010',  /* Overdrawn Accounts (LCY) */
            'F1500011',  /* Provisions on NPL Overdrawn (LCY) */
            'F1500012',  /* Non performing Overdrawn (LCY) */
            'F1500013',  /* Overdraft Accounts (FCY) */
            'F1500014',  /* Provisions on NPL Overdrawn (FCY) */
            'F1500015',  /* Non performing Overdrawn (FCY) */
            'F1500016',  /* Suspended Interest on Overdrawn (LCY) */
            'F1500017',  /* Suspended Interest on Overdrawn (FCY) */

            /* ======== Commercial & Treasury Loans ======== */
            'F1500050',  /* Commercial debts on Rwanda (LCY) */
            'F1500055',  /* Commercial debts on Rwanda (FCY) */
            'F1500060',  /* Factoring Debts (LCY) */
            'F1500065',  /* Factoring Debts (FCY) */
            'F1500070',  /* Export loans (LCY) */
            'F1500075',  /* Export loans (FCY) */
            'F1500080',  /* Overnight Treasury Loans */
            'F1500085',  /* Term treasury loans (LCY) */
            'F1500086',  /* Non performing Treasury Loans (LCY) */
            'F1500087',  /* Provisions on NPL Treasury Loans (LCY) */
            'F1500088',  /* Suspended Interest Treasury Loans (LCY) */
            'F1500090',  /* Term treasury loans (FCY) */
            'F1500091',  /* Non performing Treasury Loans (FCY) */
            'F1500092',  /* Provisions on NPL Treasury Loans (FCY) */
            'F1500093',  /* Suspended Interest Treasury Loans (FCY) */
            'F1500095',  /* Seasonal and Stock Financing (LCY) */
            'F1500100',  /* Seasonal and Stock Financing (FCY) */
            'F1500105',  /* Market Financing Loans (LCY) */
            'F1500110',  /* Market Financing Loans (FCY) */
            'F1500115',  /* Advances on Financial Assets (LCY) */
            'F1500120',  /* Advances on Financial Assets (FCY) */
            'F1500125',  /* Treasury loans Subsidiaries Abroad (LCY) */
            'F1500130',  /* Treasury loans Subsidiaries Abroad (FCY) */
            'F1500135',  /* Other Treasury Loans (LCY) */
            'F1500140',  /* Other Treasury Loans (FCY) */
            'F1500145',  /* Accrual Receivable Interest Treasury (LCY) */
            'F1500150',  /* Accrual Receivable Interest Treasury (FCY) */

            /* ======== Equipment Loans ======== */
            'F1500210',  /* Equipment loans (LCY) */
            'F1500211',  /* Non performing Equipment Loans (LCY) */
            'F1500212',  /* Provisions on NPL Equipment Loans (LCY) */
            'F1500213',  /* Suspended Interest Equipment Loans (LCY) */
            'F1500220',  /* Equipment loans (FCY) */
            'F1500221',  /* Non performing Equipment Loans (FCY) */
            'F1500222',  /* Provisions on NPL Equipment Loans (FCY) */
            'F1500223',  /* Suspended Interest Equipment Loans (FCY) */
            'F1500230',  /* Equipment Loans to Companies (LCY) */
            'F1500240',  /* Equipment Loans to Companies (FCY) */
            'F1500250',  /* Equipment Loans to Local Govt (LCY) */
            'F1500260',  /* Equipment Loans to Local Govt (FCY) */
            'F1500270',  /* Syndicated Equipment Loans (LCY) */
            'F1500280',  /* Syndicated Equipment Loans (FCY) */
            'F1500290',  /* Other Equipment Loans (LCY) */
            'F1500300',  /* Other Equipment Loans (FCY) */
            'F1500310',  /* Accrual Receivable Interest Equipment (LCY) */
            'F1500320',  /* Accrual Receivable Interest Equipment (FCY) */

            /* ======== Consumer Loans ======== */
            'F1500410',  /* Consumer loans (LCY) */
            'F1500411',  /* Non performing Consumer Loans (LCY) */
            'F1500412',  /* Provisions on NPL Consumer Loans (LCY) */
            'F1500413',  /* Suspended Interests Consumer Loans (LCY) */
            'F1500420',  /* Consumer loans (FCY) */
            'F1500421',  /* Non performing Consumer Loans (FCY) */
            'F1500422',  /* Provisions on NPL Consumer Loans (FCY) */
            'F1500423',  /* Suspended Interests Consumer Loans (FCY) */
            'F1500430',  /* Allocated Consumer Loans (LCY) */
            'F1500440',  /* Allocated Consumer Loans (FCY) */
            'F1500450',  /* Non Allocated Consumer Loans (LCY) */
            'F1500460',  /* Non Allocated Consumer Loans (FCY) */
            'F1500470',  /* Retail lending/Consumer Loans Households */
            'F1500480',  /* Accrual Receivable Interests Consumer (LCY) */
            'F1500490',  /* Accrual Receivable Interests Consumer (FCY) */

            /* ======== Mortgage Loans ======== */
            'F1500510',  /* Mortgage Loans (LCY) */
            'F1500511',  /* Non performing Mortgage (LCY) */
            'F1500512',  /* Provisions on NPL Mortgage (LCY) */
            'F1500513',  /* Suspended Interests Mortgage (LCY) */
            'F1500515',  /* Mortgage Loans (FCY) */
            'F1500516',  /* Non performing Mortgage (FCY) */
            'F1500517',  /* Provisions on NPL Mortgage (FCY) */
            'F1500518',  /* Suspended Interests Mortgage (FCY) */
            'F1500520',  /* Residential Mortgage (LCY) */
            'F1500525',  /* Residential Mortgage (FCY) */
            'F1500530',  /* Mortgage Loans to Promoters (LCY) */
            'F1500535',  /* Mortgage Loans To Promoters (FCY) */
            'F1500540',  /* Non-Financial Corp Commercial Mortgages */
            'F1500545',  /* Residential Mortgages Households */
            'F1500550',  /* Accrual Receivable Interests Mortgage (LCY) */
            'F1500555',  /* Accrual Receivable Interests Mortgage (FCY) */

            /* ======== Finance Lease ======== */
            'F1500610',  /* Finance Lease (LCY) */
            'F1500611',  /* Non performing Finance Lease (LCY) */
            'F1500612',  /* Provisions on NPL Finance Lease (LCY) */
            'F1500613',  /* Suspended Interests Finance Lease (LCY) */
            'F1500620',  /* Finance Lease (FCY) */
            'F1500621',  /* Non performing Finance Lease (FCY) */
            'F1500622',  /* Provisions on NPL Finance Lease (FCY) */
            'F1500623',  /* Suspended Interests Finance Lease (FCY) */
            'F1500630',  /* Intangible Fixed Assets Finance Lease (LCY) */
            'F1500640',  /* Intangible Fixed Assets Finance Lease (FCY) */
            'F1500650',  /* Furniture Finance Lease (LCY) */
            'F1500660',  /* Furniture Finance Lease (FCY) */
            'F1500670',  /* Tangible Fixed Assets Finance Lease (LCY) */
            'F1500680',  /* Tangible Fixed Assets Finance Lease (FCY) */
            'F1500690',  /* Accrual Receivable Interests Lease (LCY) */
            'F1500700',  /* Accrual Receivable Interests Lease (FCY) */

            /* ======== Other Loans to Clients and Banks ======== */
            'F1500810',  /* Loans And Advances To Banks */
            'F1500815',  /* Loans To Agriculture & Agro Business */
            'F1500820',  /* Other Loans To Banks */
            'F1500825',  /* Accrued Interest On Loans To Banks */
            'F1500830',  /* Loans And Advances To Staff */
            'F1500835',  /* Car Loans */
            'F1500840',  /* Housing Loans */
            'F1500845',  /* Motorcycle Loans */
            'F1500850',  /* Pension Fund Advance */
            'F1500855',  /* Special Advance */
            'F1500860',  /* Salary Advance */
            'F1500865',  /* Advance To Agaciro */
            'F1500870',  /* Other Advances To Staff In Place */
            'F1500875',  /* Medical Fees To Be Deducted */
            'F1500880',  /* House Insurance To Be Deducted */
            'F1500885',  /* Car Insurance To Be Deducted */
            'F1500890',  /* Medical Fees From Staff */
            'F1500895',  /* Car Insur From Staff */
            'F1500900',  /* House Insur From Staff */
            'F1500905',  /* Loans And Advances To Former Staff */
            'F1500910',  /* Former Staff Car Loans */
            'F1500915',  /* Former Staff Housing Loans */
            'F1500920',  /* Former Staff Motorcycle Loans */
            'F1500925',  /* Former Staff Pension Fund Advance */
            'F1500930',  /* Former Staff Special Advance */
            'F1500935',  /* Former Staff Salary Advance */
            'F1500940',  /* Former Staff Advance To Agaciro */
            'F1500945',  /* Former Staff Other Advances */
            'F1500950',  /* Outstanding On Housing Loan */
            'F1500955',  /* Outstanding On Motor Vehicles Loan */
            'F1500960',  /* Outstanding On Salary Advance */
            'F1500965',  /* Former Staff Medical Fees */
            'F1500970',  /* Former Staff Fire Insurance */
            'F1500975',  /* Former Staff Car Insurance */
            'F1500980',  /* Other Loans of Clients (LCY) */
            'F1500985',  /* Other Loans of Clients (FCY) */
            'F1500990',  /* Reverse Repo with Clients (LCY) */
            'F1500995',  /* Reverse Repo with Clients (FCY) */
            'F1501000',  /* Loans to Financial Clients (LCY) */
            'F1501005',  /* Loans to Financial Clients (FCY) */
            'F1501010',  /* Subordinated Loans to Clients (LCY) */
            'F1501015',  /* Subordinated Loans to Clients (FCY) */
            'F1501020',  /* Other Debts to Clients (LCY) */
            'F1501025',  /* Other Debts to Clients (FCY) */
            'F1501030',  /* Accrual Receivable Interests other Loans (LCY) */
            'F1501035',  /* Accrual Receivable Interests other Loans (FCY) */
            'F1501040',  /* Other loans and advances */
            'F1501041',  /* Due from Insurance Brokers */

            /* ======== Receivables, NPL, Provisions ======== */
            'F1510010',  /* Receivables in transit payment */
            'F1510020',  /* Other Receivables In Transit */
            'F1510110',  /* Non performing loans (LCY) */
            'F1510120',  /* Non performing loans (FCY) */
            'F1510210',  /* Substandard/Doubtful/Loss (LCY) */
            'F1510220',  /* Substandard/Doubtful/Loss (FCY) */
            'F1510310',  /* Suspended Interests (LCY) */
            'F1510320',  /* Suspended Interests (FCY) */
            'F1510330',  /* Allowance for Bad Debts */
            'F1510410',  /* Depreciation NPLs (LCY) */
            'F1510420',  /* Depreciation NPLs (FCY) */

            /* ======== Insurance ======== */
            'F1600350',  /* Reinsurance receivables */
            'F1600435',  /* Def comm expenses Broker */
            'F1600530',  /* Def comm expenses Agent */
            'F1600625',  /* Due from Insurance Brokers */
            'F1600630',  /* Due from insurance Agents */
            'F1600635',  /* Due from insurance companies */
            'F1600640',  /* Due from RDB */
            'F1600645',  /* Due from Connected person */
            'F1600650',  /* Deferred acquisition cost */
            'F1600660',  /* Premium receivables from policyholders */
            'F1600665',  /* Premium receivable from insurance companies */
            'F1600670',  /* Re Share in UPR */
            'F1600675',  /* Re Share in prov for Unexp risk */
            'F1600680',  /* Re Share in reported claims */
            'F1600685',  /* Re Share in Gross IBNR */

            /* ======== Fixed Tangible Assets (incl. Accum Dep) ======== */
            'F1700010',  /* Land */
            'F1700011',  /* Accumulated Dep. Land */
            'F1700015',  /* Properties, Buildings and Offices */
            'F1700016',  /* Accumulated Dep. Properties */
            'F1700020',  /* Share of Housing Companies */
            'F1700021',  /* Accumulated Dep. Housing Companies */
            'F1700025',  /* Equipments, Furniture and IT */
            'F1700026',  /* Accumulated Dep. Equipment */
            'F1700030',  /* Vehicles */
            'F1700031',  /* Accumulated Dep. Vehicles */
            'F1700035',  /* Refurbishment and Installation */
            'F1700036',  /* Accumulated Dep. Refurbishment */
            'F1700040',  /* Other tangible fixed assets */
            'F1700041',  /* Accumulated Dep. Other Tangible */
            'F1700045',  /* Operating lease */
            'F1700046',  /* Accumulated Dep. Operating Lease */
            'F1700050',  /* Property, Plant and Equipment */
            'F1700051',  /* Accumulated Dep. PPE */
            'F1700055',  /* Investment property */
            'F1700056',  /* Accumulated Dep. Investment Property */
            'F1700060',  /* Fixed Assets in progress */
            'F1700061',  /* Accumulated Dep. Fixed Assets in progress */
            'F1700065',  /* WIP Buildings */
            'F1700066',  /* Accumulated Dep. WIP Buildings */
            'F1700070',  /* WIP Motorvehicle */
            'F1700071',  /* Accumulated Dep. WIP Motor vehicle */
            'F1700075',  /* WIP Freehold Land */
            'F1700076',  /* Accumulated Dep. WIP Freehold Land */
            'F1700080',  /* WIP Softwares */
            'F1700081',  /* Accumulated Dep. WIP Software */
            'F1700085',  /* WIP Security Equipment */
            'F1700086',  /* Accumulated Dep. WIP Security Equipment */
            'F1700090',  /* WIP Machine */
            'F1700091',  /* Accumulated Dep. WIP Machine */
            'F1700095',  /* WIP Furniture And Fittings */
            'F1700096',  /* Accumulated Dep. WIP Furniture */
            'F1700100',  /* WIP Lift Equipment */
            'F1700101',  /* Accumulated Dep. WIP Lift Equipment */
            'F1700105',  /* WIP Computer Equipment */
            'F1700106',  /* Accumulated Dep. WIP Computer Equipment */
            'F1700110',  /* WIP-Nop Furniture&Fittings */
            'F1700111',  /* Accumulated Dep. WIP Nop Furniture */
            'F1700115',  /* WIP-Medical Equipment */
            'F1700116',  /* Accumulated Dep. WIP Medical Equipment */
            'F1700120',  /* WIP Multimedia */
            'F1700121',  /* Accumulated Dep. WIP Multimedia */
            'F1700125',  /* WIP-Investment Property */
            'F1700126',  /* Accumulated Dep. WIP Investment Property */
            'F1700130',  /* Asset Clearing Account */
            'F1700131',  /* Accumulated Dep. Asset Clearing */
            'F1700135',  /* Land Asset Clearing */
            'F1700136',  /* Accumulated Dep. Land Asset Clearing */
            'F1700140',  /* Buildings Asset Clearing */
            'F1700141',  /* Accumulated Dep. Buildings Asset Clearing */
            'F1700145',  /* Vehicles Asset Clearing */
            'F1700146',  /* Accumulated Dep. Vehicles Asset Clearing */
            'F1700150',  /* Computer Equipment Asset Clearing */
            'F1700151',  /* Accumulated Dep. Computer Equip Clearing */
            'F1700155',  /* Security Equipment Asset Clearing */
            'F1700156',  /* Accumulated Dep. Security Equip Clearing */
            'F1700160',  /* Machines Asset Clearing */
            'F1700161',  /* Accumulated Dep. Machines Clearing */
            'F1700165',  /* Furniture And Fittings Asset Clearing */
            'F1700166',  /* Accumulated Dep. Furniture Clearing */
            'F1700170',  /* Lift Equipment Asset Clearing */
            'F1700171',  /* Accumulated Dep. Lift Equipment Clearing */
            'F1700175',  /* Ripps Software Asset Clearing */
            'F1700176',  /* Accumulated Dep. RIPPS Software Clearing */
            'F1700180',  /* Software Asset Clearing */
            'F1700181',  /* Accumulated Dep. Software Clearing */
            'F1700185',  /* Deffered Cost Print Notes Clearing */
            'F1700186',  /* Accumulated Dep. Deferred Cost Clearing */
            'F1700190',  /* Deffered Cost Coins Clearing */
            'F1700191',  /* Accumulated Dep. Deferred Cost Coins */
            'F1700195',  /* T24-Erp Systems */
            'F1700196',  /* Accumulated Dep. T24-ERP Systems */
            'F1700200',  /* Nop Furn.&Fitt Clearing */
            'F1700201',  /* Accumulated Dep. Nop Furn Clearing */
            'F1700205',  /* Medical Equipment Clearing */
            'F1700206',  /* Accumulated Dep. Medical Equipment Clearing */
            'F1700210',  /* Multimedia Asset Clearing */
            'F1700211',  /* Accumulated Dep. Multimedia Clearing */
            'F1700215',  /* Investment Property Clearing */
            'F1700216',  /* Accumulated Dep. Investment Property Clearing */
            'F1700220',  /* WIP Clearing */
            'F1700221',  /* Accumulated Dep. WIP Clearing */
            'F1700225',  /* CIP Clearing Building */
            'F1700226',  /* Accumulated Dep. CIP Building */
            'F1700230',  /* CIP Clearing Motor Vehicle */
            'F1700231',  /* Accumulated Dep. CIP Motor Vehicle */
            'F1700235',  /* CIP Freehold Land */
            'F1700236',  /* Accumulated Dep. CIP Freehold Land */
            'F1700240',  /* CIP Software Clearing */
            'F1700241',  /* Accumulated Dep. CIP Software */
            'F1700245',  /* WIP Security Equip Clearing */
            'F1700246',  /* Accumulated Dep. WIP Security Equip */
            'F1700250',  /* WIP Machinery Clearing */
            'F1700251',  /* Accumulated Dep. WIP Machinery */
            'F1700255',  /* WIP Furn.&Fittings Clearing */
            'F1700256',  /* Accumulated Dep. WIP Furn Clearing */
            'F1700260',  /* WIP Lift Clearing */
            'F1700261',  /* Accumulated Dep. WIP Lift Clearing */
            'F1700265',  /* WIP Computer Equip Clearing */
            'F1700266',  /* Accumulated Dep. WIP Computer Clearing */
            'F1700270',  /* WIP Multimedia Clearing */
            'F1700271',  /* Accumulated Dep. WIP Multimedia Clearing */
            'F1700275',  /* Advance On Fixed Asset Order */
            'F1700276',  /* Accumulated Dep. Advance On Fixed Asset */
            'F1700280',  /* Machinery Advance On Orders */
            'F1700281',  /* Accumulated Dep. Machinery Advance */

            /* ======== Properties & Depreciation of Placement ======== */
            'F1700310',  /* Land of placement */
            'F1700320',  /* Building of Placement */
            'F1700330',  /* Other tangible fixed assets of placement */
            'F1700340',  /* Properties of Placement in progress */
            'F1700410',  /* Depreciation of fixed tangible assets */
            'F1700420',  /* Depreciation of properties of placement */
            'F1700510',  /* Impairment of fixed tangible assets */
            'F1700520',  /* Impairment of properties of placement */

            /* ======== Intangible Assets ======== */
            'F1700610',  /* Amortization Software */
            'F1700620',  /* RIPPS Software */
            'F1700630',  /* Goodwill */
            'F1700690',  /* Other Intangible assets */

            /* ======== Other Receivables & Assets ======== */
            'F1800010',  /* Amount due from Government */
            'F1800020',  /* Current Tax Assets */
            'F1800030',  /* Deferred tax assets */
            'F1800040',  /* Amount due from pension funds */
            'F1800050',  /* Amount due from employees */
            'F1800060',  /* Client accounts non banking services */
            'F1800070',  /* Contributions and other Receivables */
            'F1800095',  /* Other debtors */
            'F1800110',  /* Accrued expenses */
            'F1800120',  /* Deferred revenues */
            'F1800210',  /* Accrued revenues */
            'F1800220',  /* Prepaid expenses */
            'F1800310',  /* FX position for transfer */
            'F1800320',  /* RWF exchange value position of transfer */
            'F1800330',  /* FX position of bank notes */
            'F1800340',  /* RWF exchange position of bank notes */
            'F1800350',  /* Structural FX position */
            'F1800360',  /* RWF exchange value of structural FX */
            'F1800410',  /* FX conversion gap with exchange guarantee */
            'F1800415',  /* Intergroup operations */
            'F1800420',  /* Debtors accounts in transit */
            'F1800425',  /* Creditors accounts in transit */
            'F1800430',  /* Linked inter service accounts */
            'F1800435',  /* Clearing house */
            'F1800440',  /* Prepaid Tax */
            'F1800445',  /* Inventory */
            'F1800450',  /* Stocks */
            'F1800455',  /* Related Party Balance */
            'F1800460',  /* Deffered Charges */
            'F1800465',  /* Coins Minting Costs */
            'F1800470',  /* Banknotes Printing Costs */
            'F1800475',  /* Order In Progress Coins */
            'F1800480',  /* Order In Progress Banknotes */
            'F1800485',  /* CIP Deffered Cost */
            'F1800490',  /* Clearing Deffered Cost */
            'F1800495',  /* Clearing Cip Deffered Cost */
            'F1800500',  /* Total Stock Of Consumables */
            'F1800505',  /* Stock Of Consumables */
            'F1800510',  /* Office Stationeries */
            'F1800515',  /* Repair And Maintenance Material */
            'F1800520',  /* IT Consumables Stock */
            'F1800525',  /* Fuel Consumables */
            'F1800530',  /* Medical Consumables */
            'F1800535',  /* Preprinted Values Documents */
            'F1800540',  /* Outside Processing */
            'F1800545',  /* Material Overhead */
            'F1800550',  /* Overhead */
            'F1800555',  /* Resource */
            'F1800560',  /* Transfer Credit */
            'F1800565',  /* Purchase Price Variance */
            'F1800570',  /* Intransit Inventory */
            'F1800575',  /* Invoice Price Variance */
            'F1800580',  /* Receiving Inventory Clearing */
            'F1800585',  /* Current Assets */
            'F1800590',  /* Receivables */
            'F1800595',  /* Accounts Receivables */
            'F1800600',  /* Receipt Confirmation */
            'F1800605',  /* Remittance Account */
            'F1800610',  /* Unapplied Receipt */
            'F1800615',  /* Unidentified Receipt */
            'F1800620',  /* On Account Receipt */
            'F1800625',  /* Proceed Of Sale Clearing */
            'F1800630',  /* Receivables From T24 Accounts */
            'F1800635',  /* Receivables From BNR Partnership */
            'F1800640',  /* Prefinanced Letter Of Credit RWF */
            'F1800645',  /* Prefinanced Letter Of Credit USD */
            'F1800650',  /* Prefinanced Letter Of Credit EUR */
            'F1800655',  /* Grand Total Miscellaneous Assets */
            'F1800660',  /* Total Miscellaneous Assets */
            'F1800665',  /* Miscellaneous Assets */
            'F1800667',  /* Suspense Accounts Assets */
            'F1800670',  /* 20% Advance On Contracts */
            'F1800675',  /* Other Guarantees Deposits */
            'F1800680',  /* Guarantees Deposits */
            'F1800685',  /* Cash Budget Operation */
            'F1800690',  /* Staff Loan Cash Budget */
            'F1800695',  /* AP & AR Cash Budget Account */
            'F1800700',  /* Imbalance Of Incremental Tb */
            'F1800705',  /* Balance Sheet And Off Balance Sheet Diff */
            'F1800710',  /* Deffered Charges(Prepaid Exps) */
            'F1800715',  /* Cash Budget Clearing */
            'F1800720',  /* Staff Loans Budget Clearing */
            'F1800725',  /* Revenue To Be Received */
            'F1800730',  /* T24 Accrual Revenues */
            'F1800735',  /* BNR Settlement Account */
            'F1800740',  /* Accumulated Recovery Grants Depreciation */
            'F1800745',  /* On Line Account Closure */
            'F1800750',  /* National Bank Of Rwanda (Nostro) Eur */
            'F1800755',  /* Ach Transitory Account */
            'F1800760',  /* BNR Currency Balancing Account */
            'F1800765',  /* Suspense Accounts */
            'F1800895'   /* Other Assets */
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
WHERE
    Year || LPAD(TO_CHAR(Month_Number), 2, '0') >= TO_CHAR(ADD_MONTHS(SYSDATE, -12), 'YYYYMM')
    AND Year || LPAD(TO_CHAR(Month_Number), 2, '0') <= TO_CHAR(SYSDATE, 'YYYYMM')
GROUP BY
    Year, LE_Book, Month_Number
ORDER BY
    LE_Book, Year, Month_Number