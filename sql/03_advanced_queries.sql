-- 🔴 ADVANCED (Queries 13-18)

--    Q13. Rank applicants by income within each region (WINDOW)
-- "Rank applicants by income within each region — so the highest earner in each region gets rank 1"
SELECT 
    applicant_id,
    region,
    applicant_income,
    -- ROW_NUMBER used insted of RANK() because Winsorizing in cleaning phase capped multiple 
    -- incomes to same upper bound, causing ties.
    ROW_NUMBER() OVER(
    PARTITION BY region
    ORDER BY applicant_income DESC
    ) AS income_rank
FROM loan_applicants_clean
ORDER BY region, income_rank 
LIMIT 20;

-- This shows top 3 earners from each region cleanly — East, North, South, West all visible.
-- "how do you get top N rows per group in SQL?"
SELECT * FROM(
    SELECT 
        applicant_id,
        region,
        applicant_income,
        ROW_NUMBER() OVER(
        PARTITION BY region
        ORDER BY applicant_income
        ) as income_rank
	FROM loan_applicants_clean
)ranked
WHERE income_rank <= 3
ORDER BY region, income_rank;

--    Q14. Running total of loan amount by application date (WINDOW)
-- "Show the running total of loan amount disbursed day by day as applications came in"
SELECT 
    application_date,
    SUM(loan_amount) AS daily_loan_amount,
    SUM(SUM(loan_amount))OVER(
        ORDER BY application_date
    ) AS running_total
FROM loan_applicants_clean
GROUP BY application_date
ORDER BY application_date;    

--    Q15. Applicants whose loan amount is above their region's average (SUBQUERY)
-- "Find all applicants whose loan amount is above their own region's average loan amount"
SELECT
    applicant_id,
    region,
    loan_amount,
    ROUND(loan_amount - (
        SELECT
            AVG(loan_amount)
            FROM loan_applicants_clean AS inner_table
            WHERE inner_table.region = outer_table.region), 2) AS above_regional_avg_by,
	default_status
FROM loan_applicants_clean AS outer_table
WHERE loan_amount > (
    SELECT 
        AVG(loan_amount)
        FROM loan_applicants_clean AS inner_table
        WHERE inner_table.region = outer_table.region
)
ORDER BY region, loan_amount DESC;

SELECT 
    o.applicant_id,
    o.region,
    o.loan_amount,
    ROUND(o.loan_amount - r.avg_loan, 2) AS above_regional_avg_by,
    o.default_status
FROM loan_applicants_clean AS o
JOIN (
    SELECT 
        region,
        AVG(loan_amount) AS avg_loan
    FROM loan_applicants_clean
    GROUP BY region
) AS r ON o.region = r.region
WHERE o.loan_amount > r.avg_loan
ORDER BY o.region, o.loan_amount DESC;

--    Q16. Default rate trend month by month (DATE + GROUP BY)
-- "Show the default rate month by month — and compare each month's default rate against the previous month using LAG()"
WITH monthly_defaults AS (
    SELECT
        YEAR(application_date) AS year,
        MONTH(application_date) AS month,
        COUNT(applicant_id) AS total_applicants,
        ROUND(SUM(default_status) / COUNT(applicant_id) * 100, 2) AS default_rate
	FROM loan_applicants_clean
    GROUP BY year, month
)
SELECT
    year,
    month,
    total_applicants,
    default_rate,
    LAG(default_rate) OVER(ORDER BY year, month) AS prev_month_rate,
    ROUND(default_rate - LAG(default_rate) OVER(ORDER BY year, month), 2) AS rate_change
FROM monthly_defaults
ORDER BY year, month;

--    Q17. High risk applicants: bad credit + high EMI burden + low income (MULTI-CONDITION)
-- "Identify the highest risk applicants — those who have ALL THREE of: bad/no credit history,
-- high EMI burden (>30%), and low income (below overall median income)"
SELECT
    applicant_id,
    region,
    credit_history,
    ROUND(applicant_income, 2) AS applicant_income,
    ROUND(existing_emi / applicant_income, 2) AS emi_to_income_ratio,
    ROUND(loan_amount, 2) AS loan_amount,
    default_status
FROM loan_applicants_clean
WHERE 
    -- Condition 1: Bad or No Credit History
    credit_history IN ('Bad','No History')
    AND
    -- Condition 2: High EMI Burden (above 30%)
    (existing_emi / applicant_income) > 0.30
    AND
    -- Condition 3: Low income (below average income)
    applicant_income < (
        SELECT AVG(applicant_income)
        FROM loan_applicants_clean
	)
ORDER BY emi_to_income_ratio DESC;

--    Q18. CTE: Segment applicants into risk tiers and count defaults per tier
-- "Segment all applicants into risk tiers based on their credit history and EMI burden,
-- then show how many applicants fall in each tier and what the actual default rate is per tier"

-- CTE 1: Calculate risk score components for each applicant
WITH applicant_risk AS (
    SELECT
        applicant_id,
        credit_history,
        applicant_income,
        existing_emi,
        loan_amount,
        default_status,
        ROUND(existing_emi / applicant_income, 2) AS emi_ratio,
        -- Assign a simple risk score based on credit history
        CASE
            WHEN credit_history = 'Bad' THEN 3
            WHEN credit_history = 'No History' THEN 2
            WHEN credit_history = 'Good' THEN 1
	    END AS credit_score,
        -- Assign EMI risk score
        CASE
            WHEN (existing_emi / applicant_income) > 0.30 THEN 3
            WHEN (existing_emi / applicant_income) > 0.15 THEN 2
            ELSE 1
	    END AS emi_score
	FROM loan_applicants_clean
),
-- CTE 2: Combine scores into final risk tier
risk_tiered AS (
    SELECT
        applicant_id,
        credit_history,
        emi_ratio,
        default_status,
        credit_score + emi_score AS total_risk_score,
        CASE
            WHEN credit_score + emi_score >= 5 THEN 'High Risk'
            WHEN credit_score + emi_score >= 3 THEN 'Medium Risk'
            ELSE 'Low Risk'
		END AS risk_tier
	FROM applicant_risk
)
-- Final SELECT: Summarize by risk tier
SELECT
    risk_tier,
    COUNT(applicant_id) AS total_applicants,
    ROUND(SUM(default_status) / COUNT(applicant_id) * 100, 2) AS default_rate_percent,
    ROUND(AVG(emi_ratio) * 100, 2) AS avg_emi_burden_percent
FROM risk_tiered
GROUP BY risk_tier
ORDER BY default_rate_percent DESC;