-- 🟡 INTERMEDIATE (Queries 6-12)

--    Q6.  Default rate by education + employment type (grouped)
-- "What is the default rate broken down by both education AND employment type together?"
SELECT 
    education,
    employment_type,
    ROUND(SUM(default_status) / COUNT(applicant_id) * 100, 2) AS default_rate_percent
FROM loan_applicants_clean
GROUP BY education, employment_type
ORDER BY default_rate_percent DESC;

--    Q7.  Monthly application trend (2023 vs 2024)
-- "How many loan applications came in each month across 2023 and 2024?"
SELECT
    YEAR(application_date) AS year,
    MONTH(application_date) AS month,
     COUNT(applicant_id) AS total_applications
FROM loan_applicants_clean
GROUP BY year, month
ORDER BY year, month;

--    Q8.  Average loan-to-income ratio by region
-- "What is the average loan-to-income ratio by region?"
SELECT
    region,
    ROUND(AVG(loan_amount / applicant_income), 2) AS avg_loan_to_income_ratio
FROM loan_applicants_clean
GROUP BY region
ORDER BY avg_loan_to_income_ratio DESC;

--    Q9.  Applicants with EMI burden > 30% (high risk segment)
-- "Which applicants have an EMI burden greater than 30% of their income?
-- Show their applicant ID, income, existing EMI and EMI-to-income ratio."
SELECT 
    applicant_id,
    applicant_income,
    existing_emi,
    ROUND(existing_emi / applicant_income, 2) as emi_to_income_ratio
FROM loan_applicants_clean
WHERE (existing_emi / applicant_income) > 0.30
ORDER BY emi_to_income_ratio DESC;

--    Q10. Default rate by loan term bucket
-- "What is the default rate broken down by loan term? Group loan terms into buckets:
-- Short (≤24 months), Medium (25-60 months), Long (61-120 months), Very Long (>120 months)"
SELECT 
    CASE 
        WHEN loan_term_months <= 24 THEN 'Short'
        WHEN loan_term_months <= 60 THEN 'Medium'
        WHEN loan_term_months <= 120 THEN 'Long'
        ELSE 'Very Long'
	END AS loan_term_bucket,
    COUNT(applicant_id) as applicants_per_bucket,
    ROUND(SUM(default_status) / COUNT(applicant_id) * 100, 2) AS default_rate_percent
FROM loan_applicants_clean
GROUP BY loan_term_bucket
ORDER BY default_rate_percent DESC;
    
--    Q11. Gender-wise default comparison
-- "Compare default rate between Male and Female applicants — which gender defaults more?"
SELECT 
    gender, 
    ROUND(SUM(default_status) / COUNT(applicant_id) * 100, 2) AS default_rate_percent
FROM loan_applicants_clean
GROUP BY gender
ORDER BY default_rate_percent DESC;

--    Q12. Top 5 regions by total loan amount disbursed
-- "Which regions have disbursed the highest total loan amount? Show top 5."
SELECT 
    region,
    SUM(loan_amount) AS total_loan_disbursed
FROM loan_applicants_clean
GROUP BY region
ORDER BY total_loan_disbursed DESC
LIMIT 5;