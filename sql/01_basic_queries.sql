-- CREATE SCHEMA loan_project
-- SELECT * FROM loan_applicants_clean
-- SELECT COUNT(*) FROM loan_applicants_clean

-- 🟢 BASIC (Queries 1-5)

--    Q1. Total applicants, defaulters, default rate
SELECT
   COUNT(applicant_id) AS total_applicants,
   SUM(default_status) AS total_defaults,
   ROUND(SUM(default_status) / COUNT(applicant_id) * 100, 2) AS default_rate_percent
FROM loan_applicants_clean;

--    Q2. Average income, loan amount, EMI by employment type
SELECT 
    ROUND(AVG(applicant_income), 2) AS avg_income,
    ROUND(AVG(loan_amount), 2) AS avg_loan_amount,
    ROUND(AVG(existing_emi), 2) AS avg_existing_emi 
FROM loan_applicants_clean
GROUP BY employment_type;

--    Q3. Default rate by region
SELECT 
    region,
    ROUND(SUM(default_status) / COUNT(applicant_id) * 100, 2) AS default_rate_percent
FROM loan_applicants_clean
GROUP BY region
ORDER BY default_rate_percent DESC;

--    Q4. Top 10 highest loan amounts
SELECT
    loan_amount,
    applicant_id
FROM loan_applicants_clean
ORDER BY loan_amount DESC
LIMIT 10;

--    Q5. Count of applicants by credit history category
SELECT 
    credit_history,
    COUNT(applicant_id) AS total_applicants
FROM loan_applicants_clean
GROUP BY credit_history;