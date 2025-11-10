-- First, create a database so we can add the table into it 
CREATE DATABASE project5;
USE project5;
SELECT *
FROM ds_salaries;

-- Because there is no PRIMARY KEY on the table, I want to add it and make id column become our PRIMARY KEY. 
-- We check the duplicate value first, and make sure all values is unique 
SELECT id, COUNT(*) 
FROM ds_salaries
GROUP BY id
HAVING COUNT(*) > 1;

-- Change the id column into PRIMARY KEY
ALTER TABLE ds_salaries
ADD PRIMARY KEY (id);

-- Checking null values 
SELECT * 
FROM ds_salaries
WHERE 
	work_year IS NULL
	OR experience_level IS NULL
    OR employment_type IS NULL
    OR job_title IS NULL
    OR salary IS NULL
    OR salary_currency IS NULL
    OR salary_in_usd IS NULL
    OR employee_residence IS NULL
    OR remote_ratio IS NULL
    OR company_location IS NULL
    OR company_size IS NULL;
    
-- Checking what kind of data in job_title column and how many their average salary based on their job?
SELECT job_title, 
	AVG(salary)
FROM ds_salaries 
GROUP BY job_title
ORDER BY job_title;

-- What job_title or positions that contain "data analyst"?
SELECT *
FROM ds_salaries
WHERE job_title LIKE "%data analyst%"
ORDER BY job_title;

-- What is the average salary of a data analyst job in USD?
SELECT job_title, AVG(salary_in_usd) 
FROM ds_salaries
WHERE job_title LIKE "%data analyst%"
GROUP BY job_title;

-- What is the average salary of a data analyst based on experience level?
SELECT job_title AS data_analyst, experience_level, AVG(salary_in_usd)
FROM ds_salaries
WHERE job_title LIKE "%data analyst%"
GROUP BY job_title, experience_level;

-- What is the average salary of a data analyst based on experience level and type of employment?
SELECT job_title AS data_analyst, experience_level, employment_type, AVG(salary)
FROM ds_salaries
WHERE job_title LIKE "%data analyst%"
GROUP BY job_title, experience_level, employment_type;

-- Countries with attractive salaries for data analyst positions, full-time, entry-level and mid-level work experience
SELECT job_title as data_analyst, experience_level, company_location, AVG(salary_in_usd) AS avg_salary
FROM ds_salaries
WHERE job_title LIKE "%data analyst%"
GROUP BY job_title, experience_level, company_location
ORDER BY avg_salary DESC;

-- In which year did the salary increase from mid to senior have the highest increase? -- (for full-time data analyst related jobs)?
WITH ds_1 AS (
	SELECT work_year,
		AVG(salary_in_usd) sal_in_usd_ex
	FROM ds_salaries
	WHERE employment_type = 'FT'
		AND experience_level = 'EX'
		AND job_title LIKE '%data analyst%'
	GROUP BY work_year
),
ds_2 AS (
	SELECT work_year,
		AVG(salary_in_usd) sal_in_usd_mi
	FROM ds_salaries
	WHERE employment_type = 'FT'
		AND experience_level = 'MI'
		AND job_title LIKE '%data analyst%'
	GROUP BY work_year
),
t_year AS (
	SELECT DISTINCT work_year
	FROM ds_salaries
)
SELECT t_year.work_year,
	ds_1.sal_in_usd_ex,
	ds_2.sal_in_usd_mi,
	ds_1.sal_in_usd_ex - ds_2.sal_in_usd_mi differences
FROM t_year
	LEFT JOIN ds_1 ON ds_1.work_year = t_year.work_year
	LEFT JOIN ds_2 ON ds_2.work_year = t_year.work_year
ORDER BY differences DESC