-- HOSPITAL MORTALITY QUERY
-- total no. of patient?
select count(1) from mortality.mortality1;

-- update ethnicity column, adding "mixed" value where value is blank.
UPDATE mortality.mortality1
SET ethnicity = CASE
    WHEN ethnicity = '' THEN 'Mixed'
    ELSE ethnicity
    END;

-- add hospital_death_prob column in mortality table.
alter table mortality.mortality1 
add column hospital_death_prob decimal(10,2);

-- How many total deaths occured in the hospital and what was the percentage of the mortality rate?
SELECT COUNT(CASE WHEN hospital_death = 1 THEN 1 END) AS total_hospital_deaths, 
concat(round(COUNT(CASE WHEN hospital_death = 1 THEN 1 END)*100/COUNT(*),2),"%") AS mortality_rate
FROM mortality.mortality1;

-- What was the death count of each ethnicity? 
SELECT ethnicity, COUNT(hospital_death) as total_hospital_deaths
FROM mortality.mortality1
WHERE hospital_death = '1'
GROUP BY ethnicity; 

-- What was the death count of each gender? 
SELECT gender, COUNT(hospital_death) as total_hospital_deaths
FROM mortality.mortality1
WHERE hospital_death = '1'
GROUP BY gender; 

-- Comparing the average and max ages of patients who died and patients who survived
SELECT ROUND(AVG(age),2) as avg_age,
MAX(age) as max_age, 
hospital_death
FROM mortality.mortality1
WHERE hospital_death = '1'
GROUP BY hospital_death
UNION
SELECT ROUND(AVG(age),2) as avg_age,
MAX(age) as max_age, 
hospital_death
FROM mortality.mortality1
WHERE hospital_death = '0'
GROUP BY hospital_death;

-- Comparing the amount of patients that died and survived by each age 
SELECT age,
	COUNT(CASE WHEN hospital_death = '1' THEN 1 END) as amount_that_died,
	COUNT(CASE WHEN hospital_death = '0' THEN 1 END) as amount_that_survived
FROM mortality.mortality1
GROUP BY age
ORDER BY age ASC;

-- Age distribution of patients in 10-year intervals 
SELECT
    CONCAT(FLOOR(age/10)*10, '-', FLOOR(age/10)*10+9) AS age_interval,
    COUNT(*) AS patient_count
FROM mortality.mortality1
GROUP BY age_interval
ORDER BY age_interval;

-- Amount of patients above 65 who died vs Amount of patients between 50-65 who died
SELECT COUNT(CASE WHEN age > 65 AND hospital_death = '0' THEN 1 END) as survived_over_65,
       COUNT(CASE WHEN age BETWEEN 50 AND 65 AND hospital_death = '0' THEN 1 END) as survived_between_50_and_65,
       COUNT(CASE WHEN age > 65 AND hospital_death = '1' THEN 1 END) as died_over_65,
       COUNT(CASE WHEN age BETWEEN 50 AND 65 AND hospital_death = '1' THEN 1 END) as died_between_50_and_65
FROM mortality.mortality1;

-- Calculating the average probability of hospital death for patients of different age groups
SELECT
    CASE
        WHEN age < 40 THEN 'Under 40'
        WHEN age >= 40 AND age < 60 THEN '40-59'
        WHEN age >= 60 AND age < 80 THEN '60-79'
        ELSE '80 and above'
    END AS age_group,
    ROUND(AVG(apache_4a_hospital_death_prob),3) AS average_death_prob
FROM mortality.mortality1
GROUP BY age_group;

-- Which admit source of the ICU did most patients die in and get admitted to?
SELECT DISTINCT icu_admit_source,
	COUNT(CASE WHEN hospital_death = '1' THEN 1 END) as amount_that_died,
	COUNT(CASE WHEN hospital_death = '0' THEN 1 END) as amount_that_survived
FROM mortality.mortality1
GROUP BY icu_admit_source;

-- Average age of people in each ICU admit source and amount that died
SELECT DISTINCT icu_admit_source,
	COUNT(hospital_death) as amount_that_died,
	ROUND(AVG(age),2) as avg_age
FROM mortality.mortality1
WHERE hospital_death = '1'
GROUP BY icu_admit_source;

-- Average age of people in each type of ICU and amount that died
SELECT DISTINCT icu_type,
	COUNT(hospital_death) as amount_that_died,
	ROUND(AVG(age),2) as avg_age
FROM mortality.mortality1
WHERE hospital_death = '1'
GROUP BY icu_type; 

-- Average weight, bmi, and max heartrate of people who died
SELECT ROUND(AVG(weight),2) as avg_weight,
	ROUND(AVG(bmi),2) as avg_bmi, 
    ROUND(AVG(d1_heartrate_max),2) as avg_max_heartrate
FROM mortality.mortality1
WHERE hospital_death = '1';

-- What were the top 5 ethnicities with the highest BMI? 
SELECT
    ethnicity,
    ROUND(AVG(bmi),2) AS average_bmi
FROM mortality.mortality1
GROUP BY ethnicity
ORDER BY average_bmi DESC
LIMIT 5;

-- How many patients are suffering from each comorbidity? 
SELECT
    SUM(aids) AS patients_with_aids,
    SUM(cirrhosis) AS patients_with_cirrhosis,
    SUM(diabetes_mellitus) AS patients_with_diabetes,
    SUM(hepatic_failure) AS patients_with_hepatic_failure,
    SUM(immunosuppression) AS patients_with_immunosuppression,
    SUM(leukemia) AS patients_with_leukemia,
    SUM(lymphoma) AS patients_with_lymphoma,
    SUM(solid_tumor_with_metastasis) AS patients_with_solid_tumor
FROM mortality.mortality1;

-- What was the percentage of patients with each comorbidity among those who died? 
SELECT
    concat(ROUND(SUM(CASE WHEN aids = 1 THEN 1 ELSE 0 END) * 100 / COUNT(*),2),"%") AS aids_percentage,
    concat(ROUND(SUM(CASE WHEN cirrhosis = 1 THEN 1 ELSE 0 END) * 100 / COUNT(*),2),"%") AS cirrhosis_percentage,
    concat(ROUND(SUM(CASE WHEN diabetes_mellitus = 1 THEN 1 ELSE 0 END) * 100 / COUNT(*),2),"%") AS diabetes_percentage,
    concat(ROUND(SUM(CASE WHEN hepatic_failure = 1 THEN 1 ELSE 0 END) * 100 / COUNT(*),2),"%") AS hepatic_failure_percentage,
    concat(ROUND(SUM(CASE WHEN immunosuppression = 1 THEN 1 ELSE 0 END) * 100 / COUNT(*),2),"%") AS immunosuppression_percentage,
    concat(ROUND(SUM(CASE WHEN leukemia = 1 THEN 1 ELSE 0 END) * 100 / COUNT(*),2),"%") AS leukemia_percentage,
    concat(ROUND(SUM(CASE WHEN lymphoma = 1 THEN 1 ELSE 0 END) * 100 / COUNT(*),2),"%") AS lymphoma_percentage,
    concat(ROUND(SUM(CASE WHEN solid_tumor_with_metastasis = 1 THEN 1 ELSE 0 END) * 100 / COUNT(*),2),"%") AS solid_tumor_percentage
FROM mortality.mortality1
WHERE hospital_death = 1;

-- What is the mortality rate in percentage? 
SELECT
    concat(round(COUNT(CASE WHEN hospital_death = 1 THEN 1 END)*100/COUNT(*),2),"%") AS mortality_rate
FROM mortality.mortality1;

-- What was the percentage of patients who underwent elective surgery?
SELECT
    concat(round(sum(CASE WHEN elective_surgery = 1 THEN 1 END)*100/COUNT(*),2),"%") AS elective_surgery_percentage
FROM mortality.mortality1;

-- What was the average weight and height for male & female patients who underwent elective surgery?
SELECT
    concat(ROUND(AVG(CASE WHEN gender = 'M' THEN weight END),2),"%") AS avg_weight_male,
    concat(ROUND(AVG(CASE WHEN gender = 'M' THEN height END),2),"%") AS avg_height_male,
    concat(ROUND(AVG(CASE WHEN gender = 'F' THEN weight END),2),"%") AS avg_weight_female,
    concat(ROUND(AVG(CASE WHEN gender = 'F' THEN height END),2),"%") AS avg_height_female
FROM mortality.mortality1
WHERE elective_surgery = 1;

-- What were the top 10 ICUs with the highest hospital death probability? 
SELECT icu_type, 
	apache_4a_hospital_death_prob as hospital_death_prob
FROM mortality.mortality1
ORDER BY apache_4a_hospital_death_prob DESC
LIMIT 10;

-- What was the average length of stay at each ICU for patients who survived and those who didn't? 
SELECT
    icu_type,
    ROUND(AVG(CASE WHEN hospital_death = 1 THEN pre_icu_los_days END), 2) AS avg_icu_stay_death,
    ROUND(AVG(CASE WHEN hospital_death = 0 THEN pre_icu_los_days END), 2) AS avg_icu_stay_survived
FROM mortality.mortality1
GROUP BY icu_type
ORDER BY icu_type;

-- What was the average BMI for patients that died based on ethnicity? (excluding missing or null values)
SELECT
    ethnicity,
    ROUND(AVG(bmi),2) AS average_bmi
FROM mortality.mortality1
WHERE bmi IS NOT NULL
AND hospital_death = '1'
GROUP BY ethnicity;

-- What was the death percentage for each ethnicity? 
SELECT
    ethnicity,
    concat(ROUND(COUNT(CASE WHEN hospital_death = 1 THEN 1 END) * 100 / (SELECT COUNT(*) FROM mortality.mortality1), 2),"%") AS death_percentage
FROM mortality.mortality1
GROUP BY ethnicity;

-- Finding out how many patients are in each BMI category based on their BMI value
SELECT
    COUNT(*) AS patient_count,
    CASE
        WHEN bmi < 18.5 THEN 'Underweight'
        WHEN bmi >= 18.5 AND bmi < 25 THEN 'Normal'
        WHEN bmi >= 25 AND bmi < 30 THEN 'Overweight'
        ELSE 'Obese'
    END AS bmi_category
FROM (
    SELECT
        patient_id,
        ROUND(bmi, 2) AS bmi
    FROM mortality.mortality1
    WHERE bmi IS NOT NULL
) AS subquery
GROUP BY bmi_category;

-- Hospital death probabilities where the ICU type is 'SICU' and BMI is above 30
SELECT
    patient_id,
    apache_4a_hospital_death_prob as hospital_death_prob
FROM mortality.mortality1
WHERE icu_type = 'SICU' AND bmi > 30
ORDER BY hospital_death_prob DESC;

-- how many patient in each age group?
select 
case when age<9 then "0-9"
	when age>=10 and age<=19 then "10-19"
	when age>=20 and age<=29 then "20-29"
	when age>=30 and age<=39 then "30-39"
	when age>=40 and age<=49 then "40-49"
	when age>=50 and age<=59 then "50-59"
	when age>=60 and age<=69 then "60-69"
	when age>=70 and age<=79 then "70-79"
	when age>=80 and age<=89 then "80-89"
	else "over 90"
	end as "age_interval",count(*) as total
from mortality.mortality1
where age is not null
group by age_interval;










