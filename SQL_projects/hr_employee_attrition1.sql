/* =====================================
   HR Attrition Risk Analysis (SQL)
   Author: Adekunle Mahmud – Junior Data Analyst
   Date: August 2025
   ===================================== */

SELECT * FROM hr_employee_attrition;
--  1. Data Cleaning & Preparation ----
ALTER TABLE hr_employee_attrition
RENAME COLUMN `ï»¿Age` TO Age;

-- Create Age Group
ALTER TABLE hr_employee_attrition
ADD age_group text as (
        CASE 
            WHEN age BETWEEN 18 AND 30 THEN 'young'
            WHEN age BETWEEN 31 AND 45 THEN 'middle'
            WHEN age BETWEEN 46 AND 60 THEN 'old'
            ELSE 'out of range'
        END);

-- Create Tenure Group
ALTER TABLE hr_employee_attrition
ADD yearsatcompany_group text as (
        CASE 
            WHEN YearsAtCompany BETWEEN 0 AND 2 THEN 'New hires'
            WHEN YearsAtCompany BETWEEN 3 AND 5 THEN 'Early tenure'
            WHEN YearsAtCompany BETWEEN 6 AND 10 THEN 'Mid-term'
            WHEN YearsAtCompany BETWEEN 11 AND 20 THEN 'Long-term'
            WHEN YearsAtCompany BETWEEN 21 AND 50 THEN 'Veterans'
            ELSE 'out of range'
        END);
        
-- Percentage Function
DELIMITER //

CREATE FUNCTION calc_percentage(numerator DECIMAL(10,2), denominator DECIMAL(10,2))
RETURNS DECIMAL(5,2)
DETERMINISTIC
BEGIN
    IF denominator = 0 THEN
        RETURN 0;
    ELSE
        RETURN (numerator * 100.0) / denominator;
    END IF;
END //

DELIMITER ;

-- 2. Overall Attrition -----
SELECT  
count(*) AS Total_Staff,
(sum(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END)* 100.0/ count(*)) AS `%attrition`,
(sum(CASE WHEN attrition = 'No' THEN 1 ELSE 0 END)* 100.0/ count(*)) AS `%non_attrition`
FROM hr_employee_attrition;

-- 3. Attrition by AgeGroup ----
WITH age_attrition_cte AS (
    SELECT 
        age_group,
        attrition
    FROM hr_employee_attrition
    WHERE attrition = 'Yes'
),
-- this counts the different age group
age_group_counts AS (
    SELECT 
        age_group,
        COUNT(*) AS age_group_total
    FROM age_attrition_cte
    GROUP BY age_group
),
-- this counts the total age group
total_count_cte AS (
    SELECT COUNT(*) AS total_yes
    FROM age_attrition_cte
)
-- this now performs the pecentage proper
SELECT 
    agc.age_group,
    agc.age_group_total,
    calc_percentage(agc.age_group_total, t.total_yes) AS percentage
FROM age_group_counts agc, total_count_cte t;

-- 4. Attrition by Tenure Group ----
with total_yearsatcompany_group_cte as(
select yearsatcompany_group,count(*) as total_employees 
from hr_employee_attrition group by yearsatcompany_group),
 yearsatcompany_group_attrition_cte as (
SELECT yearsatcompany_group,COUNT(*) as attrition_yes 
FROM hr_employee_attrition WHERE attrition = 'Yes'
group by yearsatcompany_group)
SELECT 
    t.yearsatcompany_group,
    t.total_employees,
    d.attrition_yes,
    calc_percentage(d.attrition_yes, t.total_employees) AS attrition_percentage
FROM total_yearsatcompany_group_cte t
LEFT JOIN yearsatcompany_group_attrition_cte d ON t.yearsatcompany_group = d.yearsatcompany_group;

-- 5. Attrition by Department ----
with total_by_dept_cte as(
select Department,count(*) as total_employees 
from hr_employee_attrition group by department
),
 dept_attrition_cte as (
SELECT department,COUNT(*) as attrition_yes 
FROM hr_employee_attrition WHERE attrition = 'Yes'
group by Department)
SELECT 
    t.department,
    t.total_employees,
    d.attrition_yes,
    calc_percentage(d.attrition_yes, t.total_employees) AS attrition_percentage
FROM total_by_dept_cte t
LEFT JOIN dept_attrition_cte d ON t.department = d.department order by attrition_percentage desc;

-- 6. Satisfaction Metrics Combined View ----
CREATE VIEW vw_combined_satisfaction AS
SELECT 
    yearsatcompany_group,
    'JobSatisfaction' AS satisfaction_type,
    JobSatisfaction AS satisfaction_score,
    COUNT(*) AS total_employees
FROM hr_employee_attrition
WHERE attrition = 'Yes'
GROUP BY yearsatcompany_group, JobSatisfaction

UNION ALL

SELECT 
    yearsatcompany_group,
    'EnvironmentSatisfaction' AS satisfaction_type,
    EnvironmentSatisfaction AS satisfaction_score,
    COUNT(*) AS total_employees
FROM hr_employee_attrition
WHERE attrition = 'Yes'
GROUP BY yearsatcompany_group, EnvironmentSatisfaction

UNION ALL

SELECT 
    yearsatcompany_group,
    'WorkLifeBalance' AS satisfaction_type,
    WorkLifeBalance AS satisfaction_score,
    COUNT(*) AS total_employees
FROM hr_employee_attrition
WHERE attrition = 'Yes'
GROUP BY yearsatcompany_group, WorkLifeBalance;

-- 7. Compensation Anomaly Check ----
SELECT
    CASE 
        WHEN MonthlyIncome < MonthlyRate THEN 'ANOMALY: Income < Rate'
        ELSE 'OK'
    END AS rate_vs_income_flag,
    COUNT(*) AS total_employees
FROM hr_employee_attrition
GROUP BY rate_vs_income_flag;